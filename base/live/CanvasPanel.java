
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
import java.net.URL;

public class CanvasPanel extends JPanel {
	private Vector<Sensor> sensors;
	private double zoom;
	private Dimension canvasSize;
	private int counter;
	private Boolean locked;
	private BufferedImage background;
	private double aspectRatio;
	private Vector<activeIcon> shapeHeap;
	private int x_offset, y_offset;
	private static int x_original_offset = -6, y_original_offset = 6;
	private static int hallway_width = 30;
	private static int sensor_icon_size = hallway_width / 3;
		
	public CanvasPanel(Vector<Sensor> s) {
		super();
		sensors = s;

		shapeHeap = new Vector<activeIcon>();

		counter = 0;

		URL url = this.getClass().getResource("/new_map.bmp");
		//System.out.println(url.toString());

		try{ 
    			background = ImageIO.read(url);
			double w = background.getWidth();
			double h = background.getHeight();
			aspectRatio = w / h;
		} catch(Exception e) {
			// Suppressed exception. BAD!
			System.out.println("Failed to open background image. Exiting");
			System.exit(1);
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
		
		drawShapeHeap(g2d);

  	} //end public void paintComponent(Graphics g)

	// Currently "deprecated". Used to draw time on background.
	private void drawTime(Graphics2D g2d) {
    		//g2d.setColor( Color.BLUE );
		//g2d.drawString( Integer.toString(current_state.get_time()), 700, 50);
		//g2d.drawString( new String("TIME: " + Integer.toString(current_state.get_time())), 200, 50);
	} //end private void drawTime(

	// Draws elements contained on the shapeHeap
	private void drawShapeHeap(Graphics2D g2d) {
		g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
		g2d.setColor(Color.RED);
		g2d.setComposite( AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 0.5F) );
		synchronized (shapeHeap) {
			Iterator<activeIcon> i = shapeHeap.iterator();
			while (i.hasNext()) {
				activeIcon n = i.next();
				g2d.fill( n.getMoved( resizePoint(n.getCenter()), zoom ) );
			}
		}
	} // end private void drawShapeHeap

  	private void drawSensors(Graphics2D g2d) {
		g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
		Iterator<Sensor> i = sensors.iterator();
		while (i.hasNext()) {
			Sensor s = i.next();
			g2d.setColor(Color.BLUE);
			g2d.fill( new Sensor_icon( resizePoint(s.get_loc()), sensor_icon_size * zoom, sensor_icon_size * zoom) );
		}
  	} //end private void drawSensors

	// Draw the background image. Original must be resized to fit current window dimensions.
	private void drawImage(Graphics2D g2d) {
		BufferedImage resizedBackground;
		double w = canvasSize.getWidth();
		double h = canvasSize.getHeight();
		
		// Ratio of JPanel's width and height. Used to calculated max image size.
		double ratio = w / h;
		if( ratio >= aspectRatio ) {
			resizedBackground = createResizedCopy(background, (int)(h * aspectRatio), (int)h, true);
		} else {
			resizedBackground = createResizedCopy(background, (int)w, (int)(w / aspectRatio), true);
		}
		
		// Zoom is multiplied by coordinates of objects on shapeHeap to ensure they're shifted correctly.
		zoom = ( (double)resizedBackground.getWidth() / (double)background.getWidth() );
		g2d.drawImage(resizedBackground, null, 0, 0);	
	} //end private void drawImage

  	protected void clear(Graphics g) {
        	super.paintComponent(g);
  	}

	// Used to shift objects according to both the zoom and arbitrary offset.
	private Point resizePoint(Point p) {
		//System.out.println("ZOOM: " + zoom);
		Point q = new Point((int)(p.getX() + x_original_offset), (int)(p.getY() + y_original_offset));
		q.translate(x_offset, y_offset);
		q.move( (int)(q.getX() * zoom), (int)(q.getY() * zoom) );
		return q;
	}

	// Creates resized version of original background image.
  	BufferedImage createResizedCopy(Image originalImage, int scaledWidth, int scaledHeight, boolean preserveAlpha) {
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
			super( (p.getX()-(w/2)), (p.getY()-(w/2)), w, h);
		}
	}

	public void setShapeHeap(Vector<activeIcon> h) {
		shapeHeap = h;
	}

	public Vector<activeIcon> getShapeHeap() {
		return shapeHeap;
	}

  	private class ping_icon extends Ellipse2D.Double {
   		 public ping_icon(Point p, int w, int h) {
      			super( p.getX(), p.getY(), w, h);
    		}
  	} //end private class ping_icon extends Ellipse2D.Double 

} //end public class CanvasPanel
