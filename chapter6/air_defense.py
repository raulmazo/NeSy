import re 

import sys 

 

import tensorflow as tf 

from src.core import Term, Atom 

from src.ilp import Language_Frame, Program_Template, Rule_Template 

from src.dilp import DILP 

 

def read_atoms(filename): 

    '''Reads the ground atoms of a file, written as predicate(constant).''' 

    with open(filename) as f: 

        atoms = re.findall(r'(\w+)\(([^)]*)\)\s*\.', f.read()) 

    return [Atom([Term(False, c.strip()) for c in args.split(',')], pred) 

            for pred, args in atoms] 

 

folder = sys.argv[1] 

B = read_atoms(folder + '/facts.dilp')     # background knowledge 

P = read_atoms(folder + '/positive.dilp')  # positive examples 

N = read_atoms(folder + '/negative.dilp')  # negative examples 

print('%d facts, %d positive and %d negative examples' 

      % (len(B), len(P), len(N))) 

 

# Extensional predicates and constants, shared by all the target predicates 

X = [Term(True, 'X_0'), Term(True, 'X_1')] 

p_e = sorted({Atom(X[:a.arity], a.predicate) for a in B}, key=str) 

constants = sorted({t.name for a in B + P + N for t in a.terms}) 

targets = list(dict.fromkeys(a.predicate for a in P))  # in order of appearance 

 

results = [] 

for name in targets: 

    pos = [a for a in P if a.predicate == name] 

    neg = [a for a in N if a.predicate == name] 

    target = Atom(X[:pos[0].arity], name) 

    language_frame = Language_Frame(target, p_e, constants) 

 

    # Program template: no auxiliary predicates, a single rule template for 

    # the target (no existential variables, only extensional predicates in 

    # the body) and T = 2 forward-chaining inference steps 

    rules = {target: (Rule_Template(0, False), None)} 

    program_template = Program_Template([], rules, 2) 

 

    # One differentiable model per target predicate (501 iterations) 

    dilp = DILP(language_frame, B, pos, neg, program_template) 

    dilp.train() 

 

    # Clause with the highest learned weight and value inferred for obj4 

    weights = tf.nn.softmax(tf.reshape(dilp.rule_weights[target], [-1])) 

    best = int(tf.argmax(weights)) 

    obj4 = Atom([Term(False, 'obj4')], name) 

    value = float(dilp.deduction()[dilp.valuation_mapping[obj4]]) 

    results.append((float(weights[best]), dilp.clause_map[target][0][best], 

                    obj4, value)) 

 

print('Learned rules:') 

for weight, clause, _, _ in results: 

    print('%.3f  %s' % (weight, clause)) 

     

print('Classification of obj4:') 

for _, _, atom, value in results: 

    print('%s: %.3f' % (atom, value)) 