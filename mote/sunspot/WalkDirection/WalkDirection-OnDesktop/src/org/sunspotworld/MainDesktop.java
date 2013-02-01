package org.sunspotworld;

import com.sun.spot.io.j2me.radiogram.RadiogramConnection;
import com.sun.spot.peripheral.radio.RadioFactory;
import com.sun.spot.util.IEEEAddress;
import java.io.FileWriter;
import java.util.ArrayList;
import javax.microedition.io.Connector;
import javax.microedition.io.Datagram;

class ClientConnection extends Thread {
    
    public String addr;
    public int payload;
    public RadiogramConnection rConn;
    
    public ClientConnection(Datagram dg) {
        try {
            this.payload = dg.readInt();
            this.addr = dg.getAddress();
        } catch (Exception e) {
            System.out.println("Problem in constructor.");
        }
    }
     
    public void run() {
        ArrayList data;
        try {
            System.out.println("New connection from " + this.addr);
            
            //If my payload is leet then unicode connection and data dump
            if(this.payload == 1337) {
                if (connectUnicast()) {
                    sendPing();
                    data = grabData();
                    
                    //Write to file with name of this.addr
                    FileWriter writer = new FileWriter(Const.DATA_DIRECTORY + this.addr, true); 
                    
                    for(int i = 0; i < data.size(); i++) {
                        Integer tmp = (Integer)data.get(i);
                        writer.write(tmp);
                    }
                    writer.close();                    
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
            //Unicode connections on LOCAL_PORT
            this.rConn = (RadiogramConnection) Connector.open("radiogram://" + addr + ":" + Const.LOCAL_PORT);
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
            dg.writeShort(Const.DATA_DUMP);
            this.rConn.send(dg);
        } catch (Exception e) {
            System.out.println("sendPing failed.");
        }
    }
    
    private ArrayList grabData() {
        
        ArrayList data = new ArrayList();
        boolean EOF = false;
        
        try {
            Datagram dg = this.rConn.newDatagram(this.rConn.getMaximumLength());
            this.rConn.setTimeout(2000);
            
            while(EOF == false){
                this.rConn.receive(dg);
                System.out.println("Got data.");
                
                byte[] tmpD = new byte[10];
                //dg.readFully(tmpD, 0, 10);
                dg.readFully(tmpD);
                
                System.out.println(tmpD);
                System.out.println(tmpD[8]);
                System.out.println(tmpD[9]);
                if(tmpD[9] != Const.EOF) {
                    //deserialize data
                    data.add(new Integer(1));
                } else if(tmpD[9] == Const.EOF) {
                    System.out.println("Got end of file.");
                    EOF = true;
                }
            }
        } catch (Exception e) {
            System.out.println("Error in grabData. ");
            System.out.println(e);
        }
        
        System.out.println("Total data downloaded " + data.size());
        return data;
    }
}


public class MainDesktop {

    public void run() {
        
        try {
            //Listen for data
            RadiogramConnection rCon = (RadiogramConnection) Connector.open("radiogram://:" + Const.BROADCAST_PORT);
            Datagram dg = rCon.newDatagram(rCon.getMaximumLength());
            
            long ourAddr = RadioFactory.getRadioPolicyManager().getIEEEAddress();
            System.out.println("Data server started on port " + Const.BROADCAST_PORT);
            System.out.println("Server address " + IEEEAddress.toDottedHex(ourAddr));
            System.out.println("\n");
            
            // Open up a server-side radiogram connection on BROADCAST_PORT
            // to listen for various sunSPOTs
            while(true) {
                dg.reset();
                rCon.receive(dg);
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
        
        MainDesktop app = new MainDesktop();
        System.out.println("Started server.");
        app.run();
    }
}