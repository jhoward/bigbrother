import numpy
import math
import random
import correlation
import bbdata
import dataio
import visualizer

class Distribution(object):
    
    def __init__(self, nLoiter = 0, mLoiter = 0, stdLoiter = 1, \
                 nWalkLeft = 0, mWalkLeft = 0, stdWalkLeft = 1, \
                 nWalkRight = 0, mWalkRight = 0, stdWalkRight = 1, \
                 pMissReading = 0, noisePercent = 0, \
                 mSpeed = 1, stdSpeed = 0, specialOne = 0, \
                 specialTwo = 0):
                 
        self.nLoiter = nLoiter
        self.mLoiter = mLoiter
        self.stdLoiter = stdLoiter
        self.nWalkLeft = nWalkLeft
        self.mWalkLeft = mWalkLeft
        self.stdWalkLeft = stdWalkLeft
        self.nWalkRight = nWalkRight
        self.mWalkRight = mWalkRight
        self.stdWalkRight = stdWalkRight
        self.pMissReading = pMissReading
        self.noisePercent = noisePercent
        self.mSpeed = mSpeed
        self.stdSpeed = stdSpeed
        
        self.nSpecialOne = specialOne
        self.specialTwo = specialTwo


def makeLoiter(data, nIndex, dIndex, loiterLength, dataDist = Distribution()):
    """
    Update data with a loiter.
    """
    
    #Set the data points
    for j in range(int(loiterLength)):
        if random.random() > dataDist.pMissReading:
            data[nIndex + j, dIndex] = 1


def makeWalkLeft(data, nIndex, dIndex, walkLeftLength, dataDist = Distribution(), \
                speed = 1, numSensors = 1, numReadings = 10):

    if walkLeftLength > numSensors:
        walkLeftLength = numSensors

    if dIndex < 0:
        dIndex = 0

    if dIndex > numSensors - 1:
        dIndex = numSensors - 1

    if nIndex < 0:
        nIndex = 0

    if nIndex > numReadings - 1:
        nIndex = numReadings - 1

    d = dIndex

    for j in range(int(walkLeftLength)):
        if round(d) < numSensors and round(d) >= 0:
            if random.random() > dataDist.pMissReading:
                data[nIndex + j, numSensors - round(d) - 1] = 1
        d = d + speed;


def makeWalkRight(data, nIndex, dIndex, walkRightLength, dataDist = Distribution(), \
                  speed = 1, numSensors = 1, numReadings = 10):
    
    if walkRightLength > numSensors:
      walkRightLength = numSensors

    if dIndex < 0:
      dIndex = 0

    if dIndex > numSensors - 1:
      dIndex = numSensors - 1

    if nIndex < 0:
      nIndex = 0

    if nIndex > numReadings - 1:
      nIndex = numReadings - 1

    d = dIndex
    j = 0
    if speed > 0:
        while d < (dIndex + walkRightLength):
            data[nIndex + j, int(d)] = 1
            d = d + speed
            j += 1

            if j > 20:
                break


def makeSpecialOne(data, nIndex, dIndex, walkLength, dataDist = Distribution(), \
                   speed = 1, numSensors = 1, numReadings = 10):
    
    if random.random() > 0.5:
        makeWalkRight(data, nIndex, dIndex, walkLength, dataDist = Distribution(), \
                      speed = 1, numSensors = 1, numReadings = 10)
        makeWalkLeft(data, nIndex + walkLength - 1, dIndex + walkLength - 1, walkLength, \
                     dataDist = Distribution(), speed = 1, numSensors = 1, numReadings = 10)
    else:
        makeWalkLeft(data, nIndex, dIndex, walkLength, dataDist, \
                      speed, numSensors, numReadings)
        makeWalkRight(data, nIndex - walkLength + 1, dIndex + walkLength - 1, walkLength, \
                     dataDist, speed, numSensors, numReadings)



#Main function
def makeData(dataDist = Distribution(), numReadings = 10, numSensors = 1, \
             includeTime = False, randomize = False):
    """Main function for data generation program"""

    data = numpy.zeros((numReadings, numSensors), bool)

    #Loitering
    for i in range(dataDist.nLoiter):
        loiterLength = round(random.normalvariate(dataDist.mLoiter, dataDist.stdLoiter))
        startN = math.floor(random.random()*(numReadings - loiterLength))
        startD = math.floor(random.random()*numSensors)

        makeLoiter(data, startN, startD, loiterLength, dataDist)



    #Walk Right
    for i in range(dataDist.nWalkRight):

        walkRightLength =  \
            round(random.normalvariate(dataDist.mWalkRight, dataDist.stdWalkRight))
        startN = math.floor(random.random()*(numReadings - walkRightLength))
        startD = math.floor(random.random()*(numSensors - walkRightLength))
        if startD < 0:
            startD = 0
                    
        speed = random.normalvariate(dataDist.mSpeed, dataDist.stdSpeed)
        if speed < 0:
            speed = 0
        
        makeWalkRight(data, startN, startD, walkRightLength, dataDist, speed, \
                        numSensors, numReadings)


    #Walk Left
    for i in range(dataDist.nWalkLeft):

        walkLeftLength = \
            round(random.normalvariate(dataDist.mWalkLeft, dataDist.stdWalkLeft))
        startN = math.floor(random.random()*(numReadings - walkLeftLength))
        startD = math.floor(random.random()*(numSensors - walkLeftLength))
        speed = random.normalvariate(dataDist.mSpeed, dataDist.stdSpeed)
        
        if speed < 0:
            speed = 0

        makeWalkLeft(data, startN, startD, walkLeftLength, dataDist, speed, \
                        numSensors, numReadings)



    #Special One
    for i in range(dataDist.nSpecialOne):

        walkLength = \
            round(random.normalvariate(dataDist.mWalkLeft, dataDist.stdWalkLeft))
        startN = math.floor(random.random()*(numReadings - walkLength))
        startD = math.floor(random.random()*(numSensors - walkLength))
        speed = random.normalvariate(dataDist.mSpeed, dataDist.stdSpeed)

        makeSpecialOne(data, startN, startD, walkLength, dataDist, speed, \
                     numSensors, numReadings)

    #Randomize the columns
    if randomize:
        for i in range(numSensors):
            #Not a perfect randomization, but it isn't too bad
            j = math.floor(random.random() * numSensors)
            k = math.floor(random.random() * numSensors)
            
            tmpData = data[:, k].copy()
            data[:, k] = data[:, j]
            data[:, j] = tmpData

    return data
    
    

def combineData(distList = [], readings = 0, sensors = 0):
    data = numpy.zeros((readings * len(distList), sensors), float)
    
    for i in range(len(distList)):
        tmpData = makeData(distList[i], numReadings = readings, numSensors = sensors)
        data[i*readings:i*readings + readings, :] = tmpData
    
    return data



if __name__ == "__main__":
    
    dist = []
    saveLocation = "../data/generated/small.dat"
    sensors = 5
    readings = 250

    #dist.append(Distribution(nLoiter = 20, \
    #                        mLoiter = 5, \
    #                        stdLoiter = 0))

    dist.append(Distribution(nWalkLeft = 20, \
                            mWalkLeft = 5, \
                            stdWalkLeft = 0))
    
    dist.append(Distribution(nWalkRight = 20, \
                            mWalkRight = 5, \
                            stdWalkRight = 0))
                            
    data = combineData(dist, readings, sensors)
    tmpData = bbdata.Dataset(data)
    dataio.saveData(saveLocation, tmpData)
    
    visualizer.drawData(data)
    print "Generated image."
