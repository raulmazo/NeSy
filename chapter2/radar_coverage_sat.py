""" 

radar_coverage_sat.py file: 

Optimizing Radar Coverage using Glucose SAT Solver 

Corrected version with consistent values and proper solution handling 

""" 

 

import subprocess 

import tempfile 

import os 

from typing import List, Tuple, Set, Optional 

import numpy as np 

from itertools import combinations 

 

class RadarCoverageSAT: 

    """ 

    Main class that encapsulates the SAT encoding logic for radar coverage optimization in air defense systems. 

    """ 

    def __init__(self): 

        # Problem Settings 

        self.num_radars = 8 

        self.num_sectors = 12 

 

        # Relative costs of each radar 

        self.radar_costs = [3, 4, 6, 5, 4, 3, 5, 4] 

 

        # Power consumption (standard units) 

        self.power_consumption = [2, 3, 4, 3, 3, 2, 4, 3] 

        self.max_power = 15  # Available power limit 

 

        # COVERAGE MATRIX (radar i covers sector j) based on propagation analysis 

        # real electromagnetic (also to be adjusted according to the data obtained in other cases) 

        self.coverage_matrix = np.array([ 

            [1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],  # North coastal radar 0 

            [0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0],  # Central elevated radar 1 

            [0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0],  # East Mountain radar 2 

            [0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1],  # East valley radar 3 

            [1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0],  # South-east radar 4 

            [0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1],  # Interior south radar 5 

            [1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0],  # Southern coastal radar 6 

            [0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0],  # Mobile west radar 7 

        ]) 

 

        # Pairs of radars with interference (reduced to facilitate solution) 

        # Determined by frequency and location analysis 

        self.interference_pairs = [(0, 6), (2, 3)] 

         

        # Critical sectors that require redundant coverage 

        # 0: Naval base, 4: Airport, 8: Command center 

        self.critical_sectors = [0, 4, 8] 

 

        # Counters for variables and clauses 

        self.var_counter = 1 

        self.clauses = [] 

 

        # Variable mapping 

        self.radar_vars = {} 

        self.auxiliary_vars = {} 

 

    def allocate_var(self, name: str = None) -> int: 

        """ 

        Assigns a new SAT variable number with namespace management. The separation between main variables (radars) and auxiliary variables facilitates the interpretation of results and the analysis of solutions. 

        """ 

        var_id = self.var_counter 

        self.var_counter += 1 

        if name: 

            if name.startswith('radar_'): 

                self.radar_vars[name] = var_id 

            else: 

                self.auxiliary_vars[name] = var_id 

        return var_id 

 

    def add_clause(self, literals: List[int]): 

        """ 

        Adds a clause to the CNF formula. 

        Each literal can be positive (true variable) or negative (false variable). The clause is satisfied if at least one literal is true. 

        """ 

        self.clauses.append(literals) 

 

    def verify_coverage_feasibility(self): 

        """Verifica que el problema tenga solución antes de codificar""" 

        print("Verificando viabilidad del problema...") 

 

        # Verificar que cada sector puede ser cubierto 

        for sector in range(self.num_sectors): 

            covering_radars = [] 

            for radar in range(self.num_radars): 

                if self.coverage_matrix[radar][sector] == 1: 

                    covering_radars.append(radar) 

 

            if not covering_radars: 

                print(f"  ERROR: Sector {sector} cannot be covered by any radar") 

                return False 

            print(f"  Sector {sector}: can be covered by radars {covering_radars}") 

 

        # Verificar sectores críticos 

        for sector in self.critical_sectors: 

            covering_radars = [] 

            for radar in range(self.num_radars): 

                if self.coverage_matrix[radar][sector] == 1: 

                    covering_radars.append(radar) 

 

            if len(covering_radars) < 2: 

                print(f"  ERROR: Critical sector {sector} does not have sufficient radars") 

                return False 

            print(f"  Critical sector {sector}: has {len(covering_radars)} radars available for redundancy") 

 

        return True 

 

    def encode_coverage_constraints(self): 

        """ 

        Encodes the coverage constraints in CNF. 

        Each sector must be covered by at least one active radar. 

        This fundamental constraint ensures that the solution is operationally viable. 

        """ 

        print("\nCoding coverage restrictions...") 

 

        # Create variables for each radar 

        for i in range(self.num_radars): 

            self.allocate_var(f'radar_{i}') 

 

        # For each sector, create coverage clause 

        for sector in range(self.num_sectors): 

            covering_radars = [] 

            for radar in range(self.num_radars): 

                if self.coverage_matrix[radar][sector] == 1: 

                    covering_radars.append(self.radar_vars[f'radar_{radar}']) 

 

            if covering_radars: 

                self.add_clause(covering_radars) 

                print(f"  Sector {sector}: must be covered by at least one of {len(covering_radars)} radars") 

 

    def encode_interference_constraints(self): 

        """ 

        Codes interference constraints. 

        Electromagnetic interference between radars is a physical phenomenon that must be reflected as logical const. in the SAT model. 

        """ 

        print("\nCoding interference restrictions...") 

        for radar_i, radar_j in self.interference_pairs: 

            # ¬xi ∨ ¬xj (at least one must be inactive) 

            clause = [-self.radar_vars[f'radar_{radar_i}'], 

                      -self.radar_vars[f'radar_{radar_j}']] 

            self.add_clause(clause) 

            print(f"  Interference between radar {radar_i} and radar {radar_j}") 

 

    def encode_redundancy_constraints(self): 

        """ 

        Encodes redundant coverage restrictions for critical sectors. Redundancy is essential for operational robustness but introduces complexity in CNF encoding due to non-boolean nature of the restriction "at least two active radars". 

        """ 

        print("\nCoding redundancy constraints...") 

        for sector in self.critical_sectors: 

            covering_radars = [] 

            for radar in range(self.num_radars): 

                if self.coverage_matrix[radar][sector] == 1: 

                    covering_radars.append(self.radar_vars[f'radar_{radar}']) 

 

            if len(covering_radars) < 2: 

                print(f"ERROR: Critical sector {sector} does not have sufficient radars") 

                continue 

 

            # Generate all combinations of 2 radars 

            # At least one pair must be active 

            redundancy_clause = [] 

            for i in range(len(covering_radars)): 

                for j in range(i + 1, len(covering_radars)): 

                    # Create auxiliary variable for xi ∧ xj 

                    aux_var = self.allocate_var(f'aux_s{sector}_r{i}_{j}') 

 

                    # aux_var → xi ∧ xj 

                    self.add_clause([-aux_var, covering_radars[i]]) 

                    self.add_clause([-aux_var, covering_radars[j]]) 

 

                    # xi ∧ xj → aux_var 

                    self.add_clause([-covering_radars[i], -covering_radars[j], aux_var]) 

 

                    redundancy_clause.append(aux_var) 

 

            # At least one combination must be true 

            self.add_clause(redundancy_clause) 

            print(f"  Critical sector {sector}: requires at least 2 of {len(covering_radars)} possible radars") 

 

    def encode_power_constraint(self): 

        """ 

        Encodes power restriction using heuristic approximation. In industrial implementations, techniques such as totalizer encoding or sequential counters for exact encoding of arithmetic restrictions or solvers such as those in Chapter 4. 

        """ 

        print("\nEncoding power constraints...") 

 

        # Identify high-power radars 

        high_power_radars = [i for i, p in enumerate(self.power_consumption) if p >= 4] 

 

        if len(high_power_radars) > 2: 

            # Maximum 2 high-power radars can be active 

            for combo in combinations(high_power_radars, 3): 

                clause = [-self.radar_vars[f'radar_{r}'] for r in combo] 

                self.add_clause(clause) 

            print(f"  Maximum 2 of {len(high_power_radars)} high-power radars can be active") 

 

    def encode_cardinality_constraint(self, max_radars: int): 

        """ 

        Encodes cardinality restriction: maximum active max_radars. The cardinality constraint is essential for optimization since it allows binary search on the number of active radars, transforming the optimization problem into a decision problem. 

        """ 

        print(f"\nEncoding cardinality constraint (at most {max_radars} radars)...") 

 

        radar_vars_list = [self.radar_vars[f'radar_{i}'] for i in range(self.num_radars)] 

 

        # Only add constraints if necessary 

        if max_radars < self.num_radars: 

            # Limit combinations to avoid combinatorial explosion 

            count = 0 

            for combo in combinations(range(self.num_radars), max_radars + 1): 

                # Prohibit all these radars from being active simultaneously 

                clause = [-self.radar_vars[f'radar_{r}'] for r in combo] 

                self.add_clause(clause) 

                count += 1 

            print(f"  Added {count} cardinality clauses") 

 

    def write_dimacs(self, filename: str): 

        """Write the CNF formula in DIMACS format""" 

        with open(filename, 'w') as f: 

            f.write(f"p cnf {self.var_counter - 1} {len(self.clauses)}\n") 

            for clause in self.clauses: 

                f.write(" ".join(map(str, clause)) + " 0\n") 

        print(f"\nDIMACS file written: {len(self.clauses)} clauses, {self.var_counter - 1} variables") 

 

    def solve_with_glucose(self, dimacs_file: str) -> Tuple[bool, Optional[List[int]]]: 

        """Resolve the SAT instance using Glucose""" 

        try: 

            # Try with glucose if glucose-syrup is not available 

            result = subprocess.run( 

                ['./glucose', '-model', dimacs_file], 

                capture_output=True, 

                text=True, 

                timeout=30 

            ) 

        except (FileNotFoundError, subprocess.SubprocessError): 

            print("ERROR: Glucose has not been found. Make sure the file is in the same folder.") 

            return False, None 

 

        # === LINES ADDED FOR DEBUG === 

        print("\n--- START: RAW OUTPUT FROM GLUCOSE ---") 

        print("--- STDOUT (Standard Output): ---") 

        print(result.stdout) 

        print("--- STDERR (Standard Error): ---") 

        print(result.stderr) 

        print("--- FIN: RAW OUTPUT FROM GLUCOSE ---\n") 

        # ========================================== 

 

        # Parse result 

        lines = result.stdout.split('\n') 

 

        for line in lines: 

            if line.startswith('s SATISFIABLE'): 

                # Find the line with the model 

                for model_line in lines: 

                    if model_line.startswith('v '): 

                        model = [] 

                        tokens = model_line[2:].split() 

                        for token in tokens: 

                            if token != '0': 

                                model.append(int(token)) 

                        return True, model 

                return True, None 

            elif line.startswith('s UNSATISFIABLE'): 

                return False, None 

 

        return False, None 

 

    def analyze_solution(self, model: List[int]) -> List[int]: 

        """Analyze and present the found solution""" 

        active_radars = [] 

 

        print("\n=== SOLUTION FOUND ===") 

 

        # Identify active radars 

        for i in range(self.num_radars): 

            var_id = self.radar_vars[f'radar_{i}'] 

            if var_id in model: 

                active_radars.append(i) 

 

        print(f"\nActive radars: {active_radars}") 

        print(f"Total radars: {len(active_radars)}") 

 

        # Calculate total cost 

        total_cost = sum(self.radar_costs[i] for i in active_radars) 

        print(f"Total cost: {total_cost}") 

 

        # Calculate power consumption 

        total_power = sum(self.power_consumption[i] for i in active_radars) 

        print(f"Power consumption: {total_power}/{self.max_power}") 

 

        # Verify coverage 

        print("\nCoverage of sectors:") 

        for sector in range(self.num_sectors): 

            covering = [i for i in active_radars if self.coverage_matrix[i][sector] == 1] 

            is_critical = " (CRÍTICO)" if sector in self.critical_sectors else "" 

            print(f"  Sector {sector}{is_critical}: covered by radars {covering}") 

 

        # Verify interference 

        print("\nInterference verification:") 

        conflicts = [] 

        for r1, r2 in self.interference_pairs: 

            if r1 in active_radars and r2 in active_radars: 

                conflicts.append((r1, r2)) 

 

        if conflicts: 

            print(f"  WARNING: Conflicts detected: {conflicts}") 

        else: 

            print("  No interference conflicts detected.") 

 

        return active_radars 

 

    def find_optimal_solution(self): 

        """Find the optimal solution using binary search""" 

        print("\n" + "=" * 60) 

        print("STARTING OPTIMIZATION OF RADAR COVERAGE") 

        print("=" * 60) 

 

        # Verify feasibility 

        if not self.verify_coverage_feasibility(): 

            print("\nThe problem is not feasible. Please check the configuration.") 

            return None 

 

        # First search without cardinality restriction 

        print("\n--- Initial search without cardinality restriction ---") 

 

        self.clauses = [] 

        self.var_counter = 1 

        self.radar_vars = {} 

        self.auxiliary_vars = {} 

 

        self.encode_coverage_constraints() 

        self.encode_interference_constraints() 

        self.encode_redundancy_constraints() 

        self.encode_power_constraint() 

 

        with tempfile.NamedTemporaryFile(mode='w', suffix='.cnf', delete=False) as f: 

            self.write_dimacs(f.name) 

            temp_file = f.name 

 

        try: 

            sat, model = self.solve_with_glucose(temp_file) 

 

            if not sat: 

                print("\nINSATISFACIBLE PROBLEM without cardinality constraint! The constraints are contradictory.") 

                return None 

 

            if not model: 

                print("\nERROR: The solver returned 'SATISFIABLE' but did not provide a solution model.") 

                print("This may indicate a problem with the Glucose version or the solver output.") 

                return None 

 

            if model: 

                initial_solution = self.analyze_solution(model) 

                best_solution = initial_solution 

                best_count = len(initial_solution) 

 

                # Binary search for optimize 

                min_radars = 1 

                max_radars = best_count - 1 

 

                print(f"\n--- Starting binary search: range [{min_radars}, {max_radars}] ---") 

 

                while min_radars <= max_radars: 

                    mid = (min_radars + max_radars) // 2 

 

                    print(f"\nTesting with maximum {mid} radars...") 

 

                    # Reset for new encoding 

                    self.clauses = [] 

                    self.var_counter = 1 

                    self.radar_vars = {} 

                    self.auxiliary_vars = {} 

 

                    self.encode_coverage_constraints() 

                    self.encode_interference_constraints() 

                    self.encode_redundancy_constraints() 

                    self.encode_power_constraint() 

                    self.encode_cardinality_constraint(mid) 

 

                    with tempfile.NamedTemporaryFile(mode='w', suffix='.cnf', delete=False) as f: 

                        self.write_dimacs(f.name) 

                        temp_file2 = f.name 

 

                    sat, model = self.solve_with_glucose(temp_file2) 

                    os.unlink(temp_file2) 

 

                    if sat and model: 

                        print(f"  ✓ Solution found with {mid} radars") 

                        best_solution = self.analyze_solution(model) 

                        best_count = len(best_solution) 

                        max_radars = mid - 1 

                    else: 

                        print(f"  ✗ No solution found with {mid} radars") 

                        min_radars = mid + 1 

 

                print("\n" + "=" * 60) 

                print("OPTIMAL SOLUTION FOUND") 

                print("=" * 60) 

                print(f"Minimum number of radars: {best_count}") 

                print(f"Active radars: {best_solution}") 

 

                return best_solution 

 

        finally: 

            if os.path.exists(temp_file): 

                os.unlink(temp_file) 

 

        return None 

 

def main(): 

    """Main function to run the optimizer""" 

    optimizer = RadarCoverageSAT() 

    solution = optimizer.find_optimal_solution() 

 

    if solution: 

        print("\n✓ Optimization completed successfully") 

    else: 

        print("\n✗ No solution could be found") 

 

if __name__ == "__main__": 

    main() 
