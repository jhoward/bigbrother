
import java.io.*;
import javax.swing.*;
import java.awt.*;
import java.awt.geom.*;
import java.util.*;
import com.thoughtworks.xstream.XStream;

public class CanvasPanel extends JPanel implements Runnable {
	private sim simmy;
	private double zoom;
	private int x_offset;
	private int y_offset;
	private int x_min;
	private int x_max;
	private int y_min;
	private int y_max;
	private static int padding = 10;
	private Dimension canvasSize;
	private SimState current_state;
	private Thread thread;
	private int counter;
	private Vector<ping_data> pings;
	private int pings_size;
	private Boolean is_live;	
	private floorplan layout;
	private Boolean locked;
		
	public CanvasPanel(sim t) {
		super();
		simmy = t;

		current_state = new SimState();		
		counter = 0;
		//thread = new Thread();	
		is_live = false;

		Iterator<Wall> i = simmy.get_layout().get_walls();
		pings = new Vector<ping_data>();
	
		x_min = 1000;
		x_max = 0;
		y_min = 1000;
		y_max = 0;

		while(i.hasNext()) {
			Wall w = i.next();
			int a = (int)w.get_startpoint().getX();
			int b = (int)w.get_startpoint().getY();
			int c = (int)w.get_endpoint().getX();
			int d = (int)w.get_endpoint().getY();
			if(a < x_min) {
				x_min = a;
			} else if(a > x_max) {
				x_max = a;		
			}
			if(b < y_min) {
				y_min = b;
			} else if(b > y_max) {
				y_max = b;		
			}
			if(c < x_min) {
				x_min = c;
			} else if(c > x_max) {
				x_max = c;		
			}
			if(d < y_min) {
				y_min = d;
			} else if(d > y_max) {
				y_max = d;		
			}
		
		Iterator<Sensor> m = simmy.get_layout().get_sensors();
		while(m.hasNext()) {
			Sensor s = m.next();
			s.set_is_on(false);
			ping_data pd = new ping_data( s.get_loc(), s.get_id(), 0);
			pd.set_sensor(s);
			pings.add(pd);
		}

			//this.start();
		}

	} //end public CanvasPanel()

	public CanvasPanel(floorplan f) {
		super();
			
		layout = f;
			
		counter = 0;	
		is_live = true;
		locked = false;
		
		Iterator<Wall> i = layout.get_walls();
		pings = new Vector<ping_data>();
	
		x_min = 1000;
		x_max = 0;
		y_min = 1000;
		y_max = 0;

		while(i.hasNext()) {
			Wall w = i.next();
			int a = (int)w.get_startpoint().getX();
			int b = (int)w.get_startpoint().getY();
			int c = (int)w.get_endpoint().getX();
			int d = (int)w.get_endpoint().getY();
			if(a < x_min) {
				x_min = a;
			} else if(a > x_max) {
				x_max = a;		
			}
			if(b < y_min) {
				y_min = b;
			} else if(b > y_max) {
				y_max = b;		
			}
			if(c < x_min) {
				x_min = c;
			} else if(c > x_max) {
				x_max = c;		
			}
			if(d < y_min) {
				y_min = d;
			} else if(d > y_max) {
				y_max = d;		
			}
		}	
	
		Iterator<Sensor> m = layout.get_sensors();
		while(m.hasNext()) {
			Sensor s = m.next();
			s.set_is_on(false);
			ping_data pd = new ping_data( s.get_loc(), s.get_id(), 0);
			pd.set_sensor(s);
			pings.add(pd);
		}
	

			this.start();

	} //end public CanvasPanel(floorplan f)
		
	public void add_triggered(int id) {
		//System.out.println("Adding triggered with id: " + id);
		Boolean set = false;
		for(int i = 0; i < pings.size(); ++i) {
			Sensor s = pings.get(i).get_sensor();
			if(s.get_id() == id) {
				s.set_is_on(true);
				set = true;
				break;
			}	
		}
		if(!set) { System.out.println("ERROR: FAILED TO TRIGGER SENSOR " + id); }
	} //end public void add_triggered(int id) 


	/*
	synchronized public void messageReceived(int dest_addr, Message msg) {
    if (msg instanceof BigBrotherMsg) {
      BigBrotherMsg bbmsg = (BigBrotherMsg)msg;
      writeMsg(bbmsg);
    }
  }
 
  private void writeMsg(BigBrotherMsg bbmsg) {
    for(int i = 0; i < bbmsg.numElements_readings(); ++i) {
      System.out.println(bbmsg.getElement_readings(i));
      //db.insertRecord(bbmsg.getElement_readings(i), new GregorianCalendar());
    }
  }
	*/

