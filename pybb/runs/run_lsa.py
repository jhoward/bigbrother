"""
run_lsa.py

Author: James Howard

Quick program used to take trained data, make a td matrix and then save the
plsa vector outputs.
"""

import pybb.data.dataio as dataio
import pybb.math.analysis as analysis
import pybb.math.lsa as lsa
from ghmm import *
import pybb.math.markov_anneal as markov_anneal
import datetime
import pybb.data.bbdata as bbdata
import numpy
import os
import random
import pybb.suppress as suppress
import pybb.math.ncluster as ncluster
        
#dataDirectory = "../../data/generated/clean/"
#modelDirectory = "../../runs/clean/models/"
#writeLocation = "../../runs/clean/data.lsa"

dataDirectory = "../../data/real/all/"
modelDirectory = "../../runs/small/models/"
writeLocation = "../../runs/small/all.lsa"
tdMatrixLocation = "../../runs/real/all/tdMatrix.dat"
neighborhoodLocation = "../../data/generated/clean/neighborclusters.txt"
        
#st = "2010-01-01 00:00:00"
#et = "2010-01-01 00:20:00"
st = "2008-03-09 00:00:00"
et = "2008-04-13 23:59:59"
periodStart = "00:00:00"
periodEnd = "23:59:59"
compress = 1
splitLen = 10
numTopics = 8

#validDays = [0, 1, 2, 3, 4, 5, 6]
validDays = [0, 2, 4]
tdMatrix = []
minBehaviour = 2

if __name__ == "__main__":
    
    #neighborclusters = ncluster.parse(neighborhoodLocation)
    
    splits = bbdata.makeSplitsSequential(5184, "2008-03-09 00:00:00", \
                    splitLen = datetime.timedelta(minutes = splitLen),
                    skip = datetime.timedelta(minutes = 10))
    
    """
    #Create all splits (documents) used for TD matrix
    splits = bbdata.makeSplits(25, st, et, valid=validDays, \
                    splitLen = datetime.timedelta(minutes = splitLen),
                    sPeriod = "07:50:00", \
                    ePeriod = "08:00:00")
                    
    splits += bbdata.makeSplits(25, st, et, valid=validDays, \
                    splitLen = datetime.timedelta(minutes = splitLen),
                    sPeriod = "15:50:00", \
                    ePeriod = "16:00:00")
                    
    splits += bbdata.makeSplits(25, st, et, valid=validDays, \
                    splitLen = datetime.timedelta(minutes = splitLen),
                    sPeriod = "08:50:00", \
                    ePeriod = "09:00:00")
                    
    splits += bbdata.makeSplits(25, st, et, valid=validDays, \
                    splitLen = datetime.timedelta(minutes = splitLen),
                    sPeriod = "09:50:00", \
                    ePeriod = "10:00:00")
    """
    
    #Use splits to create TD Matrix
    files = os.listdir(modelDirectory)
    models = []
    firstRun = True #Used to save the models once.
    print "Getting Data"
    for s in splits:
        print s
        oldSplit = datetime.datetime.strptime(s[0], "%Y-%m-%d %H:%M:%S")
        newSplit = datetime.datetime.strptime(s[1], "%Y-%m-%d %H:%M:%S")
        tmpDoc = []  #Used to determine if we are below the minimum num counts

        #for f in files:
            #It is a data file.
            #if f.split('.')[-1] == 'dat':
                #Open it and grab the models and sensor list
                #fn = dataio.loadData(modelDirectory + str(f))
                #fn.matrixToModel(fn.modelList)
                
                #if firstRun == True:
                    #Append the model list to a new dataset
                    #foo = bbdata.Dataset(None)
                    #foo.sensors = fn.sensors
                    #foo.models = fn.models
                    #foo.obs = fn.obs
                    #models.append(foo)
                
                #cd, td = bbdata.getdata(oldSplit, newSplit, \
                #                    comp = compress, \
                #                    sens = fn.sensors, \
                #                    vDays = validDays, \
                #                    readLocation = dataDirectory)
                                    
                #Used to convert to HMM data
                #local = neighborclusters[str(fn.sensors)]
                #cd2 = ncluster.convertNeighborhood(cd, local)
                #cd2 = numpy.array(cd2, ndmin = 2)
                #cd2 = cd2.T
                
                #sData = markov_anneal.splitLocalMax(cd2, td, splitLen)

                #try:
                #    val, counts = analysis.ratio(sData.values(), fn.models)
                #except Exception, e:
                #    counts = [0] * len(fn.models)
                #    val = [0] * len(fn.models)

                #tmpDoc += counts
        
        
        
        cd, td = bbdata.getdata(oldSplit, newSplit, \
                            comp = compress, \
                            sens = bbdata.allSensors, \
                            vDays = validDays, \
                            readLocation = dataDirectory)

        cd2 = bbdata.uncompressData(cd, 50)
        b = numpy.array(cd2)
        b = numpy.sum(b, axis = 0)
        
        tmpDoc = list(b)
                
        #if sum(tmpDoc) >= minBehaviour:
        #    tdMatrix.append(tmpDoc)
        #    print len(tdMatrix)

        firstRun = False

        tdMatrix.append(tmpDoc)

    sfirst = [s[0] for s in splits]

    tdMatrix = numpy.array(tdMatrix)
    bbdata.writeTDMatrix(tdMatrix.T, sfirst, tdMatrixLocation)
    
    #tdMatrix = tdMatrix.T
    
    #tmpData = bbdata.Data()
    #tmpData.tdMatrix = tdMatrix
    
    #print "Calculating plsa"
    #pz, pwz, pdz, pzd, pzdw = lsa.plsa(tdMatrix, numTopics, iterations = 150)
    #pwz, pz, pzd = lsa.lsa(tdMatrix)
    #Save to an lsa file.
    #tmpData.pz = pz
    #tmpData.pwz = pwz
    #tmpData.pzd = pzd
    #tmpData.splits = splits
    #tmpData.regions = models
    
    #for r in tmpData.regions:
    #    r.modelToMatrix(True)
    
    #dataio.saveData(writeLocation, tmpData)

    

        