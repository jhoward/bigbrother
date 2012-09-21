package sunspot;

import com.sun.spot.resources.Resources;
import com.sun.spot.resources.transducers.ISwitch;
import com.sun.spot.resources.transducers.ISwitchListener;
import com.sun.spot.resources.transducers.LEDColor;
import com.sun.spot.resources.transducers.ITriColorLEDArray;
import com.sun.spot.resources.transducers.SwitchEvent;
import com.sun.spot.io.j2me.radiogram.*;

import java.io.*;
import javax.microedition.io.*;
import javax.microedition.midlet.MIDlet;
import javax.microedition.midlet.MIDletStateChangeException;


public class Mote extends MIDlet implements ISwitchListener {
    private static final int CHANGE_COLOR = 1;
    private static final int CHANGE_COUNT = 2;

    private ITriColorLEDArray leds = (ITriColorLEDArray)Resources.lookup(ITriColorLEDArray.class);
    private ISwitch sw1 = (ISwitch)Resources.lookup(ISwitch.class, "SW1");
    private ISwitch sw2 = (ISwitch)Resources.lookup(ISwitch.class, "SW2");
    private int count = -1;
    private int color = 0;
    private LEDColor[] colors = { LEDColor.RED, LEDColor.GREEN, LEDColor.BLUE };
    private RadiogramConnection tx = null;
    private Radiogram xdg;
    
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
        System.out.println("Broadcast Counter MIDlet");
        showColor(color);
        sw1.addISwitchListener(this);
        sw2.addISwitchListener(this);
        try {
            tx = (RadiogramConnection)Connector.open("radiogram://broadcast:123");
            xdg = (Radiogram)tx.newDatagram(20);
            RadiogramConnection rx = (RadiogramConnection)Connector.open("radiogram://:123");
            Radiogram rdg = (Radiogram)rx.newDatagram(20);
            while (true) {
                try {
                    rx.receive(rdg);
                    int cmd = rdg.readInt();
                    int newCount = rdg.readInt();
                    int newColor = rdg.readInt();
                    if (cmd == CHANGE_COLOR) {
                        System.out.println("Received packet from " + rdg.getAddress());
                        showColor(newColor);
                    } else {
                        showCount(newCount, newColor);
                    }
                } catch (IOException ex) {
                    System.out.println("Error receiving packet: " + ex);
                    ex.printStackTrace();
                }
            }
        } catch (IOException ex) {
            System.out.println("Error opening connections: " + ex);
            ex.printStackTrace();
        }
    }

    protected void pauseApp() {
        // This will never be called by the Squawk VM
    }

    protected void destroyApp(boolean arg0) throws MIDletStateChangeException {
        // Only called if startApp throws any exception other than MIDletStateChangeException
    }

    public void switchReleased(SwitchEvent evt) {
        int cmd;
        if (evt.getSwitch() == sw1) {
            cmd = CHANGE_COLOR;
            if (++color >= colors.length) { color = 0; }
            count = -1;
        } else {
            cmd = CHANGE_COUNT;
            count++;
        }
        try {
            xdg.reset();
            xdg.writeInt(cmd);
            xdg.writeInt(count);
            xdg.writeInt(color);
            tx.send(xdg);
        } catch (IOException ex)  {
            System.out.println("Error sending packet: " + ex);
            ex.printStackTrace();
        }
    }

    public void switchPressed(SwitchEvent evt) {
    }
}
