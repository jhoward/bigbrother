package org.sunspotworld;

import com.sun.spot.util.Utils;
import javax.microedition.rms.RecordStore;
import javax.microedition.rms.RecordStoreException;


public class Storage {
    
    private static void saveEvent() {
        try {
            
            RecordStore rms = RecordStore.openRecordStore("Events", true);
            byte[] inputData = new byte[]{12,13,14,15,16}; /////this should be our sensor data
            rms.addRecord(inputData, 0, inputData.length);
            rms.closeRecordStore();
            
        } catch (RecordStoreException ex) {
            System.out.print("----- Record store exception");
//            flashColor(2);
//            Utils.sleep(100);
//            flashColor(0);
//            Utils.sleep(100);
//            flashColor(2);
//            Utils.sleep(100);
//            flashColor(0);
//            Utils.sleep(100);
//            flashColor(2);
        }
    }
    
    private static void printEvents() {
        try {
            
            RecordStore rms = RecordStore.openRecordStore("Events", true);
            int records = rms.getNumRecords();
            byte[] outputData = rms.getRecord(records);
            rms.closeRecordStore();
            ///////actually do what I want to do
            
        } catch (RecordStoreException ex) {
            System.out.print("----- Record store exception");
//            flashColor(2);
//            Utils.sleep(100);
//            flashColor(0);
//            Utils.sleep(100);
//            flashColor(2);
//            Utils.sleep(100);
//            flashColor(0);
//            Utils.sleep(100);
//            flashColor(2);
        }
    }
    
    private static void eraseEvents() {
        try {
            
//            if (DEBUG)
//                showColor(5);
            
            RecordStore rms = RecordStore.openRecordStore("Events", true);
            int records = rms.getNumRecords();
            rms.deleteRecord(records); //loop through and remove all records
            rms.closeRecordStore();
            ///////actually do what I want to do
            
//            if (DEBUG)
//                leds.setOff();
            
        } catch (RecordStoreException ex) {
            System.out.print("----- Record store exception");
//            flashColor(2);
//            Utils.sleep(100);
//            flashColor(0);
//            Utils.sleep(100);
//            flashColor(2);
//            Utils.sleep(100);
//            flashColor(0);
//            Utils.sleep(100);
//            flashColor(2);
        }
    }
    
}
