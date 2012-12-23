/*
 * Main.java
 *
 * Created on Dec 17, 2012 11:27:10 AM;
 */

package org.sunspotworld;

import com.sun.spot.resources.Resources;
import com.sun.spot.resources.transducers.IIOPin;
import com.sun.spot.resources.transducers.ITriColorLEDArray;
import com.sun.spot.resources.transducers.LEDColor;
import com.sun.spot.sensorboard.EDemoBoard;
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
    private ITriColorLEDArray leds = (ITriColorLEDArray) Resources.lookup(ITriColorLEDArray.class);
    private LEDColor[] colors = {LEDColor.RED, LEDColor.GREEN, LEDColor.BLUE};
    
    boolean p0, p1;
    
    IIOPin[] ioPins = EDemoBoard.getInstance().getIOPins();
    
    protected void startApp() throws MIDletStateChangeException {
    
        leds.getLED(0).setColor(colors[0]);
        leds.getLED(1).setColor(colors[2]);
        

        
        while(true) {
            p0 = ioPins[0].getState();
            p1 = ioPins[1].getState();
            
            if(p0 == false) {
                leds.getLED(0).setOn();
            } else {
                leds.getLED(0).setOff();
            }
            
            if(p1 == false) {
                leds.getLED(1).setOn();
            } else {
                leds.getLED(1).setOff();
            }
            
            //System.out.print(ioPins[0].getState() + "    ");
            //System.out.println(ioPins[4].getState());
            
            Utils.sleep(100);
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
