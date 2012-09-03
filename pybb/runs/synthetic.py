"""Make a run of synthetic data

Also used to sample arima forecasting.
"""

import pybb.data
import time
import pybb.model.kmeans_hmm as khmm
import pybb.model.gaussian as gaussian
import pybb.model.bayesian_forecast as bayesianforecast
import matplotlib.pyplot as mpl
import numpy as np
import pybb.math.analysis as analysis
import rpy2.robjects.numpy2ri
import rpy2.robjects as R
from rpy2.robjects.packages import importr
forecast = importr("forecast")

def fArima(data1d, ar, ma, sma, period, mean = 0.0):
    
    fd = [0.0] * len(data1d)
    
    d = data1d.tolist()
    fd[0:period + 1] = d[0:period + 1]
    
    for i in range(period, len(data1d) - 1):
        tmpCons = data1d[i - period + 1]
        tmpAr =  ar * (data1d[i] - data1d[i - period])
        tmpMa = ma * (data1d[i] - fd[i])
        tmpSma = sma * (data1d[i - period + 1] - fd[i - period + 1])
        tmpMaSma = ma * sma * (data1d[i - period] - fd[i - period])
        
        fd[i + 1] = mean + tmpCons + tmpAr - tmpMa - tmpSma + tmpMaSma
        
    return fd
    
    
def fArima2(data1d, ar, ma, sma, period):

    fd = [0.0] * len(data1d)

    d = data1d.tolist()
    fd[0:period + 1] = d[0:period + 1]
    print "Hi"
    for i in range(period + 1, len(data1d)):
        tmpCons = data1d[i - period]
        tmpAr =  ar * (data1d[i - 1] - data1d[i - period - 1])
        tmpMa = ma * (data1d[i - 1] - fd[i - 1])
        tmpSma = sma *  (data1d[i - period] - fd[i - period])
        tmpMaSma = ma * sma * (data1d[i - period - 1] - fd[i - period - 1])

        fd[i] = tmpCons + tmpAr - tmpMa - tmpSma + tmpMaSma

    return fd


def f011011(data1d, ma, sma, period):
    fd = [0.0] * len(data1d)

    d = data1d.tolist()
    fd[0:period] = d[0:period]

    for i in range(period, len(data1d) - 1):
        tmpCons = d[i] + d[i - period + 1] - d[i - period]
        tmpMa = ma * (fd[i] - d[i])
        tmpSma = sma * (fd[i - period + 1] - d[i - period + 1])
        tmpMaSma = ma * sma * (fd[i - period] - d[i - period])

        fd[i + 1] = tmpCons - tmpMa - tmpSma + tmpMaSma

    return fd


def fAr(data1d, ar, mean):
    
    fd = [0.0] * len(data1d)
    
    fd[0] = data1d[0]
    
    for i in range(1, len(data1d)):
        fd[i] = mean + ar * (fd[i - 1] - mean)
        
    return fd
    
    
def f011(data1d, ma, mean):
    fd = [0.0] * len(data1d)
    fd[0] = data1d[0]
    
    for i in range(0, len(data1d) - 1):
        fd[i + 1] = data1d[i] - ma * (fd[i] - data1d[i])
        
    return fd
    
    
def f000011(data1d, sma, period):
    fd = [0.0] * len(data1d)
    d = data1d.tolist()
    fd[0:period] = d[0:period]

    for i in range(period, len(data1d) - 1):
        tmpCons = d[i - period + 1]
        tmpSma = sma * (fd[i - period + 1] - d[i - period + 1])
        fd[i + 1] = tmpCons - tmpSma

    return fd
    
    

