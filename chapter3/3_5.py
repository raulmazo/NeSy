from z3 import * 

from typing import Any 

 

def all_smt( 

    s: Solver | Optimize, initial_terms, optimization_vars: list[tuple[str, Any]] 

): 

    def block_term(s, m, t): 

        s.add(t != m.eval(t, model_completion=True)) 

 

    def fix_term(s, m, t): 

        s.add(t == m.eval(t, model_completion=True)) 

 

    def all_smt_rec(terms): 

        if sat == s.check(): 

            # This function is modified to be able to report the limits 

            # that are calculated for the variables. 

            for o_var_str, o_var in optimization_vars: 

                print(o_var_str +  str(o_var.value())) 

            m = s.model() 

            # print(m) 

            yield m 

            for i in range(len(terms)): 

                s.push() 

                block_term(s, m, terms[i]) 

                for j in range(i): 

                    fix_term(s, m, terms[j]) 

                yield from all_smt_rec(terms[i:]) 

                s.pop() 

        else: 

            return 

 

    yield from all_smt_rec(list(initial_terms)) 

 

# solver instance, to search for ranges we must use Optimize 

# s = Solver() 

s = Optimize() 

 

# Feature Variables, for simplicity we will keep everything an Int 

vars = F1, F2, F3, F4, F5, F7, F8, F9 = Ints("F1 F2 F3 F4 F5 F7 F8 F9") 

# Root and F6 is a special case so we keep it apart 

Root = Int("Root") 

F6 = IntVector("F6", 4) 

# Variable Domains 

for v in vars: 

    s.add(Or(v == 0, v == 1)) 

# Root Domain 

s.add(Root == 1) 

# F6 Domain 

for i in range(4): 

    s.add(Or(F6[i] == 0, F6[i] == 1)) 

 

# Attributes 

F2_Version = Real("F2_Version") 

s.add(RealVal(0) <= F2_Version, F2_Version <= RealVal(10)) 

# Since we have a real variable, we need to add objective variabless 

F2_Version_Max = s.maximize(F2_Version) 

F2_Version_Min = s.minimize(F2_Version) 

F3_Version = Int("F3_Version") 

s.add(0 <= F3_Version, F3_Version <= 100) 

# For simplicity, we must assume a set size for F5's array property 

F5_Size = 3 

# We will also reuse these colors for F8 

valid_color_stringvals = [StringVal(c) for c in ["White", "Red", "Black"]] 

# This declaration essentially indicates that the variable F5_Color represents an array that maps integers to strings; in other words, each element of that array is indexed by a number. This allows us to ask, for example, what F5_Color[0] is. The solution allows us to say, for example, that F5_Color[1] = “White” 

 

F5_Color = Array("F5_Color", IntSort(), StringSort()) 

# The reason for the * is that the Or operator requires each part of the disjunction to be passed as an argument. Since we’re generating it from the list above in valid_color_stringvals, to flatten that list, we use the * operator—the “spread” operator—which converts the list’s elements into a flat tuple that serves as the arguments for the Or() function. Otherwise, it would throw an error because Z3 only accepts arguments directly and not a list. A type-generating expression (a for a in list) also doesn’t work, because even there it’s necessary to use the spread operator. 

 

# Now, what is being done specifically is that for each of the indices, i.e., 0, 1, 2, we would get an expression like this: s.add(Or(F5_Color == StringVal("White"), F5_Color == StringVal("Red"), etc.)) 

for i in range(F5_Size): 

    s.add(Or(*[F5_Color[i] == vcs for vcs in valid_color_stringvals])) 

# F6_Precio is a special version of an Array for reals, where only 

# the number of positions of the array needs to be specified and by default 

# it is indexed with numbers, similar to F5_Color but without requiring 

# the more complex declaration above. 

F6_Precio = RealVector("F6_Precio", 4) 

F6_Precio_Max = RealVector("F6_Precio_Max", 4) 

