import numpy
import time
import datetime
import bbdata
import lsa
import dataio
import sys

patternsPerSensor = 7

def __toSeconds(tDelta):
    return tDelta.days * 24 * 60 * 60 + tDelta.seconds


def calculateTDMatrix(readLoc = "", startTime = None, endTime = None, \
                      interval = None, directories = [], sensors = []):
    """
    Calculate the TD matrix for a set of detections created using Bill's matlab
    detection code.
     
    Returns a tdMatrix or an exception.
    """                  
    
    intervalSeconds = __toSeconds(interval)
    numIntervals = __toSeconds(endTime - startTime)/intervalSeconds
    intervalSpot = None
    print "Num intervals:" + str(numIntervals)
    tdMatrix = numpy.zeros((patternsPerSensor * len(sensors), numIntervals + 1), int)
    f = None

    for i in range(len(sensors)):
        
        print "Sensor number:" + str(i)
        for dirName in directories:
            fileName = readLoc + dirName + "/" + "detections" + str(sensors[i]) + ".txt"
            try:
                f = open(fileName).readlines()
            except:
                f = None
            
            if f:
                for line in f:
                    line = line.split()
                    lineTime = line[3] + " " + line[4]
                
                    lineTime = datetime.datetime.strptime(lineTime, "%Y-%m-%d %H:%M:%S")
                
                    if lineTime > endTime:
                        break
                
                    if lineTime < startTime:
                        continue
                    
                    intervalSpot = __toSeconds(lineTime - startTime)/intervalSeconds
                
                    # - 1 in formula because patterns are numbered starting from 1 and not zero
                    tdMatrix[i * patternsPerSensor + int(line[1]) - 1][intervalSpot] += 1
                    
    return tdMatrix



def calcTDForFile(readLoc, split = [], start = 0, includeEmpty = False, \
                    patternWindowSize = 18, tdMatrix = []):
    """
    Using the given tdMatrix, read a detection file and put the patterns in to 
    the tdMatrix with the "term" part of the pattern starting at index start.
    
    patternWindowSize is used to know how often to fill in an empty pattern.
    """


    oldTime = -1
    startTime = -1
    currentSplit = 0

    try:
        f = open(readLoc).readlines()
    except Exception, e:
        #print "Unable to open file " + str(readLoc)
        return tdMatrix

    for line in f:
        line = line.split()
        patternNum = int(line[1]) + start
        patternStr = float(line[2])
        lineTime = str(line[3]) + " " + str(line[4])
        lineTime = time.strptime(lineTime, "%Y-%m-%d %H:%M:%S")
        lineTime = time.mktime(lineTime)
        
        if startTime == -1:
            startTime = lineTime
        
        didSplit = False

        try:
            if ((lineTime - startTime)) >= split[currentSplit]:
                currentSplit += 1
                didSplit = True
        except Exception, e:
            pass
        
        timeDifference = lineTime - oldTime
        
        if timeDifference > patternWindowSize and oldTime > 0 and \
            includeEmpty == True:

            #If we have a period of no activity then fill in with empty 
            #pattern.
            #However have to make sure that we don't cross a split in this empty calculation.
            if didSplit == True:
                tdMatrix[0][currentSplit - 1] += \
                    int((split[currentSplit - 1] - oldTime)/patternWindowSize)
                tdMatrix[0][currentSplit] += \
                    int((lineTime - split[currentSplit - 1])/patternWindowSize)
            else:
                tdMatrix[0][currentSplit] += int(timeDifference/patternWindowSize)
        
        tdMatrix[patternNum][currentSplit] += 1
        oldTime = lineTime
        
    return tdMatrix


def makeOutputFiles(outData, writeLoc):

    makeProbLatentFile(outData, writeLoc)
    #makeProbDocumentLatentFile(outData, writeLoc)
    #makeTopPatternsLatentFile(outData, writeLoc)
    
    

def makeTopPatternsLatentFile(outData, writeLoc):

    print outData.numPatterns

    for i in range(len(outData.pz)):
        f = open(writeLoc + str("topPatterns") + str(i) + ".txt", "w")
        f.write("Probability of pattern within latent class number " + str(i) + ".\n")

        tmp = numpy.zeros((outData.pwz.shape[0], 1), float)
        for j in range(outData.pwz.shape[0]):
            tmp[j] = outData.pwz[j][i]
        
        tmp = tmp.transpose()
        tmp = numpy.argsort(tmp)
    
        for k in range(tmp.shape[1]):
            index = tmp[0][-1*k - 1]
        
            if index == 0:
                f.write("0   0   " + "%.4f" % outData.pwz[index][i] + "\n")
            else:
                for l in range(len(outData.numPatterns)):
                    if outData.numPatterns[l] >= index:
                        sensor = 10 + 10*(int((l - 1)/5)) + (l - 1)%5
                        pattern = index - outData.numPatterns[l - 1]
                        f.write(str(sensor) + "   " + \
                                str(pattern) + "   " + \
                                "%.4f" % outData.pwz[index][i] + "\n")
                        break
                


def makeProbLatentFile(outData, writeLoc):    
    #Make probability of latent class
    f = open(writeLoc + str("probLatent.txt"), "w")
    
    f.write("Probability of individual latent class.\n")
    
    for i in range(len(outData.pz)):
        f.write(str(i) + "   %.4f\n" % outData.pz[i])
        
    
    f.close()
    


def makeProbDocumentLatentFile(outData, writeLoc): 
    #make probability of latent class given document
    
    f = open(writeLoc + str("probDocumentLatent.txt"), "w")
    
    #Normalize pdz
    for i in range(outData.pdz.shape[0]):
        total = 0
        
        for j in range(outData.pdz.shape[1]):
            total += outData.pdz[i][j]
            
        for j in range(outData.pdz.shape[1]):
            outData.pdz[i][j]/=total
            
    
    f.write("Probability of Documents given latent class.\n")
    for i in range(outData.pdz.shape[0]):
        f.write(str(i) + "   " + str(outData.splitTimes[i]) + "   ")
        
        for j in range(plsaData.pdz.shape[1]):
            f.write('%.4f   ' % plsaData.pdz[i][j])
        f.write("\n")



if __name__ == "__main__":

    readLoc = "../data/detections/"
    fileLoc = "../data/sensor_data/detections.dat"
    startTime = "2008-03-01 00:00:00"
    endTime = "2008-03-07 23:59:59"
    interval = datetime.timedelta(hours = 1)

    startTime = datetime.datetime.strptime(startTime, "%Y-%m-%d %H:%M:%S")
    endTime = datetime.datetime.strptime(endTime, "%Y-%m-%d %H:%M:%S")
    
    directories = []
    sensors = []
    
    #directories.append("detectionsSep2007")
    #directories.append("detectionsOct2007")
    #directories.append("detectionsNov2007")
    #directories.append("detectionsDec2007")
    #directories.append("detectionsJan2008")
    #directories.append("detectionsFeb2008")
    #directories.append("detectionsMar2008")
    #directories.append("detectionsApr2008")

    directories.append("detectionsJan2008-Mar2008")
    #directories.append("detectionsSep2007-Dec2007")

    for i in range(1, 11):
        for j in range(0, 5):
            sensors.append(i*10 + j)
    
    print "Sensors:" + str(len(sensors))
    
    tdMatrix = calculateTDMatrix(readLoc, startTime, endTime, interval, directories, sensors)
    print tdMatrix

    oData = None
    
    try:
        oData = dataio.loadData(fileLoc)
    except:
        oData = bbdata.Dataset(None)
    
    oData.tdMatrix = tdMatrix
    dataio.saveData(fileLoc, oData)

