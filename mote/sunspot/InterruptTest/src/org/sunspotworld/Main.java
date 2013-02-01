/*
 * Main.java
 *
 * Created on Dec 17, 2012 11:27:10 AM;
 */

package org.sunspotworld;

import com.sun.spot.resources.transducers.IIOPin;
import com.sun.spot.resources.transducers.IInputPinListener;
import com.sun.spot.resources.transducers.InputPinEvent;
import com.sun.spot.sensorboard.EDemoBoard;
import com.sun.spot.sensorboard.EDemoController;
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
    
    IIOPin[] ioPins = EDemoBoard.getInstance().getIOPins();
    EDemoController edc = EDemoBoard.getInstance().getEDemoController();
    
    public class PinListener implements IInputPinListener {
        public void pinSetHigh(InputPinEvent evt) {
            System.out.println("LOW TO HIGH");
        }
        
        public void pinSetLow(InputPinEvent evt) {
            System.out.println("HIGH TO LOW");
        }
    }
    
    PinListener pl = new PinListener(); 
   
    protected void startApp() throws MIDletStateChangeException {

        ioPins[0].addIInputPinListener(pl);
        //edc.enablePinChangeInterrupts((IInputPin)ioPins[0]);
        
        while(true) {
            System.out.println(ioPins[0].getState());
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
