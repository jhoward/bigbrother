
import java.util.*;
import java.io.*;
import java.awt.*;
import jdsl.graph.api.*;
import java.awt.geom.*;

public class Person implements Comparable {
	private Waypoint source;
	private Waypoint dest;
	private Waypoint sink;
	// Speed in m/s at which Person moves 
	private double speed;
	// Person's current location within the point
	private Point2D.Double loc;
	private int spawn_time;
	private LinkedList<Waypoint> path;
	private int current_waypoint;
	private Boolean sink_reached;

	public Person(Waypoint source, Waypoint dest, Waypoint sink, LinkedList<Waypoint> path, int spawn_time) {
		this.source = source;
		//this.dest = dest;
		//this.sink = sink;
		this.path = path;
		this.speed = 3;
		loc = new Point2D.Double(source.getX(), source.getY());
		this.spawn_time = spawn_time;
		current_waypoint = 0;
		sink_reached = false;
	} //end public Person()

	public Person(Person p) {
		source = p.get_source();
		dest = p.get_dest();
		speed = p.get_speed();
		loc = new Point2D.Double(p.get_loc().getX(), p.get_loc().getY());
		spawn_time = p.get_spawn_time();
		sink_reached = p.sink_reached();
	}

	public int compareTo(Object p) {
		Person q = new Person((Person) p);
		if(spawn_time < q.get_spawn_time()) {
			return -1;
		} else if(spawn_time == q.get_spawn_time()) {
			return 0;
		} else {
			return 1;
		}
	}

	public void move(double stride) {
		Waypoint objective_waypoint = path.get(current_waypoint);
		double gap = Toolbox.distance_between(loc, objective_waypoint);
		if(stride < gap) {
			double ratio = stride / gap;
			double diff_x = objective_waypoint.get_x() - loc.getX();
			double diff_y = objective_waypoint.get_y() - loc.getY();
			diff_x *= ratio;
			diff_y *= ratio;
			//System.out.println("Moving person from " + loc);
			loc.setLocation(loc.getX() + diff_x, loc.getY() + diff_y);
			//System.out.println(" to " + loc); 
		} else { 
			if(current_waypoint == (path.size()-1)) {
				sink_reached = true;
			} else {
				stride -= gap;
				loc.setLocation((double)objective_waypoint.get_x(), (double)objective_waypoint.get_y());
				++current_waypoint;
				move(stride);
			}
		}

	} //end public void move(int timestep)

	public Boolean sink_reached() {
		return sink_reached;
	}

	public LinkedList<Waypoint> get_path() {
			return path;
	} 

	public int get_spawn_time() {
		return spawn_time;
	}

	public void set_spawn_time(int i) {
		spawn_time = i;
	}

	public Waypoint get_source() {
		return source;
	} //end public int get_source_point()

	public void set_source_point(Waypoint s) {
		source = s;
	} //end public void set_source_point(int s)

	public void set_dest(Waypoint d) {
		dest = d;
	} //end public void set_dest_point(int d)

	public Waypoint get_dest() {
		return dest;
	} //end public int get_dest_point()

	public void set_speed(double s) {
		speed = s;
	} //end public void set_speed(double s)

	public double get_speed() {
		return speed;
	} //end public double get_speed()

	public Point2D.Double get_loc() {
		return loc;
	} //end public Point get_loc()

	public void set_loc(Point2D.Double p) {
		loc = p;
	} //end public void set_loc(Point p)

} //end public class Person
