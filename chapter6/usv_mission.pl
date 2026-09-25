% usv_mission.pl  -- First (simplified) version 

% Coded in SWI-Prolog with the Aleph pack 

% Run with:  swipl -g "[usv_mission], induce, halt." usv_mission.pl 

 

:- use_module(library(aleph)). 

:- aleph. 

 

% ── Mode declarations ───────────────────────────────────────────────── 

% modeh: declares the predicate to be LEARNED (the rule head) 

%   1 = recall parameter; bounds the number of successful calls 

%       considered for this mode pattern to one 

%   +contact = input variable of type contact 

:- modeh(1, hostile_mission(+contact)). 

 

% modeb: declares predicates that may appear in learned rule bodies 

%   * = no fixed numeric recall limit; Aleph assumes bounded 

%       non-determinacy for this mode 

%   +contact  = input variable of type contact 

%   #indicator = ground constant of type indicator drawn from the BK 

:- modeb(*, has_indicator(+contact, #indicator)). 

 

% determination: declares has_indicator/2 as relevant background 

% knowledge for learning hostile_mission/1 

:- determination(hostile_mission/1, has_indicator/2). 

 

% ── Positive examples: confirmed hostile surveillance missions ───────── 

 

:- begin_in_pos. 

hostile_mission(c01).   % Hostile USV 1 

hostile_mission(c02).   % Hostile USV 2 

hostile_mission(c03).   % Hostile USV 3 

:- end_in_pos. 

 

% ── Negative examples: confirmed benign contacts ─────────────────────── 

 

:- begin_in_neg. 

hostile_mission(c04).   % Fishing vessel 

hostile_mission(c05).   % Coast guard patrol 

hostile_mission(c06).   % Research drone 

:- end_in_neg. 

 

% ── Background knowledge: CNN-discretised sensor facts ───────────────── 

 

:- begin_bg. 

 

% Positive contacts: each exhibits two suspicious indicators 

has_indicator(c01, ais_off). 

has_indicator(c01, zigzag_wake). 

 

has_indicator(c02, ais_off). 

has_indicator(c02, sensor_mast). 

 

has_indicator(c03, zigzag_wake). 

has_indicator(c03, sensor_mast). 

 

% Negative contacts are designed to constrain over-generalisation. 

% c04 and c05 contain only benign identifying information. 

% c06 is particularly important: AIS is off, but no second suspicious 

% indicator is present, preventing ais_off alone from being sufficient. 

has_indicator(c04, filed_transit_plan). 

has_indicator(c05, coast_guard_id). 

has_indicator(c06, ais_off). 

 

:- end_bg. 