import net.tinyos.message.*;
import net.tinyos.util.*;
import java.io.*;
import java.util.*;

public class BigBrother implements MessageListener {
	MoteIF mote;
  String outFile;
	RandomAccessFile f;
	String outputType;
	BigBrotherDB db;
	DuplicatePacketFilter filter;

	int version = -1;
	int count;

   /* Constructor used when writing to file. Clunky. */
	public BigBrother(String file) {
		filter = new DuplicatePacketFilter();
		outputType = "file";
		outFile = file;
		try {
			f = new RandomAccessFile(outFile, "r");
			System.out.println("Error: file exists");
			System.exit(1);
		} catch (FileNotFoundException ex1) {
			try {
				f = new RandomAccessFile(outFile, "rw");
			} catch (FileNotFoundException ex2) {
				System.out.println("Error: unable to create file " + outFile );
				System.exit(1);
			}
		}
		
		count = 0;

		mote = new MoteIF(PrintStreamMessenger.err);
		mote.registerListener(new BigBrotherMsg(), this);
	}

   /* Constructor used when writing to db. Clunky. */
	public BigBrother() {
		filter = new DuplicatePacketFilter();
		outputType = "db";
		db = new BigBrotherDB("bigbrother");
		
		count = 0;

		mote = new MoteIF(PrintStreamMessenger.err);
		mote.registerListener(new BigBrotherMsg(), this);
	}

	synchronized public void messageReceived(int dest_addr, Message msg) {
      if (msg instanceof BigBrotherMsg) {
         BigBrotherMsg bbmsg = (BigBrotherMsg)msg;
         int mote_id = bbmsg.get_id();
         int counter = bbmsg.get_counter();
         if(!filter.already_received(mote_id, counter)) {
				if(outputType == "file")
					writeMsgFile(bbmsg);
				else
					writeMsgDB(bbmsg);
		   } //end if
  	   } //end if

	} // end syncronized public void messageReceived(

  private void writeMsgFile(BigBrotherMsg bbmsg) {
		try {
			String readings = new String(bbmsg.get_id() + "\t\t" + "Counter: " + bbmsg.get_counter() + "\t\t" + bbmsg.getElement_readings(0) + "\t" + bbmsg.getElement_readings(1) + "\t" + bbmsg.getElement_readings(2) + "\t" + bbmsg.getElement_readings(3) + "\t" + bbmsg.getElement_readings(4));
			GregorianCalendar g = new GregorianCalendar();
			Date date = g.getTime();
         // Echo data written to file to prompt.
			System.out.println(date + "\t" + "\tMote: " + readings);
			f.writeBytes(count++ + "\t" + readings + "\n");
		} catch (IOException io) {
      System.exit(1);  
		}
	}

  private void writeMsgDB(BigBrotherMsg bbmsg) {
		GregorianCalendar g = new GregorianCalendar();
		int sensor_num;
		for(int i = 0; i < 5; ++i) {
			if(bbmsg.getElement_readings(i) == 1) {
				sensor_num = (bbmsg.get_id() * 10 + i);
				if(db.insertRecord(sensor_num, g))
        {
          // Display timestamp of last record inserted. Uses \r to print to same line. 
          System.out.print("\rLast record inserted for sensor" + sensor_num + " on " + String.format( "-%1$tY%1$tm%1$td%1$tH%1$tM%1$tS", g ));
			  } else 
        {
          try {
            String[] cmds = {"echo", "-e", "Problem with database.", "|", "mail", "-s", "`date`", "ploden@gmail.com"};
            Process prcs = Runtime.getRuntime().exec(cmds);
            db = new BigBrotherDB("bigbrother");
		        mote = new MoteIF(PrintStreamMessenger.err);
		        mote.registerListener(new BigBrotherMsg(), this);
          } catch (IOException e) {
            System.exit(1);  
          }
        }
		  }
	  } // end for loop
  } // end private void writeMsgDB

	public static void main(String[] args) {
		try {
			if(args[0].equals("file")) {
				BigBrother me = new BigBrother(args[1]);
			} else if(args[0].equals("db")) {
				BigBrother me = new BigBrother();
			} else {
			System.out.println("Usage: java BigBrother file <outputfile> OR java BigBrother db");
			System.exit(1);
			}
		} catch (ArrayIndexOutOfBoundsException a) {
			System.out.println("Usage: java BigBrother <output file>");
			System.exit(1);
		}	
	}

}

