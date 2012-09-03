"""Bayesian Combined Forecast class"""
#TODO Implement future forecasts
#TODO Handle multivariate input data

import numpy as np
import pybb.model.gaussian as gaussian
import random
import math
import matplotlib.pyplot as mpl
import pybb.data
import pybb.model.kmeans_hmm as khmm


class BayesianForecast(object):
    def __init__(self, models):
        self.models = models
        self.stds = [1.0] * len(models)
        
    def setStd(self, i, std):
        """Set the standard deviation for model i."""
        self.stds[i] = std
        
    def setStdAll(self, std):
        self.stds = [std] * len(self.models)
        
    def _updatePmodel(self, data, pmodel, minProb = 0.01, maxProb = 0.99):
        """Update the probabilities for all models.
        """
        nc = 0
        for k in range(len(pmodel)):
            tmp = (data[-1] - self.models[k].forecast(data))**2
            dtmp = 2 * (self.stds[k]**2)
            nc += pmodel[k] * math.exp(-1 * tmp / dtmp)
            
        for k in range(len(pmodel)):
            tmp = (data[-1] - self.models[k].forecast(data))**2
            dtmp = 2 * (self.stds[k]**2)
            pmodel[k] = pmodel[k] * math.exp(-1 * tmp / dtmp) / nc
            if pmodel[k] < minProb:
                pmodel[k] = minProb
            if pmodel[k] > maxProb:
                pmodel[k] = maxProb
            
        return pmodel


        
    def forecastSingle(self, data, pmodel, ftype = "aggregate"):
        """Forcasts just the next point from a dataset.
        
        Possible types are "best" and "aggregate"
        """
        f = 0.0
        pmodel = self._updatePmodel(data, pmodel)

        if ftype == "aggregate":
            for p in range(len(pmodel)):
                f += pmodel[p] * self.models[p].forecast(data)
        
        if ftype == "best":
            #I know I can do this better, but I don't care for now.
            bIndex = 0
            bValue = 0
            for p in range(len(pmodel)):
                if pmodel[p] > bValue:
                    bIndex = p
                    bValue = pmodel[p]
                    
            f = self.models[bIndex].forecast(data)
                
        return f, pmodel
                
    
    
    def forecast(self, data, windowLen = 5, ftype = "aggregate", minProb = 0.01):
        """Perform a complete forcast for a dataset.  Initial model 
        probabilities are set to 1/numModels
        
        Returns all forecasts for data and all probabilities of forecasts
        """
        print ftype
        probs = []
        window = [windowLen] * len(data)
        models = []
        for i in range(len(data)):
            probs.append([1.0/len(self.models)] * len(self.models))
        fdata = [0.0] * len(data)
        fdata[0:windowLen] = data[0:windowLen]
        
        for i in range(len(data) - windowLen):
            tmp = self.forecastSingle(data[i:i + windowLen], \
                                    pmodel = probs[-1], \
                                    ftype=ftype)
            fdata[i + windowLen] = tmp[0]
            probs[i + windowLen] = (list(tmp[1]))
            
            
        return fdata, probs, window, models
        
        
    
    def windowForecast(self, data, minWindow = 5, maxWindow = 10, \
                                ftype = "aggregate"):
        """Forecast with multiple concurent windows.  Return the forecast
        of the best window.
        """
        probs = []
        window = [0] * len(data)
        numWindows = (maxWindow - minWindow) + 1
        models = [0] * len(data)
        
        for i in range(numWindows):
            tmp = []
            for j in range(len(data)):
                tmp.append([1.0/len(self.models)] * len(self.models))
            probs.append(tmp)

        fdata = [0.0] * len(data)
        fdata[0:maxWindow] = data[0:maxWindow]
        
        for j in range(maxWindow, len(data)):
            
            if j % 200 == 0:
                print j
            
            bestProb = 0.0
            bestModel = 0
            bestForecast = -1
            
            for i in range(numWindows):
                tmp = self.forecastSingle(data[j - minWindow - i:j + 1], \
                                        pmodel = probs[i][-1], \
                                        ftype=ftype)
                
                #Update the probability array
                probs[i][j] = list(tmp[1])
                                        
                #Get the most probable model
                tmpProbs = list(tmp[1])
                modelProbs = pybb.data.indexsort(tmpProbs, reverse = True)
                tmpBestProb = tmpProbs[modelProbs[0]]
                tmpBestModel = modelProbs[0]
                tmpForecast = tmp[0]
                
                #Check if it is the best probability model
                if tmpBestProb > bestProb:
                    bestProb = tmpBestProb
                    bestModel = tmpBestModel
                    bestForecast = tmpForecast
                    bestWindow = i + minWindow
            
            fdata[j] = bestForecast
            window[j] = bestWindow
            models[j] = bestModel
                
        return fdata, probs, window, models
        

