/*
 * Main.java
 *
 * Created on Dec 2, 2012 9:13:59 AM;
 */

package org.sunspotworld;


import com.sun.spot.peripheral.IAT91_PowerManager;
import com.sun.spot.peripheral.Spot;
import com.sun.spot.sensorboard.EDemoBoard;
import com.sun.spot.sensorboard.io.IIOPin;
import com.sun.spot.util.Utils;
import javax.microedition.midlet.MIDlet;
import javax.microedition.midlet.MIDletStateChangeException;

/**
 * The startApp method of this class is called by the VM to start the
 * application.
 * 
 * The manifest specifies this class as MIDlet-1, which means it will
 * be selected for execution.
 */
public class Main extends MIDlet {
    private IIOPin[] ioPins = EDemoBoard.getInstance().getIOPins();
    boolean rs, ls;
    IAT91_PowerManager pm = Spot.getInstance().getAT91_PowerManager();
    
    protected void startApp() throws MIDletStateChangeException {

        pm.setShallowSleepClockMode(IAT91_PowerManager.SHALLOW_SLEEP_CLOCK_MODE_9_MHZ);
        //pm.setShallowSleepClockMode(IAT91_PowerManager.SHALLOW_SLEEP_CLOCK_MODE_18_MHZ);
        //pm.setShallowSleepClockMode(IAT91_PowerManager.SHALLOW_SLEEP_CLOCK_MODE_45_MHZ);
        //pm.setShallowSleepClockMode(IAT91_PowerManager.SHALLOW_SLEEP_CLOCK_MODE_NORMAL);
        
        //pm.disablePeripheralClock(0);
        //pm.setUsartEnable(false);
        //pm.setUsbEnable(false);
        
        while(true) {
            rs = ioPins[0].getState();
            ls = ioPins[1].getState();
            
            System.out.println("Sensor readings: " + rs + "   " + ls);
                    
            Utils.sleep(1000);
        }
 
    }

    protected void pauseApp() {
        // This is not currently called by the Squawk VM
    }

    /**
     * Called if the MIDlet is terminated by the system.
     * It is not called if MIDlet.notifyDestroyed() was called.
     *
     * @param unconditional If true the MIDlet must cleanup and release all resources.
     */
    protected void destroyApp(boolean unconditional) throws MIDletStateChangeException {
    }
}