F6_Precio_Min = RealVector("F6_Precio_Min", 4) 

# In this case, we are initializing each element of F6_Price by accessing them directly, and using each element’s index to link it to the truth value of each element in the single-valued set F6. That F6 is declared as an array (vector) of 4 positions that can be 1 or 0. From there, a constraint is added that requires each of the prices associated with each of the positions in F6 to be > 0 if the position in F6 is greater than 0—that is, if it is selected. To determine the limits of each variable, we must also add the objective variables. 

for i, f6_p in enumerate(F6_Precio): 

    s.add(RealVal(0) <= f6_p, Implies(F6[i] == 1, RealVal(0) < f6_p)) 

    F6_Precio_Max[i] = s.maximize(f6_p) 

    F6_Precio_Min[i] = s.minimize(f6_p) 

F7_Color = String("F7_Color") 

F8_Color = String("F8_Color") 

s.add(Or(*[F8_Color == vcs for vcs in valid_color_stringvals])) 

F9_Obsoleto = Int("F9_Obsoleto") 

s.add(Or(F9_Obsoleto == 0, F9_Obsoleto == 1)) 

 

# Mandatory Rels 

s.add(Root == F1, F4 == F8) 

# Optional Individual Card 

f6_sum = Sum(F6) 

s.add(F1 <= f6_sum, f6_sum <= F1 * 4) 

# Optional Normal 

s.add(F3 >= F7, F4 >= F9, F1 >= F5) 

# Requires 

s.add(F9 >= F5, F7 >= F8) 

# Excludes 

s.add(F3 * F8 == 0, F4 * F8 == 0) 

# Group Cardinality 

v_sum = Sum(F2, F3, F4) 

s.add(Root == v_sum) 

 

# Extra constraints 

s.add(Implies(F2_Version < RealVal(4.5), F3_Version >= IntVal(6))) 

s.add(Implies(F9_Obsoleto == 1, F2 * F9 == 0)) 

 

all_smt_gen = all_smt( 

    s, 

    ( 

        Root, 

        F1, 

        F2, 

        F3, 

        F4, 

        F5, 

        *F6, 

        F7, 

        F8, 

        F9, 

        F8_Color, 

        F7_Color, 

        F5_Color, 

        F3_Version, 

        F9_Obsoleto, 

        F2_Version, 

        *F6_Precio, 

    ), 

    # By adding objective variables, it becomes possible to obtain the ranges within which the real variables can take values. However, this approach has two fundamental limitations that make it somewhat impractical for use. The first is the need to add an objective function f and ask the solver to find min(f) and max(f) simultaneously, which means that in practice the solver ends up generating a solution at one of the two extremes, and the calculation of the range can only be approximated. The second limitation is tied to the effect that using optimization has on the order in which solutions are reported, because now these are tied to the search for extreme values and are not presented in any intuitive order but rather according to whatever strategy the solver determines. 

    # 

    # It must be said that this is an imperfect solution for reporting results; one can clearly see that these ranges vary from solution to solution, and that to obtain the most accurate actual ranges possible, it would be necessary to analyze the resulting values or implement a better strategy to do this optimally. 

    [ 

        ("min F2_Version = ", F2_Version_Max),  

        ("max F2_Version = ", F2_Version_Min),  

        *((f"min F6_Precio[{i}] = ", F6_Precio_Min[i]) for i in range(4)),  

        *((f"max F6_Precio[{i}] = ", F6_Precio_Max[i]) for i in range(4)) 

    ], 

) 

# We add this instruction to make the computation of variable bounds as independent as possible according to 

# https://microsoft.github.io/z3guide/docs/optimization/combiningobjectives 

s.set(priority="box") 

 

ns = 0 

ns_max = 10 

for sol in all_smt_gen: 

    print(sol) 

    ns = ns + 1 

    if ns == ns_max: 

        break 
