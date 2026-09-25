% apt_detection.pl  

% Run online: https://dtai.cs.kuleuven.be/problog/editor.html  

% Or locally: python -m problog apt_detection.pl  

%  

% USAGE: prepend the output of bridge.py before these rules.  

% For host_42 the prepended block is:  

%  

% 0.91::port_scan(host_42).  

% 0.78::exploit_attempt(host_42).  

% 0.85::unusual_auth(host_42).  

% 0.63::lateral_movement(host_42).  

% 0.82::data_staging(host_42).  

% ---------------------------------------------------------------  

% Kill-chain rules  (MITRE ATT&CK phases, Hutchins et al. 2011)  

% Each rule is DETERMINISTIC given the probabilistic facts above.  

% The uncertainty propagates entirely through the probabilistic facts.  

% ---------------------------------------------------------------  

  

% Phase 1: Reconnaissance  

% Systematic port scanning is the canonical first observable step.  

recon(Host) :- port_scan(Host).  

  

% Phase 2: Initial Access  

% Gaining a foothold requires both a probe of the target surface  

% and a successful exploitation of a discovered vulnerability.  

initial_access(Host) :-  

    recon(Host),  

    exploit_attempt(Host).  

  

% Phase 3: Persistence  

% Once inside, the attacker establishes persistence, which typically  

% involves unusual authentication activity (new accounts, scheduled  

% tasks, registry modifications manifesting as auth anomalies).  

persistence(Host) :-  

    initial_access(Host),  

    unusual_auth(Host).  

  

% Phase 4: Lateral Movement  

% An active APT campaign expands its reach across the network.  

% Lateral movement is the clearest sign of an ongoing campaign  

% rather than a single compromised endpoint.  

apt_campaign(Host) :-  

    persistence(Host),  

    lateral_movement(Host).  

  

% Phase 5: Exfiltration (Critical Threat)  

% The highest-severity indicator: the attacker has completed the  

% kill chain and is preparing or executing data theft.  

critical_threat(Host) :-  

    apt_campaign(Host),  

    data_staging(Host).  

  

% ---------------------------------------------------------------  

% Queries: ask for the probability of each kill-chain phase  

% ---------------------------------------------------------------  

query(recon(host_42)).  

query(initial_access(host_42)).  

query(persistence(host_42)).  

query(apt_campaign(host_42)).  

query(critical_threat(host_42)).  