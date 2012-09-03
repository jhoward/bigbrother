import pybb.suppress as suppress
suppress.suppress(2)
from ghmm import *
suppress.restore(2)
import random
import numpy
import os
import warnings
import math
import pybb.math.hmmextra as hmmextra
warnings.simplefilter("ignore")

def splitInactive(data, offset = 0):
    """Returns a list of lists where the data is split (for now) by areas 
    of inactivity at least offset in length."""
    
    i = 0
    instance = []
    trainData = []
    timeSinceLast = 0
    extra = []
    
    while(i < data.shape[0]):
        tmp = data[i][0]

        if tmp == 0 and timeSinceLast < offset:
            extra.append(tmp)
            timeSinceLast += 1
        elif tmp == 0 and timeSinceLast >= offset:
            if len(instance) > 0:
                trainData.append(instance)
                instance = []
                extra = []
        elif tmp > 0:
            #print instance
            #print extra
            if len(instance) > 0:
                instance += extra
            instance.append(tmp)
            extra = []
            timeSinceLast = 0

        i += 1

    return trainData
    
    
def splitAll(data, splitSize):
    """Makes split at each original data element.  
    Splits are defined by splitSize.
        
    Note data must already be compressed.
    """
    
    trainData = []
    
    for i in range(data.shape[0] - splitSize + 1):
        trainData.append(data[i:i + splitSize, 0].tolist())
    
    return trainData
    

def splitLocalMax(data, timeData, patternSize, minActivity = 2):
    """Returns a hash of lists where the data is split by areas of 
    maximum activity.
    
    patternSize:  The size of each local activity pattern
    bufferGap: the minimum distance between patterns
    minActivity: the minimum amount of activity in a pattern
    """
    
    i = patternSize
    splitData = {}
    pattern = [0] * patternSize
    localCount = 0
    maxCount = 0
    maxIndex = -1
    stopIndex = -1
    nextValid = 0
                
    #Iterate over dataset, find maximum local patterns
    while(i < (data.shape[0])):
        tmp = data[i][0]

        if tmp == 0:
            pattern.append(0)
        else:
            pattern.append(1)

        localCount += pattern[-1]
        localCount -= pattern.pop(0)
        
        if i > nextValid:
        
            if localCount >= maxCount and localCount >= minActivity:
                maxCount = localCount
                maxIndex = i
            
                if stopIndex == -1:
                    stopIndex = i + patternSize

            #If i hits a stopping point
            #save the max pattern
            if i == stopIndex:
                splitData[timeData[maxIndex][0]] = list(data[maxIndex - patternSize + 1:maxIndex + 1, 0])
                maxCount = 0
                maxIndex = -1
                stopIndex = -1
                nextValid = i + 1#patternSize

        i += 1
                    
    return splitData


def splitActivityMax(data, timeData, patternSize, minActivity = 3):
    """Returns a hash of lists where the data is split by areas of 
    maximum local activity and the local pattern size is determined by 
    patternSize."""

    i = 0
    splitData = {}

    while(i < (data.shape[0] - patternSize - 1)):
        tmp = data[i][0]

        #Find start of local activity
        #Find activity maximum within small region
        #parse out that activity
        #Find end of current local activity

        localMax = i
        localMaxCount = 0

        localCount = 0

        #Start of local activity
        if tmp > 0:

            #Count initial local activity
            for j in range(patternSize):
                if data[i + j][0] > 0:
                    localCount += 1

            if localCount < minActivity:
                i += 1
                continue

            localMaxCount = localCount

            #Iterate until end of current activity.  If local count becomes
            #greater than current overwrite.
            for j in xrange(i + 1, data.shape[0] - patternSize - 1):
                tmp = data[j][0]

                if tmp == 0 and data[j + 1][0] == 0:
                    i = j - 1 + patternSize
                    splitData[timeData[localMax][0]] = \
                            list(data[localMax:localMax + patternSize, 0])
                    break

                if data[j - 1][0] > 0:
                    localCount -= 1
                if data[j + patternSize - 1][0] > 0:
                    localCount += 1

                if localCount > localMaxCount:
                    localMaxCount = localCount
                    localMax = j

        i += 1

    return splitData


#BEGIN MARKOV ANNEAL FUNCTIONS
    
