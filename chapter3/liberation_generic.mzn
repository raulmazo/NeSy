% ───────────────────────────────────────────────────────── 

% liberation_generic.mzn  |  Fully generic military planning model 

% Works for any number of asset types and resource constraints 

% ───────────────────────────────────────────────────────── 

 

% ASSET TYPES (defined in .dzn) 

enum ASSET; 

 

% Offensive Power per unit 

array[ASSET] of float: opu; 

 

% RESOURCE TYPES (defined in .dzn) 

enum RESOURCE; 

 

% Available capacity for each resource 

array[RESOURCE] of float: capacity; 

 

% Consumption of each resource per unit of each asset 

array[ASSET, RESOURCE] of float: consumption; 

 

% Maximum units available for each asset type 

array[ASSET] of int: max_units; 

 

% ─── DECISION VARIABLES ─────────────────────────────── 

array[ASSET] of var int: deploy; 

 

% ─── CONSTRAINTS ────────────────────────────────────── 

% Availability constraint: do not exceed force structure limits 

constraint forall(a in ASSET)(deploy[a] >= 0 /\ deploy[a] <= max_units[a]); 

 

% Resource constraint: do not exceed capacity for each resource 

constraint forall(r in RESOURCE)( 

  sum(a in ASSET)(consumption[a, r] * deploy[a]) <= capacity[r] 

); 

 

% ─── OBJECTIVE ──────────────────────────────────────── 

solve maximize sum(a in ASSET)(opu[a] * deploy[a]); 

 

% ─── OUTPUT ─────────────────────────────────────────── 

output [ 

  show(a) ++ " = " ++ show(deploy[a]) ++ "\n" | a in ASSET 

] ++ [ 

  "Total OPU = ", 

  show(sum(a in ASSET)(opu[a] * deploy[a])), "\n" 

]; 