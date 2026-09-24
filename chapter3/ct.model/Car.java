package ct.model; 

 

public class Car { 

 

    private int position; 

    private int speed; 

    private int acceleration; 

 

    private int speedMax; 

    private int accelerationMax; 

    private int accelerationMin; 

 

    public Car(int initialPosition, int initialSpeed, int initialAcceleration, int vMax, int aMin, int aMax){ 

        this.position = initialPosition; 

        this.speed = initialSpeed; 

        this.acceleration = initialAcceleration; 

        this.speedMax = vMax; 

        this.accelerationMax = aMax; 

        this.accelerationMin = aMin; 

    } 

 

    public void setPosition(int newPosition) { 

        this.position = newPosition; 

    } 

 

    public int getPosition() { 

        return position; 

    } 

 

    public void setSpeed(int newSpeed) { 

        this.speed = newSpeed; 

    } 

 

    public int getSpeed() { 

        return speed; 

    } 

 

    public void setAcceleration(int newAcceleration){ 

        this.acceleration = newAcceleration; 

    } 

 

    public int getAcceleration() { 

        return acceleration; 

    } 

     

    public int getSpeedMax() { 

        return speedMax; 

    } 

 

    public int getAccelerationMax(){ 

        return accelerationMax; 

    } 

 

    public int getAccelerationMin(){ 

        return accelerationMin; 

    } 

 

    public int stopDistance(int tr){ 

        int v = getSpeed(); 

        int aMin = getAccelerationMin(); 

        return v*v/(2*aMin) - v*tr; 

    } 

} 