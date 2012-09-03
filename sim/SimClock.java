
import com.thoughtworks.xstream.XStream;

/*
 * Time is recorded on a twenty four hour clock using an integer value. The hour, minute, second, and 1/100 second are stored. So 23:17:1:57 would be 23170157.
*/

public class SimClock {
	public int start_time;
	private int end_time;
	// Units of 1/100 s
	private int timestep;
	private int current_time;

	public SimClock() {
		start_time = 0;
		end_time = 0;
		timestep = 0;
		current_time = 0;
	}

	public SimClock(int st, int et, int step) {
		start_time = st;
		end_time = et;
		timestep = step;
		current_time = start_time;
	}

	public void reset() {
		current_time = start_time;
	} //end public void reset()

	public Boolean done() {
		return (current_time >= end_time);
	} //end public Boolean done()

	public void add_time(int t) {
		int h = get_current_h();
		int m = get_current_m();
		int s = get_current_s();
		int c = get_current_centi_s();

		int remainder = (c + t) / 100;
		c = (c + t) % 100;
		s += remainder;
		remainder = s / 60;
		s = s % 60;
		m += remainder;
		remainder = m / 60;
		m = m % 60;
		h += remainder;
		remainder = h / 60;
		h = h % 60;
		current_time = h*1000000 + m*10000 + s*100 + c;
	}

	public void increment() {
		add_time(timestep);
	}

	public int get_current_centi_s() {
		return current_time % 100;
	}

	public int get_current_s() {
		int s = current_time % 10000;
		return (s / 100);
	}

	public int get_current_m() {
		int m = current_time % 1000000;
		return (m / 10000);
	}

	public int get_current_h() {
		return (current_time / 1000000);
	}

	public int get_current_time() {
		return current_time;
	}
	
	public int get_end_time() {
		return end_time;
	}

	public double get_timestep() {
		return (timestep / 100);
	}

	public void set_current_time(int t) {
		current_time = t;
	}

	public static void main(String [] args) {
		/*
		XStream xstream = new XStream();
		SimClock clock = new SimClock();
		String x = xstream.toXML(clock);
		System.out.println(x);
		*/
		SimClock clock = new SimClock(11000000, 12000000, 100);
		while(!clock.done()) {
			clock.increment();
		}
	}
} //end public class SimClock
