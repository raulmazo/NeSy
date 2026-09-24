% ───────────────────────────────────────────────────────── 

% liberation_c2.mzn  |  Operation Liberation – Challenge 2 

% NEW: adds a personnel (manpower) constraint 

% ───────────────────────────────────────────────────────── 

 

% 1. PARAMETERS 

int: budget     = 10000;    % USD M × 1000 

int: max_troops = 250000;   % maximum deployable personnel 

 

% 2. DECISION VARIABLES 

var 0..1000: INF; 

var 0..400:  ARMR; 

var 0..500:  ARTY; 

var 0..150:  UAV; 

 

% 3. CONSTRAINTS 

constraint 1300*INF + 2100*ARMR + 1700*ARTY + 10000*UAV <= budget * 1000; 

constraint 4000*INF + 800*ARMR  + 300*ARTY  + 120*UAV   <= max_troops; 

 

% 4. OBJECTIVE 

solve maximize 6*INF + 10*ARMR + 8*ARTY + 40*UAV; 

 

% 5. OUTPUT 

output [ 

  "INF  = ", show(INF),  "\n", 

  "ARMR = ", show(ARMR), "\n", 

  "ARTY = ", show(ARTY), "\n", 

  "UAV  = ", show(UAV),  "\n", 

  "Total OPU  = ", show(6*INF + 10*ARMR + 8*ARTY + 40*UAV), "\n", 

  "Total Cost = ", show(13*INF/10 + 21*ARMR/10 + 17*ARTY/10 + 100*UAV/10), "\n" 

  "Personnel  = ", show(4000*INF + 800*ARMR + 300*ARTY + 120*UAV), "\n" 

]; 
