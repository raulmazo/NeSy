metaprogramming_demo :- 

    write('=== META_PROGRAMMING DEMOSTRATION IN PROLOG ==='), nl, 

 % 1. Dynamic manipulation of the knowledge base 

    dynamic_knowledge_base, 

 % 2. Structural analysis of terms 

    analysis_structural, 

 % 3. Dynamic execution of goals 

    dynamic_execution, 

 % 4. Construction and manipulation of rules 

    rule_manipulation. 

 

% Demonstration of assert/retract for manipulating the knowledge base 

dynamic_knowledge_base :- 

    write('1. Dynamic manipulation of the knowledge base:'), nl, 

     

    % Add facts dynamically 

    assert(employee(juan, engineer, 5000)), 

    assert(employee(maria, doctor, 8000)), 

    assert(employee(carlos, programmer, 4500)), 

     

    % Show added employees 

    write('   Added employees:'), nl, 

    employee(Person, Position, Salary), 

    write('   - '), write(Person), write(': '), write(Position),  

    write(' ('), write(Salary), write(')'), nl, 

    fail. 

 

dynamic_knowledge_base :- 

    % Add a dynamic rule 

    assert((high_salary(Employee) :- employee(Employee, _, Salary), Salary > 6000)), 

     

    % Use the dynamically created rule 

    write('   Employees with high salary: '), 

    findall(P, high_salary(P), Persons), 

    write(Persons), nl, 

     

    % Clear some data 

    retract(employee(carlos, programmer, 4500)), 

    write('   Employee Carlos removed from the base'), nl, nl. 

 

% Demonstration of functor/arg for structural analysis 

analysis_structural :- 

    write('2. Structural analysis of terms:'), nl, 

     

    Term = person(ana, 28, [computer_science, programmer]), 

     

    % Use functor to obtain name and arity 

    functor(Term, Name, Arity), 

    write('   Term: '), write(Term), nl, 

    write('   Functor: '), write(Name), write('/'), write(Arity), nl, 

     

    % Use arg to extract specific arguments 

    arg(1, Term, Arg1), 

    arg(2, Term, Arg2), 

    arg(3, Term, Arg3), 

    write('   Argument 1: '), write(Arg1), nl, 

    write('   Argument 2: '), write(Arg2), nl, 

    write('   Argument 3: '), write(Arg3), nl, 

     

    % Construct term dynamically using functor 

    functor(NewTerm, person, 2), 

    arg(1, NewTerm, pedro), 

    arg(2, NewTerm, 35), 

    write('   Constructed term: '), write(NewTerm), nl, nl. 

 

% Demonstration of call for dynamic execution 

dynamic_execution :- 

    write('3. Dynamic execution of goals:'), nl, 

     

    % List of goals to execute dynamically 

    Goals = [ 

        employee(maria, Position, Salary), 

        high_salary(Person), 

        length([1,2,3,4], Length) 

    ], 

     

    execute_goals(Goals), nl. 

 

execute_goals([]). 

execute_goals([Goal|Rest]) :- 

    write('   Executing: '), write(Goal), write(' → '), 

    (call(Goal) -> 

        write('Success: '), write(Goal), nl 

    ; 

        write('Failure'), nl 

    ), 

    execute_goals(Rest). 

 

% Demonstration of clause for examining rules 

rule_manipulation :- 

    write('4. Examination of rules with clause:'), nl, 

     

    % Examine the high_salary rule we created dynamically 

    clause(high_salary(X), Body), 

    write('   Rule found:'), nl, 

    write('   Head: high_salary('), write(X), write(')'), nl, 

    write('   Body: '), write(Body), nl, 

     

    % Create a meta-predicate that uses call 

    write('   Applying meta-predicate apply_to_all:'), nl, 

    List = [juan, maria, ana], 

    apply_to_all(check_employee, List), nl. 

 

% Higher-order meta-predicate 

apply_to_all(_, []). 

apply_to_all(Predicate, [Element|Rest]) :- 

    % Construct goal dynamically 

    Goal =.. [Predicate, Element], 

    write('   '), call(Goal), 

    apply_to_all(Predicate, Rest). 

 

% Helper predicate for the meta-predicate 

check_employee(Person) :- 

    (employee(Person, Position, Salary) -> 

        write(Person), write(' is an employee: '), write(Position), nl 

    ; 

        write(Person), write(' is not in the employee database'), nl 

    ). 