package org.sunspotworld;

import com.sun.spot.io.j2me.radiogram.*;
import com.sun.spot.sensorboard.EDemoBoard;
import com.sun.spot.sensorboard.io.*;
import com.sun.spot.sensorboard.peripheral.ITriColorLED;
import com.sun.spot.util.Utils;
import java.util.Calendar;
import java.util.Date;
import javax.microedition.io.*;
import javax.microedition.midlet.MIDlet;
import javax.microedition.midlet.MIDletStateChangeException;


public class Main extends MIDlet {
    protected void startApp() throws MIDletStateChangeException {
        //This is in miliseconds.
        int readInterval = 500;
        int counter = 0;
        boolean rs, ls;
        ITriColorLED[] leds = EDemoBoard.getInstance().getLEDs();
        IIOPin[] ioPins = EDemoBoard.getInstance().getIOPins();
        leds[7].setRGB(255, 255, 255);
        int walkState = 0; // 0 = nothing, 1 = walkLeft 2 = walkRight 5 = wait for reset.
        int lagTime = 8;
        int lsCount, rsCount;
        rsCount = 0;
        lsCount = 0;
        
        while (true) {
        
            //Constant LED to indicate running
            if (counter % 10 == 0) {
                if (leds[7].isOn()) {
                    leds[7].setOff();
                } else {
                    leds[7].setOn();
                }
            }

            rs = ioPins[0].getState();
            ls = ioPins[1].getState();

            
            
            if (rs && ls) {
                if (walkState == 5) {
                    System.out.println("Reset");
                    walkState = 0;
                    rsCount = 0;
                    lsCount = 0;
                }
            }
            
            if (walkState == 0) {
                if (!rs && ls)  {
                    lsCount = lagTime;
                    //System.out.println("WalkState 1");
                    walkState = 1;
                }
                if (!ls && rs) {
                    //System.out.println("WalkState 2");
                    rsCount = lagTime;
                    walkState = 2;
                }
                
                if (!ls && !rs) {
                    walkState = 5;
                    System.out.println("Too fast walk detected.");
                }
            }
            
            if (walkState == 1) {
                if (!ls) {
                    System.out.println("Walked left detected.");
                    walkState = 5;
                    lsCount = 0;
                }
            }
            
            if (walkState == 2) {
                if (!rs) {
                    System.out.println("Walked right detected.");
                    walkState = 5;
                    rsCount = 0;
                }
            }

            if (rsCount > 0) {
                rsCount -= 1;
            }
            
            if (lsCount > 0) {
                lsCount -= 1;
            }
        
            if (rsCount == 0 && lsCount == 0 && (walkState == 1 || walkState == 2)) {
                System.out.print("Bad Event detected:  ");
                System.out.println(walkState);
                walkState = 5;
            }
            
            
            // Go to sleep to conserve battery
            Utils.sleep(100);
            counter += 1;
        }
    }
    
    protected void pauseApp() {
        // This will never be called by the Squawk VM
    }
    
    protected void destroyApp(boolean arg0) throws MIDletStateChangeException {
        // Only called if startApp throws any exception other than MIDletStateChangeException
    }
}
