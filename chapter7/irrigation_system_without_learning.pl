% Rain probabilities (example values, subject to change) 

0.3::rain_today. 

0.7::no_rain_today. 

0.2::rain_tomorrow. % Low probability of rain tomorrow 

0.8::no_rain_tomorrow. 

 

% Soil moisture probabilities (example values, subject to change) 

0.5::soil_dry. 

0.3::soil_humid. 

0.2::soil_very_humid. 

 

% Temperature probabilities (example values, subject to change) 

0.4::hot. 

0.5::mild. 

0.1::cold. 

 

% Facts about the season (example, can change) 

season(summer). 

 

% Facts about the type of plant 

thirsty_plant(rose). 

humid_plant(hydrangea). 

moderately_humid_plant(lawn). 

non_thirsty_plant(cactus). 

 

% Probabilistic rules for deciding whether to irrigate 

0.9::irrigate(Plant) :-  

thirsty_plant(Plant), soil_dry, no_rain_today, hot, season(summer). % High probability under dry and hot conditions 

0.7::irrigate(Plant) :-  

thirsty_plant(Plant), soil_humid, no_rain_today, hot. % Moderate probability if the soil is already somewhat humid 

0.6::irrigate(Plant) :-  

thirsty_plant(Plant), soil_dry, mild, no_rain_today. % Lower probability if the temperature is mild 

0.4::irrigate(Plant) :-  

thirsty_plant(Plant), rain_today. % Low probability if it is already raining 

0.5::irrigate(Plant) :-  

moderately_humid_plant(Plant), soil_dry, no_rain_today. % Moderate probability for moderately humid plants in dry soil 

0.0::irrigate(Plant) :-  

non_thirsty_plant(Plant). % Do not irrigate non-thirsty plants 

 

% Consider the weather forecast 

0.3::irrigate(Plant) :-  

thirsty_plant(Plant), no_rain_tomorrow, soil_dry. % If it won't rain tomorrow and the soil is dry, increase the probability of irrigating, and the same reasoning can be applied to other irrigation predicates. 

 

% Queries 

query(irrigate(rose)). 

query(irrigate(lawn)). 

query(irrigate(cactus)). 