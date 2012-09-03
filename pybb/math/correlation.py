"""
correlation.py

Author: James Howard

Perform a simple correlation calculation between various columns of a given 
array.  The correlation calculation is based on the Pearson product-moment
coefficient.
"""

import numpy
import math


def correlation(data, offset):
    """data must be of type numpy.ndarray or bbdata.Data
    
    returns an array of correlations for a given offset from sensor x to 
    sensor y.
    """
    
    baseCounts = data.sum(0)
    correlation = numpy.zeros((data.shape[1], data.shape[1]), float)
    
    x = data[0:data.shape[0] - offset, :]
    y = data[offset:data.shape[0], :]
    
    ex = x.sum(0)/(1.0 * x.shape[0])
    ey = y.sum(0)/(1.0 * y.shape[0])
    
    ex.resize(ex.shape[0], 1)
    ey.resize(ey.shape[0], 1)
    
    #make joint counts array
    #tile y and repeat x
    xx = x.repeat(x.shape[1], axis = 1)
    yy = numpy.hstack([y for i in range(y.shape[1])])
    
    xy = (xx*yy).sum(0)
    xy.resize(x.shape[1], y.shape[1])
    xy = xy/(1.0 * x.shape[0])
    
    tmpX = (ex - ex**2)**0.5
    tmpY = (ey - ey**2)**0.5
    
    #Make resulting matrix
    tmp = xy - numpy.dot(ex, ey.transpose())
    tmp = tmp / (numpy.dot(tmpX, tmpY.transpose()))
    
    return tmp
    
    
def cooccurence(data, offset):
    cooccurence = numpy.zeros((data.shape[1], data.shape[1]), float)
    x = data[0:data.shape[0] - offset, :]
    y = data[offset:data.shape[0], :]
    
    xx = x.repeat(x.shape[1], axis = 1)
    yy = numpy.hstack([y for i in range(y.shape[1])])
    
    xy = (xx * yy).sum(0)
    xy.resize(x.shape[1], y.shape[1])

    return xy


def bestCorrelation(data, offsetMax = 4, offsetMin = 1):
    """Calculates the best correlation value from offsetMin to offsetMax."""

    val = [correlation(data, i) for i in range(offsetMin, offsetMax)]
    val = numpy.dstack(val)
    
    return numpy.max(val, 2)
            
        
def createNeighbors(correlation):
    """Creates the neighborhood table from a correlation matrix as 
    returned by the function correlation.
    
    Sort order is from least correlated neighbor to most correlated.
    """
    neighbors = numpy.argsort(correlation, 0)
    return neighbors
    

def demo(readLocation = "../data/sensor_data/late_small.dat"):
    import dataio
    
    oData = dataio.loadData(readLocation)
    val = bestCorrelation(oData.data, offsetMax = 3, offsetMin = 1)
    
    neighbors = createNeighbors(val)
    
    oData.correlation = val
    oData.neighbors = neighbors
    
    dataio.saveData(readLocation, oData)

    
if __name__ == "__main__":
    pass
    