  public void paintComponent(Graphics g) {
		clear(g);
	  Graphics2D g2d = (Graphics2D)g;
		canvasSize = getSize();
		int x_dif = x_max - x_min;
		int y_dif = y_max - x_min;
		double x_quotient = ((canvasSize.getWidth()-(padding*2)) / x_dif);
		double y_quotient = ((canvasSize.getHeight()-(padding*2)) / y_dif);
		if(x_quotient <= y_quotient) {
			zoom = x_quotient;
		} else {
			zoom = y_quotient;
		}
		x_offset = (int)(zoom * (x_min * -1) + padding);
		y_offset = (int)(zoom * (y_min * -1) + padding);

		drawBackground(g2d);

		drawWalls(g2d);

		drawSensors(g2d);
	
		drawPings(g2d);
   	/*
		g2d.setColor( Color.BLACK );
    g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
    g2d.setStroke( new BasicStroke(.8f) );
	
		for( int i = 0; i < pings.size(); ++i) {
    	ping_data data = pings.get(i);
    	data.update();
    	g2d.draw( new ping_icon( data.getP(), data.getSize(), data.getSize() ) );
    }
		*/
		
		if(!is_live) {
			drawPeople(g2d);

			drawWaypoints(g2d);

			drawTime(g2d);
		}
		
		//System.out.println("Calling repaint...");
  } //end public void paintComponent(Graphics g)

	public void refresh(SimState s) {
		current_state = s;
		Iterator<Sensor> i = current_state.get_sensors();
		while(i.hasNext()) {
			Sensor sens = i.next();
			if(sens.get_is_on()) {
				add_triggered(sens.get_id());
			}
		}
		repaint();
	}

	private void drawTime(Graphics2D g2d) {
    g2d.setColor( Color.BLUE );
		//g2d.drawString( Integer.toString(current_state.get_time()), 700, 50);
		g2d.drawString( new String("TIME: " + Integer.toString(current_state.get_time())), 200, 50);

	}

	private void drawWaypoints(Graphics2D g2d) {
    g2d.setColor( Color.BLUE );
    g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

		Iterator<Waypoint> i = simmy.get_layout().get_waypoints();
		while(i.hasNext()) {
			Waypoint w = i.next();
			int cross_size = 5;
			if(w.get_is_dest()) {
    		g2d.setColor( Color.BLACK );
				cross_size *= 2;
			} else {
    		g2d.setColor( Color.BLUE );
			}	
			Point vert1 = resizePoint(w);
			vert1.translate(0,-cross_size);
			Point vert2 = resizePoint(w);
			vert2.translate(0,cross_size);
			Point horz1 = resizePoint(w);
			horz1.translate(-cross_size,0);
			Point horz2 = resizePoint(w);
			horz2.translate(cross_size,0);
			g2d.draw( new Line2D.Double(vert1, vert2));
			g2d.draw( new Line2D.Double(horz1, horz2));
		}

	}

	private void drawPeople(Graphics2D g2d) {
    g2d.setColor( Color.BLUE );
    g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
		
		Iterator<Person> i = current_state.get_people();
		//if( current_state.get_num_people() > 0 ) { System.out.println("NUM PEOPLE: " + current_state.get_num_people()); }
		while(i.hasNext()) {
			Person s = i.next();
			g2d.fill( new Sensor_icon( resizePoint(s.get_loc()), 7.0, 7.0) );
		}
	} 

	private void drawSensors(Graphics2D g2d) {
		if(!is_live) {
			Iterator<Sensor> i = current_state.get_sensors();
			while(i.hasNext()) {
				Sensor s = i.next();
   			g2d.setColor(Color.RED);
				g2d.fill( new Sensor_icon( resizePoint(s.get_loc()), 6.0, 6.0) );
			}
		} else {
			Iterator<Sensor> i = layout.get_sensors();
			while(i.hasNext()) {
				Sensor s = i.next();
   			g2d.setColor(Color.RED);
				g2d.fill( new Sensor_icon( resizePoint(s.get_loc()), 6.0, 6.0) );
			}
		}
	} //end private void drawSensors    		


