% usv_mission_v2.pl  -- Improved version 

% Run with:  swipl -g "[usv_mission_v2], induce, halt." usv_mission_v2.pl 

 

:- use_module(library(aleph)). 

:- aleph. 

 

% ── Aleph configuration settings ───────────────────────────────────── 

% clauselength: maximum number of literals in the body of a learned clause. 

%   Setting this to 3 allows rules with up to 3 co-occurring indicators. 

:- aleph_set(clauselength, 3). 

 

% minpos: minimum number of positive examples a clause must cover 

%   to be retained. Setting to 2 avoids memorizing individual cases. 

:- aleph_set(minpos, 2). 

 

% evalfn: the scoring function used to compare candidate clauses. 

%   'coverage' = positive coverage minus negative coverage. 

:- aleph_set(evalfn, coverage). 

 

% ── Mode declarations ───────────────────────────────────────────────── 

:- modeh(1, hostile_mission(+contact)). 

:- modeb(*, has_indicator(+contact, #indicator)). 

:- determination(hostile_mission/1, has_indicator/2). 

 

% ── Positive examples: 6 confirmed hostile surveillance contacts ────── 

:- begin_in_pos. 

hostile_mission(c01).  % Hostile USV A -- zigzag, AIS off 

hostile_mission(c02).  % Hostile USV B -- AIS off, sensor mast 

hostile_mission(c03).  % Hostile USV C -- zigzag, sensor mast 

hostile_mission(c04).  % Hostile USV D -- zigzag, AIS off 

hostile_mission(c05).  % Hostile USV E -- AIS off, encrypted RF 

hostile_mission(c06).  % Hostile USV F -- zigzag, encrypted RF 

:- end_in_pos. 

 

% ── Negative examples: 6 confirmed benign contacts ───────────────────── 

:- begin_in_neg. 

hostile_mission(c07).  % Fishing vessel: loitering, AIS on 

hostile_mission(c08).  % Coast guard: high speed, AIS on, ID present 

hostile_mission(c09).  % Research drone: AIS off (legitimate), no other indicator 

hostile_mission(c10).  % Merchant vessel: AIS on, filed transit plan 

hostile_mission(c11).  % SAR vessel: loitering, AIS on, identified 

hostile_mission(c12).  % Survey USV: zigzag (survey pattern), AIS on 

:- end_in_neg. 

 

% ── Background knowledge: CNN-discretised sensor attributes ───────────── 

:- begin_bg. 

 

% ---- Hostile contacts (c01-c06) 

% c01: zigzag wake + AIS off 

has_indicator(c01, zigzag_wake). 

has_indicator(c01, ais_off). 

 

% c02: AIS off + sensor mast detected 

has_indicator(c02, ais_off). 

has_indicator(c02, sensor_mast). 

 

% c03: zigzag wake + sensor mast 

has_indicator(c03, zigzag_wake). 

has_indicator(c03, sensor_mast). 

 

% c04: zigzag wake + AIS off (second case of this combination) 

has_indicator(c04, zigzag_wake). 

has_indicator(c04, ais_off). 

 

% c05: AIS off + encrypted RF emissions 

has_indicator(c05, ais_off). 

has_indicator(c05, encrypted_rf). 

 

% c06: zigzag wake + encrypted RF 

has_indicator(c06, zigzag_wake). 

has_indicator(c06, encrypted_rf). 

 

% ---- Benign contacts (c07-c12) 

% c07: Fishing vessel. Loitering speed, AIS on -- no suspicious indicator 

has_indicator(c07, loiter_speed). 

has_indicator(c07, ais_on). 

 

% c08: Coast guard. High speed, AIS on, official ID 

has_indicator(c08, high_speed). 

has_indicator(c08, ais_on). 

has_indicator(c08, official_id). 

 

% c09: Research drone. AIS off (legitimate scientific use), no other indicator. 

% CRITICAL: this is the key negative example that prevents 

% 'hostile_mission(C) :- has_indicator(C, ais_off).' from being valid. 

has_indicator(c09, ais_off). 

 

% c10: Merchant vessel. AIS on, filed transit plan 

has_indicator(c10, ais_on). 

has_indicator(c10, filed_transit_plan). 

 

% c11: SAR vessel. Loitering (search pattern), AIS on, identified 

has_indicator(c11, loiter_speed). 

has_indicator(c11, ais_on). 

has_indicator(c11, official_id). 

 

% c12: Survey USV. Zigzag pattern (legitimate survey), AIS on. 

% CRITICAL: this prevents 'hostile_mission(C):-has_indicator(C,zigzag_wake).' 

% from being a valid rule, since that rule would cover c12 (a negative). 

has_indicator(c12, zigzag_wake). 

has_indicator(c12, ais_on). 

:- end_bg. 