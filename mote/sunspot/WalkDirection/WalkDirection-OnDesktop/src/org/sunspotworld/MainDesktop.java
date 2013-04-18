package org.sunspotworld;

import com.sun.spot.io.j2me.radiogram.RadiogramConnection;
import com.sun.spot.peripheral.radio.RadioFactory;
import com.sun.spot.util.IEEEAddress;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Scanner;
import javax.microedition.io.Connector;
import javax.microedition.io.Datagram;

class ClientConnection extends Thread {
    
    public String addr;
    public RecordData payload;
    public RadiogramConnection rConn;
    
    public ClientConnection(Datagram dg) {
        this.payload = RecordData.deserialize(dg);
        this.addr = dg.getAddress();
    }
     
    public void run() {
        
        boolean dataMode = true;
        
        ArrayList data;
        Scanner input=new Scanner(System.in);
        
        try {
            System.out.println("New connection from " + this.addr);
            
            //If my payload is leet then unicode connection and data dump
            if(payload.type == Const.BROADCAST) {
                if (connectUnicast()) {
                    if (dataMode){
                        sendRequestDataCommand();
                        data = recieveData();
                        writeData(data);                       
                    }
                    else {
                        sendTimeOffset();
                    }
                }
                else { // kolten - added
                    System.out.println("Exiting...");
                    return;
                }
            }
            
            if (dataMode){
                System.out.println("Do you want to delete buffered data? (y/n)");
                String ans = input.next();
            
                if("y".equals(ans)) {
                    sendDeleteCommand();
                } else {
                    sendNoDeleteCommand();
                }
            }
            
            System.out.println("Closing " + this.addr + " connection");
            this.rConn.close();
        } catch(Exception e) {
            System.out.println("No valid message");
            System.out.println(e);
        }
    }
    
    private void writeData(ArrayList data) {
        try {
            FileWriter writer = new FileWriter(Const.DATA_DIRECTORY + this.addr + ".txt", true); 

            for(int i = 0; i < data.size(); i++) {
                RecordData tmp = (RecordData)data.get(i);
                writer.write(tmp.toString() + "\n");
            }
            writer.close();
        } catch (Exception e) {
            System.out.println("Problems writing data to file.");
            System.out.println(e);
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
    
    private void sendRequestDataCommand() {
        try {
            Datagram dg = this.rConn.newDatagram(this.rConn.getMaximumLength());
            RecordData rd = new RecordData(Const.DATA_DUMP, (short)0);
            dg.write(rd.serialize());
            this.rConn.send(dg);
        } catch (Exception e) {
            System.out.println("sendPing failed.");
        }
    }
    
    private void sendTimeOffset() {
        try {
            System.out.println("Sending system time offset to mote...");
            Datagram dg = this.rConn.newDatagram(this.rConn.getMaximumLength());
            RecordData rd = new RecordData(System.currentTimeMillis(),Const.TIME_DUMP, (short)0);
            dg.write(rd.serialize());
            this.rConn.send(dg);
            System.out.println("Sent time offset to mote");
        } catch (Exception e) {
            System.out.println("sendPing failed.");
        }
    }
    
    private void sendDeleteCommand() {
        try {
            Datagram dg = this.rConn.newDatagram(this.rConn.getMaximumLength());
            RecordData tmpData = new RecordData(Const.DELETE_RECORDS, (short)0);
            dg.write(tmpData.serialize());
            this.rConn.send(dg);
        } catch(Exception e) {
            System.out.println("Problems with send delete command");
            System.out.println(e);
        }
    }
    
    private void sendNoDeleteCommand() {
        try {
            Datagram dg = this.rConn.newDatagram(this.rConn.getMaximumLength());
            RecordData tmpData = new RecordData(Const.NO_DELETE_RECORDS, (short)0);
            dg.write(tmpData.serialize());
            this.rConn.send(dg);
        } catch(Exception e) {
            System.out.println("Problems with send no delete command");
            System.out.println(e);
        }
    }
    
    private ArrayList recieveData() {
        
        ArrayList data = new ArrayList();
        boolean EOF = false;
        int counter = 0;
        RecordData deserialData;
        
        try {
            Datagram dg = this.rConn.newDatagram(this.rConn.getMaximumLength());
            this.rConn.setTimeout(2000);
            
            while(EOF == false){
                this.rConn.receive(dg);
                counter += 1;
                
                deserialData = RecordData.deserialize(dg);
                
                if((short)deserialData.type != Const.EOF) {
                    data.add(deserialData);
                } else if((short)deserialData.type == Const.EOF) {
                    //System.out.println("Got end of file.");
                    EOF = true;
                }
            }
        } catch (Exception e) {
            System.out.println("Error in grabData. ");
            System.out.println("Recieved " + counter + " packets");
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