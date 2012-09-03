"""Sample file used to make forecast runs for traffic data"""
import pybb.data.dataio as dataio
import pybb.data
import pybb.math.analysis as analysis
import numpy as np
import matplotlib.pyplot as mpl
import ghmm
import pybb.model.kmeans_hmm as khmm
import pybb.model.bayesian_forecast as bayesianforecast
import pybb.model.gaussian as gaussian
import rpy2.robjects.numpy2ri
import rpy2.robjects as R
from rpy2.robjects.packages import importr
forecast = importr("forecast")

files = ["../../data/traffic/counts/025A207P.txt"]#, \
        #"../../data/traffic/counts/006G283P.txt", \
        #"../../data/traffic/counts/225A9S.txt", \
        #"../../data/traffic/counts/270A39P.txt", \
        #"../../data/traffic/counts/070A270P.txt", \
        #"../../data/traffic/counts/070A277P.txt"]
        
otherFileLocation = "../../data/other/broncos.txt"

"""
def forecast(data, ar, ma, sma, season):
    #WORRY ABOUT THIS LATER
    fdata = [0.0] * len(data)
    fdata[0:season + 1] = data[0:season + 1]
    
    for i in range(season + 1, data):
        tmpAR = ar * (data[i - 1] - data[i - season - 1])
        tmpMA = 0
"""

def combineData(data, times, otherData, otherTimes):
    d = []
    t = []
    od = []
    ot = []
    
    for i in range(len(times)):
        tmpDate = times[i].date()
        for j in range(len(otherTimes)):
            tmpOtherDate = otherTimes[j].date()
            
            if tmpDate == tmpOtherDate:
                d.append(data[i])
                t.append(times[i])
                od.append(otherData[j])
                ot.append(otherTimes[j])
    
    return np.array(d), np.array(od), np.array(t)
                

def parseTrafficTimes(data, times, event_times, before = 2, length = 5):
    
    events = []
    etimes = []

    for t in event_times:
        tmp_event = t.date()
        for j in range(len(times)):
            tmp_time = times[j].date()
            if tmp_event == tmp_time:
                events.append(list(data[j, t.hour - before:\
                                    t.hour - before + length]))
                etimes.append(tmp_event)
                
    np.array(events)
    np.array(etimes)
    return events, etimes

