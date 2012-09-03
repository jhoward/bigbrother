
import java.io.*;
import com.thoughtworks.xstream.XStream;
import java.util.*;
import java.awt.*;
import jdsl.graph.api.*;

public class sim {

	private String config_file;
	private floorplan layout;
	private Vector<Person> inactive_people;
	private Vector<Person> active_people;
	private SimClock clock;
	private Vector<SimState> simstates;
	private Boolean visualize;
	private String output_type;
	private String outfilename;
	private String logfilename;
	private String dbname;
	private String dbusername;
	private String dbpassword;
	private RandomAccessFile log;
	private RandomAccessFile out;

	public sim() {
 		config_file = new String();
		layout = new floorplan();
		inactive_people = new Vector<Person>();
		active_people = new Vector<Person>();
		simstates = new Vector<SimState>();
		clock = new SimClock();
		visualize = false;
		output_type = new String();
		outfilename = new String();
		logfilename = new String();
		dbname = new String();
		dbusername = new String();
		dbpassword = new String();
	} //end public sim(String filename)

	//public void add_person(Waypoint source_waypoint, Waypoint dest_waypoint, Waypoint sink_waypoint, int time) {
	//	LinkedList<Waypoint> path = layout.get_path(source_vertex, dest_vertex, source_vertex);
	//	inactive_people.add(new Person(source_waypoint, dest_waypoint, source_waypoint, path, time));			
	//}

	public void run() {
		clock.reset();
		create_people();
		Collections.sort(inactive_people);		 

		while(!clock.done()) {
			clock.increment();
			for(int i = 0; i < active_people.size(); ++i) {
				//System.out.println("\t" + active_people.get(i).get_loc());
			}
			while(!inactive_people.isEmpty() && inactive_people.get(0).get_spawn_time() <= clock.get_current_time()) {
				active_people.add(inactive_people.remove(0));
			}
			Sensor s;
			Iterator<Sensor> it = layout.get_sensors();
			while(it.hasNext()) {
				s = it.next();
				s.set_is_on(false);
			}
			move_people();
			SimState state = new SimState(active_people, layout.get_sensors_vector(), clock.get_current_time());
			simstates.add(state);
		} //end while(current_time <= clock.get_end_time())
		for(int i = 0; i < simstates.size(); ++i) {
			Iterator<Person> tmp_it = simstates.get(i).get_people();
		}

	} //end public void run()

	public void move_people() {
		for(int i = 0; i < active_people.size(); ++i) {
			Person p = active_people.get(i);
			p.move(clock.get_timestep() * p.get_speed());
			Sensor s;
			Iterator<Sensor> it = layout.get_sensors();
			while(it.hasNext()) {
				s = it.next();
				if(Toolbox.distance_between(p.get_loc(), s.get_loc()) <= s.get_radius()) {
					try {
						out.writeBytes(s.get_id() + "\t" + clock.get_current_time() + "\n");
					} catch (IOException err) {}
					s.set_is_on(true);
				}
			}

			if(p.sink_reached()) {
				active_people.remove(i);
			}
			}
	} //end public void move_people()

	public void create_people() {
		ListIterator<Vertex> di = layout.get_destinations();
		ListIterator<Vertex> si = layout.get_sources();
		Vertex dest_vertex;
		Waypoint dest_waypoint;
		Vertex source_vertex;
		Vertex sink_vertex;
		Waypoint source_waypoint;
		Waypoint sink_waypoint;
		
		while(di.hasNext()) {
			dest_vertex = di.next();
			dest_waypoint = new Waypoint((Waypoint)(dest_vertex.element()));
			
			SimClock t = new SimClock();
			t.set_current_time(Toolbox.get_exp_dist(dest_waypoint.get_visit_rate())*100);
			while(t.get_current_time() <= clock.get_end_time()) {
				source_vertex = layout.get_random_source();
				sink_vertex = layout.get_random_source();
				source_waypoint = new Waypoint((Waypoint)(source_vertex.element()));
				sink_waypoint = new Waypoint((Waypoint)(sink_vertex.element()));
				try {
					log.writeBytes("Creating person with source " + source_waypoint.get_id() + " and dest " + dest_waypoint.get_id() + " and sink " + sink_waypoint.get_id() + " and spawn time " + t.get_current_time() + "\n");
				} catch (IOException err) {
				}
				LinkedList<Waypoint> path = layout.get_path(source_vertex, dest_vertex, sink_vertex);
				inactive_people.add(new Person(source_waypoint, dest_waypoint, sink_waypoint, path, t.get_current_time()));			
				t.add_time(Toolbox.get_exp_dist(dest_waypoint.get_visit_rate())*100);
			}
		}	
		
	} 

	public Vector<SimState> get_simstates() {
		return simstates;
	}	//end public Vector<SimState> get_simstates()
	
	public void set_layout(floorplan f) {
		layout = f;
	} //end public void set_layout(floorplan f)

	public floorplan get_layout() {
		return layout;
	} //end public floorplan get_layout()
		
	public Boolean fromXML(String filename) {
		try {
			XStream xstream = new XStream();
  		FileInputStream fin = new FileInputStream(filename);
			try {
			SimData data = (SimData)xstream.fromXML(fin);
			this.config_file = data.config_file;
			this.visualize = data.visualize;
			this.output_type = data.output_type;
			this.outfilename = data.outfilename;
			this.logfilename = data.logfilename;
			this.dbname = data.dbname;
			this.dbusername = data.dbusername;
			this.dbpassword = data.dbpassword;
			this.clock = data.clock;	
			layout.set_walls(data.walls);
			layout.set_sensors(data.sensors);	

			for(int i = 0; i < data.waypoints.size(); ++i) {
				layout.add_waypoint(data.waypoints.get(i));
			}
	
			layout.connect_waypoints();
	
			try {
				log = new RandomAccessFile(logfilename, "rw");
			} catch (IOException err) {
				System.out.println("Error parsing " + filename + ". Either there is an error with the XML syntax, or config.xml structure does not match class structure. Exiting.");
				System.exit(1);
			}
			try {
				out = new RandomAccessFile(outfilename, "rw");
			} catch (IOException err) {
				System.out.println("Unable to open outputfile. Exiting.");
				return false;
			}
			} catch (Exception fuck) {
				System.out.println("Error parsing config file. Exiting.");
				return false;
			}
			return true;
		} catch (IOException err) {
			System.out.println("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
			return false;
		}	
	}

	public void output() {
		if(visualize) {
			new ControlPanel(this);
		}
	} //end public void output()

	public SimClock get_clock() {
		return clock;
	}

	public static void main(String [] args) {

		try {
			sim s = new sim();
			if(!s.fromXML(args[0])) {
				System.out.println("Error opening file. Aborting.");
				System.exit(1);
			} else {	
			s.run();
			s.output();
			}
		} catch (ArrayIndexOutOfBoundsException err) {
			System.out.println("Usage: java -jar Sim.jar <configfile.xml>");
			System.exit(1); 
		} 

	} //end public static void main(String [] args)

} //end public class sim
