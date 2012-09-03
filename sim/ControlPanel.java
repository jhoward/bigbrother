
import java.io.*;
import java.util.*;
import java.awt.*;
import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.*;
import java.awt.event.*;
import com.thoughtworks.xstream.XStream;

public class ControlPanel extends JPanel {
	private CanvasPanel cp;
	private Vector<SimState> simstates;
	private java.util.Timer timer;
	private sim s;
	JLabel timelabel;	
	JLabel tolabel;	
	JTextField fromField;
	JTextField toField;
	
	public ControlPanel(sim simmy) {
		super();		

		s = simmy;
		cp = new CanvasPanel(s);
		simstates = new Vector(s.get_simstates());	
		//System.out.println("Num simstates: " + simstates.size());
	  timer = new java.util.Timer();
		long time = 25;
	
   	//timer.schedule(new RemindTask(), 0, time );

    JPanel mainPanel = new JPanel( new BorderLayout() );

    timelabel = new JLabel( "Time: " );
    this.add( timelabel );
    fromField = new JTextField( "0" , 6 );
    this.add( fromField );
		tolabel = new JLabel( " to " );
		this.add( tolabel);
    toField = new JTextField( Integer.toString(s.get_clock().get_end_time()) , 6 );
    this.add( toField );
    //buttons
    JButton StartButton = new JButton( "Start" );
    StartButton.addActionListener( new StartButtonListener() );
    JButton StopButton = new JButton( "Stop" );
    StopButton.addActionListener( new StopButtonListener() );
    this.add( StartButton );
    this.add( StopButton );

    mainPanel.add( cp, BorderLayout.CENTER );
    mainPanel.add( this, BorderLayout.NORTH );


    JFrame frame = new JFrame("Simulator");
    frame.setSize(600, 400);
    frame.add(mainPanel);
    frame.setVisible(true);
    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

	} //end public ControlPanel(Vector<SimState v)

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
					if(currentTime < toTime && currentTime < simstates.size()) {
						cp.refresh(simstates.get(currentTime++));
					} else {
						this.cancel();
						timer.cancel();
						cp.stop();
					}
					/*
					if(simstates.hasNext()) {
						SimState next = simstates.next();
						timelabel = new JLabel( "Current time: " + next.get_time());
						repaint();
         		cp.refresh(next);
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
			timer = new java.util.Timer();
   		timer.schedule(new RemindTask( Integer.parseInt(fromField.getText()), Integer.parseInt(toField.getText())), 0, 25 );
		}
	}


	/*
  public static void main(String [] args) {
    try {
			new ControlPanel(args[0]);
    } catch (ArrayIndexOutOfBoundsException err) {
      System.out.println("Usage: java CanvasPanel <config file>");
      System.exit(1);
    }

  } //end public static void main(String [] args)
	*/

} //end public class ControlPanel extends JPanel
