/*
 * Copyright (c) 2006-2010 Sun Microsystems, Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to 
 * deal in the Software without restriction, including without limitation the 
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
 * sell copies of the Software, and to permit persons to whom the Software is 
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in 
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 * DEALINGS IN THE SOFTWARE.
 **/

package org.sunspotworld.demo;

import com.sun.spot.resources.Resources;
import com.sun.spot.resources.transducers.IAccelerometer3D;
import com.sun.spot.resources.transducers.ITriColorLEDArray;
import com.sun.spot.sensorboard.hardware.IADT7411;
import java.io.IOException;

/**
 * This class is used to flash the LEDs on and off in a pattern that
 * will display characters in the air if the Sun SPOT is moved back
 * and forth quickly.  For best results, swing the Sun SPOT at a rate
 * of about 2-3 cycles per second.
 * 
 * This uses the accelerometer to sense the back and forth motion
 * which triggers the display to start blinking the LEDs in a pattern
 * to display characters.
 *
 * @author Roger Meike (mods by vipul)
 * @version 1.1
 */

public class AirText {
    
    /**
     * The array of LEDs to blink
     */
    private ITriColorLEDArray LED;
    /**
     * The device used to sense acceleration
     */
    private IAccelerometer3D accelerometer;
    /**
     * A SpotFont to display characters in the air
     */
    private SpotFont font;
    
    private int dots[];
    private int preferredDispLen = 5;
    
    /**
     * Creates a new instance of AirText
     * @param inBoard the eDemoBoard we will be operating on
     */
    public AirText(  ) {
        LED           = (ITriColorLEDArray)Resources.lookup(ITriColorLEDArray.class);
        accelerometer = (IAccelerometer3D) Resources.lookup(IAccelerometer3D.class );
        IADT7411 adt = (IADT7411) Resources.lookup(IADT7411.class);
        if (adt != null) adt.setFastConversion(true);
        font = new SpotFont();
        setColor( 0, 0, 0);
        LED.setOff();
    }
    
    /**
     * Set Red, Green or Blue on (non-zero) or off (zero).  Note that
     * we don't provide support for intensity levels because on LEDs
     * intensities are acheived by pulsing the LED and this would
     * screw up the data we are trying to display.  Also note that
     * while you can turn on multiple colors at once, we have found
     * this distracts from the legibility of the displayed text.
     * Therefore I recommend passing in 255 for exactly one of the
     * colors and zeros for the others.
     * @param red non-zero if you want the LEDs to display red
     * @param green non-zero if you want the LEDs to display green
     * @param blue non-zero if you want the LEDs to display blue
     */
    public void setColor( int red, int green, int blue ){
        LED.setOff();
        LED.setRGB((red==0)?0:255,(green==0)?0:255,(blue==0)?0:255);
    }
    