def _trainModels(trainData, models, sigma):
    """Train models using every data element designated from the _assign
    functions.  
    
    Note: this function is independent from the type of data split used.
    """
    for i in range(len(models)):

        #Create a sequence set used for training from the multiple observations
        seqSet = SequenceSet(sigma, [])
        for tmpData in trainData[i]:
            seqSet.merge(EmissionSequence(sigma, tmpData))
        models[i].baumWelch(seqSet, nrSteps = 20)#, loglikelihoodCutoff = 0.000001)
        #models[i].baumWelchSetup(seqSet, nrSteps = 20)#, loglikelihoodCutoff = 0.000001)
        #models[i].baumWelchStep(nrSteps = 1)#, loglikelihoodCutoff = 0.000001)
        
        
        hmmextra.normalizeBMat(models[i])
        hmmextra.normalizeAMat(models[i])
    
    return models
    

def _removeOutliers(models, trainData, outliers, sigma):
    needTrain = False

    for i in range(len(models)):
        
        mean = 0
        variance = 0
        
        #Calculate model mean
        for tmp in trainData[i]:
            eSeq = EmissionSequence(sigma, tmp)
            a = abs(models[i].loglikelihood(eSeq))
            #print a
            mean += a
        
        try:
            mean /= (len(trainData[i]) * 1.0)
        except:
            continue
        
        #Calculate the model variance
        for tmp in trainData[i]:
            eSeq = EmissionSequence(sigma, tmp)
            v = abs(models[i].loglikelihood(eSeq))
            variance += (mean - v)**2
            
        variance /= (len(trainData[i]) * 1.0)
        std = variance**0.5
        
        for tmp in trainData[i]:
            eSeq = EmissionSequence(sigma, tmp)
            v = abs(models[i].loglikelihood(eSeq))
            if (v - mean) > (2 * std):
                trainData[i].remove(tmp)
                outliers.append(tmp)
                needTrain = True
    
    if needTrain:
        models = _trainModels(trainData, models, sigma)
    #else:
        #print "No outliers found."


def _includeOutliers(models, trainData, outliers, sigma):
    
    means = []
    stds = []
    
    for i in range(len(models)):
        
        mean = 0
        variance = 0
        
        #Calculate model mean
        for tmp in trainData[i]:
            eSeq = EmissionSequence(sigma, tmp)
            a = abs(models[i].loglikelihood(eSeq))
            #print a
            mean += a
        
        mean /= (len(trainData[i]) * 1.0)
        
        means.append(mean)
        
        #Calculate the model variance
        for tmp in trainData[i]:
            eSeq = EmissionSequence(sigma, tmp)
            v = abs(models[i].loglikelihood(eSeq))
            variance += (mean - v)**2
            
        variance /= (len(trainData[i]) * 1.0)
        std = variance**0.5
        
        stds.append(std)

    #For each data element in outliers, check for the model that it most 
    #fits.  If the outlier fits the model within one standard deviation
    #include it back into the data.
    for tmp in outliers:
        eSeq = EmissionSequence(sigma, tmp)
        best = -1
        bestModel = -1
        for j in range(len(models)):
            val = abs(models[j].loglikelihood(eSeq))

            if val < best or best == -1:
                best = val
                bestModel = j
        
        #Determine if the best fit is "good" enough.
        #If it is, add the outlier back into the model
        if (best - means[bestModel]) < 1*(stds[bestModel]):
                trainData[bestModel].append(tmp)
                outliers.remove(tmp)
                
    return trainData, outliers


def train(data, numModels, states, obs, iterations = 20, stopThreshold = 0, \
                rOutliers = True, printBest = True, clustering = "kmeans", \
                verbose = True):
    """Train a given number of hidden markov models on a set of data.
    This data must first be run through a split function.  This allows 
    for the data to work with all functions contained within.

    numModels = number of models to create.
    states = number of states in each model.
    obs = number of valid observations for each model. 
            This value is typically 2**(num sensors).
    iterations = number of iterations to complete until stoppping point.  
    stopThreshold = a threshold at which to stop early.  If the change 
                    between iterations is less than this value, then 
                    stop training.  A value of 0 equates to no early
                    stopping.

    """
    
                
    if clustering == "kmeans":
        return _kmeans(data, numModels, states, obs, iterations, \
                        stopThreshold, rOutliers, printBest, verbose)
                        
    if clustering == "kmeans++":
        return _kmeanspp(data, numModels, states, obs, iterations, \
                        stopThreshold, rOutliers, printBest, verbose)
        

