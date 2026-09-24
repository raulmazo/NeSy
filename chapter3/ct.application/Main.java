package ct.application; 

import ct.controller.SimulationCSP; 

 

public class Main { 

 

    public static void main(String[] args) { 

        System.out.println("Console Simulation - MMethod 1 started"); 

        int[] initTL1 = {0, 1, 5, 5}; 

        boolean[] initTL2 = {false, false, true, false}; 

        int[] initCar = {-30, 10, 0, 30, -4, 3}; // Car(initPos, initSpeed, initAcc, vMax, aMin, aMax) 

        SimulationCSP simulation = new SimulationCSP(1, 10, initTL1, initTL2, initCar); 

 

        for (int i = 0; i <= 15; i++) { 

            System.out.println("\n - Result of the CSP :"); 

            simulation.OneLap(-100, 14, 1); 

        } 

    } 

} 
