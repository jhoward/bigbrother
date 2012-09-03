
import java.io.*;
import java.util.*;
import java.awt.Point;

public class Wall {

	private Point startpoint;
	private Point endpoint;
	
	public Wall() {
	} //end public Wall()

	public Wall(Point s, Point e) {
		startpoint = s;
		endpoint = e;
	} //end public Wall(Point s, Point e)

	public Point get_startpoint() {
		return startpoint;
	}

	public Point get_endpoint() {
		return endpoint;
	}

} //end public class Wall
