import pybb
import numpy as np
import matplotlib.pyplot as mpl
import rpy2.robjects.numpy2ri
import rpy2.robjects as R
from rpy2.robjects.packages import importr
import pybb.model.kmeans_hmm as khmm
import pybb.model.bayesian_forecast as bayesian
import pybb.model.gaussian as gaussian
forecast = importr("forecast")


def oneActivity(periodLength = 30, activityLength = 10):
    """Run on one activity....
    """
    numPeriods = 200
    periodSize = 1.0
    periodStd = 0.02
    
    numActivities = 10
    typesActivities = [0]
    activitySize = 0.3
    activityStd = 0.02
    
    
    data, acts = pybb.data.generateDataRandom1d(numPeriods, periodLength, \
                        periodStd, periodSize, numActivities, \
                        typesActivities, activityLength, activityStd, \
                        activitySize)
    
    sample, sacts = pybb.data.generateDataRandom1d(10, periodLength, \
                        periodStd, periodSize, 2, \
                        typesActivities, activityLength, activityStd, \
                        activitySize)
    
     
    return data, acts, sample, sacts
    

if __name__ == "__main__":
    
    periodLength = 30
    activityLength = 10
    numModels = 1
    
    data, acts, sample, sacts = oneActivity(periodLength, activityLength)
    data1d = pybb.data.concatonate(data)
    
    R.r.assign("d", data1d)
    R.r.assign("periodLength", periodLength)
    mod = R.r('mod = arima0(d, order=c(2,0,1), seasonal=list(order=c(0,1,1), period=periodLength))')
    fdata = R.r('fd = forecast.Arima(mod)')

    #Create all necessary arrays
    #fit = np.reshape(fdata[8], (len(fdata[8])/periodLength, periodLength))
    res = np.reshape(fdata[9], (len(fdata[9])/periodLength, periodLength))
    res1d = np.array(fdata[9])
    #fit1d = np.array(fdata[8])

    act = []
    for a in acts:
        #act.append(res[a[0]][a[1]:a[1] + activityLength])
        #If arima0 use offset of -1
        act.append(res[a[0] - 1][a[1]:a[1] + activityLength])
    act = np.array(act)
    
    #print "Mape value is:" + str(pybb.math.mape(data1d, fdata[8])[0])

    #Plot the data and the residuals
    #Data
    mpl.subplot(211)
    xdata = range(periodLength)
    for d in data:
        mpl.plot(xdata, d, 'k', alpha = 0.3)
    mpl.xlim([0, periodLength - 1])

    #Residuals
    mpl.subplot(212)
    xdata = range(activityLength)
    for a in act:
        mpl.plot(xdata, a, 'k', alpha = 0.3)
    mpl.xlim([0, activityLength - 1])

    #Train Models
    model, mdata, mout = khmm.train(act.tolist(), numModels, activityLength, \
                                    iterations = 20, outliers = False, \
                                    clustering = "kmeans++")
                                    
    model.append(gaussian.Gaussian(0, res1d.std()))
    """
    #Perform a simple forecast for one dataelement.
    #Start with simply two periods
    sdata = res1d[(acts[0][0] - 2) * periodLength:(acts[0][0]) * periodLength]
    
    #Forecast all points along sdata
    bf = bayesian.BayesianForecast(model)
    bf.setStd(0, res1d.std())
    bf.setStd(1, res1d.std())
    
    windowLen = 5
    bfData = []
    bfProbs = []
    
    for i in range(len(sdata) - windowLen):
        s = sdata[i:i + windowLen].tolist()
        print s
        tmp, tmp2 = bf.forecast(s)
        bfData.append(tmp)
        bfProbs.append(tmp2)
        
    mpl.subplot(313)
    xdata = range(len(sdata))
    mpl.plot(xdata, sdata, 'k')
    mpl.xlim([0, len(sdata) - 1])
    """
