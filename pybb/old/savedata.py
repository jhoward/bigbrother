"""
savedata.py

Author: James Howard

NOT USED ANY MORE
Simple program to save sensor data to file.  This is the file where 
correlation should be calculated if necessary.
"""

import bbparser
import dataio
import time
import correlation
import bbdata


if __name__ == "__main__":
    readLocation = "../data/old_sensor_data_raw/"
    writeLocation = "../data/sensor_data/ss.dat"
    startTime = "2008-02-15 00:00:00"
    endTime = "2008-02-25 23:59:59"
    
    sensors = [53, 52, 51, 50, 44]
    validDays = [1, 3, 5]
    
    data, start, end = bbparser.rawDataToBinaryExtended(readLocation, \
                                                #bbparser.allSensors, \
                                                sensors, \
                                                startTime, endTime, \
                                                validDays = validDays, \
                                                verbose = True)
                                                
    sTime = time.ctime(start)
    eTime = time.ctime(end)
    
    print "Data made.  Size is " + str(data.shape)
    print "Time goes from " + str(sTime) + " to " + str(eTime)
    
    tmpData = bbdata.Dataset(data)
    tmpData.startTime = sTime
    tmpData.endTime = eTime
    
    dataio.saveData(writeLocation, tmpData)