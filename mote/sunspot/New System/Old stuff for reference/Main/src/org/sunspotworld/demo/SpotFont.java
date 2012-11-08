/*
 * Copyright (c) 2006 Sun Microsystems, Inc.
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

/**
 * SpotFont.java
 * @author rogermeike (minor mods by vipul)
 */
 

import java.util.Hashtable;

public class SpotFont implements ISpotFont {
    /**
     * The datastructure that holds the array of values representing each 
     * of the possible characters.
     */
    private Hashtable fontData;
    
    /** Creates a new instance of SpotFont */
    public SpotFont() {
        fontData = new Hashtable();
        int a[] = {126, 144, 144, 144, 126};
        fontData.put(new Character('A'), a );
        int b[] = {254, 146, 146, 146, 124};
        fontData.put(new Character('B'), b);
        int c[] = {124, 130, 130, 130, 68};
        fontData.put(new Character('C'), c);
        int d[] = {254, 130, 130, 130, 124};
        fontData.put(new Character('D'), d);
        int e[] = {254, 146, 146, 146, 130 };
        fontData.put(new Character('E'), e);
        int f[] = {254, 144, 144, 128};
        fontData.put(new Character('F'), f);
        int g[] = {124, 130, 146, 146, 92};
        fontData.put(new Character('G'), g);
        int h[] = {254, 16, 16, 16, 254};
        fontData.put(new Character('H'), h);
        int i[] = {130, 254, 130};
        fontData.put(new Character('I'), i);
        int j[] = {4, 2, 130, 252, 128};
        fontData.put(new Character('J'), j);
        int k[] = {254, 16, 40, 198};
        fontData.put(new Character('K'), k);
        int l[] = {254, 2, 2, 2, 2};
        fontData.put(new Character('L'), l);
        int m[] = {254, 64, 48, 64, 254};
        fontData.put(new Character('M'), m);
        int n[] = {254, 96, 16, 12, 254};
        fontData.put(new Character('N'), n);
        int o[] = {124, 130, 130, 130, 124};
        fontData.put(new Character('O'), o);
        int p[] = {254, 144, 144, 144, 96};
        fontData.put(new Character('P'), p);
        int q[] = {124, 130, 134, 131, 124};
        fontData.put(new Character('Q'), q);
        int r[] = {254, 144, 152, 148, 98};
        fontData.put(new Character('R'), r);
        int s[] = {100, 146, 146, 76};
        fontData.put(new Character('S'), s);
        int t[] = {128, 128, 254, 128, 128};
        fontData.put(new Character('T'), t);
        int u[] = {252, 2, 2, 2, 252};
        fontData.put(new Character('U'), u);
        int v[] = {224, 28, 2, 28, 224};
        fontData.put(new Character('V'), v);
        int w[] = {248, 6, 248, 6, 248};
        fontData.put(new Character('W'), w);
        int x[] = {198, 40, 16, 40, 198};
        fontData.put(new Character('X'), x);
        int y[] = {192, 32, 30, 32, 192};
        fontData.put(new Character('Y'), y);
        int z[] = {134, 138, 146, 162, 194};
        fontData.put(new Character('Z'), z);
        int d0[] = {124, 130, 186, 130, 124};
        fontData.put(new Character('0'), d0);
        int d1[] = {66, 254, 2};
        fontData.put(new Character('1'), d1);
        int d2[] = {78, 146, 146, 98};
        fontData.put(new Character('2'), d2);
        int d3[] = {68, 146, 146, 108};
        fontData.put(new Character('3'), d3);
        int d4[] = {112, 16, 16, 254};
        fontData.put(new Character('4'), d4);
        int d5[] = {242, 146, 146, 140};
        fontData.put(new Character('5'), d5);
        int d6[] = {124, 146, 146, 76};
        fontData.put(new Character('6'), d6);
        int d7[] = {128, 134, 152, 224};
        fontData.put(new Character('7'), d7);
        int d8[] = {108, 146, 146, 108};
        fontData.put(new Character('8'), d8);
        int d9[] = {96, 146, 146, 124};
        fontData.put(new Character('9'), d9);
        int p0[] = {0, 0, 0, 0};
        fontData.put(new Character(' '), p0);
        int p1[] = {2, 0};
        fontData.put(new Character('.'), p1);
        int p2[] = {1, 2};
        fontData.put(new Character(','), p2);
        int p3[] = {64, 138, 144, 96};
        fontData.put(new Character('?'), p3);
        int p4[] = {20, 0};
        fontData.put(new Character(':'), p4);
        int p5[] = {2, 4, 8, 16, 32};
        fontData.put(new Character('/'), p5);
        int p6[] = {0, 250, 0};
        fontData.put(new Character('!'), p6);
        System.out.println("Font inited");
    }
    
    /**
     * Return the array of pixels used to create the character
     * @param character The charater to retreive
     * @return The array of values each representing a vertical column 
     * of pixels in the character.
     */
    public int[] getChar( char character ) {
        return (int[])(fontData.get(new 
            Character( Character.toUpperCase(character))));
    }

    /**
     * 
     * @param character The character to look up
     * @return The number of pixel columns in the bitmap of the character
     */
    public int getCharWidth(char character) {
        return ((int[])(fontData.get(new 
              Character( Character.toUpperCase(character))))).length;        
    }
}
