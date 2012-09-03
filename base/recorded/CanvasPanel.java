
/**
 * This is the JPanel where the floorplan and sensors are rendered.
 * Should be kept as generic as possible so that the same class can be used
 * for recorded data, live data, and sim data. Another class acts as a controller, 
 * adding objects to the shapeHeap as necessary for dynamic elements (people,
 * sensor on-off, etc).
 */

import java.io.*;
import javax.swing.*;
import java.awt.*;
import java.awt.geom.*;
import java.util.*;
import com.thoughtworks.xstream.XStream;
import java.awt.image.*;
import javax.imageio.*;

public class CanvasPanel extends JPanel {
	private Vector<Sensor> sensors;
	private double zoom;
	private Dimension canvasSize;
	private SimState2 current_state;
	private int counter;
	private Vector<ping_data> pings;
	private int pings_size;
	private Boolean is_live;	
	private Boolean locked;
	private BufferedImage background;
	private double aspectRatio;
	private Vector<Shape> shapeHeap;
	private int x_offset, y_offset;
	private static int x_original_offset = -6, y_original_offset = 6;
	private static int hallway_width = 30;
	private static int sensor_icon_size = hallway_width / 3;
		
	public CanvasPanel(Vector<Sensor> s) {
		super();
		sensors = s;

		shapeHeap = new Vector<Shape>();

		current_state = new SimState2();		
		counter = 0;
		is_live = false;

		pings = new Vector<ping_data>();

  	File file = new File("../../include/new_map.bmp");
		try{ 
    	background = ImageIO.read(file);
			double w = background.getWidth();
			double h = background.getHeight();
			aspectRatio = w / h;
		} catch(Exception e) {
			// Suppressed exception. BAD!
		}

		x_offset = 120;
		y_offset = 0;
	
	} //end public CanvasPanel()

  public void paintComponent(Graphics g) {
		clear(g);
	  Graphics2D g2d = (Graphics2D)g;
		canvasSize = getSize();

		drawImage(g2d);

		drawSensors(g2d);
		
  } //end public void paintComponent(Graphics g)

	public void refresh(SimState2 s) {
	}

	private void drawTime(Graphics2D g2d) {
    g2d.setColor( Color.BLUE );
		//g2d.drawString( Integer.toString(current_state.get_time()), 700, 50);
		g2d.drawString( new String("TIME: " + Integer.toString(current_state.get_time())), 200, 50);

	}

  private void drawSensors(Graphics2D g2d) {
		g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
		Iterator<Sensor> i = sensors.iterator();
		while(i.hasNext()) {
			Sensor s = i.next();
			g2d.setColor(Color.BLUE);
			g2d.fill( new Sensor_icon( resizePoint(s.get_loc()), sensor_icon_size * zoom, sensor_icon_size * zoom) );
		}
  } //end private void drawSensors

	private void drawImage(Graphics2D g2d) {
		BufferedImage resizedBackground;
		double w = canvasSize.getWidth();
		double h = canvasSize.getHeight();
		
		//System.out.println("CanvasWidth: " + w + " CanvasHeight: " + h);
		//System.out.println("AspectRatio: " + aspectRatio);
		
		double ratio = w / h;
		if( ratio >= aspectRatio ) {
			resizedBackground = createResizedCopy(background, (int)(h * aspectRatio), (int)h, true);
		} else {
			resizedBackground = createResizedCopy(background, (int)w, (int)(w / aspectRatio), true);
		}
		
		zoom = ( (double)resizedBackground.getWidth() / (double)background.getWidth() );
		//System.out.println("rs: " + resizedBackground.getWidth() + "bkg: " + background.getWidth());
		//System.out.println("Zoom: " + zoom);
		g2d.drawImage(resizedBackground, null, 0, 0);	
	} //end private void drawImage

  protected void clear(Graphics g) {
        super.paintComponent(g);
  }

	private Point resizePoint(Point p) {
		//System.out.println("ZOOM: " + zoom);
		Point q = new Point((int)(p.getX() + x_original_offset), (int)(p.getY() + y_original_offset));
		q.translate(x_offset, y_offset);
		q.move( (int)(q.getX() * zoom), (int)(q.getY() * zoom) );
		return q;
	}

	/*
	private Point resizePoint2D(Point2D.Double p) {
		Point q = new Point((int)(p.getX() * zoom), (int)(p.getY() * zoom));
		//q.translate(x_offset, y_offset);
		return q;
	}
	*/

  BufferedImage createResizedCopy(Image originalImage,
                                int scaledWidth, int scaledHeight,
                                boolean preserveAlpha)
  {
		//System.out.println("WIDTH: " + scaledWidth + " HEIGHT: " + scaledHeight);
    int imageType = preserveAlpha ? BufferedImage.TYPE_INT_RGB : BufferedImage.TYPE_INT_ARGB;
    BufferedImage scaledBI = new BufferedImage(scaledWidth, scaledHeight, imageType);
    Graphics2D g = scaledBI.createGraphics();
    if (preserveAlpha) {
       g.setComposite(AlphaComposite.Src);
    }
    g.drawImage(originalImage, 0, 0, scaledWidth, scaledHeight, null);
    g.dispose();
    return scaledBI;
  }

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
