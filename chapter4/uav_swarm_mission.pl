:- use_module(library(clpfd)). 

% 1. UAV MISSION TASKS DEFINITION 

% task(Id, Description, Duration, DronesRequired) 

task(a, 'Sensor selection and calibration', 2, 2). 

task(b, 'Firmware upload and software update', 1, 1). 

task(c, 'Communication test with ground station', 1, 2). 

task(d, 'Weather and airspace analysis', 2, 1). 

task(e, 'Flight route planning', 3, 2). 

task(f, 'Swarm formation configuration', 2, 3). 

task(g, 'Physical assembly of the swarm', 1, 1). 

task(h, 'Mission requirements definition', 2, 2). 

task(i, 'Data-link configuration', 3, 2). 

task(j, 'Feasibility and mission-area scope study', 4, 2). 

task(k, 'Coordination with local authorities', 2, 1). 

task(l, 'Operator training on emergency protocols', 6, 1). 

task(m, 'Security audit and contingency protocols', 2, 1). 

task(n, 'Obstacle-avoidance testing', 2, 2). 

task(o, 'Coordinated swarm deployment and takeoff', 2, 3). 

task(p, 'Mapping/surveillance sweep execution', 5, 2). 

task(q, 'Data collection and transmission to ground station', 2, 2). 

task(r, 'Swarm landing and recovery', 2, 2). 

task(s, 'Drafting of the mission report and results', 2, 1). 

% 2. TASK DEPENDENCY DEFINITION 

% dependency(PredecessorTask, SuccessorTask) 

dependency(a, b). 

dependency(b, c). 

dependency(d, e). 

dependency(h, e). 

dependency(e, f). 

dependency(i, f). 

dependency(g, h). 

dependency(h, i). 

dependency(i, k). 

dependency(j, k). 

dependency(i, m). 

dependency(m, n). 

dependency(l, n). 

dependency(m, o). 

dependency(f, o). 

dependency(c, o). 

dependency(o, p). 

dependency(n, p). 

dependency(p, q). 

dependency(n, r). 

dependency(k, r). 

dependency(o, r). 

dependency(r, s). 

% 3. MISSION CONSTANTS AND HELPER PREDICATES 

% Available resources 

available_resources(5).  % 5 drones maximum in the swarm 

  

% Get all tasks of the mission 

all_tasks(Tasks) :- 

    findall(Id, task(Id, _, _, _), Tasks). 

  

% Direct predecessors of a task 

predecessors(Task, Preds) :- 

    findall(P, dependency(P, Task), Preds). 

  

% Direct successors of a task 

successors(Task, Succs) :- 

    findall(S, dependency(Task, S), Succs). 

% 4. TOPOLOGICAL ORDERING OF TASKS 

% topo_order(-Order) 

topo_order(Order) :- 

    all_tasks(Tasks), 

    build_topo_order(Tasks, [], Order). 

  

build_topo_order([], Scheduled, Order) :- 

    reverse(Scheduled, Order). 

build_topo_order(Remaining, Scheduled, Order) :- 

    once(select_ready_task(Remaining, Scheduled, Task)), 

    delete(Remaining, Task, Rest), 

    build_topo_order(Rest, [Task|Scheduled], Order). 

  

select_ready_task(Remaining, Scheduled, Task) :- 

    member(Task, Remaining), 

    predecessors(Task, Preds), 

    forall(member(P, Preds), member(P, Scheduled)). 

% 5. GREEDY SCHEDULING ENGINE (MAIN SOLVER) 

% resolve_planning(-Solution, -TotalTime) 

resolve_planning(Solution, TotalTime) :- 

    available_resources(MaxDrones), 

    topo_order(Order), 

    schedule_tasks(Order, MaxDrones, [], Solution), 

    calculate_total_time(Solution, TotalTime). 

  

schedule_tasks([], _, Schedule, Schedule). 

schedule_tasks([Task|Rest], MaxDrones, ScheduleSoFar, FinalSchedule) :- 

    task(Task, _, Duration, DronesNeeded), 

    earliest_predecessor_end(Task, ScheduleSoFar, MinStart), 

    earliest_feasible_start(MinStart, Duration, DronesNeeded, MaxDrones, ScheduleSoFar, Start), 

    End is Start + Duration, 

    schedule_tasks(Rest, MaxDrones, [sched(Task, Start, End, DronesNeeded)|ScheduleSoFar], FinalSchedule). 

  

