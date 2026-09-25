# operator_model.py 

# 

# Operator state predictor for the Systems Engineering Theory of Reliability. 

# 

# In production, replace the simulated matrices below with a trained model: 

# 

#   from joblib import load 

#   import numpy as np 

#   model = load('operator_reliability_model.pkl') 

# 

#   def predict_attention(operator_id, time_period): 

#       features = build_feature_vector(operator_id, time_period) 

#       return int(model.predict_attention(features)) 

# 

# The feature vector would typically include: 

#   - Heart rate variability (normalised, 0-1) 

#   - Eye fixation duration (mean, in ms, normalised) 

#   - Time since last rest break (minutes) 

#   - Mission phase (integer 1-6) 

#   - Task load index from NASA-TLX (0-100) 

#   - Hours since last training certification 

#   - Historical success rate for this task (0-100) 

#   - Peer assessment score (0-100) 

 

# Each operator is characterised by a profile vector: 

# [hrv_score, eye_fixation_score, training_hours_score, 

#  simulation_score, historical_success_rate] 

# All values normalised to [0, 1]. 

 

OPERATOR_PROFILES = { 

    'lt_chen':     [0.82, 0.78, 0.91, 0.84, 0.87], 

    'sgt_okonkwo': [0.75, 0.71, 0.83, 0.79, 0.81], 

    'cpl_reyes':   [0.68, 0.65, 0.74, 0.71, 0.73], 

    'maj_vasquez': [0.91, 0.89, 0.95, 0.93, 0.94], 

} 

 

# Task adjustment factors reflect the cognitive demand of each task 

# relative to the operator's general capability profile. 

# Values > 1.0 indicate tasks where operators tend to exceed their 

# general profile; values < 1.0 indicate tasks where demand exceeds profile. 

TASK_ADJUSTMENT = { 

    'launch_authorisation':   0.95, 

    'radar_interpretation':   1.00, 

    'threat_classification':  0.92, 

    'fire_control_decision':  0.88, 

    'system_reconfiguration': 0.97, 

    'communication_relay':    1.02, 

} 

 

# Fatigue rate: attentional capacity degrades by this fraction per time period. 

# This is a model parameter that would be estimated from empirical data. 

FATIGUE_RATE_PER_PERIOD = 0.03  # 3% degradation per mission phase 

 

def predict_attention(operator_id: str, time_period: int) -> int: 

    """ 

    Predicts attentional capacity (0-100) at a given mission phase. 

    Combines physiological indicators with a linear fatigue model. 

    The fatigue model here mirrors the symbolic theory's linear assumption, 

    making the two layers mutually consistent. 

    In production: replace with model.predict([features])[0] 

    """ 

    profile = OPERATOR_PROFILES.get(operator_id) 

    if profile is None: 

        return 70   # Conservative default for unknown operators 

    hrv_score  = profile[0] 

    eye_score  = profile[1] 

    # Base attentional capacity from physiological indicators 

    base = (hrv_score * 0.5 + eye_score * 0.5) * 100 

    # Linear fatigue degradation over mission phases 

    fatigue_penalty = (time_period - 1) * FATIGUE_RATE_PER_PERIOD * base 

    return max(0, int(round(base - fatigue_penalty))) 

 

def predict_training_level(operator_id: str, task: str) -> int: 

    """ 

    Predicts training adequacy (0-100) for a specific task. 

    Combines training record features with task-specific demand adjustment. 

    In production: replace with task-specific classifier output. 

    """ 

    profile = OPERATOR_PROFILES.get(operator_id) 

    if profile is None: 

        return 70 

    training_score = profile[2] 

    sim_score      = profile[3] 

    task_adj = TASK_ADJUSTMENT.get(task, 1.0) 

    base = (training_score * 0.6 + sim_score * 0.4) * 100 * task_adj 

    return min(100, int(round(base))) 

 

def predict_self_efficacy(operator_id: str, task: str) -> int: 

    """ 

    Predicts self-efficacy (0-100) for a specific task. 

    Combines historical success rate with task-specific adjustment. 

    In production: replace with regression model output incorporating 

    pre-mission questionnaire scores and recent performance history. 

    """ 

    profile = OPERATOR_PROFILES.get(operator_id) 

    if profile is None: 

        return 70 

    success_rate = profile[4] 

    task_adj = TASK_ADJUSTMENT.get(task, 1.0) 

    return min(100, int(round(success_rate * 100 * task_adj))) 

 

def predict_all(operator_id: str, task: str, time_period: int) -> dict: 

    """ 

    Convenience function returning all three predictions at once. 

    Useful when the Prolog layer needs multiple parameters simultaneously. 

    Returns a dictionary with keys: attention, training, self_efficacy. 

    """ 

    return { 

        'attention':     predict_attention(operator_id, time_period), 

        'training':      predict_training_level(operator_id, task), 

        'self_efficacy': predict_self_efficacy(operator_id, task), 

    } 