if __name__ == "__main__":
    periods = 75
    periodLength = 50
    backStd = 0.04
    backSize = 1.0
    numActs = 12
    actTypes = [4]
    actLength = 12
    actStd = 0.01
    actSize = 0.22
    
    data, acts = pybb.data.generateDataRandom1d(periods, periodLength, \
                        backStd, backSize, numActs, actTypes, \
                        actLength, actStd, actSize)
    
    tdata, tacts = pybb.data.generateDataRandom1d(periods, periodLength, \
                                    backStd, backSize, numActs, actTypes, \
                                    actLength, actStd, actSize)
    
    #Train arima
    data1d = np.reshape(data, -1)
    tdata1d = np.reshape(tdata, -1)
    R.r.assign("data1d", data1d)
    R.r.assign("tdata1d", tdata1d)
    R.r.assign("periodLength", periodLength)
    st = time.time()
    mod = R.r('mod = arima0(data1d, order=c(1,0,1), seasonal=list(order=c(0,1,1), include.mean = TRUE, period=periodLength))')
    print "Parameter fit Time = " + str(time.time() - st)
    st = time.time()
    tmod = R.r('tmod = Arima(tdata1d, model = mod)')
    print "Model fit Time = " + str(time.time() - st)
    st = time.time()
    ftd = R.r('ftd = forecast.Arima(tmod)')
    print "Forecast Time = " + str(time.time() - st)

    fTData1d = np.array(ftd[8])
    fTData = np.array(fTData1d)
    fTData = np.reshape(fTData, (len(ftd[8])/periodLength, periodLength))

    tres1d = np.array(ftd[9])
    tres = np.array(tres1d)
    tres = np.reshape(tres, (len(ftd[9])/periodLength, periodLength))
    
    print "Arima Training data Std:", mod[1][0]**0.5
    
    mase = analysis.mase(tdata1d, fTData1d)
    mape = analysis.mape(tdata1d, fTData1d)

    print "Testing Mase:", mase
    print "Testing Mape:", mape

    #Make residual events
    resEventData = []
    for a in tacts:
        resEventData.append(tres[a[0]][a[1]:a[1] + actLength])
        
    resEventData = np.array(resEventData)
    resEventData = resEventData.tolist()
    
    #Train HMM
    m, mdata, mout = khmm.train(resEventData, 1, actLength, \
                                    iterations = 20, outliers = False, \
                                    clustering = "kmeans++", 
                                    verbose = False)

    #Setup forecast
    model = []
    model.append(gaussian.Gaussian(0, tres.std()))
    model.append(m[0])
    tmpResEventData = np.array(resEventData)
    
    bf = bayesianforecast.BayesianForecast(model)
    bf.setStd(0, tres.std())
    bf.setStd(1, tres.std())
    
    bfData1d, probs, windowLens, models = bf.windowForecast(tres1d.tolist(), \
                                                minWindow = 4, \
                                                maxWindow = 12, \
                                                ftype = "best")
                                                
    #Add and calc mape
    tmpBFD = np.array(bfData1d)
    tmpFTData1d = np.array(fTData1d)
    
    bFTData1d = tmpBFD + tmpFTData1d
    
    mase = analysis.mase(tdata1d, bFTData1d)
    mape = analysis.mape(tdata1d, bFTData1d)

    print "Bayesian Forecast Mean Mase:", mase
    print "Bayesian Forecast Mean Mape:", mape
    
    """
    mpl.subplot(111)
    xdata = range(24)
    mpl.plot(xdata, stripData[2], 'k', alpha = 0.4, linewidth = 2)
    mpl.plot(xdata, fSData[2], 'b', alpha = 0.7, linewidth = 2)
    mpl.plot(xdata, totalFData1d, 'r', alpha = 0.7, linewidth = 2)

    mpl.xlim([0, 23])

    mpl.subplot(111)
    xdata = range(60)
    mpl.plot(xdata, tdata1d[tacts[0][0] * periodLength:tacts[0][0] * periodLength + 60], 'k', alpha = 0.8, linewidth = 1)
    mpl.plot(xdata, fTData1d[tacts[0][0] * periodLength:tacts[0][0] * periodLength + 60], 'r', alpha = 0.8, linewidth = 1)
    #mpl.plot(xdata, myFTData1d[tacts[0][0] * periodLength:tacts[0][0] * periodLength + 60], 'b', alpha = 0.8, linewidth = 1)
    mpl.xlim([0, 59])
    """
    mpl.subplot(111)
    xdata = range(periodLength * 2)
    mpl.plot(xdata, tdata1d[tacts[0][0] * periodLength:tacts[0][0] * periodLength + 2 * periodLength], 'k', alpha = 0.8, linewidth = 1)
    mpl.plot(xdata, fTData1d[tacts[0][0] * periodLength:tacts[0][0] * periodLength + 2 * periodLength], 'r', alpha = 0.8, linewidth = 1)
    mpl.plot(xdata, bFTData1d[tacts[0][0] * periodLength:tacts[0][0] * periodLength + 2 * periodLength], 'b', alpha = 0.8, linewidth = 1)
    mpl.xlim([0, 2 * periodLength - 1])
    
    """
    mpl.subplot(212)
    xdata = range(actLength)
    for a in resEventData:
        mpl.plot(xdata, a, 'k', alpha = 0.5)
    mpl.xlim([0, actLength - 1])
    
    mpl.subplot(111)
    xdata = range(periodLength)
    for a in tres:
        mpl.plot(xdata, a, 'k', alpha = 0.1)
    mpl.xlim([0, periodLength - 1])
    for a in tacts:
        mpl.plot(xdata, tres[a[0]], 'r', alpha = 0.4)
    mpl.xlim([0, periodLength - 1])
    
    mpl.subplot(111)
    xdata = range(periodLength)
    for d in tdata:
        mpl.plot(xdata, d, 'k', alpha = 0.3)
    mpl.xlim([0, periodLength - 1])
    
    """