earliest_predecessor_end(Task, Schedule, MinStart) :- 

    predecessors(Task, Preds), 

    ( Preds == [] 

    -> MinStart = 0 

    ;  findall(End, (member(P, Preds), member(sched(P, _, End, _), Schedule)), Ends), 

       max_list(Ends, MinStart) 

    ). 

  

earliest_feasible_start(MinStart, Duration, DronesNeeded, MaxDrones, Schedule, Start) :- 

    between(MinStart, 200, Start), 

    resources_available(Start, Duration, DronesNeeded, MaxDrones, Schedule), 

    !. 

  

calculate_total_time(Schedule, TotalTime) :- 

    findall(End, member(sched(_, _, End, _), Schedule), Ends), 

    max_list(Ends, TotalTime). 

% 6. RESOURCE-CONFLICT CHECKING 

resources_available(Start, Duration, DronesNeeded, MaxDrones, Schedule) :- 

    LastOffset is Duration - 1, 

    forall(between(0, LastOffset, Offset), 

           ( T is Start + Offset, 

             drones_used_at(T, Schedule, Used), 

             Total is Used + DronesNeeded, 

             Total =< MaxDrones )). 

  

drones_used_at(T, Schedule, Used) :- 

    findall(D, (member(sched(_, S, E, D), Schedule), T >= S, T < E), Ds), 

    sum_list(Ds, Used). 

% 7. SOLUTION CONSTRUCTION AND DISPLAY 

sort_by_start(Schedule, Sorted) :- 

    findall(Start-Entry, (member(Entry, Schedule), Entry = sched(_, Start, _, _)), Pairs), 

    keysort(Pairs, SortedPairs), 

    pairs_values(SortedPairs, Sorted). 

  

display_solution(Schedule, TotalTime) :- 

    sort_by_start(Schedule, Sorted), 

    format("~n=== UAV Swarm Mission Schedule ===~n"), 

    forall(member(sched(Task, Start, End, Drones), Sorted), 

           ( task(Task, Desc, _, _), 

             format("Task ~w (~w): start = ~w, end = ~w, drones = ~w~n", 

                    [Task, Desc, Start, End, Drones]) )), 

    format("~nMission makespan: ~w time units~n", [TotalTime]). 

% 8. CRITICAL PATH ANALYSIS 

latest_finish(Task, ProjectEnd, LF) :- 

    successors(Task, Succs), 

    ( Succs == [] 

    -> LF = ProjectEnd 

    ;  findall(LS, (member(S, Succs), latest_start(S, ProjectEnd, LS)), LSs), 

       min_list(LSs, LF) 

    ). 

  

latest_start(Task, ProjectEnd, LS) :- 

    latest_finish(Task, ProjectEnd, LF), 

    task(Task, _, Duration, _), 

    LS is LF - Duration. 

  

slack(Task, ProjectEnd, Schedule, Slack) :- 

    member(sched(Task, EarliestStart, _, _), Schedule), 

    latest_start(Task, ProjectEnd, LatestStart), 

    Slack is LatestStart - EarliestStart. 

  

critical_tasks(Schedule, ProjectEnd, CriticalTasks) :- 

    findall(Task, 

            ( member(sched(Task, _, _, _), Schedule), 

              slack(Task, ProjectEnd, Schedule, 0) ), 

            CriticalTasks). 

% EXTENSION OF MODULE 8: DISPLAYING THE CRITICAL PATH 

show_critical_path(CriticalPath) :- 

    format("~n=== CRITICAL PATH ===~n"), 

    forall(member(Task, CriticalPath), 

           ( task(Task, Desc, _, _), 

             format("~w: ~w~n", [Task, Desc]) )). 

% EXTENSION OF MODULE 8: DETAILED CRITICAL PATH DISPLAY 

show_critical_path_detailed(CriticalPath, Schedule) :- 

    writeln('=== CRITICAL PATH ANALYSIS ==='), 

    length(CriticalPath, NumTasks), 

    format('The critical path contains ~w tasks:~n~n', [NumTasks]), 

    show_critical_tasks_numbered(CriticalPath, Schedule, 1), 

    calculate_critical_duration(CriticalPath, TotalDuration), 

    format('~nTotal duration along the critical path: ~w time units~n', [TotalDuration]), 

    writeln('ATTENTION: any delay in these tasks will delay the entire mission.'). 

  

