% Step 1: abducible declarations  

:- use_module(library(scasp)).  

  

% ── FOUNDATION 2: Abducible predicates ────────────────────────────  

% These are the ONLY atoms the system may hypothesize.  

% Anything not declared here cannot appear in an explanation.  

% This is what keeps abduction operationally grounded:  

% we do not want the system suggesting that the drone is haunted.  

#abducible power_supply_fault(_D).  

#abducible propulsion_fault(_D).  

#abducible software_crash(_D).  

  

% Step 2: background knowledge  

% ── Background knowledge (KB) ─────────────────────────────────────  

% Causal rules: each fault type produces specific observable symptoms.  

% A power supply fault starves both propulsion and peripherals.  

loses_altitude(D) :- 

    power_supply_fault(D). 

  

% A propulsion fault affects altitude directly but not the camera.  

loses_altitude(D) :- 

    propulsion_fault(D). 

  

camera_offline(D) :- 

    power_supply_fault(D). 

  

% A software crash kills peripheral processes, including the camera feed.  

camera_offline(D) :- 

    software_crash(D). 

  

% A drone losing altitude while below 50m is in a critical situation.  

critical_situation(D) :- loses_altitude(D), below_50m(D).  

  

% Contextual facts for UAV-Delta (known from telemetry).  

below_50m(uav_delta).  

abort_triggered(uav_delta).   % emergency protocol already active  

  

% Step 3: integrity constraints  

% ── FOUNDATION 3: Integrity constraints (denials) ─────────────────  

% IC-1: Mutual exclusion of power supply and propulsion faults.  

% These are independently powered systems. If both fail simultaneously,  

% the root cause must be external (e.g. battle damage). Hypothesizing  

% both independently is not admissible.  

false :- power_supply_fault(D), propulsion_fault(D).  

  

% IC-2: Operational protocol requirement.  

% Any critical situation MUST have an abort protocol active.  

% If our hypotheses would create a critical situation without an abort,  

% the hypothesis set is inadmissible.  

false :- critical_situation(D), not abort_triggered(D).  

  

% ── FOUNDATION 1: The observation to be explained ─────────────────  

% s(CASP) will try to prove this query.  

% When it cannot prove the abducible subgoals directly, it  

% hypothesises them -- this is abduction reinterpreting failed  

% proof branches as hypothesis opportunities.  