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
 * This is the interface to an 8 pixel tall font defined in columns so
 * that it can be displayed by the Sun SPOT as it is waved around in
 * the air.
 * 
 * @author rogermeike
 */
public interface ISpotFont {
    /**
     * Given a character, get the numberic values that correspond to
     * it.
     * @param character The character to look up
     * @return An array of ints where each int is an 8-bit column of 
     * on/off values for each LED on the eDemoBoard. Together the 
     * array columns should define a bitmap for the character in question.
     */
    int[] getChar(char character);
    
    /**
     * Return the width in pixels of the character in question
     * @param character The character to examine
     * @return The width in pixels
     */
    int getCharWidth(char character);
}
