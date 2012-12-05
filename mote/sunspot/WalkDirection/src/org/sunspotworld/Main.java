package org.sunspotworld;

import com.sun.spot.resources.Resources;
import com.sun.spot.resources.transducers.ISwitch;
import com.sun.spot.resources.transducers.ITriColorLEDArray;
import com.sun.spot.resources.transducers.LEDColor;
import com.sun.spot.resources.transducers.SwitchEvent;
import com.sun.spot.sensorboard.EDemoBoard;
import com.sun.spot.sensorboard.io.*;
import com.sun.spot.util.Utils;
import javax.microedition.midlet.MIDlet;
import javax.microedition.midlet.MIDletStateChangeException;
import javax.microedition.rms.RecordStore;
import javax.microedition.rms.RecordStoreException;
import javax.microedition.rms.RecordStoreFullException;
import javax.microedition.rms.RecordStoreNotFoundException;

public class Main extends MIDlet {
    
    
    private static final boolean DEBUG = true; //set to true for flashing LED for direction events
    
    
    //IO PINS
    private IIOPin[] ioPins = EDemoBoard.getInstance().getIOPins();
    private static final int IO_LEFT_SENSOR = 1;
    private static final int IO_RIGHT_SENSOR = 0;
    //MULTICOLOR LEDs
    private ITriColorLEDArray leds = (ITriColorLEDArray) Resources.lookup(ITriColorLEDArray.class);
    private LEDColor[] colors = {LEDColor.RED, LEDColor.GREEN, LEDColor.BLUE, LEDColor.CYAN, LEDColor.MAGENTA, LEDColor.WHITE};
    //BUTTONS
    private ISwitch sw1 = (ISwitch) Resources.lookup(ISwitch.class, "SW1");
    private ISwitch sw2 = (ISwitch) Resources.lookup(ISwitch.class, "SW2");
    //STATES
    private static final int STATE_INITIALIZING = 0;
    private static final int STATE_SENSING = 1;
    private static final int STATE_TRANSMITTING = 2;
    private int state = STATE_INITIALIZING;
    //MOTE DIFFERENTIATION
    private int motenum = -1;
    //WALK STATES
    private static final int WALK_NOTHING = 0;
    private static final int WALK_LEFT = 1;
    private static final int WALK_RIGHT = 2;
    private static final int WALK_WAITING = 5; //wait for reset
    private int walkState = WALK_NOTHING;
    //CONSTANTS
    private static final String DEST_MOTE = "0014.4F01.0000.0007"; //Mote connected to computer for collecting data

    public void switchReleased(SwitchEvent evt) {
        if (evt.getSwitch() == sw1) {
            //Blink binary mote num
            leds.setOff();
            Utils.sleep(200);
            showCount(motenum, 0);
            Utils.sleep(1000);
            leds.setOff();
            state = STATE_SENSING;
        } else {
            motenum++;
            showCount(motenum, 0);
        }
    }

    public void switchPressed(SwitchEvent evt) {
    }

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

    /************ Set LEDs to specified color ************/
    private void showColor(int color) {
        leds.setColor(colors[color]);
        leds.setOn();
    }
    
