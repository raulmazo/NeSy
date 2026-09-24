% ───────────────────────────────────────────────────────── 

% liberation_c3.mzn  |  Operation Liberation – Challenge 3 

% NEW: pairwise Joint Effects Matrix (JEM) 

% ───────────────────────────────────────────────────────── 

 

% 1. PARAMETERS 

int: budget     = 10000; 

int: max_troops = 250000; 

 

% Binary selection flags (deploy or not) 

var 0..1: sel_INF; 

var 0..1: sel_ARMR; 

var 0..1: sel_ARTY; 

var 0..1: sel_UAV; 

 

% 2. DECISION VARIABLES (quantities) 

var 0..1000: INF; 

var 0..400:  ARMR; 

var 0..500:  ARTY; 

var 0..150:  UAV; 

 

% 3. LINK selection flags to quantities 

constraint INF  > 0 <-> sel_INF  = 1; 

constraint ARMR > 0 <-> sel_ARMR = 1; 

constraint ARTY > 0 <-> sel_ARTY = 1; 

constraint UAV  > 0 <-> sel_UAV  = 1; 

 

% 4. RESOURCE CONSTRAINTS 

constraint 1300*INF + 2100*ARMR + 1700*ARTY + 10000*UAV <= budget * 1000; 

constraint 4000*INF + 800*ARMR  + 300*ARTY  + 120*UAV   <= max_troops; 

 

% 5. OBJECTIVE: individual OPU + joint effects 

var int: individual_opu  = 6*INF + 10*ARMR + 8*ARTY + 40*UAV; 

var int: synergy_opu     = sel_ARMR*sel_ARTY*5    % ARMR+ARTY 

                         + sel_ARTY*sel_UAV*12   % ARTY+UAV (best pair) 

                         - sel_INF*sel_UAV*8;    % INF+UAV  (interference) 

 

solve maximize individual_opu + synergy_opu; 

 

% 6. OUTPUT 

output [ 

  "INF  = ", show(INF),  "\n", 

  "ARMR = ", show(ARMR), "\n", 

  "ARTY = ", show(ARTY), "\n", 

  "UAV  = ", show(UAV),  "\n", 

  "Individual OPU = ", show(individual_opu), "\n", 

  "Synergy OPU    = ", show(synergy_opu),    "\n", 

  "Total OPU      = ", show(individual_opu + synergy_opu), "\n" 

]; 