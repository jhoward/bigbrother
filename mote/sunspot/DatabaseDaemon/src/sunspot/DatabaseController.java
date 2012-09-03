package sunspot;

import java.sql.Statement;
import java.sql.DriverManager;

public class DatabaseController {

    private static final String DATABASE_URL = "jdbc:mysql://localhost:3306/";
    private static final String DATABASE_NAME = "bigbrother";
    private static final String DATABASE_USER = "root";
    private static final String DATABASE_PASSWORD = "brother";
    private static final String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    private static final String DATA_TABLE_NAME = "data";

    private Statement stmt = null;
    private java.sql.Connection dbCon = null;

    public DatabaseController() throws Exception {
        initialize();
    }

    private void initialize() throws Exception {
        Class.forName(JDBC_DRIVER);
        String url = DATABASE_URL + DATABASE_NAME;
        dbCon = DriverManager.getConnection(url, DATABASE_USER,
                                            DATABASE_PASSWORD);

        System.out.println("Connection: " + dbCon);
        stmt = dbCon.createStatement();

    }

    public void addEntry(String sensorTime, int moteID, int sensorID, int value,
                    String tags, String extra) throws Exception {
        stmt.execute("INSERT INTO " + DATA_TABLE_NAME +
                        "(database_time, sensor_time, mote_id, sensor_id, " +
                        "value, tag, extra)" + " VALUES(" +
                        "NOW(), \'" + sensorTime + "\', " +
                        Integer.toString(moteID) + ", " +
                        Integer.toString(sensorID) + ", " +
                        Integer.toString(value) + ", " +
                        "\'" + tags + "\', " +
                        "\'" + extra + "\')");
    }
}
