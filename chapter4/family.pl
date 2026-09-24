% ========================================================= 

% BLOCK 1: ALL FACTS OF 'FATHER/2' MUST APPEAR WITHOUT INTERRUPTION 

% ========================================================= 

father(juan, carlos).  

father(juan, ana).    

father(carlos, luis).  

father(carlos, miguel).  

% BLOCK 2: ALL FACTS OF 'MOTHER/2' MUST APPEAR WITHOUT INTERRUPTION 

% ========================================================= 

mother(maria, carlos).  

mother(maria, ana).    

mother(sara, luis).    

mother(sara, miguel).  

% ========================================================= 

% BLOCK 3: ALL FACTS OF 'MALE/1' MUST APPEAR WITHOUT INTERRUPTION 

% ========================================================= 

male(juan). 

male(carlos). 

male(luis). 

male(miguel). 

% ========================================================= 

% BLOCK 4: ALL FACTS OF 'FEMALE/1' MUST APPEAR WITHOUT INTERRUPTION 

female(maria). 

female(ana). 

female(sara). 

% ================================= 

%  BLOCK 5: RULES OF THE ABSTRACT KNOWLEDGE BASE 

% ================================= 

% 1. Definitional Rule: Parent 

parent(X, Y) :-  

mother(X, Y). 

parent(X, Y) :-  

father(X, Y). 

% 2. Definitional Rule: Grandfather 

grandfather(X, Z) :-  

father(X, Y), parent(Y, Z). 

% 3. Definitional Rule: Sibling 

% X and Y have the same mother and the same father, and are not the same person 

sibling(X, Y) :-  

mother(M, X), mother(M, Y),  

father(F, X), father(F, Y),  

X \= Y. 

% 4. Recursive Rules: Predecessor 

% Base Case: The predecessor is the direct parent 

predecessor (X,Y) :- 

parent(X,Y). 

% Recursive Case: The predecessor is a parent of a predecessor (Z) 

predecessor(X,Y) :- 

parent(X,Z), predecessor(Z,Y). 