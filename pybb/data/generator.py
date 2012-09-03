"""
generator.py
Author: James Howard

File used to generate synthetic data for testing
"""

import numpy as np
import matplotlib.pyplot as mpl
import random
import pybb.data

def _noise(mu = 0, sigma = 0.02):
    return random.gauss(mu, sigma)

def background1d(length, size, std = 0.02):
    """Create a single background data set.
    Data is first half of a sine curve.
    Noise is gaussian.
    """
    data = [0.0] * length
    for i in range(length):
        data[i] = size * np.sin((i / (1.0 * length)) * (np.pi))
        
        #Add noise
        data[i] += _noise(sigma = std)
    
    return np.array(data)


def activity1d(length, size, std, aType = 0):
    """Create a single activity.
    Activities are a half cosine curve.  
    type 
        0 - First half sine curve (ramp up then down)
        1 - Second half sine curve (ramp down then up)
        2 - Linear curve up
        3 - Linear curve down
    """
    act = [0] * length
    
    for i in range(length):
        if aType == 0:
            act[i] = size * np.sin((i / (1.0 * length - 1)) * np.pi)
        if aType == 1:
            act[i] = size * np.sin((i / (1.0 * length - 1)) * np.pi + np.pi)
        if aType == 2:
            act[i] = size * i / (1.0 * length - 1)
        if aType == 3:
            act[i] = -1 * size * i / (1.0 * length - 1)
        if aType == 4:
            act[i] = size * np.sin((i / (1.0 * length - 1)) * (2 * np.pi))

        act[i] += _noise(sigma = std)
        
    return np.array(act)
    
      
def generateActivities1d(num, length, size, std, aType = 0):
    """Create a list of activities
    """
    return np.array([activity1d(length, size, std, aType) for i in range(num)])


def generateBackgrounds1d(num, length, size, std):
    """Create a list of backgrounds
    """
    return np.array([background1d(length, size, std) for i in range(num)])


def generateDataRandom1d(periods = 100, \
                            periodLength = 100, \
                            noiseStd = 0.1, \
                            size = 1.0, \
                            numActivities = 10, \
                            types = [0, 1], \
                            activityLength = 10, \
                            activityStd = 0.1, \
                            activitySize = 0.4):
    """Generate a data set of one dimensional data
    
    The total number of activities is numActivities * the number of types
    Activities are randomly placed in activities
    
    Output:
    data -- Actual data
    activities -- indicies, start time, and type of each activity
    """                    
    data = generateBackgrounds1d(periods, periodLength, size, noiseStd)
    acts = []
    
    for t in types:
        for n in range(numActivities):
            a = activity1d(activityLength, activitySize, activityStd, t)
            
            p = int(random.random() * periods)
            s = int(random.random() * (periodLength - activityLength))
            
            for i in range(len(a)):
                data[p][s + i] += a[i]
                
            acts.append((p, s, t))
    
    return data, np.array(acts)

if __name__ == "__main__":
    periodLength = 100
    
    data, acts = generateDataRandom1d()
    cdata = pybb.data.concatonate(data)
    
    #All periods on top of each other
    mpl.subplot(211)
    xdata = range(periodLength)
    for d in data:
        mpl.plot(xdata, d, 'k', alpha = 0.3)
    mpl.xlim([0, periodLength - 1])

    #First 5
    mpl.subplot(212)
    start = acts[0][0] * periodLength
    xdata = range(periodLength * 5)
    mpl.plot(xdata, cdata[start:start + periodLength * 5], 'k', linewidth = 2)
    mpl.xlim([0, periodLength * 5 - 1])
    