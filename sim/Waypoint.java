
import java.io.*;
import java.awt.*;
import java.util.*;
import java.awt.geom.*;
import jdsl.graph.api.*;
import jdsl.core.api.*;

public class Waypoint extends Point {
	private int id;
	// Is this Waypoint a destination point?
	private Boolean is_dest;
	// Average rate in persons / second that room is visited.
	private double visit_rate;
	// Defines whether meetings occur at this point.
	private Boolean is_meeting;
	// Defines rate in meetings / second that meetings occur.
	private double meeting_rate;
	private double avg_meeting_size;
	// Is this point a source/sink for spawning people?
	private Boolean is_source;
	private Vector<Integer> adjacent_waypoints;	

	public Waypoint() {
		super();
		adjacent_waypoints = new Vector<Integer>();
	}

	public Waypoint(Waypoint w) {
		super(w);
		id = w.get_id();
		is_dest = w.get_is_dest();
		visit_rate = w.get_visit_rate();
		is_meeting = w.get_is_meeting();
		meeting_rate = w.get_meeting_rate();
		avg_meeting_size = w.get_avg_meeting_size();
		is_source = w.get_is_source();
		adjacent_waypoints = new Vector<Integer>(w.get_adjacent_waypoint_ids());
	}

	public Waypoint(Point p, int i, double r, Boolean s, Boolean d) {
		super(p);
		id = i;
		visit_rate = r;
		is_meeting = false;
		is_source = s;
		is_dest = d;
		adjacent_waypoints = new Vector<Integer>();
	}

	public void add_adjacent_waypoint_id(int i) {
		adjacent_waypoints.add(i);
	}

	public Vector<Integer> get_adjacent_waypoint_ids() {
		return adjacent_waypoints;
	}

	public Boolean get_is_dest() {
		return is_dest;
	}

	public Boolean get_is_source() {
		return is_source;
	} 

	public void set_id(int i) {
		id = i;
	} //end public void set_id(int i)

	public int get_id() {
		return id;
	} //end public int get_id()

	public void set_visit_rate(double p) {
		visit_rate = p;
	} //end public void set_visit_rate(double p)

	public void set_meeting_rate(double r) {
		meeting_rate = r; 
	} //public void set_meeting_rate(double r)

	public double get_meeting_rate() {
		return meeting_rate; 
	} //public double get_meeting_rate()

	public void set_avg_meeting_size(double s) {
		avg_meeting_size = s;
	}

	public double get_avg_meeting_size() {
		return avg_meeting_size;
	}
	
	public void set_is_meeting(Boolean b) {
		is_meeting = b;
	} //public void set_is_meeting(Boolean b)

	public Boolean get_is_meeting() {
		return is_meeting;
	} //pubilc Boolean get_is_meeting()

	public double get_visit_rate() {
		return visit_rate;
	} //end public double get_visit_rate()

	public int get_x() {
		return x;
	}

	public int get_y() {
		return y;
	}

} //end public class Waypoint extends Point

