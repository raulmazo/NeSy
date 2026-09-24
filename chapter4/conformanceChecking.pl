%Calculate the execution time of a rule: 

%user_time(T1), conformance_rule_1(FeatureName, AttId1, AttId2, AttName), user_time(T2), T is T2 - T1.    

 

load_fm(File) :- 

   '$remove_predicate'(root, 1), 

   '$remove_predicate'(feature, 3), 

   '$remove_predicate'(attribute, 3), 

   '$remove_predicate'(dependency, 4), 

   '$remove_predicate'(groupCardinality, 3), 

   consult(File), 

   mk_index. 

 

:- dynamic(inclusion_dep/2). 

 

mk_index :- 

   retractall(inclusion_dep(_, _)), 

   dependency(_, Id1, Id2, Type), 

   inclusion_type(Type), %for the consistency rule at the end of the example 

   assertz(inclusion_dep(Id1, Id2)), 

   fail. 

 

mk_index. 

 

inclusion_type(mandatory). 

inclusion_type(optional). 

inclusion_type(requires). 

 

%A feature should not have two attributes with the same name 

conformance_rule_1(FeatureName,AttId1,AttId2,AttName) :-  

   feature(_, FeatureName, LAttId), 

   chose(LAttId, AttId1, LAttId1), 

   member(AttId2, LAttId1), 

   AttId1 \== AttId2, 

   attribute(AttId1, AttName, _), 

   attribute(AttId2, AttName, _). 

 

chose([X|L], X, L). 

 

chose([_|L], X, L1) :- 

   chose(L, X, L1). 

 

%Two features should not have the same name on the same model 

conformance_rule_2(FeatureId1, FeatureId2, FeatureName) :-  

   findall(FName-FId, feature(FId, FName,_), LNameId), 

   keysort(LNameId ,LNameId1), 

   append(_,[FeatureName-FeatureId1, FeatureName-FeatureId2|_], LNameId1). 

 

%Models of product lines specified using FMs should not have more than one root 

conformance_rule_3(LRootId) :-  

   findall(FeatureId, root(FeatureId), LRootId), 

   length(LRootId, N), 

   N \== 1. 

 

%Features that are involved in a group cardinality relationship must be of type optional (they cannot be mandatory features) 

conformance_rule_4(DepId, FeatureId) :-  

   groupCardinality(LDepId, _, _), 

   member(DepId, LDepId), 

   dependency(DepId, _, FeatureId, mandatory). 

 

%A feature cannot be optional and mandatory at the same time 

conformance_rule_5(FeatureId, DepId1, DepId2) :-  

   dependency(DepId1, _, FeatureId, mandatory), 

   dependency(DepId2, _, FeatureId, optional). 

 

%In a group cardinality <Min..Max> that restricts a set of N dependencies (or their associated features), the values Min and Max must be integers that satisfy: 0 ≤ Min ≤ Max ≤ N. 

conformance_rule_6(LDepId, Min, Max) :-  

   groupCardinality(LDepId, Min, Max),  

   length(LDepId, N),  % N is the number of dependencies 

   (invalid_min_max(Min, Max), ! ; Max > N). 

 

invalid_min_max(Min, Max) :- 

   integer(Min), 

   integer(Max), 

   Min >= 0, 

   Min =< Max, !,  

   fail. 

 

invalid_min_max(_, _). 

 

%Two features cannot be required and mutually exclusive at the same time 

conformance_rule_7(FeatureName1, FeatureName2) :- 

   dependency(_, A, B, requires), 

   order2(A, B, A1, B1), 

   dependency(_, A1, B1, excludes), 

   feature(A, FeatureName1, _), 

   feature(B, FeatureName2, _). 

 

order2(A, B, A, B) :- 

   A @=< B, !. 

 

order2(A, B, B, A). 