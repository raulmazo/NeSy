package ct.controller; 

 

import ct.model.TrafficLight; 

import ct.model.Car; 

import org.chocosolver.solver.Model; 

import org.chocosolver.solver.Solver; 

import org.chocosolver.solver.search.strategy.Search; 

import org.chocosolver.solver.variables.BoolVar; 

import org.chocosolver.solver.variables.IntVar; 

 

public class SimulationCSP { 

    private int timeStep; 

    private int unitScale; 

    private String unitstr; 

    private Car car; 

    private TrafficLight trafficLight; 

 

    public SimulationCSP(int h, int unit, int[] initTL1, boolean[] initTL2, int[] initCar) { 

        this.timeStep = h; 

        this.unitScale = unit; 

        this.car = new Car(initCar[0] * unit, initCar[1] * unit, initCar[2] * unit, initCar[3] * unit, initCar[4] * unit, initCar[5] * unit); 

        // Car(initPos, initSpeed, initAcc, vMax, aMin, aMax) 

        this.trafficLight = new TrafficLight(initTL1[0] * unit, initTL1[1], initTL1[2], initTL1[3], initTL2[0], initTL2[1], initTL2[2], initTL2[3]); 

        // TraficLight(pos, periodGreen, periodYellow, periodRed, isDegraded, initRed, initYellow, initGreen) 

        switch (unit) { 

            case 10: 

                unitstr = " dm"; 

                break; 

            case 100: 

                unitstr = " cm"; 

                break; 

            case 1000: 

                unitstr = " mm"; 

                break; 

        } 

    } 

 

