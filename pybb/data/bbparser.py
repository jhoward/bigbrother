"""
bbparser.py

Author: James Howard

Contains all methods used for the parsing of raw sensor data or converting
raw data into binary data.
"""

import time
import pybb.data.bbdata as bbdata
import datetime

def rawToCompressedRaw(readLocation, \
                    f = "2007-01-01 00:00:00", \
                    t = "2011-01-01 00:00:00"):
    """Makes a list of type bbdata.data with each entry containing a datetime 
    object.
    
    Only saves on data from f to t.
    """
    
    fd = datetime.datetime.strptime(f, "%Y-%m-%d %H:%M:%S")
    td = datetime.datetime.strptime(t, "%Y-%m-%d %H:%M:%S")
    
    data = bbdata.Data()
    
    f = open(readLocation).readlines()
    for timeLine in f:
        s = timeLine.split()
        s = str(s[1]) + " " + str(s[2])
        s = datetime.datetime.strptime(s, "%Y-%m-%d %H:%M:%S")
        
        if s > fd and s < td:
            data.append(s)
    
    data.st = data[0]
    data.et = data[-1]
    return data


def parseRawData(readLocation, writeLocation, sensors, startTime, \
                    endTime, verbose = False):
    """Converts raw sensor data from the old sensor network and converts 
    it into the same raw data format but parsed by the rules given.  
    
    This is optional, but allows for future manipulation of the files to be 
    faster due to shorter text files.
    
    sensorList is a list of sensor values.
    startTime/endTime must be of the format "YYYY-MM-DD HH:MM:SS"
    
    will raise an exception if a sensor's file can not be opened.
    
    TODO: Add possibility to parse intermittantly.
    """
    startTimeNum = time.strptime(startTime, "%Y-%m-%d %H:%M:%S")
    startTimeNum = time.mktime(startTimeNum)
    endTimeNum = time.strptime(endTime, "%Y-%m-%d %H:%M:%S")
    endTimeNum = time.mktime(endTimeNum)

    if verbose:
        print "parseRawData"

    for i in sensors:
        sensorString = readLocation + "sensor" + str(i) + ".txt"
    
        if verbose:
            print "Opening " + str(sensorString)
    
        f = open(sensorString).readlines()
        file = open(writeLocation + "sensor" + str(i) + ".txt", 'w')
    
        for timeLine in f:
            s = timeLine.split()
            s = str(s[1]) + " " + str(s[2])
            s = time.strptime(s, "%Y-%m-%d %H:%M:%S")
            s = time.mktime(s)
            if s >= startTimeNum and s < endTimeNum:
               file.write(timeLine) 
        
            if s > endTimeNum:
                file.close()
                break


def rawDataToBinary(readLocation, sensors, verbose = False):
    """Converts raw text data to an array.
    
    sensorList is a list of sensors. Example - [10, 11, 21, 34, 92, 103]

    returns a numpy array of data and the start and end times of the 
    data described by the files.  
    
    Array dimensions: dataLen X sensors
    
    will raise an exception if a sensor's file can not be opened.
    """

    tmpSensors = []
    startTime = 0
    endTime = 0

    if verbose:
        print "rawDataToBinary"

    for i in sensors:
        sensorString = readLocation + "sensor" + str(i) + ".txt"

        if verbose:
            print "Opening " + str(sensorString)
            
        f = open(sensorString).readlines()

        tmpF = []

        for timeLine in f:
            s = timeLine.split()
            s = str(s[1]) + " " + str(s[2])
            s = time.strptime(s, "%Y-%m-%d %H:%M:%S")
            s = time.mktime(s)

            tmpF.append(s)

        #Check global start and end time
        if tmpF[-1] > endTime:
            endTime = tmpF[-1]

        if startTime == 0:
            startTime = tmpF[0]

        if tmpF[0] < startTime:
            startTime = tmpF[0]

        tmpSensors.append(tmpF)

    if verbose:
        print "Converting data"

    #Convert to an array
    N = int(round(endTime - startTime)) + 1
    data = numpy.zeros((N, len(tmpSensors)), float)

    for i in range(len(tmpSensors)):
        for timeLine in tmpSensors[i]:
            data[int(round(int(timeLine) - startTime)), i] = 1

    return data, startTime, endTime


