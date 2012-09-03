import ghmm
import random
import numpy
import math
import pybb.model.hmm_supplimental as hmmsup
#import pybb.model.hmm

def train(data, k, states, iterations = 20, stopThreshold = 0, \
            outliers = True, printBest = True, \
            clustering = "random", verbose = True):
    """Train a given number of hidden markov models on a set of data.
    This data must first be run through a split function.  This allows 
    for the data to work with all functions contained within.

    NOTE: This assumes continous Gaussian data

    k = number of models to create.
    states = number of states in each model.
    iterations = number of iterations to complete until stoppping point.  
    stop_threshold = a threshold at which to stop early.  If the change 
                    between iterations is less than this value, then 
                    stop training.  A value of 0 equates to no early
                    stopping.
                    
    TODO Make work with multivariate Gaussians
    """
    if clustering == "random":
        return _kMeans(data, k, states, iterations, \
                        stopThreshold, outliers, printBest, verbose, \
                        "random")
                        
    if clustering == "kmeans++":
        return _kMeans(data, k, states, iterations, \
                        stopThreshold, outliers, printBest, verbose, \
                        "kmeans++")


def _kMeans(data, k, states, iterations = 20, stopThreshold = 0.01, \
            rOutliers = True, printBest = True, verbose = True, \
            iType = "kmeans++"):

    bestScore = -100
    bestModels = None
    bestData = None
    oldScore = -100
    models = []
    
    tdata = _randomAssign(data, k)
    if iType == "random":
        models = _randomModels(k, states)
        models = _trainModels(tdata, models)
    if iType == "kmeans++":
        models = _initializeGoodModels(data, k, states)
    tdata = _optimalAssign(tdata, models)
    outliers = []
    
    for i in range(iterations):
        models = _trainModels(tdata, models)
        score = _fitness(tdata, models)
        if verbose:
            print "  " + str(i) + ":  " + str(score)

        if (score > bestScore) or (bestScore == -100):
            bestScore = score
            bestModels = list(ghmm.HMMFromMatrices(ghmm.Float(), \
                                ghmm.GaussianDistribution(ghmm.Float()), \
                                m.asMatrices()[0], \
                                m.asMatrices()[1], \
                                m.asMatrices()[2]) for m in models)
            bestData = list(list(v) for v in tdata)
            bestOutliers = list(outliers)
            
        if (oldScore == -100) or (score - oldScore) > stopThreshold:
            tdata = _optimalAssign(tdata, models)
            oldScore = score

            if rOutliers:
                _removeOutliers(models, tdata)
        else:
            if verbose:
                print "Resetting all"
            tdata = _randomAssign(data, k)
            if iType == "random":
                models = _randomModels(k, states)
                models = _trainModels(tdata, models)
            if iType == "kmeans++":
                models = _initializeGoodModels(data, k, states)
            tdata = _optimalAssign(tdata, models)

            oldScore = -100

    if printBest or verbose:
        print "Average inter-cluster distance:" + str(bestScore)

    if rOutliers:    
        if verbose:    
            print "Number outliers found:" + str(len(bestOutliers))

        #For the best set of models and train data try to include any outliers 
        #again.  Then return the models, data and outliers.
        bestData, bestOutliers = _includeOutliers(bestModels, bestData, bestOutliers)
        bestModels = _trainModels(bestData, bestModels)
        bestData = _optimalAssign(bestData, bestModels)
        score = _fitness(bestData, bestModels)

        if printBest or verbose:
            print "Score with additional outliers:" + str(score)
        if verbose:
            print "New number of outliers:" + str(len(bestOutliers))

    import pybb.model.hmm
    bm = []
    for m in bestModels:
        bm.append(pybb.model.hmm.Hmm(m))

    return bm, bestData, bestOutliers



#BEGIN K Means functions
    
def _trainModels(tdata, models):
    """Train models using every data element designated from the _assign
    functions.  
    
    Note: this function is independent from the type of data split used.
    """
    for i in range(len(models)):

        #Create a sequence set used for training from the multiple observations
        seqSet = ghmm.SequenceSet(ghmm.Float(), [])
        for tmpData in tdata[i]:
            seqSet.merge(ghmm.EmissionSequence(ghmm.Float(), tmpData))

        #Make average sequence
        s = numpy.array(tdata[i])
        nm = hmmsup.obsToModel(s.mean(axis = 0), max(s.std(axis = 0)))
        nm.normalize()
        nm.baumWelch(seqSet)
        models[i] = nm
        #models[i].baumWelch(seqSet)#, loglikelihoodCutoff = 0.000001)
        hmmsup.normalizeAMat(models[i])
        hmmsup.normalizePiMat(models[i])
    return models
    

