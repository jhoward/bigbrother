from ghmm import *
import numpy
import warnings
import datetime
import pybb.suppress as suppress
import pybb.data.dataio as dataio
import pybb.data.calc as calc
from PyDbLite import Base
import random
import os
import pybb.math.analysis as analysis

warnings.simplefilter("ignore")

bLocation = "../../data/generated/chaotic_gt"
allSensors = [10, 11, 12, 13, 14, 20, 21, 22, 23, 24, 30, 31, 32, 33, 34, \
                40, 41, 42, 43, 44, 50, 51, 52, 53, 54, 60, 61, 62, 63, \
                64, 70, 71, 72, 73, 74, 80, 81, 82, 83, 84, 90, 91, 92, 93, \
                94, 100, 101, 102, 103, 104]
dataLocation = None
allData = None


class Data(list):
    """Data class for a single sensor. 
    
    Data is added 
    """
    
    def __init__(self):
        self.st = None
        self.et = None
        self.sensor = None

    
class Dataset(object):
    """
    Dataset class.
    
    Contains all information to recreate a dataset and its prediction.
    """
    def __init__(self, data):
        self.data = data
        self.obs = None
        
    def __str__(self):
        s = ""
        for k in self.__dict__.keys():
            s += k + "\n"
        return s
        
    def __repr__(self):
        return self.__str__()
        
    
    def modelToMatrix(self, deleteBM = False):
        """Conver the list of hidden markov models self.bm to a list of 
        matrices.
        
        If deleteBM is true then the list self.bm is removed.  This feature
        is used primarily to pickle the dataset.
        """
        self.modelList = []
        
        for m in self.models:
            self.modelList.append(m.asMatrices())
            
        if deleteBM:
            del self.models


    def matrixToModel(self, matrixList):
        """Convert a list of matrices to a list of hidden markov models.
        
        This list of matricies must be of the form.
        [[A], [B], [pi]]
        
        This function assumes that self.obs is set.
        """
        self.models = []
        sigma = IntegerRange(0, self.obs)
        
        for ml in matrixList:
            aMat = ml[0]
            bMat = ml[1]
            pi = ml[2]
            m = HMMFromMatrices(sigma, DiscreteDistribution(sigma), \
                                                            aMat, bMat, pi)
            
            self.models.append(m)



def localAverage(data, localRange):
    """Squash data along a given axis such that data at element i is 
    one if any elements from i + 1 to i + localRange is one.  Else 
    set i to zero.
    
    A localRange of 1 contains only value i
    """
    
    tmp = numpy.zeros((data.shape[0] - localRange + 1, data.shape[1]), float)
    
    for j in range(data.shape[1]):
        for i in range(data.shape[0] - localRange + 1):
            
            if data[i:i + localRange, j].sum() > 0:
                tmp[i, j] = 1
    
    return tmp
    

def compressData(data, numBase = 2):    
    """Convert a dataset to one that is one dimensional.  
    matrix data must contain no values other than zero and one.
    new[row_dimension] = binary reconstruction of column dimensions.
    """
    tmpData = [0] * data.shape[0]

    for i in range(data.shape[0]):
        tmp = 0

        for j in range(data.shape[1]):
            tmp += numBase**(data.shape[1] - 1 - j) * data[i][j]

        tmpData[i] = tmp
        
    tmpData = numpy.array(tmpData)
    tmpData.resize(tmpData.shape[0], 1)
    
    return tmpData
    

def uncompressData(data, numSensors, numBase = 2):
    tmp = numpy.zeros((len(data), numSensors))
    
    for l in range(len(data)):
        val = data[l]
        for m in range(numSensors):
            sub = numBase**(numSensors - 1 - m)
            if (val - sub) >= 0:
                tmp[l][m] = 1
                val = val - sub
                
    return tmp

def compressVector(v, numBase = 2):
    """Convert a positive value vector with no value greater than numBase - 1
    into a scalar.
    """
    tmp = 0
    
    for j in range(len(v)):
        tmp += numBase**(len(v) - 1 - j) * v[j]
    
    return tmp

def combineData(data, combine = 4):
    """Interatively run through a set of data if any behavior happens within 
    a window of size combine, then make the entire window that size.
    
    The new size of the data set will be equal to the original size divided 
    by combine.
    """
    
    tmp = numpy.zeros((data.shape[0] / combine, data.shape[1]), float)
    
    for j in range(data.shape[1]):
        for i in range(tmp.shape[0]):
            for k in range(combine):
                if data[i * combine + k, j] == 1:
                    tmp[i, j] = 1
    return tmp


