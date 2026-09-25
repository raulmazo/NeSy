% checkpoint.pl -- Probabilistic checkpoint security 

% Run online: https://dtai.cs.kuleuven.be/problog/editor.html 

% Or locally: python -m problog checkpoint.pl 

 

% ── Uncertain world ────────────────────────────────────────── 

% Prior: 3% of vehicles are genuine threats 

0.03::threat. 

 

% X-ray scanner 

%   0.92 = detection rate (true positive) 

%   0.05 = false-positive rate 

0.92::xray_alarm   :- threat. 

0.05::xray_alarm   :- \+threat. 

 

% Chemical sniffer 

0.88::sniffer_alarm :- threat. 

0.02::sniffer_alarm :- \+threat. 

 

% Behavioural sensor 

0.75::behavior_flag :- threat. 

0.04::behavior_flag :- \+threat. 

 

% ── Alert logic ───────────────────────────────────────────── 

% A security alert is raised when at least two sensors agree 

alert :- xray_alarm, sniffer_alarm. 

alert :- xray_alarm, behavior_flag. 

alert :- sniffer_alarm, behavior_flag. 

 

% ── Queries ───────────────────────────────────────────────── 

query(threat).   % base rate query (no evidence) 

query(alert).    % probability of any alert being raised 