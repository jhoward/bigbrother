/*
 * MainSpot.java
 * 
 * Author: James Howard
 * 01/16/2013
 * 
 * On Mote program to detect the direction of walking over open spaces.
 */

package org.sunspotworld.demo;

import com.sun.spot.io.j2me.radiogram.RadiogramConnection;
import com.sun.spot.peripheral.ISleepManager;
import com.sun.spot.peripheral.Spot;
import com.sun.spot.peripheral.radio.IRadioPolicyManager;
import com.sun.spot.peripheral.radio.RadioFactory;
import com.sun.spot.resources.transducers.IIOPin;
import com.sun.spot.resources.transducers.IInputPinListener;
import com.sun.spot.resources.transducers.ITriColorLEDArray;
import com.sun.spot.resources.transducers.InputPinEvent;
import com.sun.spot.sensorboard.EDemoBoard;
import com.sun.spot.util.IEEEAddress;
import com.sun.spot.util.Queue;
import com.sun.spot.util.Utils;
import javax.microedition.io.Connector;
import javax.microedition.io.Datagram;
import javax.microedition.midlet.MIDlet;
import javax.microedition.midlet.MIDletStateChangeException;


class PinListener implements IInputPinListener {
    
    Queue q;
    int pin;
    
    public PinListener(Queue q, int pin) {
        this.q = q;
        this.pin = pin;
    }
    
    public PinListener(Queue q) {
        this.q = q;
        this.pin = 10;
    }
    
    public void pinSetHigh(InputPinEvent evt) {
        //System.out.println("Pin " + evt.getInputPin() + "  to high.");
    }

    public void pinSetLow(InputPinEvent evt) {
        //System.out.println("Test.");
        
        if(this.q.isEmpty()) {
            //System.out.println("Pin " + evt.getInputPin() + "  to low.");
        }
        
        q.put(new Integer(this.pin));
    }
}

class MidSensorReader implements Runnable {
    
    RecordHandler records = null;
    IIOPin io = null;
    LedController ledc = null;
    int pf;
    
    public MidSensorReader(RecordHandler records, 
                               IIOPin io, LedController ledc) {
        this.records = records;
        this.io = io;
        this.ledc = ledc;
    }
    
    public void run() {
        
        int sleepSum = 0;
        int counts = 0;
        
        while(true) {
            if(io.getState() == false) {
                counts += 1;
            }
            sleepSum += Const.MID_SENSOR_POLL_FREQUENCY;
            
            if(sleepSum >= Const.MID_SENSOR_COUNT_TIME) {
                //records.addRecord(Const.ROOM_COUNT, counts); commented out because doesnt comply with new addrecord function
                counts = 0;
                sleepSum = 0;
            }
            
            Utils.sleep(Const.MID_SENSOR_POLL_FREQUENCY);
        }
    }
}



public class MainSPOT extends MIDlet {
        
    private IIOPin[]        ioPins; 
    private LedController   ledc;
    private Thread          ledThread;
    private ISleepManager   sleepManager;
    private RecordHandler   records;
    //private PinListener     pinListener;
    private PinListener     pinListenerFront;
    private PinListener     pinListenerBack;
    private Thread          midSensorThread;
    private MidSensorReader msr;
    private Queue           triggers;
    private int             state;
    private IIOPin          frontSensor, backSensor;
    private ITriColorLEDArray leds;
    
    private long timeOffset = 0; //ADDED - KOLTEN - To correct sunspot system onboard time when writing records
    private boolean useOffset;  //ADDED to control when to use the offset
    
    long outputTime;
    
