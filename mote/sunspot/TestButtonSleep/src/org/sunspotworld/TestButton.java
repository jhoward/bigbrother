/*
 * TestButton.java
 *
 * Created on Jan 22, 2013 12:24:41 PM;
 */

package org.sunspotworld;

import com.sun.spot.io.j2me.radiogram.RadiogramConnection;
import com.sun.spot.peripheral.IAT91_PowerManager;
import com.sun.spot.peripheral.ISleepManager;
import com.sun.spot.peripheral.Spot;
import com.sun.spot.peripheral.radio.RadioFactory;
import com.sun.spot.resources.Resources;
import com.sun.spot.resources.transducers.IIOPin;
import com.sun.spot.resources.transducers.ISwitch;
import com.sun.spot.resources.transducers.ISwitchListener;
import com.sun.spot.resources.transducers.ITriColorLED;
import com.sun.spot.resources.transducers.ITriColorLEDArray;
import com.sun.spot.resources.transducers.SwitchEvent;
import com.sun.spot.sensorboard.EDemoBoard;
import com.sun.spot.sensorboard.EDemoController;
import com.sun.spot.service.BootloaderListenerService;
import com.sun.spot.util.IEEEAddress;
import com.sun.spot.util.Utils;

import javax.microedition.midlet.MIDlet;
import javax.microedition.midlet.MIDletStateChangeException;


public class TestButton extends MIDlet {

    private ITriColorLEDArray leds = (ITriColorLEDArray) Resources.lookup(ITriColorLEDArray.class);
    public ITriColorLED led0 = leds.getLED(0);
    public ITriColorLED led1 = leds.getLED(1);
    public ITriColorLED led2 = leds.getLED(2);
    ISleepManager sleepManager;
    public boolean triggered = true;
    
    
    
    protected void startApp() throws MIDletStateChangeException {

        ISwitch sw1 = (ISwitch) Resources.lookup(ISwitch.class, "SW1");
        ITriColorLED led = leds.getLED(0);
        led0.setRGB(255,0,0);                    // set color to moderate red
        led1.setRGB(0, 255, 0);
        led2.setRGB(0, 0, 255);
        sleepManager = Spot.getInstance().getSleepManager();
        IAT91_PowerManager pm = Spot.getInstance().getAT91_PowerManager();
        
        
        class ButtonListener implements ISwitchListener {
            
            public void switchPressed(SwitchEvent se) {
                led0.setOn();
                triggered = false;
            }

            public void switchReleased(SwitchEvent se) {
            }
        }
        
        ButtonListener bl = new ButtonListener();
        sw1.addISwitchListener(bl);
        
        
        while (triggered) {                  // done when switch is pressed
            Utils.sleep(6000);
        }
        
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
