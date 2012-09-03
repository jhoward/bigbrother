import ghmm
import pybb.model.kmeans_hmm as khmm
import random
import model
import numpy as np
import pybb.data

class Hmm(model.Model):
    def __init__(self, model = None):
        self.model = model
        self.history = 4
        
    def set(self, model):
        self.model = model
        
    def forecast(self, data, future = 1):
        """Forecast for a model the probability of each observation.

        equation is:
        p(o_t+1) = sum_j(p(o_t+1|s_t+1^j)p(s_t+1^j)
        where
        p(s_t+1^j) is found through forward algorithm
        """
        state = self.model.asMatrices()[0]
        observe = self.model.asMatrices()[1]
        ps1 = [0.0] * len(state[0])
        po1 = [0.0] * len(observe[0])

        tmp = ghmm.EmissionSequence(ghmm.Float(), data)

        ps = self.model.forward(tmp)[0][-1]

        for j in range(len(ps1)):
            for i in range(len(ps)):
                ps1[j] += state[i][j] * ps[i]

        for k in range(len(po1)):
            for j in range(len(ps1)):
                po1[k] += observe[j][k]*ps1[j]

        return po1[0]
    

    def loglikelihood(self, data):
        tmp = ghmm.EmissionSequence(ghmm.Float(), data)
        return self.model.loglikelihood(tmp)
        
        
    def dist(self, data):
        """dist(pattern)

        Calculate the distance between piece of data and the model.
        This is an absurd distance function as the closest distance is 
        the greatest value of this function.  Also the function can be 
        greater than or less than zero.
        """
        eSeq = ghmm.EmissionSequence(ghmm.Float(), data)
        tmp = self.model.loglikelihood(eSeq)

        try:
            tmp/1
        except Exception, e:
            print "In exception"
            tmp = -1000

        return tmp
        
        
        
def sample(length, size = 1, std = 0.4, type = 0):
    """
        Length -- number of time steps for activity
        Size -- multiplier for activity
        Std -- Standard deviation of Gaussian noise for activity
        Type -- 0 is a sin curve, 1 is a linear line
    """
    
    x = [0] * length
    
    for i in range(length):
        if type == 0:
            x[i] = size * np.sin((i / (1.0 * length)) * (2 * np.pi))
        if type == 1:
            x[i] = size * i / (1.0 * length)
        
        #Add noise
        x[i] += random.gauss(0, std)
        
    return x


def sampleMany(numSamples, sampleLength, size = 1, std = 0.1, atype = 0):
    """
    Construct a dataset of many sample activities from a single type.
    """
    x = []
    
    for i in range(numSamples):
        x.append(sample(sampleLength, size, std, atype))
    return x


def bestFit(pattern, models):
    """Returns the index of the best fit model from a list of models.
    """
    scores = distAll(pattern, models)
    tmp = pybb.data.indexsort(scores, reverse=True)

    return tmp[0]


def distAll(pattern, models):
    """distAll(pattern, clusters)

    Calculate the distance between a single pattern and all the other models.
    """
    scores = []

    for c in models:
        a = c.dist(pattern)
        scores.append(a)
    return scores


def findFit(data, models):
    index = []
    
    for d in data:
        index.append(bestFit(d, models))
    
    return index
    
    
if __name__ == "__main__":
    data = sampleMany(200, 8, atype = 0)
    data += sampleMany(200, 8, atype = 1)
    
    m, d, o = khmm.train(data, 2, 8, iterations = 10, outliers = False, \
                            clustering = "kmeans++")
    
    res = findFit(data, m)
    
    counts = [0, 0]
    for r in range(len(data)):
        i = r / len(data) / 2
        counts[i] += res[r]
        
    print counts
    print "This should print out something close to 200, 0 or 0, 200"

