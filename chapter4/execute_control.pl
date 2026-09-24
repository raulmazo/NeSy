execution_control :- 

    write('=== POSITIVE AND NEGATIVE NUMBERS EVALUATION PROGRAM ==='), nl, 

    main_loop. 

 

main_loop :- 

    repeat, 

        write('────────────────────────────────────────'), nl, 

        write('Enter a number to evaluate, followed by a period and enter'), nl, 

        write('• Positive number: "X is positive" will be displayed'), nl, 

        write('• Zero or negative number: "X is not positive" will be displayed'), nl, 

        write('• To exit: type "quit" (without quotes), then . and enter'), nl, 

        write('> '), read(Input), 

         

        (Input == quit ->  

            !, 

            nl, write('Thank you for using the program!'), nl, 

            write('Exiting...'), nl 

        ; 

            (number(Input) -> 

                (test(Input), nl, fail) 

            ; 

                (write('⚠ Error: You must enter a number or "quit" to exit'), nl, fail) 

            ) 

        ). 

 

test(X) :-  

    number(X), 

    X > 0,  

    !,  

    write('→ Result: '), write(X), write(' is positive'). 

 

test(X) :-  

    number(X), 

    write('→ Result: '), write(X), write(' is not positive'). 