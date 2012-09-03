"""hmmextra.py
Author: James Howard

Extra hidden markov model functions.
"""
import pybb.suppress as suppress
import numpy
import math
import pybb.data.bbdata as bbdata
import ghmm
import random
import pybb.data

def normalizeAMat(m, constant = 0.01):
    """normalizeAMat(m, constant = 0.01)
    Add the value constant to aMatrix then normalize.
    """
    tmp = m.asMatrices()[0]
    for i in range(len(tmp)):
        for j in range(len(tmp)):
            m.setTransition(i, j, tmp[i][j] + constant)
    m.normalize()
    return m
    

def normalizePiMat(m, constant = 0.01):
    for i in range(len(m.asMatrices()[2])):
        m.setInitial(i, m.getInitial(i) + constant)
    m.normalize()
    return m


def newModel(states, randomize = True, startAtFirstState = False, \
            feedForward = True):
    """newModel(states, obs, sigma)
    Make a new random model.
    """
    pi = [1.0/states] * states
    
    if startAtFirstState:
        pi = [0] * states
        pi[0] = 1
    
    aMat = numpy.zeros((states, states), float)
    bMat = numpy.zeros((states, 2), float)
    
    if randomize:
        for i in range(states):
            for j in range(states):
                aMat[i][j] = random.random()
                if feedForward and (j != i + 1):
                    aMat[i][j] = 0
                if feedForward and (j == i + 1):
                    aMat[i][j] = 1
                
            for j in range(2):
                bMat[i][j] = random.random()

    aMat += 0.01
    bMat += 0.01

    m = ghmm.HMMFromMatrices(ghmm.Float(), \
                                ghmm.GaussianDistribution(ghmm.Float()), \
                                aMat, bMat, pi)
    return m


def obsToModel(observation, std = 0.1):
    """Makes a model from a single observation vector.
    """

    aMat = numpy.zeros((len(observation), len(observation)), float)
    bMat = numpy.zeros((len(observation), 2), float)
    pi = [0.05] * len(observation)
    pi[0] = 1.0
    
    for i in range(len(observation)):
        bMat[i][0] = observation[i]
        bMat[i][1] = std
        
        for j in range(len(observation)):
            aMat[i][j] = random.random() * 0.3
            if j == i + 1:
                aMat[i][j] = 0.9
                
    m = ghmm.HMMFromMatrices(ghmm.Float(), \
                                ghmm.GaussianDistribution(ghmm.Float()), \
                                aMat, bMat, pi)
    m.normalize()

    return m


def hmmDist(pattern, model):
    """hmmDist(pattern, cluster, sigma)
    
    Calculate the distance between a single pattern and the given cluster.
    
    This is an odd distance metric, because the greater the number the 
    close two elements are together.  I should fix this.
    """
    eSeq = ghmm.EmissionSequence(ghmm.Float(), pattern)
    tmp = model.loglikelihood(eSeq)
    
    try:
        tmp/1
    except Exception, e:
        print "In exception"
        tmp = -1000
    
    return tmp


def normHmmDistAll(pattern, clusters):
    """normHmmDistAll(pattern, clusters)
    
    Calculate the distance between a single pattern and all the other clusters.
    It then normalizes the distance score.
    
    If the pattern has a zero probability to every pattern, then make it 
    return all negative ones.
    """
    scores = []
    
    for c in clusters:
        a = hmmDist(pattern, c)
        try:
            if int(a):
                pass
        except:
            a = 0
        scores.append(a)
        
    tmp = sum(scores)

    if tmp == 0:
        scores = [-1] * len(scores)
        tmp = len(scores)
        
    return [s/tmp for s in scores]


def hmmDistAll(pattern, models):
    """hmmDistAll(pattern, clusters)
    
    Calculate the distance between a single pattern and all the other models.
    """
    scores = []
    
    for c in models:
        a = hmmDist(pattern, c)
        scores.append(a)
    return scores    
    

def hmmBestFit(pattern, models):
    """Returns the index of the best fit model from a list of models.
    """
    scores = hmmDistAll(pattern, models)
    tmp = pybb.data.indexsort(scores, reverse=True)
    
    return tmp[0]

    
def hmmSilhoutte(patterns, clusters):
    """A total cluster score for a hidden markov model clustering.
    Score is based in part from matlab's silhouette function.
    
    Actual function used is 1 - dist(your cluster)/dist(nearest neighbor)
    
    Lower scores are better.
    """
    score = 0
    total = 0
    
    for p in patterns:
        try:
            t = hmmDistAll(p, clusters)
            i = pybb.data.indexsort(t)
            score += t[i[0]]/t[i[1]]
            total += 1
        except:
            pass
    
    return 1 - score/(1.0 * total)
    
def generateAvgModel(model, length, genNum = 50):
    """Creates an average array for a given model.
    """
    
    #Number states
    states = len(model.getEmission(0))
    numSensors = int(math.log(states, 2))

    a = numpy.zeros((length, numSensors), float)
    
    for i in range(genNum):
        tmp = model.sampleSingle(length)
        
        b = bbdata.uncompressData(tmp, numSensors)
        a += b
    
    a /= genNum
    
    return a
            
    
    
    