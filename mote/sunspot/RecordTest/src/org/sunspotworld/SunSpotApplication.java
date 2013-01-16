/*
 * SunSpotApplication.java
 *
 * Created on Jan 15, 2013 3:51:43 PM;
 */

package org.sunspotworld;

import com.sun.spot.resources.Resources;
import com.sun.spot.resources.transducers.ITriColorLEDArray;
import javax.microedition.midlet.MIDlet;
import javax.microedition.midlet.MIDletStateChangeException;
import javax.microedition.rms.RecordStore;

class RData {
    public long time;
    public short type;
    
    public RData(short type) {
        this.type = type;
        this.time = System.currentTimeMillis(); 
        System.out.println("Added record at " + this.time);
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



public class SunSpotApplication extends MIDlet {

    private ITriColorLEDArray leds = (ITriColorLEDArray) Resources.lookup(ITriColorLEDArray.class);
    RecordStore rms;
    
    protected void startApp() throws MIDletStateChangeException {
        
        RData tmpData;
        System.out.println("Staring Record test.");

        try {
            rms = RecordStore.openRecordStore("Data", true);
            System.out.println("Initial Records " + rms.getNumRecords());
            tmpData = new RData((short)1);
            int tmpRecord = rms.addRecord(tmpData.serialize(), 0, 10);
            System.out.println("After Records " + rms.getNumRecords());
            byte[] data = rms.getRecord(tmpRecord);
            long[] tmpVals = RData.deserialize(data);
            System.out.println("Recovered data: " + tmpVals[0] + "    " + tmpVals[1]);
        } catch(Exception e) {
        }
        notifyDestroyed();                      // cause the MIDlet to exit
    }

    protected void pauseApp() {
        // This is not currently called by the Squawk VM
    }

    protected void destroyApp(boolean unconditional) throws MIDletStateChangeException {
    }
}