if __name__ == "__main__":
    
    actLength = 8

    eventData, eventTimes = \
                    dataio.loadOtherData(otherFileLocation, datatype = 'f')

    data, times = dataio.loadTrafficData(files[0])
    sunData, sunTimes = pybb.data.stripDataDays(data, times, ["Sun"])
    #sunData, sunTimes = pybb.data.stripDataStd(sunData, sunTimes, 2.3)
    stripTimes, rTimes, stripData, rData = \
                        pybb.data.parseEvents(sunData, sunTimes, eventTimes)
    
    #Fit an arima to this data
    sunData1d = np.reshape(sunData, -1)
    R.r.assign("sunData1d", sunData1d)
    mod = R.r('mod = arima(sunData1d, order=c(1,0,1), seasonal=list(order=c(0,1,1), include.mean = TRUE, period=24))')
    fd = R.r('fd = forecast.Arima(mod)')
    
    #This is required to do due to the way ARIMA0 works
    tmp = [0.0] * len(sunData1d)
    tmp2 = list(mod[7])
    tmp[len(tmp) - len(tmp2):] = tmp2
    res = np.array(tmp)
    resData = np.reshape(tmp, (len(tmp)/24, 24))
    resData1d = list(mod[7])
    
    #Strip forecast data (Only usable with arima not arima0
    fData1d = np.array(fd[8])
    fData = np.array(fData1d)
    fData = np.reshape(fData, (len(fd[8])/24, 24))
    
    resSTimes, resRTime, resSData, resRData = \
                        pybb.data.parseEvents(resData, sunTimes, eventTimes)
                        
    fSTimes, fRTimes, fSData, fRData = \
                        pybb.data.parseEvents(fData, sunTimes, eventTimes)
    
    #Get just the broncos residual 9-15
    resEventData = []
    for r in resSData:
        resEventData.append(r[9:17])
        
    #Convert to list
    tmp = np.array(resEventData)
    resEventData = tmp.tolist()
        
    resEventData = pybb.data.stripZero(resEventData, threshold = 6)
    

    #Train HMM
    m, mdata, mout = khmm.train(resEventData, 1, actLength, \
                                    iterations = 20, outliers = False, \
                                    clustering = "kmeans++", 
                                    verbose = False)
    
    mase = analysis.mase(sunData1d, fData1d)
    mape = analysis.mape(sunData1d, fData1d)

    print "Mean Mase:", mase
    print "Mean Mape:", mape
    
    
    #Setup forecast
    model = []
    model.append(gaussian.Gaussian(resData.mean(), resData.std()))
    #model.append(gaussian.Gaussian(0, resData.std()))
    model.append(m[0])
    
    bf = bayesianforecast.BayesianForecast(model)
    bf.setStd(0, resData.std())
    bf.setStd(1, resData.std())
    
    bfData1d, probs, windowLens, models = bf.windowForecast(resData1d, \
                                                minWindow = 4, \
                                                maxWindow = 8, \
                                                ftype = "aggregate")
                                                
    #Add and calc mape
    tmpBFD = np.array(bfData1d)
    tmpFData1d = np.array(fData1d)
    
    totalFData1d = tmpBFD + tmpFData1d
    
    mase = analysis.mase(sunData1d, totalFData1d)
    mape = analysis.mape(sunData1d, totalFData1d)

    print "Mean Mase:", mase
    print "Mean Mape:", mape
    
    
    #Make quick sample
    bfData1d, probs, windowLens, models = bf.windowForecast(resSData[2].tolist(), \
                                                minWindow = 4, \
                                                maxWindow = 8, \
                                                ftype = "aggregate")

    tmpBFD = np.array(bfData1d)
    tmpFData1d = np.array(fSData[2])

    totalFData1d = tmpBFD + tmpFData1d

    mase = analysis.mase(stripData[2], totalFData1d)
    mape = analysis.mape(stripData[2], totalFData1d)

    print "Mean Mase:", mase
    print "Mean Mape:", mape                                           
    
    mpl.subplot(111)
    xdata = range(24)
    mpl.plot(xdata, stripData[2], 'k', alpha = 0.4, linewidth = 2)
    mpl.plot(xdata, fSData[2], 'b', alpha = 0.7, linewidth = 2)
    mpl.plot(xdata, totalFData1d, 'r', alpha = 0.7, linewidth = 2)

    mpl.xlim([0, 23])
    
    """
    #sun_avg = np.average(sd, axis = 0)
    
    data_1d = np.reshape(data, -1)
    #sun_1d = np.reshape(sd, -1)
    #sun_avg_1d = np.resize(sun_avg, sd.size)

    #
    #s_1d = np.reshape(stripped_data, -1)
    
    
    R.r.assign("sd", data_1d)
    #R.r.assign("broncos", s_1d)
    mod = R.r('mod = arima(sd, order=c(0,1,1))')#, seasonal=list(order=c(0,1,1), period=168))')
    #broncos_mod = R.r('bmod = Arima(broncos, model = mod)')
    #mod = R.r('mod = arima(sd, order=c(0,1,1), seasonal=list(order=c(0,1,1), period=24))')
    #mod = R.r('mod = arima(sd, order=c(1, 0, 0))')
    fd = R.r('fd = forecast.Arima(mod)')
    #fb = R.r('fb = forecast.Arima(bmod)')
    
    #broncos = np.reshape(fb[9], (len(fb[8])/24, 24))
    #res = np.reshape(mod[7], (len(mod[7])/24, 24))
    fd_1d = list(fd[8])
    forecast = np.reshape(fd[8], (len(fd[8])/24, 24))
    residual = np.reshape(fd[9], (len(fd[8])/24, 24))
    
    res_strip_time, res_remain_time, res_strip_data, res_remain_data = parse_events(residual, st, event_times)

    #Grab the stripped broncos residual data (hours 9 - 15)
    res = []
    for r in res_strip_data:
        res.append(r[9:16])
        
    #Normalize the data
    nres, scale = normalize(res)
    
    print "Training hidden Markov model"
    obs = 30
    numModels = 1
    states = 7
    
    #Train a hmm from this data
    hmmmodel, hmmdata, hmmout = markov_anneal.train(nres, \
                                    numModels, \
                                    states, obs, \
                                    iterations = 20, \
                                    printBest = False,  \
                                    clustering = "kmeans", \
                                    verbose = False)
    
    sigma = IntegerRange(0, obs)
    #po1 = forecast_model(hmmmodel[0], nres[0][0:1], sigma)
    """
    """    
    #fm = farima101011(sun_1d, 24, mod[0][0], mod[0][1], mod[0][2])
    #fm = farima011011(sun_1d, 24, mod[0][0], mod[0][1])
    #fm = far(sun_1d, mod[0][0], mod[0][1])
    #bt, rt, broncos, rd = parse_events(res, sun_times, event_times)
    
    mase = analysis.mase(sun_1d, sun_avg_1d)
    mape = analysis.mape(sun_1d, sun_avg_1d)
    
    print "Mean Mase:", mase
    print "Mean Mape:", mape
    
    mase = analysis.mase(sun_1d, fd_1d)
    mape = analysis.mape(sun_1d, fd_1d)
    
    print "R SARIMA Mase:", mase
    print "R SARIMA Mape:", mape
    
    #mase = analysis.mase(sun_1d, fm)
    #mape = analysis.mape(sun_1d, fm)
    
    #print "My SARIMA Mase:", mase
    #print "My SARIMA Mape:", mape
    """
    """
    xrng = 24
    
    
    mpl.subplot(211)
    xdata = range(xrng)
    for d in sunData:
        mpl.plot(xdata, d, 'k', alpha = 0.2)
    for d in stripData:
        mpl.plot(xdata, d, 'r', alpha = 0.5)
    mpl.xlim([0, xrng - 1])

    """
    """
    mpl.subplot(212)
    for d in resData:
        mpl.plot(xdata, d, 'k', alpha = 0.2)
    for d in resSData:
        mpl.plot(xdata, d, 'r', alpha = 0.5)
    """
    """
    mpl.subplot(212)
    xdata = range(actLength)
    for d in resRData:
        mpl.plot(xdata, d[9:17], 'k', alpha = 0.2)
    for d in resEventData:
        mpl.plot(xdata, d, 'r', alpha = 0.5)

    mpl.xlim([0, actLength - 1])
    """
