
import java.io.*;
import java.util.*;
import jdsl.graph.api.*;
import jdsl.graph.ref.*;
import jdsl.core.api.*;
import java.awt.*;
import com.thoughtworks.xstream.XStream;

public class floorplan {
	
	private Vector<Wall> walls;
	private Vector<Sensor> sensors;
	private WaypointsGraph graph; 

	public floorplan() {
		walls = new Vector<Wall>();
		sensors = new Vector<Sensor>();
		graph = new WaypointsGraph();
	}
	
	public Sensor get_sensor(int id) {
		for(int i = 0; i < sensors.size(); ++i) {
			if(id == sensors.get(i).get_id()) {
				return sensors.get(i);
			}
		}
		return null;
	}

	public Vertex get_random_source() {
		return graph.get_random_source();
	}

	public Iterator<Wall> get_walls() {
		return walls.iterator();
	}

	public void set_walls(Vector<Wall> w) {
		walls = w;
	}

	public void set_sensors(Vector<Sensor> s) {
		sensors = s;
	}

	public Iterator<Sensor> get_sensors() {
		return sensors.iterator();
	}
	
	public Vector<Sensor> get_sensors_vector() {
		return sensors;
	}

	public Vector<Wall> get_walls_vector() {
		return walls;
	}

	public Iterator<Waypoint> get_waypoints() {
		return graph.get_waypoints();
	}

	public void connect_waypoints() {
		graph.connect_waypoints();
	}

	public void add_wall(Wall w) {
		walls.add(w);
	} //end public void add_Wall(Wall w)

	public void add_sensor(Sensor s) {
		sensors.add(s);
	} //end public void add_sensor(Sensor s)

	public void add_edge(Vertex v1, Vertex v2) {
		//graph.add_edge(v1, v2);
	}

	public Vertex add_waypoint(Waypoint w) {
		return graph.add_waypoint(w);
	}

	public ListIterator<Vertex> get_sources() {
		return graph.get_sources();
	}

	public ListIterator<Vertex> get_destinations() {
		return graph.get_destinations();
	}
	
	public LinkedList<Waypoint> get_path(Vertex source, Vertex dest, Vertex sink) {
		LinkedList<Waypoint> path = graph.get_path(source, dest, sink);	
		return path;
	}

}