    private long myCurrentTime;
    private long myFirstTime;
    private int numberOfJumps;
    
    
    protected void startApp() throws MIDletStateChangeException {
        
        long ourAddr = RadioFactory.getRadioPolicyManager().getIEEEAddress();
        System.out.println("Our radio address = " + IEEEAddress.toDottedHex(ourAddr));
        setup();
        
        if (handleNetworkCommands()){
            System.out.println("Data collection finished, exiting..."); // ADDED kolten
            return;
        }
        
        long timeoutCounter = 0;
        
        boolean fs, bs;
        
        boolean reportLength = false;   //ADDED for printing out the delay time for cooldown state
        int CONSOLWIDTH = 80;           //ADDED for formatting output to screen for pretty display

        sleepManager.disableDeepSleep();
        System.out.println("Disabled deep sleep");
        System.out.println("***PROGRAM READY***");
        
        ledc.addCommand(Const.LED_PROGRAM_READY);
        
        try {
            while(true) {
              // System.out.println("Waiting for trigger.");
               int trigger = ((Integer)triggers.get()).intValue();
             //  System.out.println("Trigger:" + trigger);

               if(trigger == Const.BACK_SENSOR) {
                   state = Const.BACK_TRIGGER_STATE;
               } else if(trigger == Const.FRONT_SENSOR) {
                   state = Const.FRONT_TRIGGER_STATE;
               }               
               outputTime = 0;
               numberOfJumps = 0;
               
               while(state != Const.WAITING_STATE) {
                   
                   
                   
                   //System.out.println("In while loop.");
                   fs = frontSensor.getState();
                   bs = backSensor.getState();   
                   //System.out.println(fs + " " + bs + "\n"); debugging line for sensor statess

                   if (useOffset){
                       myCurrentTime = System.currentTimeMillis()+timeOffset;
                   }
                   else {
                       myCurrentTime = System.currentTimeMillis();
                   }
                   
                   if ((timeoutCounter >= Const.DOWN_SENSORS_RESET_TIMEOUT) && 
                           (state != Const.COOLDOWN_STATE)) {
                       state = Const.COOLDOWN_STATE;
                //       System.out.println("Movement timeout");
                       //TODO blink error code
                   }

                  if((state == Const.COOLDOWN_STATE) && fs && bs && ( (myCurrentTime - myFirstTime)>1000 ) ) {
                       state = Const.WAITING_STATE;
                       if (reportLength){
                           
                            if (useOffset){
                                timeoutCounter = (System.currentTimeMillis()+timeOffset - outputTime);
                            }
                            else {
                                timeoutCounter = (System.currentTimeMillis() - outputTime);
                            }
                           
                           
                        System.out.print("   TIMEOUT: "+timeoutCounter); //if an enter or exit state triggered, print 'length'
                        System.out.print("*\n");
                        for(int i = 0; i < CONSOLWIDTH ; i++) {
                                System.out.print("*");
                            }
                        System.out.println("");
                        System.out.println("");
                        reportLength = false;
                        
                        
                        records.addRecord(timeoutCounter,Const.EVENT_TIMEOUT,0);
                        
                        System.out.println("\nNumber of jumps: "+numberOfJumps+"\n");
                        records.addRecord(numberOfJumps, Const.EVENT_JUMPS,0);
                        
                       }
                       break; // ADDED - KOLTEN
                   }

                   if((state == Const.BACK_TRIGGER_STATE) && (fs == false)) {
                       if (timeoutCounter == 0) {  //added if-else - KOLTEN
                   //        System.out.println("TOO FAST WALK");
                           state = Const.WAITING_STATE;
                           break;
                       }
                       else {
                            state = Const.COOLDOWN_STATE;
                            //records.addRecord(Const.EXIT, 0);   removed to add a record class with time offset
                            if (useOffset){
                                myFirstTime = System.currentTimeMillis()+timeOffset;
                                records.addRecord(System.currentTimeMillis()+timeOffset,Const.EXIT,0);
                            }
                            else {
                                myFirstTime = System.currentTimeMillis();
                                records.addRecord(System.currentTimeMillis(), Const.EXIT, 0);
                            }
                            ledc.addCommand(Const.LED_EXIT);
                            //System.out.println("Exit");
                            
                            for(int i = 0; i < CONSOLWIDTH ; i++) {
                                System.out.print("*");
                            }
                            System.out.print("\n");
                            
                            if (useOffset){
                                outputTime = System.currentTimeMillis()+timeOffset;
                            }
                            else {
                                outputTime = System.currentTimeMillis();
                            }
                            System.out.print("*RECORD TYPE: EXIT    TIMESTAMP: "+outputTime);
                            
                            Utils.sleep(Const.WAIT_AFTER_WALK);
                            reportLength = true;
                       }
                   }

                   if((state == Const.FRONT_TRIGGER_STATE) && (bs == false)) {
                       if (timeoutCounter == 0) {  //added if-else - kolten
                   //        System.out.println("TOO FAST WALK");
                           state = Const.WAITING_STATE;
                           break;
                       }
                       else{
                            state = Const.COOLDOWN_STATE;
                            //records.addRecord(Const.ENTER, 0); removed to add a record class with time offset
                            if (useOffset){
                                myFirstTime = System.currentTimeMillis()+timeOffset;
                                records.addRecord(System.currentTimeMillis()+timeOffset, Const.ENTER, 0);
                            }
                            else {
                                myFirstTime = System.currentTimeMillis();
                                records.addRecord(System.currentTimeMillis(), Const.ENTER, 0);
                            }
                            ledc.addCommand(Const.LED_ENTER);
                            //System.out.println("Enter");
                            
                            
                            for(int i = 0; i < CONSOLWIDTH ; i++) {
                                System.out.print("*");
                            }
                            System.out.print("\n");
                            
                            if (useOffset){
                                outputTime = System.currentTimeMillis()+timeOffset;
                            }
                            else {
                                outputTime = System.currentTimeMillis();
                            }
                            System.out.print("*RECORD TYPE: ENTER   TIMESTAMP: "+outputTime);
                            
                            
                            Utils.sleep(Const.WAIT_AFTER_WALK);
                            reportLength = true;
                       }
                   }

                   Utils.sleep(Const.DOWN_SENSORS_POLL_FREQUENCY);
                   timeoutCounter += Const.DOWN_SENSORS_POLL_FREQUENCY;
                   
                   if (frontSensor.getState() != fs) {
                       numberOfJumps +=1;
                   }
                   if (backSensor.getState() != bs){
                       numberOfJumps +=1;
                   }
               }
               
               myFirstTime = 0;
               myCurrentTime = 0;
               
               timeoutCounter = 0;
               triggers.empty();
              // ledc.addCommand(Const.LED_RESET);
           //    System.out.println("Reset");
            }
        } catch(Exception e) {
            //Crash state.  Mote needs to be reset.
            System.out.println("Crashed!!!!");
            while(true) {
                ledc.addCommand(Const.LED_CRASH);
                Utils.sleep(10000);
            }
        }
        
        
        
        //notifyDestroyed();                      // cause the MIDlet to exit
    }
    
