/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package filetest;

import java.io.FileWriter;

/**
 *
 * @author jahoward
 */
public class FileTest {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        try {
            FileWriter writer = new FileWriter("/Users/jahoward/Documents/Dropbox/data/people/new_brown_hall/abc.txt", true); 

            for(int i = 0; i < 10; i++) {
                String tmp = i + "\n";
                writer.write(tmp);
            }
            writer.close();  
        } catch (Exception e) {
            System.out.println("Problem writing data.");
            System.out.println(e);
        }
    }
}
