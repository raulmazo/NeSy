# drone_abl_bridge.py — The ABL training loop 

 

import random 

 

from ablkit.bridge import SimpleBridge 

from ablkit.data.evaluation import ReasoningMetric, SymbolAccuracy 

from drone_abl_learning  import learning_model, FAULT_NAMES 

from drone_abl_reasoning import DroneKBReasoner 

 

PSEUDO_LABEL_LIST = [ 

    (False, False, False),  # no fault 

    (True,  False, False),  # power supply fault only 

    (False, True,  False),  # propulsion fault only 

    (False, False, True ),  # software crash only 

    (True,  False, True ),  # power supply + software crash 

    (False, True,  True ),  # propulsion + software crash 

    # (True, True, *) omitted: IC-1 rules out this combination 

] 

 

reasoner = DroneKBReasoner( 

    pseudo_label_list=PSEUDO_LABEL_LIST, 

    max_revision=1   # prefer explanations that change at most 1 label 

) 

 

bridge = SimpleBridge( 

    learning_model, 

    reasoner, 

    metric_list=[SymbolAccuracy(prefix='drone'), ReasoningMetric(kb=reasoner.kb, prefix='drone')] 

) 

 

def make_synthetic_example(label): 

    """ 

    Build a random sensor feature vector consistent with the given fault 

    label and a KB-consistent context (below_50m, abort_triggered). 

    """ 

    ps, prop, sw = label 

    features = [ 

        random.uniform(0.7, 1.5) if (ps or prop) else random.uniform(0.0, 0.3),  # altitude_drop_rate 

        random.uniform(0.3, 0.6) if ps else random.uniform(0.9, 1.05),           # voltage_ratio 

        random.uniform(0.5, 1.0) if (ps or sw) else random.uniform(0.0, 0.1),    # camera_frame_loss 

        random.uniform(1.2, 2.0) if ps else random.uniform(0.9, 1.1),            # current_spike 

        random.uniform(3.0, 6.0) if prop else random.uniform(0.5, 1.5),          # vibration_rms 

        random.uniform(10.0, 25.0) if sw else random.uniform(0.0, 5.0),          # temp_delta 

    ] 

 

    below_50m = random.choice([True, False]) 

    loses_alt = ps or prop 

    # Keep the context KB-consistent with the label (IC-2) 

    abort_triggered = True if (loses_alt and below_50m) else random.choice([True, False]) 

 

    return features + [below_50m, abort_triggered] 

 

random.seed(42) 

train_X, train_gt_pseudo_label, train_Y = [], [], [] 

for _ in range(120): 

    label = random.choice(PSEUDO_LABEL_LIST) 

    example = make_synthetic_example(label) 

    train_X.append([example]) 

    train_gt_pseudo_label.append([label]) 

    train_Y.append(True)  # ground-truth reasoning result: KB constraints hold 

 

train_data = (train_X, train_gt_pseudo_label, train_Y) 

 

# MLPClassifier can't predict_proba before it has seen at least one fit call, 

# so warm-start it on the ground-truth pseudo-labels before the ABL loop begins. 

label_to_idx = {label: idx for idx, label in enumerate(PSEUDO_LABEL_LIST)} 

flat_X = [example[0] for example in train_X] 

flat_y = [label_to_idx[label[0]] for label in train_gt_pseudo_label] 

learning_model.base_model.fit(flat_X, flat_y) 

 

# Run the ABL training loop. 

bridge.train( 

    train_data=train_data, 

    loops=10   # number of predict -> abduce -> retrain iterations 

) 

 

# After training, use the model for diagnosis on a new sensor reading. 

# UAV-Delta in crisis: below 50m with the abort procedure triggered. 

new_reading = [0.8, 0.61, 0.92, 1.4, 0.3, 5.2, True, True] 

pred_idx = learning_model.base_model.predict([new_reading])[0] 

predicted = reasoner.idx_to_label[pred_idx] 

 

print('Predicted fault labels:', dict(zip(FAULT_NAMES, predicted))) 

# Expected output (after convergence): 

# {'power_supply_fault': True, 'propulsion_fault': False, 'software_crash': False} 

# The model has learned that this sensor pattern implies a power supply fault -- 

# consistent with Explanation 1 from the s(CASP) analysis in Part I. 