    public int[] OneLap(int xMin, int vSL, int tr) { 

        // xMin: Position from which the traffic light is viewed 

        // vSL: Speed Limit 

        // tr: Reaction Time 

        xMin *= unitScale; 

        vSL *= unitScale; 

        // Create a new model 

        Model model = new Model("Simulacion"); 

 

        trafficLight.updateLights(); 

 

        // Get car parameters 

        int xk = car.getPosition(); // Position of the car 

        int xTL = trafficLight.getPosition(); // Position of the traffic light 

        int xMax = (xTL * unitScale + car.stopDistance(tr)); // Last position where the car can stop 

 

        int vk = car.getSpeed(); // Speed of the car 

        int vMax = car.getSpeedMax(); // Maximum speed of the car 

        int aMin = car.getAccelerationMin(); // Maximum deceleration of the car 

 

        IntVar vkParam = model.intVar("v_k", vk); // v_k: speed of the car 

        IntVar vk1Var = model.intVar("v_k+1", 0, vMax); // v_k+1 to determine 

        IntVar aVar = model.intVar("a", aMin, car.getAccelerationMax()); // acceleration in [aMin, aMax] 

 

        // Booleans 

        boolean xBet = ((xMin < xk) && (xk <= xMax)); 

        boolean xInf = xk <= xMin; 

        boolean xSup = (xMax < xk && xk <= 0); 

        boolean xOver = xk > 0; 

        boolean xNotNearTL = !(xk >= (xTL - 2 * unitScale) && xk <= xTL); 

        boolean xJustAfterTL = xk >= 0 && xk < 10 * unitScale; 

        boolean accelerationPos = car.getAcceleration() >= 0; 

 

        // CTLCi booleans 

        BoolVar CTLC1456BoolPos = model.boolVar("CTLC1, CTLC4, CTLC5, CTLC6 Aceleracion Positiva", (xInf || xOver || trafficLight.isGreen() || (xSup && trafficLight.isRed())) && accelerationPos); 

        BoolVar CTLC1456BoolNeg = model.boolVar("CTLC1, CTLC4, CTLC5, CTLC6 Aceleracion Negativa", (xInf || xOver || trafficLight.isGreen() || (xSup && trafficLight.isRed())) && !accelerationPos); 

        BoolVar CTLC2Bool = model.boolVar("CTLC2", xSup && trafficLight.isYellow()); 

        BoolVar CTLC3aBool = model.boolVar("CTLC3a and CTLDC2", xBet && (trafficLight.isRed() || trafficLight.isYellow())); 

        BoolVar CTLC3bBool = model.boolVar("CTCL3b", xNotNearTL); 

        BoolVar CTLDC2Bool = model.boolVar("CTLDC2", xNotNearTL && xBet && trafficLight.isDegraded()); 

        BoolVar CTLDC3Bool = model.boolVar("CTLDC3", ((!xNotNearTL) || xJustAfterTL) && trafficLight.isDegraded()); 

 

        // Speed Limit Constraint: vk+1 <= vSL 

        model.arithm(vk1Var, "<=", vSL).post(); 

 

        // CTLC1, CTLC4, CTLC5 and CTLC6 constraints 

        model.ifThen(CTLC1456BoolPos, model.and(model.arithm(vk1Var, ">=", vkParam), model.arithm(aVar, "<=", car.getAcceleration() + 4), model.arithm(aVar, ">=", 0))); 

        model.ifThen(CTLC1456BoolNeg, model.and(model.arithm(vk1Var, ">=", vkParam), model.arithm(aVar, "=", 1))); 

 

        // CTLC2 constraints 

        model.ifThen(CTLC2Bool, model.arithm(vk1Var, "=", vkParam)); 

 

        // CTLC3 constraints 

        // Solving the inequality: 0 >= x_k+1 + x_TL - v_k+1²/(2*a_min) + v_k+1*t_r <=> v_k+1²/(2*a_min) >= v_k+1*t_r + x_k+1 + x_TL 

        IntVar vk1Square = model.intVar("v²", 0, vMax * vMax); 

        IntVar dReact = model.intVar("distancia de reaccion", 0, vMax * tr); 

        IntVar reactionTime = model.intVar("tiempo de reaccion,", tr); 

        IntVar aMinTimesTwo = model.intVar("(2*amin)", 2 * aMin); 

        IntVar squareDiv = model.intVar("v²/(2amin)", vMax * vMax / (2 * aMin), 0); 

        IntVar xk1pxTL = model.intVar("x_k+1 + x_TL", xk + vk * timeStep + xTL); // x_k+1 + x_TL 

 

        model.square(vk1Square, vk1Var).post(); // Forza vk1Square = vk1Var² 

        model.arithm(vk1Square, "/", aMinTimesTwo, "=", squareDiv).post(); 

        model.arithm(vk1Var, "*", reactionTime, "=", dReact).post(); 

 

        // Deceleration constraints 

        model.ifThen(CTLC3aBool, 

                model.and(model.arithm(vk1Var, "<=", vkParam), 

                        model.arithm(xk1pxTL, "+", dReact, "<=", squareDiv))); 

 

        // The car not should stop too far from the traffic light 

        model.ifThen(CTLC3bBool, model.arithm(vk1Var, ">", 0)); 

 

        // Degraded conditions: the car moves slowly at the intersection 

        model.ifThen( 

            CTLDC2Bool, 

            model.and( 

                model.arithm(vk1Var, "<=", vkParam), 

                model.arithm(xk1pxTL, "+", dReact, "<=", squareDiv) 

            ) 

        ); 

 

        model.ifThen(CTLDC3Bool, model.arithm(aVar, "=", Math.max(0, car.getAcceleration() + 1))); 

 

        // Valid for all CTLC: vk+1 = vk + a*timestep 

        (vkParam.add(aVar.mul(timeStep))).eq(vk1Var).post(); 

 

        // CSP solving 

        Solver solver = model.getSolver(); 

        solver.setSearch(Search.inputOrderUBSearch(aVar)); // Change the search method for acceleration: take the highest that respects the constraints 

        int[] lista = new int[5]; 

 

        if (solver.solve()) { 

            car.setPosition(xk + vk * timeStep); // update position 

            System.out.println("Posición : " + car.getPosition() + unitstr); 

 

            car.setSpeed(vk1Var.getValue()); // update speed 

            System.out.println("Velocidad : " + car.getSpeed() + unitstr + "/s"); 

 

            car.setAcceleration(aVar.getValue()); // update acceleration 

            System.out.println("Aceleración : " + car.getAcceleration() + unitstr + "/s²"); 

            lista[0] = car.getPosition(); 

            lista[1] = car.getSpeed(); 

            if (trafficLight.isRed()) { 

                lista[2] = 1; 

            } else { 

                lista[2] = 0; 

            } 

            if (trafficLight.isYellow()) { 

                lista[3] = 1; 

            } else { 

                lista[3] = 0; 

            } 

            if (trafficLight.isGreen()) { 

                lista[4] = 1; 

            } else { 

                lista[4] = 0; 

            } 

            return lista; 

        } else { 

            System.out.println("Problem with the resolution"); 

            return lista; 

        } 

    } 

} 
