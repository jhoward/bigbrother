
/**
 * Used for issuing queries to db located on the office computer.
 * Can be tested locally, of course, but remote connections are 
 * the goal.
 */

import java.io.*;
import java.util.*;
import java.sql.*;

public class PlaybackDb{

  private String dbName;
	private static String username = "bigbrother";
	private static String password = "bigbrotherpass";
  private Connection conn;
  private String useDb;
  private Statement s;
	private Boolean connected;

	public PlaybackDb() {
		dbName = "bigbrother";
		useDb = new String("USE bigbrother;");
		connectDb();
	} //end public db(String name)

  public void connectDb() {
    conn = null;

    try
    {
      String url = "jdbc:mysql://localhost:3306/mysql";
      Class.forName ("com.mysql.jdbc.Driver").newInstance ();
      conn = DriverManager.getConnection (url, username, password);
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
    finally
    {
      if (conn != null)
      {
      	try {
          Statement s = conn.createStatement();
          s.executeUpdate(useDb);
          s.close();
        } catch (Exception err) {
					err.printStackTrace();
				}
    	}
		}
  } //end public void connectDb()

	public Vector<ReadingState> queryDb(String startTime, String endTime) {
		Vector<ReadingState> states = new Vector<ReadingState>();
		String query = "show tables;";
		try {
      s = conn.createStatement();
			s.executeQuery (query);
			ResultSet tableRs = s.getResultSet();	
			while(tableRs.next()) {
				Statement ss = conn.createStatement();
				String tableName = tableRs.getString("Tables_in_bigbrother");
				String q = new String ( "SELECT * FROM " + tableName + " WHERE datetime < " + endTime + " AND datetime > " + startTime + " ORDER BY datetime;" ); 
				//System.out.println(q);
				ss.executeQuery(q);
				ResultSet dataRs = ss.getResultSet();
				while(dataRs.next()) {
					//System.out.println(remove_chars(tableName, "sensor") + "\t" + remove_delimiters(dataRs.getString("datetime")));
					states.add(new ReadingState(remove_delimiters(dataRs.getString("datetime")), remove_chars(tableName, "sensor")));
				}
				System.out.println("HI");
				dataRs.close();
			}
			tableRs.close();
      s.close();
		} catch (Exception e) {
      System.err.println("Query failed." + e.getMessage());
		}
		return states;
	} //end public void queryDb()

	public void exit() {
		try {
		conn.close();
		} catch (Exception e) {}
	
	}

	private String remove_delimiters(String s) {
		String t = new String(s);
		t = remove_chars(t, "-");
		t = remove_chars(t, ":");
		t = remove_chars(t, " ");
		t = remove_chars(t, ".");
		return t;
	}

	private String remove_chars(String s, String c) {
		String n = new String(s);
		String tmp_n;
		while(n.indexOf(c) != -1) {
			tmp_n = n.substring(0, n.indexOf(c));
			String arg = n.substring(n.indexOf(c)+c.length(), n.length());
			tmp_n = tmp_n.concat(arg);
			n = tmp_n;
		}
		return n;
	}

	public static void main(String [] args) {
		PlaybackDb db = new PlaybackDb();
		db.queryDb("20070910071459", "20070910071502");

	}
} //end public class db
