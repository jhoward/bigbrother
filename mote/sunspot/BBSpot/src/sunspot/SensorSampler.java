package sunspot;

//import com.sun.spot.io.j2me.radiogram.*;
import com.sun.spot.peripheral.ISleepManager;
import com.sun.spot.peripheral.Spot;
import com.sun.spot.peripheral.UnableToDeepSleepException;
//import com.sun.spot.sensorboard.EDemoBoard;
//import com.sun.spot.sensorboard.io.*;
//import com.sun.spot.sensorboard.peripheral.ITriColorLED;
//import com.sun.spot.util.Utils;
//import java.util.Calendar;
//import java.util.Date;
import javax.microedition.io.*;
import javax.microedition.midlet.MIDlet;
import javax.microedition.midlet.MIDletStateChangeException;


    
public class SensorSampler extends MIDlet {
    //private static final int DATA_SINK_PORT = 67;
    
    protected void startApp() throws MIDletStateChangeException {
        //Initialize everything.
        //RadiogramConnection rCon = null;
        //Datagram dg = null;
        //String ourAddress = System.getProperty("IEEE_ADDRESS");

        //IScalarInput lightSensor;
        //lightSensor = EDemoBoard.getInstance().getLightSensor();
        //int reading = 0;
        
        ISleepManager sleepManager = Spot.getInstance().getSleepManager();
        long mSleepTime;
        mSleepTime = sleepManager.getMinimumDeepSleepTime();
        mSleepTime = 4000;
        System.out.print("Minimum sleep time ");
        System.out.println(mSleepTime);
        try {
            sleepManager.ensureDeepSleep(mSleepTime + 1);
            System.out.println("Slept deeply.");
        } catch (UnableToDeepSleepException ex) {
            ex.printStackTrace();
        }    
            
            /*
            //This is in miliseconds.
            int readInterval = 200;
            //Calendar cal = Calendar.getInstance();
            //String ts = null;
            ITriColorLED[] leds = EDemoBoard.getInstance().getLEDs();
            //Read sensor values.  If anything changed, send data.
            IIOPin[] ioPins = EDemoBoard.getInstance().getIOPins();

            boolean rs, ls = false;
            int count = 0;
            
            */
            
            //int[] boolValues = new int[5];
            //int[] floatValues = new int[5];

            /*
            
            try {
                rCon = (RadiogramConnection) Connector.open(
                        "radiogram://broadcast:" + DATA_SINK_PORT);
                dg = rCon.newDatagram(rCon.getMaximumLength());
            } catch (Exception e) {
                System.err.println("Caught " + e +
                        " in connection initialization.");
                System.exit(1);
            }

    *       */
            
            //while (true) {
                //reading = lightSensor.getValue();

                // Flash an LED to indicate a sampling event
                /*
                leds[7].setRGB(255, 255, 255);
                leds[7].setOn();
                Utils.sleep(50);
                leds[7].setOff();
                */
                //Read sensor values.  If anything changed, send data.

                //System.out.println("Our radio address = " + reading);
                /*
                cal.setTime(new Date(now));
                ts = cal.get(Calendar.YEAR) + "-" +
                        (1 + cal.get(Calendar.MONTH)) + "-" +
                        cal.get(Calendar.DAY_OF_MONTH) + " " +
                        cal.get(Calendar.HOUR_OF_DAY) + ":" +
                        cal.get(Calendar.MINUTE) + ":" +
                        cal.get(Calendar.SECOND);
                */
                // Package our identifier, timestamp and sensor reading
                // into a radio datagram and send it.
                /*dg.reset();
                dg.writeUTF(ourAddress);
                dg.writeUTF(ts);
                dg.writeInt(reading);
                */  


                /*
                for(int i = 0; i < aInputs.length; i++) {
                    System.out.println(aInputs[i].getValue());
                    //aInputs[i].getValue();
                }
                */
                /*
                rs = ioPins[0].getState();
                ls = ioPins[1].getState();

                System.out.print(count);
                System.out.print("   - ");
                System.out.print(rs);
                System.out.print(" - ");
                System.out.println(ls);
                */
                /*
                for(int i = 0; i < ioPins.length; i++) {
                    int writeVal = 0;

                    if(ioPins[i].isHigh() == true) {
                        writeVal = 1;
                    }

                    if(ioPins[i].isOutput() == true) {
                        writeVal = -1;
                    }

                    dg.writeInt(writeVal);
                }

                rCon.send(dg);
                */
                // Go to sleep to conserve battery
                //Utils.sleep(readInterval);
                //count += 1;

    }

    protected void pauseApp() {
        // This will never be called by the Squawk VM
    }
    
    protected void destroyApp(boolean arg0) throws MIDletStateChangeException {
        // Only called if startApp throws any exception other than MIDletStateChangeException
    }
}