	private void drawPings(Graphics2D g2d) {
   	g2d.setColor( Color.BLACK );
    g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
    g2d.setStroke( new BasicStroke(1.0f) );
	
		for( int i = 0; i < pings.size(); ++i) {
    	ping_data data = pings.get(i);
			if(data.get_sensor().get_is_on()) {
    		g2d.draw( new ping_icon( data.getP(), data.getSize(), data.getSize() ) );
			}
    	data.update();
    }
	} //end private void drawPings(Graphics2D g2d)
	
	private void drawWalls(Graphics2D g2d) {
    g2d.setColor( Color.BLACK );
    g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
    g2d.setStroke( new BasicStroke(1.2f) );
	
		if(!is_live) {	
		Iterator<Wall> i = simmy.get_layout().get_walls();

		while(i.hasNext()) {
			Wall w = i.next();
			g2d.draw( new Line2D.Double(resizePoint(w.get_startpoint()), resizePoint(w.get_endpoint())) );
		}
		} else {
		Iterator<Wall> i = layout.get_walls();

		while(i.hasNext()) {
			Wall w = i.next();
			g2d.draw( new Line2D.Double(resizePoint(w.get_startpoint()), resizePoint(w.get_endpoint())) );
		}
		}
	
	}

  private void drawBackground(Graphics2D g2d) {
  	GradientPaint titleGradient = new GradientPaint(0,getHeight(), new Color( 119, 136, 153 ), 0,0, Color.WHITE);
    g2d.setPaint(titleGradient);
    g2d.fillRect(0, 0, getWidth(), getHeight());
  } //end private void drawBackground(Graphics2D g2d) {

  protected void clear(Graphics g) {
        super.paintComponent(g);
  }

	private Point resizePoint(Point p) {
		Point q = new Point((int)(p.getX() * zoom), (int)(p.getY() * zoom));
		q.translate(x_offset, y_offset);
		return q;
	}


  public void start() {
 		thread = new Thread(this);
    thread.setPriority(Thread.MIN_PRIORITY);
    thread.start();
  }


  public synchronized void stop() {
  	thread = null;
	}

  public void run() {
      Thread me = Thread.currentThread();
      while (thread == me) {
          repaint();
          try {
              thread.sleep(50);
          } catch (InterruptedException e) { break; }
      }
      thread = null;
  }
	
	public static void main(String [] args) {
    try {
      XStream xstream = new XStream();
      FileInputStream fin = new FileInputStream(args[0]);
      sim s = (sim)xstream.fromXML(fin);
			new CanvasPanel(s);
    } catch (ArrayIndexOutOfBoundsException err) {
      System.out.println("Usage: java CanvasPanel <config file>");
      System.exit(1);
    } catch(FileNotFoundException io_err) {
      System.out.println("Error opening file. Aborting.");
      System.exit(1);
    }

	} //end public static void main(String [] args) 

	private class Sensor_icon extends Ellipse2D.Double {
		public Sensor_icon(Point p, double w, double h) {
			super(p.getX(), p.getY(), w, h);
		}
	}

	private class ping_data {
   
		private int size;
    private int base_size;
    private int i;
    private Point center;
    private Point p;
    private double double_size;
		private Boolean done;
		private int sensor_id;
		private int time;
		private Sensor sensor;

    public ping_data(Point c, int i, int j) {
      base_size = 50;
      size = base_size;
      center = c;
      updateP();
			done = false;
			sensor_id = i;
			time = j;
    }

    public void update() {
			if(size > 30) {
				sensor.set_is_on(false);
				size = 5;
			} else {
				size*=1.2;
			}
      updateP();
    }

		public void set_sensor(Sensor s) {
			sensor = s;
		}

    private void updateP() {
      p = resizePoint(new Point( (int)(center.getX()-(size/2)), (int)(center.getY()-(size/2)) ));
    } 
      
	  public Point getP() { return p; }
  	public int getSize() { return size; }
		public Boolean get_done() { return done; }
		public int get_time() { return time; } 
		public int get_id() { return sensor_id; }
		public Sensor get_sensor() { return sensor; }
	} //end private class ping_data

  private class ping_icon extends Ellipse2D.Double {
    public ping_icon(Point p, int w, int h) {
      super( p.getX(), p.getY(), w, h);
    }
  } //end private class ping_icon extends Ellipse2D.Double 

} //end public class CanvasPanel