    /**
     * Display a single word statically on the display.  In order to
     * display the string correctly it should be about 6 characters or
     * less, otherwise the string will not display completely before
     * you start moving in the opposite direction. In these cases,
     * some characters may display backwards.
     * @param string The string to display
     * @param count how many swings to display it
     */
    public void swingThis( String string, int count ) {
        int i = 0;
        double threshold = 1.0;
        try {
            while ( i < count ) {
                // wait for motion
                double acceleration = accelerometer.getAccelY();
                // System.out.println("accelerometer =" + acceleration + 
                // " range = " + range );
                if ( acceleration > threshold ){
                    //we have acceleration right motion
                    while ( acceleration > threshold ){
                        Thread.sleep(10);
                        acceleration = accelerometer.getAccelY();
                    }
                    displayStringForward( string );
                    i++;
                    // System.out.println("time = " + (now-start) + 
                    // "fwadjust = " + forwardAdjust + ", Target = " + period);
                } else if ( acceleration < -threshold ){
                    // we have motion to the left
                    while ( acceleration < -threshold ){
                        Thread.sleep(10);
                        acceleration = accelerometer.getAccelY();
                    }
                    displayStringBackward( string );
                    i++;
                }

                Thread.yield();    // so the SpotMonitor thread won't starve
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        } catch (InterruptedException ex) {
            ex.printStackTrace();
        }
    }
    
    /**
     * Display string in a left to right swinging pattern
     * (i.e. forward)
     * @param string A string to display
     */
    public void displayStringForward( String string ){
        for( int i = 0; i < string.length(); i++ ){
            displayCharacterForward( string.charAt(i) );
        }
    }
    
    /**
     * Display string in a right to left swinging pattern
     * (i.e. backward)
     * @param string The string to display
     */
    public void displayStringBackward( String string ) {
        for( int i = string.length() - 1; i >= 0; i-- ) {
            displayCharacterBackward( string.charAt(i) );
        }
    }
    
    
    /**
     * Display a single character left to right
     * @param character Character to be displayed
     */
    public void displayCharacterForward( char character ){
        try {
            dots = font.getChar(character);
            
            for ( int i = 0; i < dots.length; i++ ){
                LED.setOn( dots[i] );
                // System.out.print(character);
                Thread.sleep(1);
            }
            LED.setOff();
            Thread.sleep(1);
            
        } catch (InterruptedException ex) {
            ex.printStackTrace();
        }
    }
    
    /**
     * Display a single character right to left
     * @param character The character to be displayed
     */
    public void displayCharacterBackward( char character ){
        try {
            dots = font.getChar(character);
            for ( int i = dots.length-1; i >= 0; i-- ) {
                LED.setOn( dots[i] );
                // System.out.print(character);
                Thread.sleep(1);
            }
            LED.setOff();
            Thread.sleep(1);
        } catch (InterruptedException ex) {
            ex.printStackTrace();
        }
    }
    
    /**
     * Scroll a string across the swinging display
     * @param string The string to display
     * @param scrollrate The speed to scroll at. To be readable, 
     * this should be a value from 1 to 10.
     */
    public void scroll( String string, int scrollrate ) {
        long start = System.currentTimeMillis();
        long left = start;
        long right = start;
        int overhead = 140; // The magic values of overhead and gap 
        int gap = 170;      // were set empirically
        int i, j, offset = overhead;
        int len = string.length();
        int mapSize = 0;
        int[] bitmap;
        boolean lefting = false; //debug
        
        System.out.println("start scrolling " + string);
        
        // find the length of the bitmap
        for ( i = 0; i < len; i++ ) {
            mapSize += (font.getCharWidth(string.charAt(i))) + 1;
        }
        
        // create a custom length array to hold the bitmap
        bitmap = new int[mapSize + (2 * overhead)];
        
        for ( i = 0; i < bitmap.length; i++ )
            bitmap[i] = 0;
        
        // preload the bitmap for the whole string
        // this is probably a bad idea memory-wse, but I'm in a hurry
        for ( i = 0; i < len; i++ ) {
            int[] character = font.getChar(string.charAt(i));
            for ( j = 0; j < character.length; j++ ) {
                bitmap[offset++] = character[j];
            }
            bitmap[offset++] = 0;
        }
        
        System.out.println("bitmap inited");
        offset = overhead - (gap-overhead);
        
        double threshold = 1.0;
        try {
            while ( offset < bitmap.length - gap ){
                // wait for motion
                double acceleration = accelerometer.getAccelY();
                if ( acceleration > threshold ){
                      while ( acceleration > threshold ){
                        Thread.sleep(10);
                        acceleration = accelerometer.getAccelY();
                    }
                    
                    bltBitmapForward( bitmap, offset, gap - overhead );
                    
                    offset += scrollrate;
                    
                } else if ( acceleration < -threshold ){
                    while ( acceleration < -threshold ){
                        Thread.sleep(10);
                        acceleration = accelerometer.getAccelY();
                    }
                    bltBitmapBackward( bitmap, offset, gap - overhead );
                    offset += scrollrate;
                }
                try {
                    Thread.sleep(100);
                } catch (InterruptedException ex) {
                    ex.printStackTrace();
                }
            }
            System.out.println( " finished scrolling " + gap);
            
        } catch (IOException ex) {
            ex.printStackTrace();
        } catch (InterruptedException ex) {
            ex.printStackTrace();
        }
        
    }
    
    private void bltBitmapForward(int[] bitmap, int offset, int size) {
        
        try {
            for (int i = offset; i < offset + size; i++ ){
                LED.setOn( bitmap[i] );
                Thread.sleep(1);
            }
            LED.setOff();
        } catch (InterruptedException ex) {
            ex.printStackTrace();
        }
    }
    
    private void bltBitmapBackward(int[] bitmap, int offset, int size) {
        try {
            for (int i = offset + size - 1; i >= offset; i-- ){
                LED.setOn( bitmap[i] );
                Thread.sleep(1);
            }
            LED.setOff();
        } catch (InterruptedException ex) {
            ex.printStackTrace();
        }
    }
}