def rawDataToBinaryExtended(readLocation, sensors, \
                            startTime, endTime, \
                            periodicStart = "00:00:00", \
                            periodicEnd = "23:59:59", \
                            validDays = [0, 1, 2, 3, 4, 5, 6], \
                            compressArray = False, \
                            verbose = False):
    """A more complete version of rawDataToBinary that can accept a 
    startTime, endTime, along with the option for periodicity so that it 
    becomes possible to parse just certain times and days of the week over 
    a long period of time.
    
    startTime/endTime is of the format "YYYY-MM-DD HH:MM:SS"
    periodicStart/periodicEnd is of the format "HH:MM:SS"
        This determines what part of a given day will be parsed.
        
    validDays is a list of the valid days of the week from which to parse.
    A full week list is [0, 1, 2, 3, 4, 5, 6] corresponding to Monday to 
    Sunday.
    
    returns a bbdata.Data array of data and the start and end times of the 
    data described by the files.
    """
    
    startTimeNum = time.strptime(startTime, "%Y-%m-%d %H:%M:%S")
    startTimeNum = time.mktime(startTimeNum)
    endTimeNum = time.strptime(endTime, "%Y-%m-%d %H:%M:%S")
    endTimeNum = time.mktime(endTimeNum)
    pStartTime = time.strptime(periodicStart, "%H:%M:%S")
    pEndTime = time.strptime(periodicEnd, "%H:%M:%S")
    
    arrayStartTime = 0
    arrayEndTime = 0
    tmpSensors = []
    
    if verbose:
        print "rawDataToBinaryExtended"

    for i in sensors:
        sensorString = readLocation + "sensor" + str(i) + ".txt"

        if verbose:
            print "Opening " + str(sensorString)

        f = open(sensorString).readlines()
   
        tmpF = []

        for timeLine in f:
            s = timeLine.split()
            s = str(s[1]) + " " + str(s[2])
            s = time.strptime(s, "%Y-%m-%d %H:%M:%S")

            #Check if before startTime or after endTime.  If not valid
            #end the loop
            if time.mktime(s) < startTimeNum:
                continue
            if time.mktime(s) > endTimeNum:
                break
            
            #Parse out the time to only the hour information.
            tmpTime = time.strftime("%H:%M:%S", s)
            tmpTime = time.strptime(tmpTime, "%H:%M:%S")
            
            #Check if within periodic time.
            if tmpTime < pStartTime:
                continue
            if tmpTime > pEndTime:
                continue
            
            #Check the day of the week.
            if not(s.tm_wday in validDays):
                continue
            
            tmpF.append(time.mktime(s))

            if tmpF[-1] > arrayEndTime:
                arrayEndTime = tmpF[-1]

            if arrayStartTime == 0:
                arrayStartTime = tmpF[0]

            if tmpF[0] < arrayStartTime:
                arrayStartTime = tmpF[0]

        tmpSensors.append(tmpF)
            
    if verbose:
        print "Converting Data"
        
    if compressArray:
        #TODO Make work. -- Must decide on a behaviour for this first.  
        #Perhaps this means a list of arrays between the period time for 
        #each valid day.
        pass
    else:
        #Convert to an array
        N = int(round(arrayEndTime - arrayStartTime)) + 1
        data = numpy.zeros((N, len(tmpSensors)), float)

        for i in range(len(tmpSensors)):
            for timeLine in tmpSensors[i]:
                data[int(round(int(timeLine) - arrayStartTime)), i] = 1
    
    return data, arrayStartTime, arrayEndTime
            


def demo():
    """Demonstration of parseRawData."""
    
    #Note write directory must exist.
    readLocation = "../data/old_sensor_data_raw/"
    writeLocation = "../data/parsed_sensor_data/"
    startTime = "2007-09-24 00:00:00"
    endTime = "2007-09-25 00:00:00"

    sensors = [53, 52, 51, 50, 44, 43, 24, 42, 41, 34, 40, 70, 71, 72, 73, 74]

    parseRawData(readLocation, writeLocation, sensors, startTime, \
                endTime, verbose = True)

                
    data, start, end = rawDataToBinary(writeLocation, sensors, verbose = True)
    
    sTime = time.ctime(start)
    eTime = time.ctime(end)
    
    print "Data made.  Size is " + str(data.shape)
    print "Time goes from " + str(sTime) + " to " + str(eTime)
    

def demoExtended():
    """Demonstration of rawDataToBinaryExtended"""
    
    readLocation = "../data/old_sensor_data_raw/"
    startTime = "2007-09-24 00:00:00"
    endTime = "2007-09-26 00:00:00"
    periodicStart = "00:00:00"
    periodicEnd = "23:59:00"
    days = [0, 1, 2, 3, 4, 5, 6]
    sensors = [52, 51, 50, 44]
    
    data, start, end = rawDataToBinaryExtended(readLocation, sensors, \
                                                startTime, endTime, \
                                                periodicStart, periodicEnd, \
                                                validDays = days, \
                                                verbose = True)
                                                
    sTime = time.ctime(start)
    eTime = time.ctime(end)

    print "Data made.  Size is " + str(data.shape)
    print "Time goes from " + str(sTime) + " to " + str(eTime)
    
    return data

if __name__ == "__main__":
    data = demoExtended()


