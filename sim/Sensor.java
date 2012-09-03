
import java.io.*;
import java.awt.*;

public class Sensor {

	private Point location;
	private int radius;
	private int id;
	private int mote_id;
	private int port_id;
	private Boolean is_on;
		
	public Sensor(Point l, int r, int i) {
		location = l;
		radius = r;
		id = i;
		mote_id = (int)(id/10);
		port_id = id - (mote_id * 10);
		is_on = false;
	} //end public Sensor(Point l, int r, int i)

	public Sensor(Sensor s) {
		location = s.get_loc();
		radius = s.get_radius();
		id = s.get_id();
		mote_id = (int)(id/10);
		port_id = id - (mote_id * 10);
		is_on = s.get_is_on();
	}

	public Point get_loc() {
		return location;
	}

	public int get_radius() {
		return radius;	
	}

	public void set_is_on(Boolean b) {
		is_on = b;
	}

	public Boolean get_is_on() {
		return is_on;
	}

	public int get_id() {
		return id;
	} 

} //end public class Sensor
