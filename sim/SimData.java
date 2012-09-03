
import java.util.*;
import java.io.*;
import com.thoughtworks.xstream.XStream;

// This is a "struct" to hold data related to the simulator. With the class being this simple, conversion
// to XML should be clean and easy. Most important info: walls, sensors, and waypoints.
//

public class SimData {

	public String config_file;

	// If true, display output on visualizer
	public Boolean visualize;

	// Output to either "file" or "db"
	public String output_type;

	// If writing data to file, this is the filename
	public String outfilename;

	public String logfilename;

	public String dbname;

	public String dbusername;

	public String dbpassword;

	public SimClock clock;
	
	public Vector<Waypoint> waypoints;

	public Vector<Sensor> sensors;

	public Vector<Wall> walls;

	public SimData() {
		clock = new SimClock();		

	}

}

