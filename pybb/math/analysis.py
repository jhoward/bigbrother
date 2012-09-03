from ghmm import *
import pybb.suppress as suppress
import numpy

def optimalModel(data, models):
    """From a set of models, determine the best one to fit a given 
    data element.
    
    Returns optimal model number and loglikelihood
    """

    best = -1
    bestModel = -1
    sigma = IntegerRange(0, len(models[0].emissionDomain))
    eSeq = EmissionSequence(sigma, data)
    for i in range(len(models)):
        try:
            tmp = models[i].loglikelihood(eSeq)

            if tmp > best or best == -1:
                best = tmp
                bestModel = i
        except:
            pass

    return bestModel, best


def ratio(cd, models, suppress = False):
    """For a compressed data set and a set of models, calculate the ratio
    of data elements that make up the data set.
    """
    mc = [0] * len(models)
    
    if suppress:
        suppress.suppress(2)

    for d in cd:
        bm = optimalModel(d, models)[0]
        if not (bm == -1):
            mc[bm] += 1

    if suppress:
        suppress.restore(2)
    
    r = [(t * 1.0)/len(cd) for t in mc]
    
    return r, mc

    
def vecMean(vec):
    """For a set of vectors, calculate the mean."""
    mean = None
    for v in vec:
        if mean == None:
            mean = numpy.array(v)
        else:
            mean += numpy.array(v)
        
    return list(mean / len(vec))
    

def vecVariance(vec, mean = None):
    """For a set of vectors, calculate the variance.
    
    If mean is not specified.  Calculate it from vecMean.
    """
    
    if mean == None:
        mean = vecMean(vec)
        
    var = None
    
    for v in vec:
        out = (numpy.array(v) - numpy.array(mean)) ** 2
        
        if var == None:
            var = out
        else:
            var += out
    
    return list(var / len(vec))

    
def lsaProjection(doc, vec):
    """Project a document vector onto an lsa vector and return the result.
    """
    
    d = numpy.array(doc)
    v = numpy.array(vec)
    
    if numpy.dot(d, d) == 0:
        return 0
    
    val = numpy.dot(d, v)/(numpy.dot(d, d)**0.5)
    
    return val
    
    
def projectList(docList, vectors):
    """Project a list of documents on to a list of vectors
    """
    
    plist = []
    
    for l in docList:
        tmp = []
        for i in range(vectors.shape[1]):
            tmp.append(lsaProjection(l, vectors[:, i]))
            
        plist.append(tmp)
        
    return plist
    
def mape(data, predicted):
    """Calculates the mean absolute percentage error between a data set and a 
    predicted set.  
    
    There may be more data than predicted.  Only uses all information from the 
    predicted list.  Zero data values are removed from the calculation.
    """
    total = 0
    num_total = 0
    
    for p in range(len(predicted)):
        if data[p] != 0:
            total += abs((data[p] - predicted[p]) / (1.0 * data[p]))
            num_total += 1
    total /= num_total
    
    return total
    
    
def smape(data, predicted):
    """Calculates the symmetric mean absolute percentage error between a data 
    set and a predicted set.
    
    There may be more data than predicted.  Only uses all information from the 
    predicted list.  If data and forcast are zero, adds zero to the total.
    """
    
    total = 0
    
    for p in range(len(predicted)):
        if data[p] + predicted[0] != 0:
            total += abs(data[p] - predicted[p]) / \
                    (1.0 * data[p] + predicted[p])
    total /= len(predicted)
    
    return total
    
def mase(data, predicted):
    """Calculates the mean absolute scale error between a data set and a 
    predicted set.
    
    mase is from the paper "Another look at measures of forecast accuracy"
    by Hyndman and Koehler
    """
    
    total = 0
    
    #First calculate the average one-step forcast error (Naive error)
    ne = 0
    for p in range(len(data) - 1):
        ne += abs(data[p + 1] - data[p])
    ne /= 1.0 * (len(data) - 1)
    
    for p in range(len(predicted)):
        total += abs(predicted[p] - data[p])
        
    total /= ne
    total /= len(predicted)
    
    return total
        
        
    
        