    /************ Flash LEDs with specified color ************/
    private void flashColor(int color) {
        leds.setColor(colors[color]);
        leds.setOn();
        Utils.sleep(100);
        leds.setOff();
    }
    
    
    /************ Main ************/
    protected void startApp() throws MIDletStateChangeException {
        leds.setColor(colors[2]);
        leds.setOn();
        Utils.sleep(1000);
        leds.setOff();



        //This is in miliseconds.
        int readInterval = 500;
        boolean rightSensorEmpty, leftSensorEmpty;
        int lagTime = 8;
        int lsCount, rsCount;
        rsCount = 0;
        lsCount = 0;




        while (true) {
            switch (state) {
                case STATE_INITIALIZING:
                    System.out.println("INITIALIZING");
                    
                    if (DEBUG) {
                        flashNumberOfEvents();
                        eraseEvents();
                    }
                    
                    state = STATE_SENSING;
                    break;


                case STATE_SENSING:
                    System.out.println("SENSING");

                    rightSensorEmpty = ioPins[IO_RIGHT_SENSOR].getState();
                    leftSensorEmpty = ioPins[IO_LEFT_SENSOR].getState();



                    if (rightSensorEmpty && leftSensorEmpty) {
                        if (walkState == WALK_WAITING) {
                            System.out.println("Reset");
                            walkState = WALK_NOTHING;
                            rsCount = 0;
                            lsCount = 0;
                        }
                    }

                    if (walkState == WALK_NOTHING) {
                        if (!rightSensorEmpty && leftSensorEmpty) {
                            lsCount = lagTime;
                            //System.out.println("WalkState 1");
                            walkState = WALK_LEFT;
                        }
                        if (!leftSensorEmpty && rightSensorEmpty) {
                            //System.out.println("WalkState 2");
                            rsCount = lagTime;
                            walkState = WALK_RIGHT;
                        }

                        if (!leftSensorEmpty && !rightSensorEmpty) {
                            walkState = WALK_WAITING;
                            if (DEBUG) {
                                System.out.println("----- Too fast walk detected.");
                                flashColor(2);
                                Utils.sleep(100);
                                flashColor(0);
                                Utils.sleep(100);
                                flashColor(2);
                            }
                        }
                    }

                    if (walkState == WALK_LEFT) {
                        if (!leftSensorEmpty) {
                            if (DEBUG) {
                                System.out.println("Walked left detected.");
                                flashColor(3);
                            }
                            walkState = WALK_WAITING;
                            lsCount = 0;
                        }
                    }

                    if (walkState == WALK_RIGHT) {
                        if (!rightSensorEmpty) {
                            if (DEBUG) {
                                System.out.println("Walked right detected.");
                                flashColor(4);
                            }
                            walkState = WALK_WAITING;
                            rsCount = 0;
                        }
                    }

                    if (rsCount > 0) {
                        rsCount -= 1;
                    }

                    if (lsCount > 0) {
                        lsCount -= 1;
                    }

                    if (rsCount == 0 && lsCount == 0 && (walkState == WALK_LEFT || walkState == WALK_RIGHT)) {
                        if (DEBUG) {
                            System.out.print("----- Bad Event detected:  ");
                            flashColor(2);
                            Utils.sleep(200);
                            flashColor(0);
                            Utils.sleep(200);
                            flashColor(2);
                        }
                        System.out.print("----- Bad Event detected:  ");
                        System.out.println(walkState);
                        walkState = WALK_WAITING;
                    }


                    // Go to sleep to conserve battery
                    Utils.sleep(100);
                    break;


                case STATE_TRANSMITTING:
                    System.out.println("TRANSMITTING");
                    /*RadiostreamConnection conn = conn = (RadiostreamConnection)Connector.open("radiostream://"+DEST_MOTE+":100");
                     DataOutputStream dos = conn.openDataOutputStream();
                     try {
                     dos.writeUTF("Hello");
                     dos.flush();
                     } catch (IOException e) {
                     System.out.println ("Exception with connection to "+DEST_MOTE);
                     } finally {
                     dos.close();
                     conn.close();
                     }*/
                    break;
            }
        }
    }

    protected void pauseApp() {
        // This will never be called by the Squawk VM
    }

    protected void destroyApp(boolean arg0) throws MIDletStateChangeException {
        // Only called if startApp throws any exception other than MIDletStateChangeException
    }
    
    
    
    
    
    
    
    
    /************ Saves an event to flash ************/
    private void saveEvent() {
        try {
            
            RecordStore rms = RecordStore.openRecordStore("Events", true);
            byte[] inputData = new byte[]{12,13,14,15,16}; /////this should be our sensor data
            rms.addRecord(inputData, 0, inputData.length);
            rms.closeRecordStore();
            
        } catch (RecordStoreException ex) {
            System.out.print("----- Record store exception");
            flashColor(2);
            Utils.sleep(100);
            flashColor(0);
            Utils.sleep(100);
            flashColor(2);
            Utils.sleep(100);
            flashColor(0);
            Utils.sleep(100);
            flashColor(2);
        }
    }
    
    /************ Flash number of events on LEDs ************/
    private void flashNumberOfEvents() {
        try {
            
            RecordStore rms = RecordStore.openRecordStore("Events", true);
            int records = rms.getNumRecords();
            rms.closeRecordStore();
            for (int i = 0; i < records; i++) {
                flashColor(5);
                Utils.sleep(150);
            }
            
        } catch (RecordStoreException ex) {
            System.out.print("----- Record store exception");
            flashColor(2);
            Utils.sleep(100);
            flashColor(0);
            Utils.sleep(100);
            flashColor(2);
            Utils.sleep(100);
            flashColor(0);
            Utils.sleep(100);
            flashColor(2);
        }
    }
    
    /************ Print events stored on flash ************/
    private void printEvents() {
        try {
            
            RecordStore rms = RecordStore.openRecordStore("Events", true);
            int records = rms.getNumRecords();
            byte[] outputData = rms.getRecord(records);
            rms.closeRecordStore();
            ///////actually do what I want to do
            
        } catch (RecordStoreException ex) {
            System.out.print("----- Record store exception");
            flashColor(2);
            Utils.sleep(100);
            flashColor(0);
            Utils.sleep(100);
            flashColor(2);
            Utils.sleep(100);
            flashColor(0);
            Utils.sleep(100);
            flashColor(2);
        }
    }
    
    /************ Clear all events from flash ************/
    private void eraseEvents() {
        try {
            
            if (DEBUG)
                showColor(5);
            
            RecordStore rms = RecordStore.openRecordStore("Events", true);
            int records = rms.getNumRecords();
            rms.deleteRecord(records); //loop through and remove all records
            rms.closeRecordStore();
            ///////actually do what I want to do
            
            if (DEBUG)
                leds.setOff();
            
        } catch (RecordStoreException ex) {
            System.out.print("----- Record store exception");
            flashColor(2);
            Utils.sleep(100);
            flashColor(0);
            Utils.sleep(100);
            flashColor(2);
            Utils.sleep(100);
            flashColor(0);
            Utils.sleep(100);
            flashColor(2);
        }
    }
    
    
    
    
    
    
}
