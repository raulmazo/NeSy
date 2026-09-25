% Observed facts 

observed(exploration_repetition). 

observed(ignores_mines). 

observed(low_reward). 

observed(avoids_risk). 

 

% Possible causes 

cause(low_epsilon). 

cause(bad_reward_function). 

cause(risk_aversion). 

cause(insufficient_training). 

 

% Abductive rules 

explanation(low_epsilon) :- observed(exploration_repetition). 

explanation(bad_reward_function) :- observed(low_reward). 

explanation(risk_aversion) :- observed(avoids_risk). 

explanation(insufficient_training) :- observed(ignores_mines). 

 

% Show explanations 

#show explanation/1. 