show_critical_tasks_numbered([], _, _). 

show_critical_tasks_numbered([Task|Rest], Schedule, Num) :- 

    task(Task, Desc, Duration, Drones), 

    member(sched(Task, Start, End, _), Schedule), 

    format('~w. Task ~w: ~w~n', [Num, Task, Desc]), 

    format('   Start: ~w, End: ~w, Duration: ~w, Drones: ~w~n~n', [Start, End, Duration, Drones]), 

    Num1 is Num + 1, 

    show_critical_tasks_numbered(Rest, Schedule, Num1). 

  

calculate_critical_duration(CriticalPath, TotalDuration) :- 

    findall(Duration, (member(Task, CriticalPath), task(Task, _, Duration, _)), Durations), 

    sum_list(Durations, TotalDuration). 


% EXTENSION OF MODULE 8: COMPLETE MISSION ANALYSIS 

is_critical(CriticalPath, sched(Task, _, _, _)) :- 

    memberchk(Task, CriticalPath). 

  

complete_mission_analysis :- 

    writeln('=== COMPLETE MISSION ANALYSIS ==='), 

    resolve_planning(Solution, TotalTime), 

    writeln('1. GENERAL SCHEDULE:'), 

    display_solution(Solution, TotalTime), 

    writeln('2. CRITICAL PATH ANALYSIS:'), 

    critical_tasks(Solution, TotalTime, CriticalPath), 

    show_critical_path_detailed(CriticalPath, Solution), 

    writeln('3. NON-CRITICAL TASKS:'), 

    exclude(is_critical(CriticalPath), Solution, NonCriticalSchedule), 

    show_non_critical_tasks(NonCriticalSchedule). 

  

show_non_critical_tasks([]) :- 

    writeln('All tasks are critical.'). 

show_non_critical_tasks(NonCritical) :- 

    length(NonCritical, NumTasks), 

    format('There are ~w tasks with slack (they can be delayed without affecting the mission):~n~n', [NumTasks]), 

    forall(member(sched(Task, Start, End, Drones), NonCritical), 

           ( task(Task, Desc, _, _), 

             format('Task ~w (~w): start=~w end=~w drones=~w~n', [Task, Desc, Start, End, Drones]) )). 

% 9. OPTIMIZED VERSION: PRIORITY-BASED TASK SELECTION 

select_ready_task_priority(Remaining, Scheduled, Task) :- 

    findall(Priority-T, 

            ( member(T, Remaining), 

              predecessors(T, Preds), 

              forall(member(P, Preds), member(P, Scheduled)), 

              count_all_successors(T, Priority) ), 

            ReadyWithPriority), 

    keysort(ReadyWithPriority, Sorted), 

    last(Sorted, _-Task). 

  

count_all_successors(Task, Count) :- 

    successors(Task, Direct), 

    findall(N, (member(D, Direct), count_all_successors(D, N)), Ns), 

    sum_list(Ns, IndirectSum), 

    length(Direct, DirectCount), 

    Count is DirectCount + IndirectSum. 

  

build_topo_order_priority([], Scheduled, Order) :- 

    reverse(Scheduled, Order). 

build_topo_order_priority(Remaining, Scheduled, Order) :- 

    select_ready_task_priority(Remaining, Scheduled, Task), 

    delete(Remaining, Task, Rest), 

    build_topo_order_priority(Rest, [Task|Scheduled], Order). 

  

topo_order_priority(Order) :- 

    all_tasks(Tasks), 

    build_topo_order_priority(Tasks, [], Order). 

  

resolve_planning_optimized(Solution, TotalTime) :- 

    available_resources(MaxDrones), 

    topo_order_priority(Order), 

    schedule_tasks(Order, MaxDrones, [], Solution), 

    calculate_total_time(Solution, TotalTime). 

% 10. SUMMARY STATISTICS 

calculate_statistics(Schedule, TotalTime) :- 

    length(Schedule, TaskCount), 

    format("~n=== MISSION STATISTICS ===~n"), 

    format("Total number of tasks: ~w~n", [TaskCount]), 

    format("Mission makespan: ~w time units~n", [TotalTime]). 

% 11. MAIN EXECUTION PREDICATE 

execute_mission :- 

    writeln('Starting mission orchestration for the UAV swarm...'), 

    resolve_planning(Solution, TotalTime), 

    display_solution(Solution, TotalTime), 

    calculate_statistics(Solution, TotalTime). 