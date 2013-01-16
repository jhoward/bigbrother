/*
 * Main.java
 *
 * Created on Jan 9, 2013 3:24:21 PM;
 */

package org.sunspotworld;

import com.sun.spot.io.j2me.radiogram.RadiogramConnection;
import com.sun.spot.peripheral.radio.RadioFactory;
import com.sun.spot.resources.Resources;
import com.sun.spot.resources.transducers.ITriColorLEDArray;
import com.sun.spot.resources.transducers.LEDColor;
import com.sun.spot.service.BootloaderListenerService;
import com.sun.spot.util.IEEEAddress;
import com.sun.spot.util.Utils;
import javax.microedition.io.Connector;
import javax.microedition.io.Datagram;
import javax.microedition.midlet.MIDlet;
import javax.microedition.midlet.MIDletStateChangeException;

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
    private static final int LOCAL_PORT = 100;
    private static final int BROADCAST_PORT = 200;
   
    protected void startApp() throws MIDletStateChangeException {
        leds.getLED(0).setColor(colors[0]);
        leds.getLED(1).setColor(colors[1]);
        leds.getLED(2).setColor(colors[2]);
        
        
        BootloaderListenerService.getInstance().start();   // monitor the USB (if connected) and recognize commands from host

        long ourAddr = RadioFactory.getRadioPolicyManager().getIEEEAddress();
        System.out.println("Our radio address = " + IEEEAddress.toDottedHex(ourAddr));
        
        //Listen for incomming connections.
        try {
            RadiogramConnection outConn = (RadiogramConnection) Connector.open("radiogram://broadcast:200");
            Datagram odg = outConn.newDatagram(outConn.getMaximumLength());
            System.out.println("After connection.");
            //Send twice due to unreliable broadcasts
            odg.writeInt(1337);
            //odg.writeInt(7);
            outConn.send(odg);
            //outConn.send(odg);
            leds.getLED(2).setOn();
            
            RadiogramConnection inConn = (RadiogramConnection) Connector.open("radiogram://:" + LOCAL_PORT);
            Datagram dg = inConn.newDatagram(inConn.getMaximumLength());
            inConn.setTimeout(1000);
            inConn.receive(dg);
            dg.reset();
            dg.writeUTF("Please work... Oh please work.");
            inConn.send(dg);
            leds.getLED(1).setOn();
            
        } catch (Exception e) {
            System.out.println("Timeout.");
            leds.getLED(0).setOn();
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
