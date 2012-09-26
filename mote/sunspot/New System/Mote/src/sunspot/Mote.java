package sunspot;

import com.sun.spot.resources.Resources;
import com.sun.spot.resources.transducers.ISwitch;
import com.sun.spot.resources.transducers.ISwitchListener;
import com.sun.spot.resources.transducers.LEDColor;
import com.sun.spot.resources.transducers.ITriColorLEDArray;
import com.sun.spot.resources.transducers.SwitchEvent;
import com.sun.spot.io.j2me.radiogram.*;
import com.sun.spot.util.Utils;

import java.io.*;
import javax.microedition.io.*;
import javax.microedition.midlet.MIDlet;
import javax.microedition.midlet.MIDletStateChangeException;


public class Mote extends MIDlet implements ISwitchListener {

    //MULTICOLOR LEDs
    private ITriColorLEDArray leds = (ITriColorLEDArray)Resources.lookup(ITriColorLEDArray.class);
    private LEDColor[] colors = { LEDColor.RED, LEDColor.GREEN, LEDColor.BLUE };
    //BUTTONS
    private ISwitch sw1 = (ISwitch)Resources.lookup(ISwitch.class, "SW1");
    private ISwitch sw2 = (ISwitch)Resources.lookup(ISwitch.class, "SW2");
    //STATES
    private static final int STATE_INITIALIZING = 0;
    private static final int STATE_SENSING = 1;
    private static final int STATE_TRANSMITTING = 2;
    private int state = STATE_INITIALIZING;
    private int motenum = -1;
    
    
    public void switchReleased(SwitchEvent evt) {
        if (evt.getSwitch() == sw1) {
            //Blink binary mote num
            leds.setOff();
            Utils.sleep(200);
            showCount(motenum, 0);
            Utils.sleep(1000);
            leds.setOff();
            state = STATE_SENSING;
        } else {
            motenum++;
            showCount(motenum, 0);
        }
    }

    public void switchPressed(SwitchEvent evt) { }
    
    
    private void showCount(int count, int color) {
        for (int i = 7, bit = 1; i >= 0; i--, bit <<= 1) {
            if ((count & bit) != 0) {
                leds.getLED(i).setColor(colors[color]);
                leds.getLED(i).setOn();
            } else {
                leds.getLED(i).setOff();
            }
        }
    }
    
    private void showColor(int color) {
        leds.setColor(colors[color]);
        leds.setOn();
    }
    
    protected void startApp() throws MIDletStateChangeException {
        while (true) {
            switch (state) {
                case STATE_INITIALIZING:
                    System.out.println("Initializing");
                    
                    
                    break;
                  
                case STATE_SENSING:
                
                    break;
            
                case STATE_TRANSMITTING:
                
                    break;
            }
        
        }
    }

    protected void pauseApp() {
        // This will never be called by the Squawk VM
    }

    protected void destroyApp(boolean arg0) throws MIDletStateChangeException {
        // Only called if startApp throws any exception other than MIDletStateChangeException
    }
}