def simpleRun():
    dataLength = 25
    events = 1
    eventMean = 2
    eventLength = 4
    window = 10
    
    #Create the data
    data = [random.gauss(0, 0.5) for i in range(dataLength)]
    starts = []
    
    for i in range(events):
        start = int((dataLength - eventLength) * random.random())
        starts.append(start)
        for j in range(eventLength):
            data[start + j] = random.gauss(0, 0.5) + eventMean
         
    #Set the run
    models = []
    models.append(gaussian.Gaussian(0, 0.5))
    models.append(gaussian.Gaussian(eventMean, 0.5))
    
    #Create the forecaster
    bf = BayesianForecast(models)
    bf.setStdAll(0.5)
    
    #fdata, probs, windowLens = bf.forecast(data, windowLen = window)
    fdata, probs, windowLens, models = bf.windowForecast(data, 5, 10)
    
    mpl.subplot(111)
    xdata = range(len(data))
    mpl.plot(xdata, data, 'k', alpha = 0.5, linewidth = 2)
    mpl.plot(xdata, fdata, 'r', alpha = 0.5)
    mpl.xlim([0, len(data) - 1])   
    
    return data, starts, fdata, probs, bf, windowLens, models



def complexRun(plot = True):
    
    dataLength = 200
    actLength = 13
    numActivities = 1
    actSize = 0.5
    actStd = 0.05
    backStd = 0.1
    minWindowLen = 2
    maxWindowLen = 8
    backMean = 0.0
    
    #Create simple gaussian noise
    data = [random.gauss(backMean, backStd) for i in range(dataLength)]
    acts = pybb.data.generateActivities1d(10, actLength, actSize, actStd, aType = 2)
    
    #Make testing data
    sacts = pybb.data.generateActivities1d(numActivities, actLength, actSize, actStd, aType = 2)    
    starts = []
    
    for s in sacts:
        #Pick a random spot
        start = int((dataLength - actLength) * random.random())
        starts.append(start)
        for i in range(len(s)):
            data[start + i] = s[i]
            
    m, mdata, mout = khmm.train(acts.tolist(), 1, actLength, \
                                    iterations = 20, outliers = False, \
                                    clustering = "kmeans++", 
                                    verbose = False)
                                    
    model = []
    model.append(gaussian.Gaussian(backMean, backStd))
    model.append(m[0])
    
    bf = BayesianForecast(model)
    bf.setStd(0, backStd)
    bf.setStd(1, actStd)
    
    #fdata, probs, windowLens = bf.forecast(data, windowLen = minWindowLen, ftype = "best")
    fdata, probs, windowLens, models = bf.windowForecast(data, \
                                                minWindow = minWindowLen, \
                                                maxWindow = maxWindowLen, \
                                                ftype = "best")
    
    if plot:
        mpl.subplot(211)
        xdata = range(len(data))
        mpl.plot(xdata, data, 'k', alpha = 0.5, linewidth = 2)
        mpl.plot(xdata, fdata, 'r', alpha = 0.5)
        mpl.xlim([0, len(data) - 1])
    
        mpl.subplot(212)
        xdata = range(actLength)
        for s in sacts:
            mpl.plot(xdata, s, 'k', alpha = 0.5)
        mpl.xlim([0, actLength - 1])

    return data, starts, fdata, probs, bf, windowLens, models
    

def modelDrift(starts, models):
    """Calculates the averge time it takes to recognize an activity"""
    d = 0
    for s in starts:
        i = s
        while models[i] == 0:
            i += 1
        d += i - s
    return d/(len(starts) * 1.0)


if __name__ == "__main__":
    
    #random.seed(10)
    
    data, starts, fdata, probs, bf, windows, models = simpleRun()
    #data, starts, fdata, probs, bf, windows, models = complexRun()#plot = False)
    print "Drift is:" + str(modelDrift(starts, models))
    
    