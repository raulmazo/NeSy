:- use_module(library(pita)). 

:- use_module(library(cplint_r)). 

 

:- pita. 

 

:- begin_lpad. 

 

strong_sneeze(X) : 0.3 ; moderate_sneeze(X) : 0.5 :- 

    flu(X). 

strong_sneeze(X) : 0.2 ; moderate_sneeze(X) : 0.6 :- 

    pollen_allergy(X). 

 

flu(bob) : 0.9. 

pollen_allergy(bob). 

:- end_lpad. 