def getdata(st, et, \
            pStart = datetime.datetime.strptime("00:00:00", "%H:%M:%S"), \
            pEnd = datetime.datetime.strptime("23:59:59", "%H:%M:%S"), \
            vDays = [0, 1, 2, 3, 4, 5, 6], \
            comp = 1, \
            sens = allSensors, \
            readLocation = bLocation,
            compress = True):
    """getdata from a given database location.
    
    st = start time
    et = end time.
    comp = how compressed (in seconds) the returned data list should be.
            compression uses the compressVector method
    compress = If the returned result should be as an array for each 
                sensor or as a single number representing the data of the 
                region of sensors given.
    
    Both start and end times must be of datetime objects.
    
    returns a numpy array.
    
    For vDays -- 0 = Monday.  6 = Sunday.
    """
    global allData
    global dataLocation
    
    #Open the database -- Do not open if already in memory.
    if (not allData) or (not (readLocation == dataLocation)):
        allData = dataio.loadData(readLocation + "data.dat")
        dataLocation = readLocation
    
    positions = {} #Position in array for each sensor
    db = allData['db']
    timeList = []
    cData = []  #Data set being built.
    ct = st
    oneSec = datetime.timedelta(seconds = 1)
    tmp = 0

    #Find the starting positions for all sensors. -- Position will always be
    #the index of the next sensor location past the current time.
    for s in sens:
        ct = st.toordinal()
        while True:
            tmp = (db('date') == ct) & (db('sensor') == s)


            if len(tmp.records) > 0:
                positions[s] = tmp.records[0]['index']
                break
            else:
                ct += 1
                
            if ct > et.toordinal():
                #Set it to an upper limit.
                positions[s] = 1000000000
                break

        ct = st
        
        #Check if position isn't far enough and advance as necessary
        current = calc.datetonumber(ct)
        try:
            while allData[s][positions[s]] < current:
                positions[s] += 1
        except:
            positions[s] = 1000000000

    while(ct <= et):
        #Check if the time is valid.
        if ct.weekday() in vDays:
            if _validTime(ct, pStart, pEnd):
                cVec = [0] * len(sens)
                
                for i in range(len(sens)):
                    if positions.has_key(sens[i]):
                        
                        #Convert the ct to compressed time
                        current = calc.datetonumber(ct)
                        t = positions[sens[i]]

                        #If the current time plus the comp time pass some real 
                        #data, then update cVec and position
                        if t >= len(allData[sens[i]]) - 1:
                            continue
                            
                        if current + comp >= allData[sens[i]][t]:
                            cVec[i] = 1
                            
                            #print "Sensor:" + str(sens[i]) + "   t:" + str(t) + "    len:" + str(len(allData[sens[i]])) + "     CC:" + str(current + comp) + "     end:" + str(allData[sens[i]][-1])
                            
                            #Find the next valid position and update.
                            while((current + comp > allData[sens[i]][t]) and \
                                  (t < len(allData[sens[i]]) - 1)):
                                  t += 1
                            positions[sens[i]] = t    
                        
                #Determine the compressed value for cVec
                if compress:
                    cData.append(compressVector(cVec))
                timeList.append(ct)

        #At the end add a second
        ct += oneSec * comp
    
    #Delete all objects
    #del ad
    cData = numpy.array(cData)
    cData.resize(cData.shape[0], 1)
    timeList = numpy.array(timeList)
    timeList.resize(timeList.shape[0], 1)
    
    return cData, timeList

        
def _validTime(ct, start, end):
    """Checks to see if a time is between a start and end time.
    """
    
    tmp = str(ct.hour) + ":" + str(ct.minute) + ":" + str(ct.second)
    tmp = datetime.datetime.strptime(tmp, "%H:%M:%S")
    
    if tmp >= start and tmp <= end:
        return True
    return False
    
    
def timetoseconds(t):
    """Takes either a time object or a string of format HH:MM:SS and 
    converts this into a integer value for the number of seconds."""

    try:
        t = datetime.datetime.strptime(t, "%H:%M:%S")
    except:
        pass

    tm = t.time()

    return tm.hour * 3600 + tm.minute * 60 + tm.second    
    
    
    
def makeSplits(numSplits, st, et, valid, \
                splitLen = datetime.timedelta(minutes = 8),
                sPeriod = "00:00:00", \
                ePeriod = "23:59:59"):
    """Returns a list of splits from one time to another spanning splitlen
    """
    start = datetime.datetime.strptime(st, "%Y-%m-%d %H:%M:%S")
    end = datetime.datetime.strptime(et, "%Y-%m-%d %H:%M:%S")
    current = datetime.datetime.strptime(st, "%Y-%m-%d %H:%M:%S")
    oneDay = datetime.timedelta(days = 1)
    sP = datetime.datetime.strptime(sPeriod, "%H:%M:%S")
    eP = datetime.datetime.strptime(ePeriod, "%H:%M:%S")
    dif = eP - sP
    t = datetime.datetime.strptime("00:00:00", "%H:%M:%S")
    add = sP - t

    splits = []
    offset = []

    while current < end:
        if current.weekday() in valid:
            offset.append(current.toordinal() - start.toordinal())

        current += oneDay


    for i in range(numSplits):
        #grab a random day
        rd = offset[int(random.random() * len(offset))]

        #grap a random starting second
        rt = int(random.random() * (dif.seconds - splitLen.seconds))
        off = datetime.timedelta(seconds = rt)

        #starting day
        temp = datetime.datetime.fromordinal(start.toordinal() + rd)
        #add start time
        temp += add

        splits.append((str(temp + off), str(temp + off + splitLen)))

    return splits


def makeSplitsSequential(numSplits, st, \
                splitLen = datetime.timedelta(minutes = 8),
                skip = datetime.timedelta(minutes = 1)):
    """Returns a list of splits from a starting time.  Skips forward skip
    each time.
    """
    current = datetime.datetime.strptime(st, "%Y-%m-%d %H:%M:%S")

    splits = []

    for i in range(numSplits):
        #grab a random day
        splits.append((str(current), str(current + splitLen)))
        current += skip

    return splits

def writeTDMatrix(tdMatrix, times = None, outfile = None):
    
    f = open(outfile, 'w')
    
    for i in range(tdMatrix.shape[1]):
        if times:
            f.write(times[i] + ", ")

        for j in range(tdMatrix.shape[0]):
            if j < tdMatrix.shape[0] - 1:
                f.write(str(tdMatrix[j, i]) + " ")
            else:
                f.write(str(tdMatrix[j, i]))
        f.write("\n")
        
        




