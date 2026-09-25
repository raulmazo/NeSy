; attack_plans.lisp 

; Attack plan recognition using Etcetera Abduction (EtcAbductionPy) 

; 

; Run with: python -m etcabductionpy -i attack_plans.lisp 

 

; ════════════════════════════════════════════════════════════ 

; SECTION 1: PLAN PRIORS 

; Each clause here has a single etcetera literal as its only 

; antecedent. This encodes the prior probability that each 

; attack plan is active, before observing any specific events. 

; Source: 18-month SOC historical incident analysis. 

; ════════════════════════════════════════════════════════════ 

 

; Web Application Attack: targets exposed web services. 

; Probability 0.40 reflects that this is the most frequently 

; observed attack class on this network. 

(if (etc0_web_attack    0.40 ?attacker) (web_attack_plan ?attacker)) 

 

; Automated Worm: self-propagating; scans widely for vulnerabilities. 

; Probability 0.50 reflects the high background rate of worm activity. 

(if (etc0_worm_scan     0.50 ?attacker) (worm_scan ?attacker)) 

 

; APT Campaign: sophisticated targeted attack; rare but severe. 

; Probability 0.08 reflects the low base rate of nation-state activity. 

(if (etc0_apt_campaign  0.08 ?attacker) (apt_campaign ?attacker)) 

 

; ════════════════════════════════════════════════════════════ 

; SECTION 2: OBSERVABLE SIGNATURES PER PLAN 

; Each clause here has the plan as one antecedent and an 

; etcetera literal as the other. The etcetera probability 

; encodes how reliably this plan produces this observable. 

; 

; Foundation 2 (abducible predicates): the three plan predicates 

; (web_attack_plan, worm_scan, apt_campaign) are abducible -- 

; they can be hypothesised but are not directly observable. 

; The observable events (port_scan, exploit_attempt, data_exfil) 

; are derived consequences, not abducibles. 

; ════════════════════════════════════════════════════════════ 

 

; -- Web Application Attack signatures -- 

; Web attackers almost always start with a port scan (P=0.85). 

(if (and (web_attack_plan ?a) (etc_scan_web    0.85 ?a)) (port_scan ?a)) 

 

; Exploitation is the core step of a web attack (P=0.90). 

(if (and (web_attack_plan ?a) (etc_exploit_web 0.90 ?a)) (exploit_attempt ?a)) 

 

; Web attacks frequently lead to data exfiltration (P=0.70). 

(if (and (web_attack_plan ?a) (etc_exfil_web   0.70 ?a)) (data_exfil ?a)) 

 

; -- Automated Worm signatures -- 

; Worms scan almost universally -- scanning IS their core behaviour (P=0.99). 

(if (and (worm_scan ?a) (etc_scan_worm    0.99 ?a)) (port_scan ?a)) 

 

; Worms exploit if they find something, but not always (P=0.60). 

(if (and (worm_scan ?a) (etc_exploit_worm 0.60 ?a)) (exploit_attempt ?a)) 

 

; Worms rarely steal data -- their goal is propagation (P=0.30). 

(if (and (worm_scan ?a) (etc_exfil_worm   0.30 ?a)) (data_exfil ?a)) 

 

; -- APT Campaign signatures -- 

; APT actors scan carefully and sparingly (P=0.60). 

(if (and (apt_campaign ?a) (etc_scan_apt    0.60 ?a)) (port_scan ?a)) 

 

; Targeted exploitation is central to APT campaigns (P=0.95). 

(if (and (apt_campaign ?a) (etc_exploit_apt 0.95 ?a)) (exploit_attempt ?a)) 

 

; APT actors almost always exfiltrate -- that is their primary goal (P=0.99). 

(if (and (apt_campaign ?a) (etc_exfil_apt   0.99 ?a)) (data_exfil ?a)) 

 

; ════════════════════════════════════════════════════════════ 

; SECTION 3: OBSERVATIONS 

; These are the three events flagged by the intrusion detection 

; system for source IP attacker1 during the observation window. 

; EtcAbductionPy will find all explanations that entail these 

; three facts, ranked by joint probability. 

; ════════════════════════════════════════════════════════════ 

 

(port_scan      attacker1) 

(exploit_attempt attacker1) 

(data_exfil     attacker1) 