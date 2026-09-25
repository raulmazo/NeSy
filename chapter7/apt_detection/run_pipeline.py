# run_pipeline.py -- end-to-end neuro-symbolic APT detection 

# Requirements: pip install torch problog 

 

import torch 

import tempfile, os 

from problog.program import PrologFile 

from problog         import get_evaluatable 

from bridge          import analyse_host 

 

KILL_CHAIN_RULES = 'apt_detection.pl' 

 

def assess_host(host_id, feature_vector): 

    """ 

    Run the full neuro-symbolic pipeline for one host. 

 

    Args: 

        host_id        : str  -- unique host identifier 

        feature_vector : list -- 41 normalised NSL-KDD features 

    Returns: 

        dict mapping kill-chain phase names to probabilities 

    """ 

    # Stage 1: neural anomaly detection -> ProbLog facts 

    problog_facts = analyse_host(host_id, feature_vector) 

 

    # Stage 2: build complete ProbLog program and run WMC inference 

    with tempfile.NamedTemporaryFile( 

        mode='w', suffix='.pl', delete=False 

    ) as tmp: 

        tmp.write(problog_facts + '\n') 

        with open(KILL_CHAIN_RULES) as rules: 

            tmp.write(rules.read()) 

        tmp_path = tmp.name 

 

    try: 

        model = get_evaluatable().create_from(PrologFile(tmp_path)) 

        result = model.evaluate() 

        return {str(k): float(v) for k, v in result.items()} 

    finally: 

        os.unlink(tmp_path) 

 

if __name__ == '__main__': 

    # Example: assess host_42 with fictional features 

    features = [0.0] * 41   # replace with real flow features 

    report = assess_host('host_42', features) 

    print('--- Kill-chain assessment ---') 

    for phase, probability in report.items(): 

        bar = '#' * int(probability * 30) 

        print(f'  {phase:<28} {probability:.4f}  {bar}') 