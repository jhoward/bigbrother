"""
visualize_counts.py

Author: James Howard
07.22.2011

A file to display a histogram of counts for a group of sensors
over a set period of time.
"""

import numpy
import matplotlib.pyplot as plt
import matplotlib
import pybb.data.bbdata as bbdata
import math
import pybb.data.dataio as dataio
import datetime
import pybb.data.calc as calc

def makeCounts(data, binWidth, startDate = "2008-03-17 00:00:00", \
                endDate = "2008-03-17 23:59:59", \
                sensors = bbdata.allSensors):
    """construct a set of counts from the given database
    """
    
    sd = datetime.datetime.strptime(startDate, "%Y-%m-%d %H:%M:%S")
    ed = datetime.datetime.strptime(endDate, "%Y-%m-%d %H:%M:%S")

    wn = datetime.timedelta(seconds = binWidth)

    secondsDiff = (ed - sd).days * 86400 + (ed - sd).seconds

    numbins = int(math.ceil((1.0 * secondsDiff)/binWidth))

    counts = [0] * numbins

    sValue = calc.datetonumber(sd)
    eValue = calc.datetonumber(ed)

    #Iterate over all sensors
    for s in sensors:
    #for s in [41]:

        sIndex = 0
        currentIndex = 0

        t = (data["db"]("sensor") == s) & (data["db"]("date") == sd.toordinal())
        currentIndex = t.records[0]['index']
        currentValue = data[s][currentIndex]
        
        while currentValue < eValue:
            
            if currentValue > sValue:
                
                #Replace this with something that handles multiple days
                sec = currentValue - sValue
                counts[int(sec/binWidth)] += 1
                
            currentIndex += 1
            currentValue = data[s][currentIndex]
            
    return counts
    

if __name__ == "__main__":
    
    startDate = "2008-03-21 00:00:00"
    endDate = "2008-03-21 23:59:59"
    binWidth = 600
    dbLocation = "../../data/real/small/data.dat"

    data = dataio.loadData(dbLocation)
    
    counts = makeCounts(data, binWidth, startDate, endDate, bbdata.allSensors)
    
    c = numpy.array(counts)
    c = c * 1.0
    c = c / max(c)
    
    """
    c /= 50
    c /= 600
    
    counts = makeCounts(data, binWidth, "2008-03-31 00:00:00", "2008-03-31 23:59:59", bbdata.allSensors)
    
    d = numpy.array(counts)
    d = d * 1.0

    d /= 50
    d /= 600

    #e = numpy.abs(c - d)
    """
    
    print "Counts made"
    fig = plt.figure()
    ax = fig.add_subplot(111)

    ax.bar(numpy.arange(len(counts)), c, width = 1.0, color = 'b')
    
    #ax.bar(numpy.arange(len(counts)), d, width = 1.0, color = 'ba')
    plt.axis([0, 24 * 6, 0, 1.0])
    plt.show()