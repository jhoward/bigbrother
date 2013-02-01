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
import javax.microedition.rms.RecordStore;


class RData {
    public long time;
    public short type;
    
    public RData(short type) {
        this.type = type;
        this.time = System.currentTimeMillis(); 
    }
    
    public byte[] serialize() {
        byte[] b = new byte[10];
        for(int i = 0; i < 8; i++) {
            b[i] = (byte)(time >> (8 * (7 - i)) & 0xff);
        }
        b[8] = (byte)((type >> 8) & 0xff);
        b[9] = (byte)(type & 0xff);
        
        return b;
   }
    
   public static long[] deserialize(byte[] data) {
       //This code is wrong.  See RecordData class in WalkDirection
       long ltime = 0;
       long ltype;
       
       for(int i = 0; i < 8; i++) {
           ltime += data[i] << (8 * (7 - i));
       }
       
       ltype = data[8] << 8;
       ltype += data[9];
       
       long[] retType = new long[2];
       retType[0] = ltime;
       retType[1] = ltype;
       
       return retType;
   }
}


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
    RecordStore rms;
    RData tmpData;
    byte[] tmpBytes, tmpRecord;
    IIOPin[] ioPins = EDemoBoard.getInstance().getIOPins();
    int count = 0;
    int lastRecord;
    
    protected void startApp() throws MIDletStateChangeException {
    
        try {
            rms = RecordStore.openRecordStore("Data", true);
        } catch(Exception e) {
        }
        
        leds.getLED(0).setColor(colors[0]);
        leds.getLED(1).setColor(colors[2]);
        ioPins[3].setAsOutput(true);
        ioPins[4].setAsOutput(true);
        
        while(true) {
            if((count % 50) == 0) {
                try {
                    tmpRecord = rms.getRecord(lastRecord);
                    System.out.println("Num Records:" + rms.getNumRecords() + "     " + tmpRecord[tmpRecord.length - 1]);
                } catch(Exception e) {
                }
            }
            p0 = ioPins[0].getState();
            p1 = ioPins[1].getState();

            
            //System.out.println("Check out this place.");
            
            if(p0 == false) {
                //System.out.println("Here we are!!!!");
                ioPins[3].setLow();
                tmpData = new RData((byte)1);
                tmpBytes = tmpData.serialize();
                try {
                    lastRecord = rms.addRecord(tmpBytes, 0, tmpBytes.length);
                } catch(Exception e) {
                }
                //leds.getLED(0).setOn();
            } else {
                ioPins[3].setHigh();
                //leds.getLED(0).setOff();
            }
            
            if(p1 == false) {
                //System.out.println("No We are infact here.");
                ioPins[4].setLow();
                //leds.getLED(1).setOn();
            } else {
                ioPins[4].setHigh();
                //leds.getLED(1).setOff();
            }
            
            //System.out.print(ioPins[0].getState() + "    ");
            //System.out.println(ioPins[4].getState());
            
            Utils.sleep(40);
            count += 1;
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
