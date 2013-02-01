/*
 * DeepSleep.java
 *
 * Created on Jan 17, 2013 12:49:16 PM;
 */

package org.sunspotworld;

import com.sun.spot.io.j2me.radiogram.RadiogramConnection;
import com.sun.spot.peripheral.ISleepManager;
import com.sun.spot.peripheral.Spot;
import com.sun.spot.resources.Resources;
import com.sun.spot.resources.transducers.IIOPin;
import com.sun.spot.resources.transducers.ITriColorLED;
import com.sun.spot.resources.transducers.ITriColorLEDArray;
import com.sun.spot.sensorboard.EDemoBoard;
import com.sun.spot.sensorboard.EDemoController;
import com.sun.spot.sensorboard.io.IInputPin;
import com.sun.spot.sensorboard.io.PinDescriptor;
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
public class DeepSleep extends MIDlet {

    private ITriColorLEDArray leds = (ITriColorLEDArray) Resources.lookup(ITriColorLEDArray.class);
    RadiogramConnection conn;
    ISleepManager sleepManager;
    IIOPin[] ioPins = EDemoBoard.getInstance().getIOPins();
    EDemoController edc = EDemoBoard.getInstance().getEDemoController();
    boolean TRIGGERED = true;

    protected void startApp() throws MIDletStateChangeException {
        
        final ITriColorLED led0 = leds.getLED(0);
        ITriColorLED led1 = leds.getLED(1);
        ITriColorLED led2 = leds.getLED(2);
        led0.setRGB(255,0,0);                    // set color to moderate red
        led1.setRGB(0, 255, 0);
        led2.setRGB(0, 0, 255);
        
        sleepManager = Spot.getInstance().getSleepManager();
        IIOPin p0 = ioPins[0];
        IInputPin ip0;
        ip0 = (IInputPin)p0;
        
        PinDescriptor d0 = EDemoController.D0;
        edc.setPinDirection(d0, false);
        edc.enablePinChangeInterrupts(ip0);
        
        /*
        class PinListener implements IInputPinListener {
            public void pinSetHigh(InputPinEvent evt) {
                System.out.println("LOW TO HIGH");
            }

            public void pinSetLow(InputPinEvent evt) {
                System.out.println("HIGH TO LOW");
                led0.setOn();
                TRIGGERED = false;
            }
        }
        */
        
        //PinListener pl = new PinListener(); 
        //ioPins[0].addIInputPinListener(pl);
        

        
        led0.setOn();
        Utils.sleep(500);
        led0.setOff();
        
        //Utils.sleep(5000);
        
        
        
        try {
            synchronized(ip0.getIndex()) {
                ip0.getIndex().wait();
                led0.setRGB(255,255,0);
                led0.setOn();
            }
        } catch(Exception e) {
            System.out.println(e);
            led0.setOn();
        }
        
        /*
        while(TRIGGERED) {
            Utils.sleep(5000);
        }
        */
        
        System.out.println("Shallow sleep:" + sleepManager.getTotalShallowSleepTime());
        System.out.println("Total time on:" + sleepManager.getUpTime());
        System.out.println("Deep sleep:"+ sleepManager.getTotalDeepSleepTime());
        
        if(sleepManager.getTotalDeepSleepTime() > 0) {
            led1.setOn();
        } else {
            led2.setOn();
        }
        
        Utils.sleep(2000);
        notifyDestroyed();                      // cause the MIDlet to exit
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
