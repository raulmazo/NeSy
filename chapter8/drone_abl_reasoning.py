# drone_abl_reasoning.py — Abductive KB and consistency checker 

 

from ablkit.reasoning import KBBase, Reasoner 

 

class DroneKB(KBBase): 

    """ 

    Implements the drone diagnostic KB as an ABLkit knowledge base. 

 

    The KB encodes the same rules and integrity constraints as the s(CASP) 

    program in Part I. Pseudo-labels are length-3 boolean lists 

    [power_supply_fault, propulsion_fault, software_crash]. Each example's 

    feature vector (``x``) holds the 6 sensor readings followed by the 2 

    contextual flags ``below_50m`` and ``abort_triggered``. 

    """ 

 

    def logic_forward(self, pseudo_label, x=None): 

        """ 

        Check all integrity constraints for a given fault prediction. 

        Returns True if the fault labels are consistent with the KB. 

        """ 

        # Each example holds a single sub-example: one fault-label triple 

        # and one 8-value feature vector (6 sensors + 2 context flags). 

        ps, prop, sw = pseudo_label[0]  # power_supply_fault, propulsion_fault, software_crash 

        below_50m, abort_triggered = x[0][6], x[0][7] 

 

        # Derive symptoms from fault flags (KB rules) 

        loses_alt = ps or prop 

 

        # IC-1: power_supply_fault and propulsion_fault are mutually exclusive 

        if ps and prop: 

            return False 

 

        # IC-2: critical_situation requires abort_triggered 

        if loses_alt and below_50m and not abort_triggered: 

            return False 

 

        return True 

 

class DroneKBReasoner(Reasoner): 

    """Builds the DroneKB internally so callers only need the label space.""" 

 

    def __init__(self, pseudo_label_list, max_revision=1): 

        kb = DroneKB(pseudo_label_list) 

        super().__init__(kb, max_revision=max_revision) 