manage_base :- 

    asserta(person(juan, 30)), 

    assertz(person(maria, 25)), 

    listing(person), 

    retract(person(juan, 30)), 

    write('After removing Juan:'), nl, 

    listing(person), 

    person(maria, Edad), 

    write('Age of Maria: '), write(Edad), nl. 

 

analyze_terms :- 

    Term = friend(pedro, ana), 

    functor(Term, Functor, Aridad), 

    write('The term has functor: '), write(Functor), nl, 

    write('And arity: '), write(Aridad), nl, 

    arg(2, Term, Segundo), 

write('The second argument is: '), write(Segundo), nl. 