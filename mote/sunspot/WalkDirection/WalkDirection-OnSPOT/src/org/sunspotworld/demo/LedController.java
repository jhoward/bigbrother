/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.sunspotworld.demo;

import com.sun.spot.resources.transducers.IIOPin;
import com.sun.spot.resources.transducers.ITriColorLED;
import com.sun.spot.resources.transducers.ITriColorLEDArray;
import com.sun.spot.util.Queue;
import com.sun.spot.util.Utils;

class LedController implements Runnable {

    Queue errors;
    IIOPin[] ioPins = null;
    ITriColorLEDArray leds = null;
    
    public LedController(IIOPin[] ioPins) {
        errors = new Queue();
        this.ioPins = ioPins;
    }
    
    public LedController(ITriColorLEDArray leds) {
        errors = new Queue();
        this.leds = leds;
        this.leds.getLED(0).setRGB(255, 0, 0);
        this.leds.getLED(1).setRGB(0, 255, 0);
    }
    
    public void run() {
        while(true) {
           int[] tmp = (int[])errors.get();
           //System.out.println("Size of queue in run:" + errors.size());
           if(ioPins == null) {
               blinkLeds(tmp);
           } else if(leds == null) {
               blinkPins(tmp);
           }
        }
    }
    
    public void addCommand(int lights, int blinks, int delay, int coolDown) {
        /*
         * lights: determine which led is in use.  1 = io3, 2 = io4, 3 = both
         * blinks: number of blinks
         * delay: time between blinks
         * coolDown: time before leds can be used again
         */
        int[] tmp = new int[4];
        
        tmp[0] = lights;
        tmp[1] = blinks;
        tmp[2] = delay;
        tmp[3] = coolDown;
        
        errors.put(tmp);
        //System.out.println("Added command:" + errors.size());
    }
    
    public void addCommand(int[] command) {
        errors.put(command);
    }
    
    private void blinkPins(int[] data) {
        int lights = data[0];
        int blinks = data[1];
        int delay = data[2];
        int coolDown = data[3];
        
        //System.out.println("In Blink Pins   " + lights + "  " + blinks + "  " + delay + "  " + coolDown);
        
        for(int i = 0; i < (2 * blinks); i++) {
            if((i % 2) == 0) { 
                if(lights == 1) {
                    ioPins[3].setLow();
                } else if (lights == 2) {
                    ioPins[4].setLow();
                } else if (lights == 3) {
                    ioPins[3].setLow();
                    ioPins[4].setLow();
                }
            } else {
                if(lights == 1) {
                    ioPins[3].setHigh();
                } else if (lights == 2) {
                    ioPins[4].setHigh();
                } else if (lights == 3) {
                    ioPins[3].setHigh();
                    ioPins[4].setHigh();
                }
            }
                Utils.sleep(delay);
        }
        ioPins[3].setHigh();
        ioPins[4].setHigh();
        
        Utils.sleep(coolDown);
    }
    
    private void blinkLeds(int[] data) {
        int lights = data[0];
        int blinks = data[1];
        int delay = data[2];
        int coolDown = data[3];
        ITriColorLED led0 = leds.getLED(0);
        ITriColorLED led1 = leds.getLED(1);
        
        //System.out.println("In Blink LEDS   " + lights + "  " + blinks + "  " + delay + "  " + coolDown);
        
        for(int i = 0; i < (2 * blinks); i++) {
            if((i % 2) == 0) { 
                if(lights == 1) {
                    led0.setOn();
                } else if (lights == 2) {
                    led1.setOn();
                } else if (lights == 3) {
                    led0.setOn();
                    led1.setOn();
                }
            } else {
                if(lights == 1) {
                    led0.setOff();
                } else if (lights == 2) {
                    led1.setOff();
                } else if (lights == 3) {
                    led0.setOff();
                    led1.setOff();
                }
            }
                Utils.sleep(delay);
        }
        led0.setOff();
        led1.setOff();
        
        Utils.sleep(coolDown);
    }
}