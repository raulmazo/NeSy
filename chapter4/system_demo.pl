system_demo :- 

    % Write data to a file 

    tell('data.txt'), 

    write('person(juan, 25).'), nl, 

    write('person(ana, 30).'), nl, 

    write('number(42).'), nl, 

    told, 

     

    % Read and process the data from the file 

    see('data.txt'), 

    process_file, 

    seen. 

 

process_file :- 

    repeat, 

    read(Term), 

    (Term == end_of_file ->  

        ! 

    ;  

        (write('Read: '), display(Term), nl, 

         analyze_term(Term), fail) 

    ). 

 

analyze_term(person(Name, Age)) :- 

    write('Is a person: '), write(Name),  

    write(' has '), write(Age), write(' years'), nl. 

 

analyze_term(number(N)) :- 

    write('Is a number: '), write(N), nl. 

 

analyze_term(_) :- 

    write('Term not recognized'), nl. 