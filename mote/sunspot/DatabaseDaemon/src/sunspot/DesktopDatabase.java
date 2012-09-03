package sunspot;

import com.sun.spot.io.j2me.radiogram.*;
import com.sun.spot.peripheral.TimeoutException;
import javax.microedition.io.*;

public class DesktopDatabase {

    //Set the constants.
    private static final int DATA_SINK_PORT = 67;
    private static final int CONNECTION_TIMEOUT = 10000;
    private static final int SAMPLING_DURATION = 60000;

    private RadiogramConnection rCon = null;
    private sunspot.DatabaseController dbCon = null;

    public void run() {

        try {
            initialize();
            collectData();
        } catch (Exception e) {
          System.out.println("We got an exception:" + e);
        }

        System.exit(0);
    }

    public void initialize() throws Exception {

        try {
            rCon = (RadiogramConnection) Connector.open("radiogram://:" + DATA_SINK_PORT);
            rCon.setTimeout(CONNECTION_TIMEOUT);

            //dbCon = new sunspot.DatabaseController();
        } catch (Exception e) {
             System.err.println("error with initialization: " + e.getMessage());
             throw e;
        }
    }

    public void collectData() throws Exception {
        String id = null;
        String ts = null;
        int val = 0;
        int numPackets = 0;
        Datagram dg = null;

        dg = rCon.newDatagram(rCon.getMaximumLength());

        // Main data collection loop
        while (numPackets < 2000) {
            try {
                // Read sensor sample received over the radio
                rCon.receive(dg);
                id = dg.readUTF();  // read sender's Id
                ts = dg.readUTF();  // read time stamp for the reading
                val = dg.readInt(); // read the sensor value

                //Read the other ints
                int a0 = dg.readInt();
                int a1 = dg.readInt();
                int a2 = dg.readInt();
                int a3 = dg.readInt();
                int a4 = dg.readInt();
                //int a5 = dg.readInt();

                System.out.println("Id:" + id + "   TS:" + ts + " Val:" + val +
                        " aI -- " + a0 + " ," + a1 + " ," + a2 + " ," +
                        a3 + " ," + a4);// + " ," + a5);
                System.out.println("*");

                numPackets++;

                //Write to database.
                //dbCon.addEntry(ts, 2, 2, val, "light", "");

            } catch (TimeoutException e) {
                System.err.println("!");
            } catch (Exception e) {
                System.err.println("Caught " + e +
                        " while reading sensor samples.");
                throw e;
            }
        }
    }

    /**
     * Start up the host application.
     *
     * @param args any command line arguments
     */
    public static void main(String[] args) {
        DesktopDatabase app = new DesktopDatabase();
        app.run();
    }
}
