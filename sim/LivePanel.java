import net.tinyos.message.*;
import net.tinyos.util.*;
import java.io.*;
import java.util.*;
import java.awt.*;
import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.*;
import java.awt.event.*;
import com.thoughtworks.xstream.XStream;

public class LivePanel extends JPanel implements MessageListener {
  MoteIF mote;
	CanvasPanel cp;
	java.util.Timer timer;
	private Vector<reading_history> history;
	
 	RandomAccessFile file;

  int count;

  public LivePanel(floorplan f) {
    super();
		cp = new CanvasPanel(f);
		history = new Vector<reading_history>();


    try {
      file = new RandomAccessFile("ray.txt", "rw");
    } catch (FileNotFoundException ex1) {
        System.out.println("Error: unable to create file.");
        System.exit(1);
    }



    JPanel mainPanel = new JPanel( new BorderLayout() );
    mainPanel.add( cp, BorderLayout.CENTER );
    mainPanel.add( this, BorderLayout.NORTH );
    JFrame frame = new JFrame("Brown Building");
    frame.setSize(600, 400);
    frame.add(mainPanel);
    frame.setVisible(true);
    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

    timer = new java.util.Timer();
    timer.schedule(new RemindTask(), 0, 10 );


    mote = new MoteIF(PrintStreamMessenger.err);
    mote.registerListener(new BigBrotherMsg(), this);
  }

	synchronized public void messageReceived(int dest_addr, Message msg) {
    if (msg instanceof BigBrotherMsg) {
      BigBrotherMsg bbmsg = (BigBrotherMsg)msg;
    	int mote_id = bbmsg.get_id();
			int counter = bbmsg.get_counter();
			if(!already_received(mote_id, counter)) {
			int reading;
			for(int i = 0; i < 5; ++i) {
				reading = bbmsg.getElement_readings(i);
				if(reading == 1) {
					//System.out.println("Triggering...");
					int tmp_id = mote_id*10 + (i+1);
					cp.add_triggered(tmp_id);
					writeReading(tmp_id);
				}
			} //end for
			} //end if
			} //end if
  }

	public void writeReading(int id) {
  	GregorianCalendar g = new GregorianCalendar();
    //Date date = g.getTime();
    try {
			file.writeBytes(id +	"\t" + g.get(Calendar.HOUR_OF_DAY) + ":" + g.get(Calendar.MINUTE) + ":" + g.get(Calendar.SECOND) + "\n"); 	
		} catch (IOException io) {

		}
	}

	private Boolean already_received(int id, int counter) {
		Boolean id_found = false;
		reading_history rh = new reading_history(0);
		for(int i = 0; i < history.size(); ++i) {
			rh = history.get(i);
			if(rh.get_id() == id) {
				id_found = true;
				break;
			}
		}
		if(id_found) {
			Boolean b = rh.find_reading(counter);	
			rh.add_reading(counter);
			return b;
		} else {
			history.add(new reading_history(id));
			return false;
		}
	}

  private class RemindTask extends TimerTask {
        public void run() {
        	cp.repaint();
				}
  }

	private class reading_history {
		public int id;
		public int [] history;
		public int index;
		private int history_size = 24;

		public reading_history(int i) {
			id = i;
			history = new int[history_size];
			index = 0;
		}

		public void add_reading(int j) {
			history[index%history_size] = j;
			++index;
		}

		public Boolean find_reading(int k) {
			for(int i = 0; i < history_size; ++i) {
				if(history[i] == k) {
					return true;
				}
			}
			return false;
		}

		public int get_id() { return id; }
	}

  public static void main(String [] args) {
    try {
      XStream xstream = new XStream();
      FileInputStream fin = new FileInputStream(args[0]);
      floorplan f = (floorplan)xstream.fromXML(fin);
      new LivePanel(f);
		} catch (ArrayIndexOutOfBoundsException err) {
      System.out.println("Usage: java CanvasPanel <config file>");
      System.exit(1);
    } catch(FileNotFoundException io_err) {
      System.out.println("Error opening file. Aborting.");
      System.exit(1);
    }
	}

} //end public class LivePanel


