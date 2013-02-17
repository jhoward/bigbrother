package org.sunspotworld;

import javax.microedition.io.Datagram;
import javax.microedition.rms.RecordEnumeration;
import javax.microedition.rms.RecordStore;



class RecordData {
    public long time;
    public short type;
    public short data;

    public RecordData(short type, short data) {
        this.type = type;
        this.data = data;
        this.time = System.currentTimeMillis(); 
    }

    public RecordData(long time, short type, short data) {
        this.time = time;
        this.type = type;
        this.data = data;
    }

    public byte[] serialize() {
        byte[] b = new byte[12];
        for(int i = 0; i < 8; i++) {
            b[i] = (byte)(time >> (8 * (7 - i)) & 0xff);
        }
        b[8] = (byte)((type >> 8) & 0xff);
        b[9] = (byte)(type & 0xff);
        b[10] = (byte)((data >> 24) & 0xff);
        b[11] = (byte)(data & 0xff);

        return b;
    }
    
    public String toString() {
        String out;
        out = this.time + "," + this.type + "," + this.data;
        return out;
    }
  
    
   public static RecordData deserialize(byte[] data) {
        long ltime = 0;
        long ltype;
        long ldata;
        RecordData rd = null;
        
        try {
            for(int i = 0; i < 8; i++) {
                ltime = (ltime << 8) + (data[i] & 0xff);
            }

            ltype = (data[8] & 0xff);
            ltype = (ltype << 8) + (data[9] & 0xff);
            
            ldata = (data[10] & 0xff);
            ldata = (ldata << 8) + (data[11] & 0xff);
            
            rd = new RecordData(ltime, (short)ltype, (short)ldata);
            
            return rd;
        } catch(Exception e) {
            return rd;
        }
   }
   
   public static RecordData deserialize(Datagram dg) {
       byte[] tmpD = new byte[12];
       
       try {
           dg.readFully(tmpD);
       } catch (Exception e) {
           return null;
       }
       
       return RecordData.deserialize(tmpD);
   }
}


class RecordHandler {
    public RecordStore rms;
    public RecordEnumeration enumerator = null;
    
    public RecordHandler(String name) {
        try {
            this.rms = RecordStore.openRecordStore(name, true);
            enumerator = rms.enumerateRecords(null, null, false);
        } catch (Exception e) {
            System.out.println("Problems with record handler.");
            //TODO add error lights here.
        }
    }
    
    public int addRecord(short recordType, int value){
        int tmpRecord = 0;
        
        try {
            RecordData tmpData = new RecordData(recordType, (short)value);
            byte[] data = tmpData.serialize();
            tmpRecord = rms.addRecord(data, 0, data.length);
        } catch(Exception e) {
            System.out.println("Problem adding record");
            //Call the led error creator here
        }
        
        return tmpRecord;
    }
    
    public int getNumRecords() {
        try {
            return rms.getNumRecords();
        } catch (Exception e) {
            return 0;
        }
    }
    
    public byte[] getNextRecord() {
        byte[] rec = null;
        
        try {
            rec = enumerator.nextRecord();
            return rec;
        } catch(Exception e) {
            return rec;
        }
    }
    
    public void deleteRecords(String storeName) {
        try {
            rms.closeRecordStore();
            RecordStore.deleteRecordStore(storeName);
        } catch(Exception e) {
            //Throw an error here.
        }
    }
    
    public void closeRecordHandler() {
        try {
            rms.closeRecordStore();
        } catch(Exception e) {
            System.out.println("Can't close");
            //Throw exception
        }
    }
    
    public void rebuildEnumerator() {
        try {
            enumerator.rebuild();
        } catch(Exception e) {
            System.out.println("problem with enumerator");
        }
    }
}