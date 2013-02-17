/*
 * Main.java
 *
 * Created on Dec 17, 2012 11:27:10 AM;
 */

package org.sunspotworld;

import com.sun.spot.resources.Resources;
import com.sun.spot.resources.transducers.IIOPin;
import com.sun.spot.resources.transducers.IInputPinListener;
import com.sun.spot.resources.transducers.ITriColorLEDArray;
import com.sun.spot.resources.transducers.InputPinEvent;
import com.sun.spot.sensorboard.EDemoBoard;
import com.sun.spot.sensorboard.EDemoController;
import com.sun.spot.util.Utils;
import javax.microedition.midlet.MIDlet;
import javax.microedition.midlet.MIDletStateChangeException;


public class Main extends MIDlet {
    IIOPin[] ioPins = EDemoBoard.getInstance().getIOPins();
    EDemoController edc = EDemoBoard.getInstance().getEDemoController();
    ITriColorLEDArray leds = (ITriColorLEDArray) Resources.lookup(ITriColorLEDArray.class);
    
    public class PinListener implements IInputPinListener {
        
        public void pinSetHigh(InputPinEvent evt) {
            leds.getLED(0).setOn();
            leds.getLED(2).setOn();
            System.out.println("LOW TO HIGH");
        }
        
        public void pinSetLow(InputPinEvent evt) {
            leds.getLED(0).setOff();
            leds.getLED(2).setOn();
            System.out.println("HIGH TO LOW");
        }
    }
    
    PinListener pl = new PinListener(); 
   
    protected void startApp() throws MIDletStateChangeException {
        leds.getLED(0).setRGB(255, 0, 0);
        leds.getLED(1).setRGB(0, 255, 0);
        
        leds.getLED(1).setOn();    
        ioPins[0].addIInputPinListener(pl);
        
        while(true) {
            System.out.println(ioPins[0].getState() + "   " + ioPins[1].getState() + "   " + ioPins[4].getState());            
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
