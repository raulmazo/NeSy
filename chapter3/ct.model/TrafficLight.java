package ct.model; 

public class TrafficLight { 

    private int position; 

    private boolean degraded; 

    private boolean green; 

    private boolean red; 

    private boolean yellow; 

    private int periodGreen; 

    private int periodYellow; 

    private int periodRed; 

    private int tG; 

    private int tY; 

    private int tR; 

    public TrafficLight(int position, int periodG, int periodY, int periodR, boolean degraded, boolean red, boolean yellow , boolean green){ 

        this.position = position; 

        this.degraded  = degraded; 

        this.red = red; 

        this.yellow = yellow; 

        this.green = green; 

        this.periodGreen = periodG; 

        this.periodYellow = periodY; 

        this.periodRed = periodR; 

        this.tG = 0; 

        this.tY = 0; 

        this.tR = 0; 

    } 

 

    public int getPosition(){ 

        return position; 

    } 

 

    public void setDegraded(boolean degraded){ 

        this.degraded = degraded; 

    } 

 

    public boolean isDegraded(){ 

        return degraded; 

    } 

 

    public void setGreen(boolean green){ 

        this.green = green; 

    } 

 

    public boolean isGreen(){ 

        return green; 

    } 

 

    public void setYellow(boolean yellow){ 

        this.yellow = yellow; 

    } 

 

    public boolean isYellow(){ 

        return yellow; 

    } 

 

    public void setRed(boolean red){ 

        this.red = red; 

    } 

 

    public boolean isRed(){ 

        return red; 

    } 

 

    public void updateLights(){ 

        if (this.isGreen()) { 

            if (this.tG == periodGreen) { 

                this.setGreen(false); 

                this.setYellow(true); 

                this.tG = 0; 

            } 

            this.tG ++; 

        } 

 

        if (this.isYellow()) { 

            if (this.tY == periodYellow) { 

                this.setYellow(false); 

                this.setRed(true); 

                this.tY = 0; 

            } 

            this.tY ++; 

        } 

 

        if (this.isRed()){ 

            if (this.tR == periodRed){ 

                this.setRed(false); 

                this.setGreen(true); 

                this.tR = 0; 

            } 

            this.tR ++; 

        } 

        System.out.println(this); 

    } 

 

    @Override 

    public String toString(){ 

        if (this.isGreen()){ 

            return "The traffic light is green!"; 

        } 

        else if (this.isYellow()){ 

            return "The traffic light is yellow!"; 

        } 

        else if (this.isRed()){ 

            return "The traffic light is red!"; 

        } 

        return "Error in the traffic light application and system!"; 

    } 

}
