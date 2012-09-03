package sunspot;

import com.sun.spot.sensorboard.EDemoBoard;
import com.sun.spot.sensorboard.io.*;
import com.sun.spot.io.j2me.radiogram.*;
import com.sun.spot.sensorboard.peripheral.ITriColorLED;
import com.sun.spot.util.Utils;
import java.util.Calendar;
import java.util.Date;
import javax.microedition.io.*;
import javax.microedition.midlet.MIDlet;
import javax.microedition.midlet.MIDletStateChangeException;


public class SensorSampler extends MIDlet {
    private static final int DATA_SINK_PORT = 67;
    
    protected void startApp() throws MIDletStateChangeException {
        //Initialize everything.
        RadiogramConnection rCon = null;
        Datagram dg = null;
        String ourAddress = System.getProperty("IEEE_ADDRESS");
        long now = 0L;
        long reset = 0L;
        IScalarInput lightSensor =  EDemoBoard.getInstance().getLightSensor();
        int reading = 0;
        //This is in miliseconds.
        int readInterval = 1000;
        Calendar cal = Calendar.getInstance();
        String ts = null;
        ITriColorLED[] leds = EDemoBoard.getInstance().getLEDs();
        IScalarInput[] aInputs = EDemoBoard.getInstance().getScalarInputs();
        IIOPin[] ioPins = EDemoBoard.getInstance().getIOPins();

        int[] boolValues = new int[5];
        int[] floatValues = new int[5];

        try {
            rCon = (RadiogramConnection) Connector.open(
                    "radiogram://broadcast:" + DATA_SINK_PORT);
            dg = rCon.newDatagram(rCon.getMaximumLength());
        } catch (Exception e) {
            System.err.println("Caught " + e +
                    " in connection initialization.");
            System.exit(1);
        }

        reset = System.currentTimeMillis() + readInterval;

        while (true) {
            try {
                now = System.currentTimeMillis();

                if (now > reset) {

                    reading = lightSensor.getValue();

                    // Flash an LED to indicate a sampling event
                    leds[7].setRGB(255, 255, 255);
                    leds[7].setOn();
                    Utils.sleep(50);
                    leds[7].setOff();

                    //Read sensor values.  If anything changed, send data.

                    cal.setTime(new Date(now));
                    ts = cal.get(Calendar.YEAR) + "-" +
                            (1 + cal.get(Calendar.MONTH)) + "-" +
                            cal.get(Calendar.DAY_OF_MONTH) + " " +
                            cal.get(Calendar.HOUR_OF_DAY) + ":" +
                            cal.get(Calendar.MINUTE) + ":" +
                            cal.get(Calendar.SECOND);

                    // Package our identifier, timestamp and sensor reading
                    // into a radio datagram and send it.
                    dg.reset();
                    dg.writeUTF(ourAddress);
                    dg.writeUTF(ts);
                    dg.writeInt(reading);
                       /*
                    for(int i = 0; i < aInputs.length; i++) {
                        dg.writeInt(aInputs[i].getValue());
                    }
                     */
                    
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

                    // Go to sleep to conserve battery
                    reset = now + readInterval;
                }
            } catch (Exception e) {
                System.err.println("Caught " + e +
                        " while collecting/sending sensor sample.");
                e.printStackTrace();
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