    protected void setup() {
        try {
            ioPins = EDemoBoard.getInstance().getIOPins();
            ioPins[Const.RED_LED].setAsOutput(true);
            ioPins[Const.BLUE_LED].setAsOutput(true);
            ioPins[Const.RED_LED].setHigh();
            ioPins[Const.BLUE_LED].setHigh();
            frontSensor = ioPins[Const.FRONT_SENSOR];
            backSensor = ioPins[Const.BACK_SENSOR];

            sleepManager = Spot.getInstance().getSleepManager();
            sleepManager.enableDeepSleep();
            
            //leds = (ITriColorLEDArray) Resources.lookup(ITriColorLEDArray.class);
            ledc = new LedController(ioPins);
            //ledc = new LedController(leds);
            ledThread = new Thread(ledc);
            ledThread.start();

            records = new RecordHandler(Const.RECORD_NAME);
            
            triggers = new Queue();
            state = Const.WAITING_STATE;
            
            pinListenerFront = new PinListener(triggers, Const.FRONT_SENSOR);
            pinListenerBack = new PinListener(triggers, Const.BACK_SENSOR);
            frontSensor.addIInputPinListener(pinListenerFront);
            backSensor.addIInputPinListener(pinListenerBack);
            
            msr = new MidSensorReader(records, ioPins[Const.MID_SENSOR], ledc);
            midSensorThread = new Thread(msr);
                        
            System.out.println("Saved mote records " + records.getNumRecords());
        } catch (Exception e) {
            System.out.println("Setup error.");
            System.out.println(e);
            ledc.addCommand(Const.LED_SETUP_ERROR);
        }
    }
    