def _kmeans(data, numModels, states, obs, iterations = 20, \
            stopThreshold = 0, rOutliers = True, printBest = True, 
            verbose = True):

    sigma = IntegerRange(0, obs)
    
    bestScore = -1
    bestModels = None
    bestData = None
    oldScore = -1
    
    trainData = _randomAssign(data, numModels)
    models = _randomModels(numModels, states, obs)
    models = _trainModels(trainData, models, sigma)
    trainData = _optimalAssign(trainData, models, sigma)

    outliers = []
    
    for i in range(iterations):
        models = _trainModels(trainData, models, sigma)
        score = _fitness(models, trainData, sigma)
        if verbose:
            print "  " + str(i) + ":  " + str(score)

        if (score < bestScore) or (bestScore == -1):
            bestScore = score
            bestModels = list(HMMFromMatrices(sigma, \
                                DiscreteDistribution(sigma), \
                                m.asMatrices()[0], \
                                m.asMatrices()[1], \
                                m.asMatrices()[2]) for m in models)
            bestData = list(list(v) for v in trainData)
            bestOutliers = list(outliers)

        if (oldScore == -1) or (score < 0.98*oldScore):
            trainData = _optimalAssign(trainData, models, sigma)
            oldScore = score
            
            if rOutliers:
                _removeOutliers(models, trainData, outliers, sigma)
        else:
            trainData = _randomAssign(data, numModels)
            models = _randomModels(numModels, states, obs)
            models = _trainModels(trainData, models, sigma)
            trainData = _optimalAssign(trainData, models, sigma)
            
            oldScore = -1
    
    if printBest:
        print "Average inter-cluster distance:" + str(bestScore)
    
    if rOutliers:    
        if verbose:    
            print "Number outliers found:" + str(len(bestOutliers))
    
        #For the best set of models and train data try to include any outliers 
        #again.  Then return the models, data and outliers.
        bestData, bestOutliers = _includeOutliers(bestModels, bestData, bestOutliers, sigma)
        bestModels = _trainModels(bestData, bestModels, sigma)
        bestData = _optimalAssign(bestData, bestModels, sigma)
        score = _fitness(bestModels, bestData, sigma)

        if printBest or verbose:
            print "Score with additional outliers:" + str(score)
        if verbose:
            print "New number of outliers:" + str(len(bestOutliers))
    
    return bestModels, bestData, bestOutliers
    
    
def _kmeanspp(data, numModels, states, obs, iterations = 20, \
            stopThreshold = 0, rOutliers = True, printBest = True, 
            verbose = True):

    sigma = IntegerRange(0, obs)

    bestScore = -1
    bestModels = None
    bestData = None
    oldScore = -1

    trainData = _randomAssign(data, numModels)
    models = _initializeGoodModels(data, numModels, states, obs)
    trainData = _optimalAssign(trainData, models, sigma)

    outliers = []

    for i in range(iterations):
        models = _trainModels(trainData, models, sigma)
        score = _fitness(models, trainData, sigma)
        if verbose:
            print "  " + str(i) + ":  " + str(score)

        if (score < bestScore) or (bestScore == -1):
            bestScore = score
            bestModels = list(HMMFromMatrices(sigma, \
                                DiscreteDistribution(sigma), \
                                m.asMatrices()[0], \
                                m.asMatrices()[1], \
                                m.asMatrices()[2]) for m in models)
            bestData = list(list(v) for v in trainData)
            bestOutliers = list(outliers)

        if (oldScore == -1) or (score < 0.98*oldScore):
            trainData = _optimalAssign(trainData, models, sigma)
            oldScore = score

            if rOutliers:
                _removeOutliers(models, trainData, outliers, sigma)
        else:
            trainData = _randomAssign(data, numModels)
            models = _initializeGoodModels(data, numModels, states, obs)
            trainData = _optimalAssign(trainData, models, sigma)

            oldScore = -1

    if printBest:
        print "Average inter-cluster distance:" + str(bestScore)

    if rOutliers:        
        if verbose:
            print "Number outliers found:" + str(len(bestOutliers))

        #For the best set of models and train data try to include any outliers 
        #again.  Then return the models, data and outliers.
        bestData, bestOutliers = _includeOutliers(bestModels, bestData, bestOutliers, sigma)
        bestModels = _trainModels(bestData, bestModels, sigma)
        bestData = _optimalAssign(bestData, bestModels, sigma)
        score = _fitness(bestModels, bestData, sigma)

        if printBest or verbose:
            print "Score with additional outliers:" + str(score)
        if verbose:
            print "New number of outliers:" + str(len(bestOutliers))

    return bestModels, bestData, bestOutliers    


