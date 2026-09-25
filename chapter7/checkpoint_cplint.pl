% checkpoint.pl (Cplint version) 

% Run online: http://cplint.eu/ 

% Or locally in SWI-Prolog after pack_install(cplint) 

 

:- use_module(library(pita)). 

:- pita. 

:- begin_lpad. 

 

% Prior probability of a genuine threat 

threat : 0.03 ; safe : 0.97. 

 

% X-ray scanner 

xray_alarm : 0.92 ; no_xray_alarm : 0.08 :- threat. 

xray_alarm : 0.05 ; no_xray_alarm : 0.95 :- safe. 

 

% Chemical sniffer 

sniffer_alarm : 0.88 ; no_sniffer_alarm : 0.12 :- threat. 

sniffer_alarm : 0.02 ; no_sniffer_alarm : 0.98 :- safe. 

 

% Behavioural sensor 

behavior_flag : 0.75 ; no_behavior_flag : 0.25 :- threat. 

behavior_flag : 0.04 ; no_behavior_flag : 0.96 :- safe. 

 

% Alert when at least two sensors agree 

alert :- xray_alarm, sniffer_alarm. 

alert :- xray_alarm, behavior_flag. 

alert :- sniffer_alarm, behavior_flag. 

 

:- end_lpad. 