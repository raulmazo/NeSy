% ───────────────────────────────────────────────────────── 

% liberation_c1.mzn  |  Operation Liberation – Challenge 1 

% Objective: maximize total offensive power (OPU) 

% ───────────────────────────────────────────────────────── 

 

% 1. PARAMETERS 

int: budget = 10000;   % campaign budget (M USD, i.e., 10 000 M = 10 Bn) 

 

% 2. DECISION VARIABLES (domain = availability constraint) 

var 0..1000: INF;    % Infantry Brigades 

var 0..400:  ARMR;   % Armoured Battle Groups 

var 0..500:  ARTY;   % Precision Artillery Batteries 

var 0..150:  UAV;    % Drone Strike Squadrons 

 

% 3. BUDGET CONSTRAINT (cost in M USD) 

constraint 1300*INF + 2100*ARMR + 1700*ARTY + 10000*UAV <= budget * 1000; 

 

% 4. OBJECTIVE FUNCTION 

solve maximize 6*INF + 10*ARMR + 8*ARTY + 40*UAV; 

 

% 5. OUTPUT 

output [ 

  "INF  = ", show(INF),  "\n", 

  "ARMR = ", show(ARMR), "\n", 

  "ARTY = ", show(ARTY), "\n", 

  "UAV  = ", show(UAV),  "\n", 

  "Total OPU = ", show(6*INF + 10*ARMR + 8*ARTY + 40*UAV), "\n" 

  "Total Cost = ", show(13*INF/10 + 21*ARMR/10 + 17*ARTY/10 + 100*UAV/10), "\n" 

]; 