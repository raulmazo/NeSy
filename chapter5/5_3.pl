% Compatibility view: enumerates the task-specific predictions. 

% For an unambiguous query, prefer predicted_operator_error/4. 

 

event(H, experience, operator_error, T1, X1) :- 

    predicted_operator_error(H, _Task, T1, X1). 

The complete database for queries 

% Operators in the system 

operator(lt_chen). 

operator(sgt_okonkwo). 

operator(cpl_reyes). 

operator(maj_vasquez). 

 

% Referents (who observes whom) 

referent(maj_vasquez, lt_chen). 

referent(sgt_okonkwo, cpl_reyes). 

 

% Theory sources active in this simulation 

source(situationAwareness). 

source(theoryOfPlannedBehavior). 

source(operantLearning). 

source(vicariousLearning). 

source(organisationalAccident). 

 

% Exogenous events: parameters supplied by the user/simulation 

% These represent conditions not derivable from the theory itself 

exogenousEvent(H, attend, environment, T, 80) :- 

    operator(H), time(T).                % Nominal attentional capacity: 80% 

 

exogenousEvent(environment, signal, _, T, 70) :- 

    time(T).                             % Nominal signal clarity: 70% 

 

exogenousEvent(H, trained_for, Context, T, Value) :- 

    training_override(H, Context, T, Value), 

    !. 

 

exogenousEvent(H, trained_for, _, T, 85) :- 

    operator(H), time(T).               % Nominal training level: 85% 

 

exogenousEvent(H, experience_level, general, T, 75) :- 

    operator(H), time(T).               % Nominal experience: 75% 

 

exogenousEvent(H, self_efficacy, _, T, 80) :- 

    operator(H), time(T).               % Nominal self-efficacy: 80% 

 

exogenousEvent(organisation, norm, _, T, 90) :- 

    time(T).                            % Strong organizational norm: 90% 

 

exogenousEvent(H, attend, R, T, 70) :- 

    operator(H), operator(R), H \= R, time(T). 

 

exogenousEvent(H, capable, _, T, 75) :- 

    operator(H), time(T). 

% Defaults required by the higher-order and memory clauses. 

exogenousEvent(H, recall, _, T, 85) :- 

    operator(H), time(T). 

exogenousEvent(C, assess, H, T, 75) :- 

    operator(C), operator(H), C \= H, time(T). 

exogenousEvent(H, infer, _, T, 65) :- 

    operator(H), time(T). 