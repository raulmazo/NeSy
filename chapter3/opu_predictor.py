# ───────────────────────────────────────────────────────────── 

# opu_predictor.py  |  OPU Predictor — architecture + training 

# ───────────────────────────────────────────────────────────── 

import torch                       # PyTorch core 

import torch.nn as nn              # Neural network layers 

import pandas as pd                # CSV reading 

from sklearn.preprocessing import StandardScaler, LabelEncoder 

from sklearn.model_selection import train_test_split 

import numpy as np 

 

# ── 1. ARCHITECTURE ────────────────────────────────────────── 

class OPUPredictor(nn.Module): 

    """ 

    Feed-forward MLP that predicts effective OPU (eOPU) for a 

    given asset type in a given battlefield context. 

 

    Input tensor shape:  (batch_size, 8)   — 8 encoded features 

    Output tensor shape: (batch_size,)      — scalar eOPU value 

    """ 

    def __init__(self): 

        super().__init__() 

        self.net = nn.Sequential( 

            nn.Linear(8, 64),   # Layer 1: 8 inputs  → 64 neurons 

            nn.ReLU(),          # Activation: f(x) = max(0, x) 

            nn.Dropout(0.2),    # Regularisation: zero 20% of neurons 

            nn.Linear(64, 32),  # Layer 2: 64 neurons → 32 neurons 

            nn.ReLU(), 

            nn.Linear(32, 1),   # Output: 32 neurons → 1 eOPU value 

            nn.ReLU()           # Ensure eOPU >= 0 always 

        ) 

 

    def forward(self, x): 

        """Forward pass: x is a (batch_size, 8) tensor.""" 

        return self.net(x).squeeze()  # Remove trailing dimension → (batch_size,) 

 

# ── 2. LOAD AND PREPROCESS TRAINING DATA ───────────────────── 

df = pd.read_csv('training_data.csv') 

 

# Encode categorical features as numbers 

terrain_enc = LabelEncoder().fit_transform(df['terrain_type'])   # 0-3 

season_enc  = LabelEncoder().fit_transform(df['season'])          # 0-3 

asset_enc   = LabelEncoder().fit_transform(df['asset_type'])      # 0-3 

 

# Build feature matrix X (12000 rows × 8 columns) 

X = np.column_stack([ 

    terrain_enc, 

    season_enc, 

    df['enemy_ADA_level'].values, 

    df['logistics_score'].values, 

    df['visibility_km'].values / 50.0,    # normalise to [0,1] 

    asset_enc, 

    df['sortie_rate'].values, 

    df['maintenance_status'].values 

]) 

 

y = df['actual_OPU'].values              # Target: measured OPU 

 

# Standardise features: subtract mean, divide by std deviation 

# IMPORTANT: fit scaler on TRAIN set only; reuse at inference time 

scaler = StandardScaler().fit(X) 

X_scaled = scaler.transform(X) 

 

# Train / validation / test split (80 / 10 / 10) 

X_tr, X_tmp, y_tr, y_tmp = train_test_split(X_scaled, y, test_size=0.2, random_state=42) 

X_val, X_te, y_val, y_te = train_test_split(X_tmp, y_tmp, test_size=0.5, random_state=42) 

 

# Convert to PyTorch tensors 

X_tr_t  = torch.tensor(X_tr,  dtype=torch.float32) 

y_tr_t  = torch.tensor(y_tr,  dtype=torch.float32) 

X_val_t = torch.tensor(X_val, dtype=torch.float32) 

y_val_t = torch.tensor(y_val, dtype=torch.float32) 

 

# ── 3. INSTANTIATE MODEL, LOSS, OPTIMISER ──────────────────── 

model     = OPUPredictor() 

criterion = nn.MSELoss()              # Mean Squared Error loss 

optimizer = torch.optim.Adam(         # Adam adaptive gradient descent 

    model.parameters(), 

    lr=1e-3                           # learning rate = 0.001 

) 

 

# ── 4. TRAINING LOOP WITH EARLY STOPPING ───────────────────── 

best_val_loss  = float('inf')         # track best validation loss 

best_weights   = None                 # snapshot of best weights 

patience       = 15                   # stop if no improvement for 15 epochs 

patience_count = 0 

 

for epoch in range(200): 

    # ── Training step 

    model.train()                     # enables Dropout 

    optimizer.zero_grad()             # reset gradients from last step 

    preds = model(X_tr_t)             # forward pass 

    loss  = criterion(preds, y_tr_t)  # compute MSE loss 

    loss.backward()                   # backpropagation (autograd) 

    optimizer.step()                  # update weights via Adam 

 

    # ── Validation step 

    model.eval()                      # disables Dropout 

    with torch.no_grad():             # no gradient tracking needed 

        val_preds = model(X_val_t) 

        val_loss  = criterion(val_preds, y_val_t).item() 

 

    if epoch % 20 == 0: 

        print(f'Epoch {epoch:3d} | train MSE: {loss.item():.3f} | val MSE: {val_loss:.3f}') 

 

    # ── Early stopping check 

    if val_loss < best_val_loss: 

        best_val_loss = val_loss 

        best_weights  = {k: v.clone() for k, v in model.state_dict().items()} 

        patience_count = 0 

    else: 

        patience_count += 1 

        if patience_count >= patience: 

            print(f'Early stopping at epoch {epoch}.') 

            break 

 

# ── 5. RESTORE BEST WEIGHTS AND SAVE ───────────────────────── 

model.load_state_dict(best_weights) 

 

# Save: only the WEIGHTS (numbers), not the architecture 

torch.save(model.state_dict(), 'opu_predictor_weights.pt') 

print('Saved opu_predictor_weights.pt') 

 

# Also save the scaler parameters so inference uses the same scaling 

import pickle 

with open('scaler.pkl', 'wb') as f: 

    pickle.dump(scaler, f) 

print('Saved scaler.pkl') 