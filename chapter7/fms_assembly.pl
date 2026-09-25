% ===== SUCCESS CASES (4 examples) ===== 

% These are processes that were completed without failures 

 

begin(model(1)). 

% Chair successfully assembled with normal times at all stations 

process_success(chair). 

assemble(chair, legs, e1). 

assemble(chair, seat, e2). 

assemble(chair, backrest, e3). 

neg(failure(e1)). 

neg(failure(e2)). 

neg(failure(e3)). 

complete(e1). 

complete(e2). 

complete(e3). 

time(e1, normal). 

time(e2, normal). 

time(e3, normal). 

end(model(1)). 

 

begin(model(2)). 

% Table successfully assembled with mixed times (fast at E1 and E3, normal at E2) 

process_success(table). 

assemble(table, legs, e1). 

assemble(table, tabletop, e2). 

assemble(table, crossbar, e3). 

neg(failure(e1)). 

neg(failure(e2)). 

neg(failure(e3)). 

complete(e1). 

complete(e2). 

complete(e3). 

time(e1, fast). 

time(e2, normal). 

time(e3, fast). 

end(model(2)). 

 

begin(model(3)). 

% Chair with mostly fast processing (E1 and E2 fast, E3 normal) 

process_success(chair). 

assemble(chair, legs, e1). 

assemble(chair, seat, e2). 

assemble(chair, backrest, e3). 

neg(failure(e1)). 

neg(failure(e2)). 

neg(failure(e3)). 

complete(e1). 

complete(e2). 

complete(e3). 

time(e1, fast). 

time(e2, fast). 

time(e3, normal). 

end(model(3)). 

 

begin(model(4)). 

% Table in standard time (all normal at the three stations) 

process_success(table). 

assemble(table, legs, e1). 

assemble(table, tabletop, e2). 

assemble(table, crossbar, e3). 

neg(failure(e1)). 

neg(failure(e2)). 

neg(failure(e3)). 

complete(e1). 

complete(e2). 

complete(e3). 

time(e1, normal). 

time(e2, normal). 

time(e3, normal). 

end(model(4)). 

 

% ===== FAILURE CASES (2 examples) ===== 

% These are processes that failed and were not completed 

 

begin(model(5)). 

% Failure in E1: prevents any subsequent process 

% When E1 fails, no subsequent station can operate 

neg(process_success(chair)). 

neg(assemble(chair, legs, e1)). 

neg(assemble(chair, seat, e2)). 

neg(assemble(chair, backrest, e3)). 

failure(e1). 

neg(failure(e2)). 

neg(failure(e3)). 

neg(complete(e1)). 

neg(complete(e2)). 

neg(complete(e3)). 

end(model(5)). 

 

begin(model(6)). 

% Failure in E2: E1 was completed but E2 and E3 cannot continue 

% This example shows that if E2 fails, even if E1 was successful, 

% the product cannot be completed 

neg(process_success(table)). 

assemble(table, legs, e1). 

neg(assemble(table, tabletop, e2)). 

neg(assemble(table, crossbar, e3)). 

neg(failure(e1)). 

failure(e2). 

neg(failure(e3)). 

complete(e1). 

neg(complete(e2)). 

neg(complete(e3)). 

time(e1, normal). 

end(model(6)). 

 

% ===== TEST DATA (3 examples) ===== 

% These data are NOT used for training, only for validation 

 

begin(model(7)). 

% Successful table for validation (similar pattern to model 1 and 4) 

process_success(table). 

assemble(table, legs, e1). 

assemble(table, tabletop, e2). 

assemble(table, crossbar, e3). 

neg(failure(e1)). 

neg(failure(e2)). 

neg(failure(e3)). 

complete(e1). 

complete(e2). 

complete(e3). 

time(e1, normal). 

time(e2, normal). 

time(e3, normal). 

end(model(7)). 

 

begin(model(8)). 

% Failure in E2 for validation (similar pattern to model 6) 

neg(process_success(chair)). 

assemble(chair, legs, e1). 

neg(assemble(chair, seat, e2)). 

neg(assemble(chair, backrest, e3)). 

neg(failure(e1)). 

failure(e2). 

neg(failure(e3)). 

complete(e1). 

neg(complete(e2)). 

neg(complete(e3)). 

time(e1, fast). 

end(model(8)). 

 

begin(model(9)). 

% Successful fast chair for validation (all fast) 

process_success(chair). 

assemble(chair, legs, e1). 

assemble(chair, seat, e2). 

assemble(chair, backrest, e3). 

neg(failure(e1)). 

neg(failure(e2)). 

neg(failure(e3)). 

complete(e1). 

complete(e2). 

complete(e3). 

time(e1, fast). 

time(e2, fast). 

time(e3, fast). 

end(model(9)). 

 

% ===== FOLD SPLITTING ===== 

 

fold(train, [1, 2, 3, 4, 5, 6]). 

fold(test, [7, 8, 9]). 

 

fold(all, F) :- 

    fold(train, Tr), 

    fold(test, Te), 

    append(Tr, Te, F). 