/*Implemented in GNU Prolog. */ 

/* Authors: Daniel Diaz, Raul Mazo, Peter Sawyer, Camille Salinesi. April 2012 */ 

 

/* Simulation */ 

/* Simulation predicate: 

 * simul(File, Format, What, StateOfTheRiver, HealthOfBattery, LC, TotC). 

 * Where: 

 * File = 'console' or a file name (a '.csv' or '.txt' suffix is added if none is provided) 

 * Format = 'txt' or 'csv' (output format) 

 * What = 'all' or 'best' (list all products for a context or only the best one) 

 * StateOfTheRiver, HealthOfBattery: context (may be provided or not; if not, all are generated) 

 * LC, TotC: Claims (may be provided or not; if not, TotC will be maximized) 

 * 

 * Example: display on the console all products for StateOfTheRiver = 2 (emergency) 

 * and HealthOfBattery = 0 (low) 

 * simul(console, txt, all, 2, 0, _, _). 

 * 

 * Example: create a file data.csv with the best product for each context 

 * simul(data, csv, best, _, _, _, _). 

 *  

 * Example: satisfy the first and last expectations and not satisfy the second and third. 

 * simul(console, txt, all, 2, 0, [1, 0, 0, _, 1], _). 

 * 

 * Example: I want to satisfy all my claims 

 * simul(console, txt, all, 2, 0, _, 5). 

*/ 

 

simul(File, Format, What, StateOfTheRiver, HealthOfBattery, LC, TotC) :- 

    findall(Product, one_product(What, StateOfTheRiver, HealthOfBattery, LC, TotC, Product), LProduct), 

    sort(LProduct, LProduct1), 

    write_to_file(File, Format, What, LProduct1). 

 

%Predicate for writing to the file File (or console) the list of products (LProduct) for a context or only the best (What) 

write_to_file(File, Format, What, LProduct) :- 

    g_assign(cxt, void), 

    (   File = console -> 

        Stm = user_output 

    ; 

        (sub_atom(File, _, _, _, '.') -> File1 = File ; format_to_atom(File1, '%s.%s', [File, Format])), 

        format('output file: %s\n', [File]), 

        open(File1, write, Stm) 

    ), 

    (   write_header(What, best, Stm, Format), 

        member(Product, LProduct), 

        write_one(Format, What, Stm, Product), 

        fail 

    ; 

        close(Stm) 

    ). 

 

%Predicate for writing the header of the results table 

write_header(What, What, Stm, Format) :- 

    !, 

    (   Format = txt -> 

        NameLSD = 'SD1...SD5', 

        NameC = 'C1,C2,...C5' 

    ; 

        NameLSD = ['SD1','SD2','SD3','SD4'], 

        NameC = ['C1','C2','C3','C4','C5'] 

    ),       

    write_line(Format, Stm, ['TransData':9, 'OrgNetwork':10, 'CalcFlowRate':15, 

                 'EE', 'FT', 'PA', 'TotNFR', 

                 NameLSD, 'TotSD', 

                 NameC, 'TotC', 'ObjValue']), nl(Stm). 

 

write_header(_, _, _, _). 

 

%Write each solution found by the solver (Product) into the results table 

