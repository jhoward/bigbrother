
import java.util.*;
import jdsl.graph.api.*;
import jdsl.graph.ref.*;
import jdsl.core.api.*;
import java.awt.*;
import jdsl.graph.algo.*;

public class WaypointsGraph extends IntegerDijkstraPathfinder {
	LinkedList<Vertex> destinations;
	LinkedList<Vertex> sources;
	IncidenceListGraph g;
	Random rand;
	int bleck;

	public WaypointsGraph() {
		destinations = new LinkedList<Vertex>();
		sources = new LinkedList<Vertex>();
		g = new IncidenceListGraph();
		rand = new Random();
		bleck = 0;
	} //end public WaypointsGraph() 

	public Vertex get_random_source() {
		//System.out.println("Sources size: " + sources.size());
		//rand = new Random();
		//bleck = (++bleck)%sources.size();
		//System.out.println("Bleck:
		return sources.get(rand.nextInt(sources.size()));
		//return sources.get(bleck);
	}

	public WaypointsGraph(IncidenceListGraph w) {
		g = w;
	}	

	public ListIterator<Vertex> get_destinations() {
		return destinations.listIterator();
	}

	public ListIterator<Vertex> get_sources() {
		return sources.listIterator();
	}

	public Iterator<Waypoint> get_waypoints() {
		VertexIterator it = g.vertices();
		Vector<Waypoint> vec = new Vector<Waypoint>();

		while(it.hasNext()) {
			vec.add((Waypoint)it.nextVertex().element());
		}

		return vec.iterator();
	}

	public Vertex add_waypoint(Waypoint w) {
		Vertex v = g.insertVertex((Object) w);
		if(w.get_is_dest()) {
			destinations.add(v);
		} else if(w.get_is_source()) {
			sources.add(v);
		}
		return v;
	}

	/*
  public void add_edge(int id1, int id2) {
		Waypoint w1 = (Waypoint)v1.element();
		Waypoint w2 = (Waypoint)v2.element();
		//System.out.println("Adding edge between waypoints " + w1.get_id() + " and " + w2.get_id());
    g.insertDirectedEdge(v1, v2, new Object());
    g.insertDirectedEdge(v2, v1, new Object());
	}
	*/

	public void connect_waypoints() {
		Vertex v1;
		Vertex v2;
		Waypoint w1;
		Waypoint w2;
		Waypoint w3;
		VertexIterator iterator1 = g.vertices();
		VertexIterator iterator2;
		while(iterator1.hasNext()) {
			v1 = iterator1.nextVertex();
			w1 = (Waypoint)v1.element();
			for(int i = 0; i < w1.get_adjacent_waypoint_ids().size(); ++i) {
				iterator2 = g.vertices();
				while(iterator2.hasNext()) {
					v2 = iterator2.nextVertex();
					w2 = (Waypoint)v2.element();	
					if(w2.get_id() == w1.get_adjacent_waypoint_ids().get(i) && (!g.areAdjacent(v1, v2))) {
    				g.insertDirectedEdge(v1, v2, new Object());
    				g.insertDirectedEdge(v2, v1, new Object());
					}	
				}
			}
		}
	} //end public void connect_waypoints()

	protected int weight(Edge e) {
		Vertex [] v = g.endVertices(e);
		double d = Toolbox.distance_between((Waypoint)v[0].element(), (Waypoint)v[1].element());
		d *= 1000;	
		return (int) d;
	}

	public LinkedList<Waypoint> get_path(Vertex source, Vertex dest, Vertex sink) {
		PathFinder tofinder = new PathFinder();
		PathFinder fromfinder = new PathFinder();
		LinkedList<Waypoint> path = new LinkedList<Waypoint>();
		tofinder.execute(g, source, dest);
		EdgeIterator to_dest = tofinder.reportPath();
		fromfinder.execute(g, dest, sink);
		EdgeIterator to_sink = fromfinder.reportPath();
		Vertex [] v = g.endVertices(to_dest.nextEdge());
		path.add((Waypoint)v[0].element());
		path.add((Waypoint)v[1].element());
		while(to_dest.hasNext()) {
			v = g.endVertices(to_dest.nextEdge());
			path.add((Waypoint)v[1].element());
		}
		v = g.endVertices(to_sink.nextEdge());
		path.add((Waypoint)v[0].element());
		path.add((Waypoint)v[1].element());
		while(to_sink.hasNext()) {
			v = g.endVertices(to_sink.nextEdge());
			path.add((Waypoint)v[1].element());
		}

		//System.out.println("Creating path.");
		if(path.size() >= 2)
			//System.out.println("Waypoint " + (path.get(0)).get_id() + " to " + (path.get(1)).get_id()); 
		for(int i = 2; i < path.size(); ++i) {
			//System.out.println("Waypoint " + (path.get(i-1)).get_id() + " to " + (path.get(i)).get_id()); 
		}	
		return path;
	}	
		
	private class PathFinder extends IntegerDijkstraPathfinder {
		public PathFinder() {
			super();
		}

		protected int weight(Edge e) {
			Vertex [] v = g.endVertices(e);
			double d = Toolbox.distance_between((Waypoint)v[0].element(), (Waypoint)v[1].element());
			d *= 1000;	
			return (int) d;
		}
	}	
} //end public class WaypointGraph extends IncidenceListGraph 

