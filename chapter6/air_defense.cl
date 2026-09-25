aircraft(X):-wing(X),fuselage(X). 

missile(X):-rocket(X),warhead(X). 

threat(X):-highspeed(X),lowalt(X). 

threat(X):-missile(X). 