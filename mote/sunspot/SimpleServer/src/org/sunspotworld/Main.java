/*Radio Client Test Program
 * Main.java
 *
 * Created on Jan 11, 2013 10:33:34 AM;
 * 
 * Author: James Howard
 * 
 * Program to run on server machine using the mote in basestation mode.
 * Extracts all data from motes in a one hop broadcast range.
 * 
 * The program first attempts to listen for a broadcast message and if a 
 * message is recieved from a mote then establish a unicode connection and 
 * grab all mote data saving to a flat file.
 */

package org.sunspotworld;

import com.sun.spot.io.j2me.radiogram.*;
import com.sun.spot.peripheral.radio.RadioFactory;
import com.sun.spot.util.IEEEAddress;
import java.io.ObjectInputStream;
import javax.microedition.io.*;


class ClientConnection extends Thread {
    
    //I am sorry for this solution. I can't copy objects through the constructor
    public String addr;
    public int payload;
    public RadiogramConnection rConn;
    public Datagram dg;
    
    public ClientConnection(Datagram dg) {
        try {
            this.dg = dg;
            this.payload = dg.readInt();
            this.addr = dg.getAddress();
        } catch (Exception e) {
            System.out.println("Problem in constructor.");
        }
    }
     
    public void run() {
        try {
            System.out.println("- addr " + this.addr);
            System.out.println("- mesg - " + this.payload);
            System.out.println("");
            
            //If my payload is leet then unicode connection and data dump
            if(this.payload == 1337) {
                if (connectUnicast()) {
                    sendPing();
                    grabData();
                }
            }
            
            System.out.println("Closing " + this.addr + " connection");
            this.rConn.close();
        } catch(Exception e) {
            System.out.println("No valid message");
        }
    }

    private boolean connectUnicast() {
        try {
            //Unicode connections on port 100
            this.rConn = (RadiogramConnection) Connector.open("radiogram://" + addr + ":100");
            return true;
        } catch (Exception e) {
            System.out.println("unicast failed.");
            try {
                this.rConn.close();
            } catch (Exception stupidException) {
            }
            return false;
        }
    }
    
    private void sendPing() {
        try {
            Datagram dg = this.rConn.newDatagram(this.rConn.getMaximumLength());
            dg.writeInt(1337);
            this.rConn.send(dg);
        } catch (Exception e) {
            System.out.println("sendPing failed.");
        }
    }
    
    private void grabData() {
        try {
            Datagram dg = this.rConn.newDatagram(this.rConn.getMaximumLength());
            this.rConn.setTimeout(1000);
            this.rConn.receive(dg);
            String tmp = dg.readUTF();
            System.out.println("We read " + tmp);
        } catch (Exception e) {
            System.out.println("Error in grabData.");
        }
    }
}


public class Main {

    public void run() {
        
        try {
            RadiogramConnection rCon = (RadiogramConnection) Connector.open("radiogram://:200");
            Datagram dg = rCon.newDatagram(rCon.getMaximumLength());
            
            long ourAddr = RadioFactory.getRadioPolicyManager().getIEEEAddress();
            System.out.println("Data server started on port 200");
            System.out.println("Server address " + IEEEAddress.toDottedHex(ourAddr));
            System.out.println("\n");
            
            // Open up a server-side radiogram connection on port 200
            // to listen for various sunSPOTs
            while(true) {
                dg.reset();
                rCon.receive(dg);
                System.out.println("New message incomming.");
                (new ClientConnection(dg)).start();

            }
            
        } catch (Exception e) {
             System.err.println("setUp caught " + e.getMessage());
        }
        
    }

    /**
     * Start up the host application.
     *
     * @param args any command line arguments
     */
    public static void main(String[] args) {
        
        Main app = new Main();
        System.out.println("Started server.");
        app.run();
    }
}