def _randomAssign(data, numModels):
    """Randomly assign data to a given model.  
    """
    trainData = [[] for i in range(numModels)]
    
    for seq in data:
        trainData[int(random.random() * numModels)].append(seq)
    
    return trainData


def _randomModels(numModels, states, obs):
    """Make a set of random models.  These models are untrained with 
    initial random values for all model matricies.
    """

    sigma = IntegerRange(0, obs)
    pi = [0.1] * states

    aMat = numpy.zeros((states, states), float)
    bMat = numpy.zeros((states, obs), float)

    models = []
    
    for n in range(numModels):
        for i in range(states):
            for j in range(states):
                aMat[i][j] = random.random()
            for j in range(obs):
                bMat[i][j] = random.random()
        m = HMMFromMatrices(sigma, DiscreteDistribution(sigma), aMat, bMat, pi)
        models.append(m)
            
    return models


def _initializeGoodModels(data, numModels, states, obs):
    """Initialization technique for selecting a good pool of models by which 
    to start the expectation maximization algorithm for unsupervised learning
    """

    sigma = IntegerRange(0, obs)
    models = []
    distances = numpy.zeros((len(data)), float)
    
    #Select initial random sequence
    seq = data[int(random.random()*len(data))]
    models.append(hmmextra.obsToModel(seq, states, obs))

    for i in range(numModels - 1):
        for j in range(len(data)):
            tmp = hmmextra.obsToModel(data[j], states, obs)
            tmpDistances = hmmextra.hmmDistAll(data[j], models, sigma)
            tmpDistances.sort()
            distances[j] = tmpDistances[0]

        distances /= sum(distances)

        #Select a model with probability dist/sum(all distance)
        val = random.random()
        distSum = 0
        
        for j in range(len(distances)):
            distSum += distances[j]
            
            if distSum >= val:
                #Make a new model using this data element
                models.append(hmmextra.obsToModel(data[j], states, obs))
                break
    return models
    

def _optimalAssign(data, models, sigma):
    """Optimally assign data to the model that it best fits.
    """
    
    newData = [[] for i in models]
    
    for i in range(len(models)):
        for seq in data[i]:
            m = hmmextra.hmmBestFit(seq, models, sigma)
            newData[m].append(seq)
    return newData
            
            
def _fitness(models, data, sigma):
    """Mean of the loglikelihood of the all datasegments as described by 
    the model that best describes it.
    """
    
    totalError = 0
    numElements = 0
    
    for i in range(len(models)):
        numElements += len(data[i])
        
        for seq in data[i]:
            totalError += hmmextra.hmmDist(seq, models[i], sigma)
        
    return totalError/(numElements * 1.0)
    

def calcModelEntropy(model):
    
    #Run for observation sequences of len = number of states
    
    #For each state calculate prob(j|i)
    a = model.asMatrices()[0]
    b = model.asMatrices()[1]
    entropy = 0
    
    for s in range(len(a)):
        #s is index of old observation state
        for i in range(len(b[0])):
            #i is old observation given state s
            #Calculate the probability of i given state s
            pis = b[s][i]
            
            for n in range(len(a)):
                #n is new observation state
                #Calculate transition probaility
                psn = a[s][n]
                
                if psn == 0:
                    continue
                
                for j in range(len(b[0])):
                    #j is new observation given state n
                    #calculate probility of j given state n
                    pjn = b[n][j]
                    
                    if pjn == 0:
                        continue
                    
                    entropy += pis * (psn * pjn) * math.log(psn * pjn, 2)
                    
    return -1 * entropy
                    

def assignedDataEntropy(assignedData, outliers = []):
    
    entropy = 0
    numbers = [len(i) for i in assignedData]
    
    length = len(outliers)
    length += sum(numbers)
    
    for i in range(len(numbers)):
        prob = numbers[i]/(length * 1.0)
        entropy += prob * math.log(prob, 2)
    
    if len(outliers) > 0:
        prob = len(outliers)/(length * 1.0)
        entropy += len(outliers) * prob * math.log(prob, 2)
    
    return -1 * entropy * length