write_one(Format, What, Stm, Product) :- 

    Product = p(StateOfTheRiver, HealthOfBattery, LRC, LC, TotC, LNFR, TotNFR, LSD, TotSD, ObjValue), 

    (   g_read(cxt, [StateOfTheRiver, HealthOfBattery]) -> 

        true 

    ; 

        g_assign(cxt, [StateOfTheRiver, HealthOfBattery]), 

        name_of(StateOfTheRiver, [normal, alert, emergency], NameStateOfTheRiver), 

        name_of(HealthOfBattery, [low, normal], NameHealthOfBattery), 

        write_line(Format, Stm, []), 

        write_line(Format, Stm, ['Context:', NameStateOfTheRiver, NameHealthOfBattery]), 

        write_line(Format, Stm, []), 

        write_header(What, all, Stm, Format) 

    ), 

     

    LRC = [WiFi, _Bluetooth, SPTopology, _FHTopology, DistributedProcessing, _SingleNodeProcessing], 

 

    LNFR = [EnergyEfficiency, FaultTolerance, PredictionAccuracy], 

 

    name_of(WiFi, ['Bluetooth', 'WiFi'], NameTD), 

    name_of(SPTopology, ['FHTopology', 'SPTopology'], NameON), 

    name_of(DistributedProcessing, ['SingleNodeProc', 'DistributedProc'], NameCFR), 

 

    name_of(EnergyEfficiency, [--, -, =, +, ++], LevelEE), 

    name_of(FaultTolerance, [--, -, =, +, ++], LevelFT), 

    name_of(PredictionAccuracy, [--, -, =, +, ++], LevelPA), 

     

    write_line(Format, Stm, [NameTD:9, NameON:10, NameCFR:15, LevelEE:2, LevelFT:2, LevelPA:2, TotNFR:6, LSD, TotSD:5, LC, TotC:4, ObjValue:6]). 

 

write_line(txt, Stm, LElem) :- 

    member(X, LElem), 

    write_txt(Stm, X), 

    write(Stm, ' '), 

    fail. 

 

write_line(csv, Stm, LElem) :- 

    member(X, LElem), 

    (   list(X) -> 

        member(Y, X), 

        write_csv(Stm, Y) 

    ; 

        write_csv(Stm, X) 

    ), 

    write(Stm, ';'), 

    fail. 

 

write_line(_, Stm, _) :- 

    nl(Stm). 

 

write_csv(Stm, X:_) :-  % ignora Width 

    !, 

    write_csv(Stm, X). 

 

write_csv(Stm, X) :- 

    atom(X), !, 

    format(Stm, '"~a"', [X]). 

 

write_csv(Stm, X) :- 

    write(Stm, X). 

 

write_txt(Stm, X:Width) :- 

    (   atom(X), 

        format(Stm, '%-*s', [Width, X]) 

    ; 

        integer(X), 

        format(Stm, '%*d', [Width, X]) 

    ; 

        write(Stm, X) 

    ), !. 

 

write_txt(Stm, X) :- 

        write(Stm, X). 

 

name_of(I, L, X) :-  

    I1 is I + 1, 

    nth(I1, L, X). 

 

/* Constraint Logic Programming */ 

one_product(What, StateOfTheRiver, HealthOfBattery, LC, TotC, Product) :- 

    set_constraint(StateOfTheRiver, HealthOfBattery, LC, TotC, LRC, LNFR, LSubNFR, TotNFR, LSD, TotSD, ObjValue), 

    fd_labeling([StateOfTheRiver, HealthOfBattery]), % if not provided, try all possible values 

    (   What = all -> 

        fd_labeling(LRC)    % label LRC before maximization to test all possibilities 

    ; 

        true 

    ), 

    fd_maximize(enumerate(LC, LRC, LNFR, LSubNFR, LSD), ObjValue), 

    Product = p(StateOfTheRiver, HealthOfBattery, LRC, LC, TotC, LNFR, TotNFR, LSD, TotSD, ObjValue). 

     

enumerate(LC, LRC, LNFR, LSubNFR, LSD) :- 

    fd_labeling(LC), 

    fd_labeling(LRC), 

    fd_labeling(LNFR), 

    fd_labeling(LSubNFR), 

    fd_labeling(LSD). 

 

set_constraint(StateOfTheRiver, HealthOfBattery, LC, TotC, LRC, LNFR, LSubNFR, TotNFR, LSD, TotSD, ObjValue):- 

    fd_domain(HealthOfBattery, 0, 1),     %  0 = low, 1 = normal 

    fd_domain(StateOfTheRiver, 0, 2),     %  0 = normal, 1 = alert, 2 = emergency 

 

% Functional requirements or Hard goals (common to all product variants) 

