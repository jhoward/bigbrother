
/**
 * Main class and controller for CanvasPanel class. Use a thread on a timer
 * to update CanvasPanel.
 */

import java.io.*;
import java.util.*;
import java.awt.*;
import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.*;
import java.awt.event.*;
import com.thoughtworks.xstream.XStream;

public class Playback extends JPanel {
	private CanvasPanel cp;
	private SimState2 currentstate;
	private java.util.Timer timer;
	private Vector<Sensor> sensors;
	JLabel timelabel;	
	JLabel steplabel;
	JLabel tolabel;	
	JTextField fromField;
	JTextField toField;
	JTextField stepField;
	PlaybackDb db;
	
	public Playback(SensorVector s) {
		super();		

		sensors = s.sensors;
		cp = new CanvasPanel(sensors);

		//db = new PlaybackDb();

	  timer = new java.util.Timer();
		long time = 25;
	
   	//timer.schedule(new RemindTask(), 0, time );

    JPanel mainPanel = new JPanel( new BorderLayout() );

		steplabel = new JLabel( "Timestep (ms): " );
		this.add( steplabel );
		stepField = new JTextField( "500", 4 );
		this.add( stepField );
    timelabel = new JLabel( "Time: " );
    this.add( timelabel );
    fromField = new JTextField( "0" , 6 );
    this.add( fromField );
		tolabel = new JLabel( " to " );
		this.add( tolabel);
    toField = new JTextField( "20070910071452", 6 );
    this.add( toField );
    //buttons
    JButton StartButton = new JButton( "Start" );
    StartButton.addActionListener( new StartButtonListener() );
    JButton StopButton = new JButton( "Stop" );
    StopButton.addActionListener( new StopButtonListener() );
    JButton pauseButton = new JButton( "Pause" );
    pauseButton.addActionListener( new PauseButtonListener() );
    this.add( StartButton );
    this.add( StopButton );
    this.add( pauseButton );

    mainPanel.add( cp, BorderLayout.CENTER );

    //mainPanel.add( this, BorderLayout.NORTH );


    JFrame frame = new JFrame("Playback");
    frame.setSize(600, 400);
    frame.add(mainPanel);
    frame.setVisible(true);
    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

	} //end public Playback(Vector<SimState v)

	private void generate_simstates() {
		//int sTime = Integer.parseInt(fromField.getText());
		//int fTime = Integer.parseInt(toField.getText());
		Vector<ReadingState> states = db.queryDb(fromField.getText(), toField.getText());
		//Collections.sort(states);

	//	while(states.size() > 0) {


		//}

	} //end private void generate_simstates()

  private class RemindTask extends TimerTask {
		int fromTime;
		int toTime;
		int currentTime;

				public RemindTask(int fT, int tT) {
					fromTime = fT;
					toTime = tT;
					currentTime = fromTime;
				}
					
        public void run() {
					/*
					if(currentTime < toTime && currentTime < simstates.size()) {
						cp.refresh(simstates.get(currentTime++));
					} else {
						this.cancel();
						timer.cancel();
						cp.stop();
					}
					*/
        }
	}

  private class StopButtonListener implements ActionListener {
    public void actionPerformed( ActionEvent e ) {
			timer.cancel();
		}
	}
  private class StartButtonListener implements ActionListener {
    public void actionPerformed( ActionEvent e ) {
			//timer = new java.util.Timer();
   		//timer.schedule(new RemindTask( Integer.parseInt(fromField.getText()), Integer.parseInt(toField.getText())), 0, 25 );
			generate_simstates();
		}
	}
  private class PauseButtonListener implements ActionListener {
    public void actionPerformed( ActionEvent e ) {
		}
	}

  public static void main(String [] args) {
		XStream xstream = new XStream();
		SensorVector s = new SensorVector();

		/*
		try {
			FileWriter fw = new FileWriter("tst.xml");
			BufferedWriter bf = new BufferedWriter(fw);
			bf.write(new String("HI"));
			bf.close();
			FileInputStream fin = new FileInputStream(
			String hi = (String)xstream.fromXML("tst.xml");
		} catch (IOException e) {}
		*/
		
		try {
			String name = args[0];
			FileInputStream fin = new FileInputStream(name);
			s = (SensorVector)xstream.fromXML(fin);
			new Playback( s );
    } catch (Exception err) {
     	System.out.println(err.getCause());
      //System.out.println("Usage: java Playback <config file>");
      System.exit(1);
    } 
  } //end public static void main(String [] args)

} //end public class Playback extends JPanel
