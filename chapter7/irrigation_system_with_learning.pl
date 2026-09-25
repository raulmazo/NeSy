% Training data (OBSERVATIONS) separated by --- as required by ProbLog 

% With categorical evidence like the first two (the rose was watered, the lawn was not watered) and 

% conditional evidence: it was observed that the rose was watered under those specific conditions 

evidence(irrigate(rose),true). 

evidence(irrigate(lawn),false). 

----- 

evidence(irrigate(rose),true). 

evidence(soil_dry,true). 

evidence(no_rain_today,true). 

evidence(hot,true). 

evidence(season(summer),true). 

----- 

evidence(irrigate(rose),false). 

evidence(soil_humid,true). 

evidence(no_rain_today,true). 

evidence(hot,true). 

----- 

evidence(irrigate(rose),true). 

evidence(soil_dry,true). 

evidence(mild,true). 

evidence(no_rain_today,true). 