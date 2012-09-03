
import java.io.*;
import java.util.*;
import java.lang.Math;
import java.awt.geom.*;

public class Toolbox {

	public Toolbox() {
		Random r = new Random();
	}

	public static int get_exp_dist(double d) {
		return (int)((-1/d) * Math.log( Math.random() ));
	}

	public static double distance_between(Point2D a, Point2D b) {
		double x = Math.abs(a.getX() - b.getX());
		double y = Math.abs(a.getY() - b.getY());
		double distance = (int) Math.sqrt(x*x + y*y);
		return distance;
	}

}
