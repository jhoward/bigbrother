"""stats.py
Author: James Howard

Contains functions pertinent to performing statistical 
tests on time series.
"""

import random as r
import numpy as np
from scipy.stats import distributions
import scipy.stats as ss


def tTestOne(data, means):
    """Perform a one sample t test against a null hypothesis
    
    Returns (t or f value, p value)
    """
    
    x = np.array(data)
    
    if len(x.shape) > 1:
        return tTestOneMulti(data, means)
    else:
        return tTestOneSingleDimension(data, means)
        

def tTestOneSingleDimension(data, mean):
    """Perform a 1 sample 1 dimensional ttest."""
    x = np.array(data)
    return ss.ttest_1samp(x, mean)



def tTestOneMulti(data, means):
    """Perform the test (hotelling's t^2 test)
    n(data means - assumed means)' * 
    (inverse covariance matrix) * 
    (data mean - assumed means)
    
    covariance matrix is from sample data
    """

    x = np.array(data)
    xm = x.mean(axis = 0)
    m = np.array(means)
    si = np.linalg.inv(np.cov(x.T))
    n = x.shape[0]
    dims = x.shape[1]
    sub = xm - m
    
    t2 = n * np.dot(sub.T, np.dot(si, sub))
    t2 = (n - dims) / (1.0 * (dims * (n - 1))) * t2
    p = 1 - distributions.f.cdf(t2, dims, n-dims)
    
    return (t2, p)
    

if __name__ == "__main__":
    offset = 0.2
    
    #Make some sample data
    sample = [[r.random() + offset, r.random() + offset] for i in range(10)]
    nullCorrect = [0.5 + offset, 0.5 + offset]
    nullWrong = [0.5, 0.5]
    
    sampOneDim = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
    
    print tTestOne(sample, nullCorrect)
    print tTestOne(sample, nullWrong)
    print tTestOne(sampOneDim, 0.6)
    
    
    
