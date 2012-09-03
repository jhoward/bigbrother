import pybb.math.stats as ps
import random
import numpy as np
import operator

def indexsort(d, reverse=False):
    """Returns the index of the sorted values of the given list d.
    Sort is from low to high.  If reverse is True then sort is from High to Low
    """
    
    return [ i for (i,j) in sorted(enumerate(d), \
                key=operator.itemgetter(1), reverse = reverse)]


def stripDataDays(d, t, validDays = \
                    ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]):
    """Strip out data to only a specific set of days.
    
    Returns a list
    """
    convTimes = []
    for i in range(len(t)):
        if t[i].strftime("%a") in validDays:
            convTimes.append(i)

    convData = d[convTimes]
    convTimes = t[convTimes]

    return convData, convTimes


def stripDataStd(d, t, std = 3):
    """Strip out days based on it being too far from the standard day"""
    #First check if there are any 0 values
    index = []
    for i in range(len(d)):
        index.append(i)
        for j in range(len(d[i])):
            if d[i][j] == 0:
                index.pop()
                print "Zero Value"
                break

    d = d[index]
    t = t[index]

    #Now strip based on std
    avgData = np.average(d, axis = 0)
    res = d - avgData
    totalRes = np.sum(np.abs(res), axis = 1)
    resStd = totalRes.std()
    index = []
    for i in range(len(totalRes)):
        if totalRes[i] <= std * resStd:
            index.append(i)

    d = d[index]
    t = t[index]

    return d, t

def parseEvents(data, times, eventTimes):
    """Parse out days associated with a given set of event times.

    Returns both the parsed data and time and the remaining data and times.
    """
    striped = []
    remaining = range(len(times))
    stripedEvents = []

    for t in eventTimes:
        tmpEvent = t.date()
        for j in range(len(times)):
            tmpTime = times[j].date()

            if tmpEvent == tmpTime:
                striped.append(tmpEvent)
                stripedEvents.append(data[j, :])
                remaining.remove(j)
                break

    stripedEvents = np.array(stripedEvents)
    remainingTimes = np.array(remaining)
    stripedTimes = np.array(striped)
    remainingEvents = data[remaining]

    return stripedTimes, remainingTimes, stripedEvents, remainingEvents

def normalize(data, steps = 30, mn = -1, mx = 1):
    new = []

    val = (mx - mn) / (1.0 * steps)
    stepstozero = abs(mn) / val
    
    for d in data:
        tmp = []
        for a in d:
            tmp.append(int(stepstozero + a / val))
        new.append(tmp)
        
    scale = [mn + val*v for v in range(steps)]
    
    return new, scale

def concatonate(data):
    """Converts a dataset of multiple elements to one long element."""
    tmp = np.array(data)
    tmp = np.reshape(tmp, (tmp.shape[0] * tmp.shape[1], -1))
    return tmp


def stripZero(data, threshold = 0):
    
    newData = []
    
    for d in data:
        if sum(np.abs(d)) > (threshold * len(d)):
            newData.append(d)
            
    return newData
            

def extractAnomalyTTest(data, windowLength, minSpacing, alpha = 0.05):
    """Fixed window data extracting function.  Uses t test to determine
    extraction criteria.  Extraction is perfomed by sliding a fixed length 
    window over input data and searching for instances where the current 
    window rejects the null hypothesis.  
    
    Minimum spacing between windows is given by parameter minSpace.
    Alpha is the reject criterion.  If the t test returns a value below 
    alpha than the window is likely an extractable window.
    
    returns a list of windows.
    """
    
    #TODO Perhaps come up with a better way to do this.  For now this
    #is only a maximum local fixed window.  In the future this should
    #probably be something that allows for varying length to more 
    #preciecly find the "anomaly"
    
    
    d = np.array(data)
    means = d.mean(axis = 0)
    i = 0
    bestValue = 0
    bestIndex = 0
    localIndex = 0
    maxIndex = 0
    localCheck = False
    windows = []
    indicies = []
    
    while (i < (len(data) - windowLength)):
        if localCheck == True and i == maxIndex:
            windows.append(data[bestIndex:bestIndex + windowLength])
            indicies.append(bestIndex)
            localCheck = False
            bestValue = 0
        
        win = data[i:i + windowLength]
        val = ps.tTestOne(win, means)[1]
        
        cv = alpha - val
        if cv > 0:
            if localCheck == False:
                localCheck = True
                maxIndex = i + minSpacing
                
            if cv > bestValue:
                bestIndex = i
                bestValue = cv
        i+=1

    return windows, indicies

if __name__ == "__main__":
    data = [random.random() for i in range(30)]
    wins, ind = extractAnomalyTTest(data, 3, 5)
    print wins
    print ind
