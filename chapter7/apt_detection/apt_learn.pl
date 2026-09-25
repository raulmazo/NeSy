% apt_learn.pl -- learning kill-chain transition probabilities from incident history 

% 

% t(_) declares each probability as a TARGET to be learned from data. 

% The SOC's 200 incident records provide the observed evidence. 

 

0.91::port_scan(Host)          :- monitored(Host). 

0.78::exploit_attempt(Host)    :- monitored(Host). 

0.85::unusual_auth(Host)       :- monitored(Host). 

0.63::lateral_movement(Host)   :- monitored(Host). 

0.82::data_staging(Host)       :- monitored(Host). 

 

% Learnable transition: does recon always precede initial access? 

% Or can initial access happen without observed recon? 

t(_)::direct_access(Host)      :- monitored(Host). 

 

initial_access(Host) :- 

    recon(Host), exploit_attempt(Host). 

initial_access(Host) :- 

    direct_access(Host), exploit_attempt(Host). 

 

% Evidence: for each confirmed incident, which phases were observed? 

% (Abbreviated; full dataset in the GitHub repository) 

evidence(recon(incident_001),          true). 

evidence(initial_access(incident_001), true). 

evidence(persistence(incident_001),    true). 

evidence(apt_campaign(incident_001),   true). 

evidence(critical_threat(incident_001),true). 

 

evidence(direct_access(incident_047), true). 

evidence(initial_access(incident_047),true). 

evidence(recon(incident_047),         false). 

% ... (196 more incidents) 