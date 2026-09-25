# aigle_reliability.py 

 

import numpy as np 

 

# Simulated trained model: in production, replace with 

# joblib.load('reliability_model.pkl') or torch.load('model.pt') 

 

# Reliability matrix: drone x capability -> probability 

# Rows: aigle_01, aigle_02, aigle_04, aigle_05 

# Cols: reconnaissance, electronic_warfare, medical_support, 

#       night_surveillance, navigation, communications 

 

DRONE_INDEX = { 

    'aigle_01': 0, 

    'aigle_02': 1, 

    'aigle_04': 2, 

    'aigle_05': 3 

} 

 

CAPABILITY_INDEX = { 

    'reconnaissance':     0, 

    'electronic_warfare': 1, 

    'medical_support':    2, 

    'night_surveillance': 3, 

    'navigation':         4, 

    'communications':     5 

} 

 

# Reliability probabilities (simulating model output) 

RELIABILITY_MATRIX = np.array([ 

    [0.92, 0.00, 0.00, 0.00, 0.95, 0.88],  # aigle_01 

    [0.00, 0.87, 0.00, 0.00, 0.91, 0.94],  # aigle_02 

    [0.00, 0.00, 0.89, 0.00, 0.93, 0.85],  # aigle_04 

    [0.00, 0.79, 0.00, 0.83, 0.90, 0.00],  # aigle_05 

]) 

 

def predict_reliability(drone_id: str, capability: str) -> float: 

    """ 

    Returns the predicted probability that drone_id will execute 

    capability reliably in the current operational context. 

    Returns 0.0 if the drone does not have the component for this capability. 

    """ 

    d_idx = DRONE_INDEX.get(drone_id, -1) 

    c_idx = CAPABILITY_INDEX.get(capability, -1) 

    if d_idx == -1 or c_idx == -1: 

        return 0.0 

    return float(RELIABILITY_MATRIX[d_idx, c_idx]) 