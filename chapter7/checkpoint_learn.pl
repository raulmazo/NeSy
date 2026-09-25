% checkpoint_learn.pl -- parameter learning version 

 

t(_)::threat. 

t(_)::xray_alarm   :- threat. 

t(_)::xray_alarm   :- \+threat. 

t(_)::sniffer_alarm :- threat. 

t(_)::sniffer_alarm :- \+threat. 

t(_)::behavior_flag :- threat. 

t(_)::behavior_flag :- \+threat. 

 

alert :- xray_alarm, sniffer_alarm. 

alert :- xray_alarm, behavior_flag. 

alert :- sniffer_alarm, behavior_flag. 

 

% Evidence: historical inspection records (partial interpretations) 

% Each group describes one vehicle inspection outcome 

% Format: evidence(atom, true/false) 

evidence(threat,        true). 

evidence(xray_alarm,    true). 

evidence(sniffer_alarm, true). 

evidence(behavior_flag, false). 

% ... (many more cases in a real training set) 