def _removeOutliers(models, trainData, outliers):
    needTrain = False

    for i in range(len(models)):
        
        mean = 0
        variance = 0
        
        #Calculate model mean
        for tmp in trainData[i]:
            eSeq = ghmm.EmissionSequence(ghmm.Float(), tmp)
            a = abs(models[i].loglikelihood(eSeq))
            mean += a
        
        try:
            mean /= (len(trainData[i]) * 1.0)
        except:
            continue
        
        #Calculate the model variance
        for tmp in trainData[i]:
            eSeq = ghmm.EmissionSequence(ghmm.Float(), tmp)
            v = abs(models[i].loglikelihood(eSeq))
            variance += (mean - v)**2
            
        variance /= (len(trainData[i]) * 1.0)
        std = variance**0.5
        
        for tmp in trainData[i]:
            eSeq = ghmm.EmissionSequence(ghmm.Float(), tmp)
            v = abs(models[i].loglikelihood(eSeq))
            if (v - mean) > (2 * std):
                trainData[i].remove(tmp)
                outliers.append(tmp)
                needTrain = True
    
    if needTrain:
        models = _trainModels(trainData, models)


def _includeOutliers(models, trainData, outliers):
    
    means = []
    stds = []
    
    for i in range(len(models)):
        
        mean = 0
        variance = 0
        
        #Calculate model mean
        for tmp in trainData[i]:
            eSeq = ghmm.EmissionSequence(ghmm.Float(), tmp)
            a = abs(models[i].loglikelihood(eSeq))
            #print a
            mean += a
        
        mean /= (len(trainData[i]) * 1.0)
        
        means.append(mean)
        
        #Calculate the model variance
        for tmp in trainData[i]:
            eSeq = ghmm.EmissionSequence(ghmm.Float(), tmp)
            v = abs(models[i].loglikelihood(eSeq))
            variance += (mean - v)**2
            
        variance /= (len(trainData[i]) * 1.0)
        std = variance**0.5
        
        stds.append(std)

    #For each data element in outliers, check for the model that it most 
    #fits.  If the outlier fits the model within one standard deviation
    #include it back into the data.
    for tmp in outliers:
        eSeq = ghmm.EmissionSequence(ghmm.Float(), tmp)
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



def _randomAssign(data, k):
    """Randomly assign data to a given set of k models.
    """
    tdata = [[] for i in range(k)]
    
    for seq in data:
        tdata[int(random.random() * k)].append(seq)
    
    return tdata


def _randomModels(k, states):
    """Make a set of k random models.  These models are untrained with 
    initial random values for all model matricies.
    """
    f = ghmm.Float()
    pi = [0.1] * states

    aMat = numpy.zeros((states, states), float)
    bMat = numpy.zeros((states, 2), float)
    #TODO Change above for multivariate Gaussians

    models = []
    
    for n in range(k):
        for i in range(states):
            for j in range(states):
                aMat[i][j] = random.random()
            for j in range(2):
                bMat[i][j] = random.random()
        m = ghmm.HMMFromMatrices(f, ghmm.GaussianDistribution(f), \
                                aMat, bMat, pi)
        models.append(m)
            
    return models


def _initializeGoodModels(data, numModels, states):
    """Initialization technique for selecting a good pool of models by which 
    to start the expectation maximization algorithm for unsupervised learning
    Based on kmeans++ paper.
    """

    models = []
    distances = numpy.zeros((len(data)), float)
    
    #Select initial random sequence
    seq = data[int(random.random()*len(data))]
    models.append(hmmsup.obsToModel(seq))

    for i in range(numModels - 1):
        for j in range(len(data)):
            tmp = hmmsup.obsToModel(data[j])
            tmpDistances = hmmsup.hmmDistAll(data[j], models)
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
                models.append(hmmsup.obsToModel(data[j]))
                break
    return models
    

def _optimalAssign(data, models):
    """Optimally assign data to the model that it best fits.
    """
    
    newData = [[] for i in models]
    
    for i in range(len(models)):
        for seq in data[i]:
            m = hmmsup.hmmBestFit(seq, models)
            newData[m].append(seq)
    return newData
            
            
def _fitness(data, models):
    """Mean of the loglikelihood of the all datasegments as described by 
    the model that best describes it.
    """
    
    total_error = 0
    num_elements = 0
    
    for i in range(len(models)):
        num_elements += len(data[i])
        
        for seq in data[i]:
            total_error += hmmsup.hmmDist(seq, models[i])
        
    return total_error/(num_elements * 1.0)
    
    

"""
DEPRECATED FUNCTIONS BELOW... 

May be of use at some time in the future.
"""

    
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



