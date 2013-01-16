/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package testfunctions;

class RData {
    public long time;
    public short type;
    
    public RData(short type) {
        this.type = type;
        this.time = System.currentTimeMillis(); 
        System.out.println("Added record at " + this.time);
    }
    
    public byte[] serialize() {
        byte[] b = new byte[10];
        for(int i = 0; i < 8; i++) {
            b[i] = (byte)(time >> (8 * (7 - i)) & 0xff);
        }
        b[8] = (byte)((type >> 8) & 0xff);
        b[9] = (byte)(type & 0xff);
        
        return b;
   }
    
   public static long[] deserialize(byte[] data) {
       long ltime = 0;
       long ltype;
       
       for(int i = 0; i < 8; i++) {
           ltime = (ltime << 8) + (data[i] & 0xff);
       }
       
       ltype = data[8] << 8;
       ltype += data[9];
       
       long[] retType = new long[2];
       retType[0] = ltime;
       retType[1] = ltype;
       
       return retType;
   }
}


public class TestFunctions {

    public static void main(String[] args) {
        RData tmp;
        
        tmp = new RData((short)10);
        byte[] data = tmp.serialize();
        long[] ldata = RData.deserialize(data);
        
        System.out.println("Recovered " + ldata[0] + "    " + ldata[1]);
    }
}