    public boolean handleNetworkCommands() {     
        
        RadiogramConnection inConn = null;
        Datagram dg;
        
        broadcast();
        
        boolean data = false;
        
        //Now wait for a response and perform the specified action
        try {
            System.out.println("Waiting for response.");
            inConn = (RadiogramConnection) Connector.open("radiogram://:" + Const.LOCAL_PORT);
            dg = inConn.newDatagram(inConn.getMaximumLength());
           //inConn.setTimeout(2000); //time out for if broadcast response recieved
           inConn.receive(dg);
           RecordData tmpData = RecordData.deserialize(dg);
            
            //dump data
            if (tmpData.type == Const.DATA_DUMP) {
                if (transmitData(inConn, dg)) {
                    if (recieveDeleteData(inConn, dg)) {
                        System.out.println("Deleting records.");
                        records.deleteRecords(Const.RECORD_NAME);
                    }
                } else {
                    System.out.println("Data did not transmit fully.");
                }
                data = true;
            }
            else if (tmpData.type == Const.TIME_DUMP){
                timeOffset = tmpData.time;
                System.out.println("The recieved system time was: " + timeOffset);
                System.out.println("The internal mote time is: " + System.currentTimeMillis());
                if (System.currentTimeMillis()/100 < 315360000){ //if on board time is less than a year dont use offset
                    System.out.println("The offset will be used");
                    useOffset = true;
                }
                else {
                    System.out.println("The offset will not be used");
                    useOffset = false;
                }
            }
        } catch (Exception e) {
            System.out.println("Timeout.");
            System.out.println(e);
        }

        
        //Now close and turn off radio
        try {
            System.out.println("Closing connections.");
            inConn.close();
            IRadioPolicyManager rpm = Spot.getInstance().getRadioPolicyManager();
            rpm.setRxOn(false);
        } catch(Exception e) {
            System.out.println("Closing radio error.");
        }
        
        return data;
    }
    
    
    public boolean recieveDeleteData(RadiogramConnection inConn, Datagram dg) {
        try {
            //Wait for delete
            dg.reset();
            inConn.setTimeout(20000);
            System.out.println("Waiting for response to delete records.");
            inConn.receive(dg);
            RecordData rd = RecordData.deserialize(dg);
            
            if (rd.type == Const.DELETE_RECORDS) {
                return true;
            }
            if (rd.type == Const.NO_DELETE_RECORDS) {
                return false;
            }
        } catch (Exception e) {
            System.out.println("Must have been a timeout.");
        }
        return false;
    }

    
    
    public boolean transmitData(RadiogramConnection inConn, Datagram dg) {
        int counter = 0;
        records.rebuildEnumerator();
        byte[] tmp = records.getNextRecord();
        
        try {
            while(tmp != null) {
                ledc.addCommand(Const.LED_DATA);
                dg.reset();
                dg.write(tmp);
                inConn.send(dg);
                tmp = records.getNextRecord();
                counter += 1;
            }
            System.out.println("Sent " + counter + " records");
            
            dg.reset();
            RecordData tmpRecord = new RecordData(Const.EOF, (short)0);
            dg.write(tmpRecord.serialize());
            inConn.send(dg);
            System.out.println("EOF sent");
            return true;
        } catch(Exception e) {
            System.out.println("Error while transmitting");
        }
        return false;
    }
    
    public void broadcast() {
        RadiogramConnection outConn = null;
        Datagram dg;
        
        //First try to broadcast out our address.
        try {    
            System.out.println("Broadcasting");
            outConn = (RadiogramConnection) Connector.open("radiogram://broadcast:" + Const.BROADCAST_PORT);
            dg = outConn.newDatagram(outConn.getMaximumLength());
            RecordData broadCommand = new RecordData(Const.BROADCAST, (short)0);
            dg.write(broadCommand.serialize());
            
            //Send three times due to unreliable broadcasts
            //outConn.send(dg);
            //outConn.send(dg);
            outConn.send(dg);
            outConn.close();
            //TODO Call led for broadcasting here.
        } catch (Exception e) {
            //TODO Call exception here
            System.out.println("Error in broadcasting");
        } 
    }
    
    
    protected void pauseApp() {
    }
    
    /**
     * Called if the MIDlet is terminated by the system.
     * I.e. if startApp throws any exception other than MIDletStateChangeException,
     * if the isolate running the MIDlet is killed with Isolate.exit(), or
     * if VM.stopVM() is called.
     * 
     * It is not called if MIDlet.notifyDestroyed() was called.
     *
     * @param unconditional If true when this method is called, the MIDlet must
     *    cleanup and release all resources. If false the MIDlet may throw
     *    MIDletStateChangeException  to indicate it does not want to be destroyed
     *    at this time.
     */
    protected void destroyApp(boolean unconditional) throws MIDletStateChangeException {
    }
}
