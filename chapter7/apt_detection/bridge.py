# bridge.py 

import torch 

import joblib 

import json 

  

from anomaly_detector import TrafficAnomalyDetector, ANOMALY_NAMES  

  

class ProbLogBridge: 

    def __init__(self, model_path="anomaly_detector.pt", preprocessor_path="preprocessor.pkl", config_path="model_config.json"): 

        # ------------------------------- 

        # Load model configuration 

        # ------------------------------- 

        with open(config_path) as f: 

            config = json.load(f) 

  

        self.n_features = config["n_features"] 

  

        # ------------------------------- 

        # Load preprocessing pipeline 

        # ------------------------------- 

        self.preprocessor = joblib.load(preprocessor_path) 

  

        # ------------------------------- 

        # Load neural model 

        # ------------------------------- 

        self.model = TrafficAnomalyDetector( 

            n_features=self.n_features, 

            n_anomalies=5 

        ) 

  

        self.model.load_state_dict( 

            torch.load(model_path, map_location="cpu") 

        ) 

        self.model.eval() 

  

    def scores_to_problog(self, host_id, scores): 

        """ 

        Convert neural probabilities 

        into ProbLog probabilistic facts. 

        """ 

        lines = [] 

        # Tensor -> vector plano 

        if isinstance(scores, torch.Tensor): 

            scores = scores.detach().cpu().flatten().tolist() 

  

        for name, score in zip(ANOMALY_NAMES, scores): 

            lines.append( 

                f"{float(score):.4f}::{name}({host_id})." 

            ) 

  

        return "\n".join(lines) 

  

    def preprocess(self, raw_features): 

        """ 

        Apply the exact same preprocessing 

        used during training. 

        """ 

        X = self.preprocessor.transform(raw_features) 

        return torch.tensor(X, dtype=torch.float32) 

  

    def analyse_host(self, host_id, raw_features): 

        """ 

        Complete pipeline: 

        NSL-KDD row 

              | 

        preprocessing 

              | 

        neural inference 

              | 

        ProbLog facts 

        """ 

        x = self.preprocess(raw_features) 

  

        with torch.no_grad(): 

            logits = self.model(x) 

            probs = torch.sigmoid(logits) 

         

        return self.scores_to_problog(host_id, probs) 