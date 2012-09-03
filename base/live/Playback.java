
/**
 * Main class and controller for CanvasPanel class. Uses a thread on a timer
 * to update CanvasPanel.
 */

import net.tinyos.message.*;
import net.tinyos.util.*;

import java.io.*;
import java.util.*;
import java.awt.*;
import java.awt.GridBagLayout;
import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.*;
import java.awt.event.*;
import java.awt.geom.*;
import com.thoughtworks.xstream.XStream;
import java.net.URL;

public class Playback extends JPanel {
	private CanvasPanel cp;
	private java.util.Timer timer;
	private Vector<Sensor> sensors;
	private Vector<activeIcon> shapeHeap;
	private static long time = 100;
	private static int limit = 15;
	private msgListener listener; 	
   private LiveListener liveListener;
   private ControlPane controlPane;

	public Playback(SensorVector s) {
		super();		

      /*		
		XStream xstream = new XStream();
      
      URL url = this.getClass().getResource("/sensors.xml");
      System.out.println(url.getPath());
 
		try {
      //File file = new File("jar:file:///home/mal/workspace/bigbrother/base/live/live.jar!/sensors.xml");
			FileInputStream fin = (FileInputStream) url.openStream();
			//SensorVector s = (SensorVector)xstream.fromXML(fin);
		   //sensors = s.sensors;
    		} catch (Exception err) {
     			System.out.println(err.getCause());
      			System.exit(1);
    		} 
      */

      sensors = s.sensors;
		shapeHeap = new Vector<activeIcon>();

		cp = new CanvasPanel(sensors);
		cp.setShapeHeap(shapeHeap);

	  	timer = new java.util.Timer();
	
   	timer.schedule(new RemindTask(), 0, time );

      liveListener = new LiveListener();

      controlPane = new ControlPane();
      controlPane.setLiveListener(liveListener);

      JSplitPane mainPanel = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, controlPane, cp);
      mainPanel.setDividerLocation(200);

      JFrame frame = new JFrame("Brown Building");
      frame.setSize(600, 400);
      frame.add(mainPanel);
      frame.setVisible(true);
    	frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	
	} //end public Playback(Vector<SimState v)

   private class LiveListener implements ActionListener {
      public void actionPerformed(ActionEvent e) {
         if(e.getActionCommand().equals("connectButton")) {
            listener = new msgListener();
         } 
      }
   }

	private class msgListener implements MessageListener {
		private MoteIF mote;
		private DuplicatePacketFilter filter;

		public msgListener() {
			filter = new DuplicatePacketFilter();
         try {
			mote = new MoteIF();
			mote.registerListener(new BigBrotherMsg(), this);
         } catch(Exception e) {
            System.out.println("HI");
            //System.exit(1);
         }
		} //end public msgListener()

		synchronized public void messageReceived(int dest_addr, Message msg) {
    			if (msg instanceof BigBrotherMsg) {
      				BigBrotherMsg bbmsg = (BigBrotherMsg)msg;
      				int mote_id = bbmsg.get_id();
      				int counter = bbmsg.get_counter();
      				if(!filter.already_received(mote_id, counter)) {
					int sensor_id = 0;
					mote_id = bbmsg.get_id() * 10;
					for( int i = 0; i < 5; ++i ) {
						if( bbmsg.getElement_readings(i) == 1 ) {
						//System.out.println("Entering if");
						sensor_id = mote_id + (i+1);		
						for( int j = 0; j < sensors.size(); ++j ) {
							if( sensors.get(j).get_id() == sensor_id ) {
								synchronized(shapeHeap) {
									shapeHeap.add( new activeIcon(sensors.get(j)) );
								}
								cp.repaint();
							}
						}
					}	
					}	
      				} //end if
    			} //end if

  		} // end syncronized public void messageReceived(

	} // end private class msgListener

  	private class RemindTask extends TimerTask {
				
		public RemindTask() {}
					
    		public void run() {
			synchronized(shapeHeap) {
			for( int i = (shapeHeap.size()-1); i >=0; --i ) {
				activeIcon x = shapeHeap.get(i);
				x.increment();
				if(x.getCounter() >= limit) {
					//System.out.println("REMOVING");
					shapeHeap.remove(i);
					cp.repaint();
				}
			}
			}
    		} //end public void run()
	} // end private class RemindTask

  	public static void main(String [] args) {
		
		//new Playback();
		XStream xstream = new XStream();
		SensorVector s = new SensorVector();
      
      //URL url = this.getClass().getResource("/new_map.bmp");
      //System.out.println(url.getFile());
 
      File file = new File(args[0]);

		try {
			String name = args[0];
			FileInputStream fin = new FileInputStream(file);
			s = (SensorVector)xstream.fromXML(fin);
			new Playback( s );
    		} catch (Exception err) {
     			System.out.println(err.getCause());
      			System.exit(1);
    		} 

  	} //end public static void main(String [] args)
} //end public class Playback extends JPanel
