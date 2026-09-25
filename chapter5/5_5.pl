% Neuro-symbolic operant-performance trajectory. 

?- findall(X, 

           ( member(T, [3,4,5,6]), 

             operant_performance( 

                 lt_chen, 

                 fire_control_decision, 

                 T, 

                 X), 

             label([X]) 

           ), 

           PerformanceTrajectory). 

PerformanceTrajectory = [24,18,14,10]. 

 

% Operator comparison: 

% who is most reliable for threat_classification at T=3? 

?- findall(Score-Op, 

           ( operator(Op), 

             once(( event(Op, perform, 

                          threat_classification, 3, Score), 

                    label([Score]) )) 

           ), 

           Pairs), 

   sort(0, @>=, Pairs, Ranked). 

Ranked = [34-maj_vasquez, 

          25-lt_chen, 

          20-sgt_okonkwo, 

          14-cpl_reyes]. 

 

% Counterfactual: 

% how much would increased training improve lt_chen's performance 

% on fire_control_decision at T=3? 

?- once(( event(lt_chen, perform, 

                fire_control_decision, 3, Baseline), 

          label([Baseline]) )), 

   once(( performance_with_training( 

              lt_chen, 

              fire_control_decision, 

              high_workload, 

              1, 

              95, 

              3, 

              Improved), 

          label([Improved]) )), 

   format("Neural baseline: ~w%~n", [Baseline]), 

   format("With training increased to 95%: ~w%~n", [Improved]). 

Neural baseline: 24% 

With training increased to 95%: 27% 

 

% Full causal trace with neuro-symbolic parameters 

?- once(( 

       event(lt_chen, perceive, 

             event(environment, cause, high_workload, 1, 1), 

             2, SA1), 

       event(lt_chen, represent, 

             event(lt_chen, understand, high_workload, 2, 1), 

             2, SA2), 

       event(lt_chen, represent, 

             event(lt_chen, project, high_workload, 2, 1), 

             2, SA3), 

       event(lt_chen, represent, 

             event(lt_chen, intend, 

                   fire_control_decision, 2, 1), 

             2, Intent), 

       event(lt_chen, perform, 

             fire_control_decision, 3, Perf), 

       predicted_operator_error( 

             lt_chen, fire_control_decision, 4, Err), 

       label([SA1, SA2, SA3, Intent, Perf, Err]) 

   )), 

   format("SA Level 1 (perception):     ~w%~n", [SA1]), 

   format("SA Level 2 (comprehension):  ~w%~n", [SA2]), 

   format("SA Level 3 (projection):     ~w%~n", [SA3]), 

   format("Intention strength:          ~w%~n", [Intent]), 

   format("Predicted performance:       ~w%~n", [Perf]), 

   format("Predicted error rate:        ~w%~n", [Err]). 

SA Level 1 (perception):     56% 

SA Level 2 (comprehension):  49% 

SA Level 3 (projection):     36% 

Intention strength:          24% 

Predicted performance:       24% 

Predicted error rate:        5% 