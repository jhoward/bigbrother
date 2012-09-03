
import java.util.*;

public class SimState {

	private Vector<Person> people;
	private Vector<Sensor> sensors;
	private int current_time;

	public SimState() {
		people = new Vector<Person>();
		sensors = new Vector<Sensor>();
		current_time = 0;
	}

	public SimState(Vector<Person> p, Vector<Sensor> s, int t) {
		people = new Vector<Person>();
		for(int i = 0; i < p.size(); ++i) {
			people.add(new Person(p.get(i)));
		}
		sensors = new Vector<Sensor>();
		for(int i = 0; i < s.size(); ++i) {
			sensors.add(new Sensor(s.get(i)));
		}
		current_time = t;
		//System.out.println("SimState created");
		for(int i = 0; i < people.size(); ++i) {
			//System.out.println(people.get(i).get_loc());
		}
	} //end public SimState()

	public Iterator<Person> get_people() {
		return people.iterator();
	}
	
	public Iterator<Sensor> get_sensors() {
		return sensors.iterator();
	}

	public int get_time() {
		return current_time;
	}

	public int get_num_people() {
		return people.size();
	}

} //end public class SimState