LHG = [PredictFlooding, MeasureDepth, CalculateFlowRate, OrganizeNetwork, TransmitData], 

fd_domain_bool(LHG), 

 

% Reusable components (operationalizations of functional requirements) 

LRC = [WiFi, Bluetooth, SPTopology, FHTopology, DistributedProcessing, SingleNodeProcessing], 

fd_domain_bool(LRC), 

 

% Non-functional requirements (NFR) 

LNFR = [EnergyEfficiency, FaultTolerance, PredictionAccuracy], 

fd_domain(LNFR, 0, 4), 

 

LSubNFR = [TDEnergyEfficiency, CFREnergyEfficiency, TDFaultTolerance, ONFaultTolerance, CFRPredictionAccuracy], 

fd_domain(LSubNFR, 0, 4), 

 

% expectations (claims) 

LC = [C1, C2, C3, C4, C5], 

fd_domain_bool(LC), 

 

LSD = [SD1, SD2, SD3, SD4], 

fd_domain_bool(LSD), 

 

%Constraints on Functional Requirements and Non-Functional Requirements 

PredictFlooding #= 1, 

PredictFlooding * 4 #= TransmitData + OrganizeNetwork + CalculateFlowRate + MeasureDepth, 

TransmitData #= Bluetooth + WiFi, 

OrganizeNetwork #= FHTopology + SPTopology, 

CalculateFlowRate #= DistributedProcessing + SingleNodeProcessing, 

Bluetooth + DistributedProcessing #=< 1, % Bluetooth and DistributedProcessing are mutually exclusive 

 

%Constraints on the Claims (as preferences, not as hard constraints) 

C1 #<=> (WiFi #==> TDEnergyEfficiency #=< 2) #/\ (Bluetooth #==> TDEnergyEfficiency #>= 3), 

C2 #<=> (WiFi #==> TDFaultTolerance #>= 3) #/\ (Bluetooth #==> TDFaultTolerance #=< 0), 

C3 #<=> (FHTopology #==> ONFaultTolerance #>= 4) #/\ (SPTopology #==> ONFaultTolerance #=< 0), 

C4 #<=> (SingleNodeProcessing #==> CFREnergyEfficiency #>= 3) #/\ (DistributedProcessing #==> CFREnergyEfficiency #=< 0), 

C5 #<=> (SingleNodeProcessing #==> CFRPredictionAccuracy #=< 1) #/\ (DistributedProcessing #==> CFRPredictionAccuracy #>= 3), 

 

TotC #= C1 + C2 + C3+ C4 + C5, 

 

% Specification of Non-Functional Requirements through Sub-Non-Functional Requirements (SubNFR) 

EnergyEfficiency #= (TDEnergyEfficiency + 2 * CFREnergyEfficiency) // 3, 

FaultTolerance #=< (TDFaultTolerance + ONFaultTolerance) // 2 + 1, % + 1 to loosen a bit 

FaultTolerance #=< (TDFaultTolerance + ONFaultTolerance),   % if both are 0 then FaultTolerance = 0 

PredictionAccuracy #= CFRPredictionAccuracy, 

 

% TotNFR #= EnergyEfficiency + FaultTolerance + PredictionAccuracy, 

TotNFR #= EnergyEfficiency * EnergyEfficiency + FaultTolerance * FaultTolerance + PredictionAccuracy * PredictionAccuracy, 

 

% Soft dependencies or soft influences 

SD1 #<=> (HealthOfBattery #= 0 #==> EnergyEfficiency #= 4), 

SD2 #<=> (StateOfTheRiver #= 0 #==> EnergyEfficiency #= 4),  

SD3 #<=> (StateOfTheRiver #= 2 #==> (FaultTolerance #= 4 #/\ PredictionAccuracy #= 4)),  

SD4 #<=> (StateOfTheRiver #= 1 #==> PredictionAccuracy #= 4),  

 

TotSD #= SD1 + SD2 + SD3+ SD4, 

 

ObjValue #= 1000 * TotC + 100 * TotSD + TotNFR. 