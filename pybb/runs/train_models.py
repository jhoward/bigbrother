"""
train_models.py

Author: James Howard

Run program to construct model files.
"""

import pybb.math.markov_anneal as markov_anneal
import pybb.data.dataio as dataio
import pybb.data.bbdata as bbdata
import pybb.math.hmmextra as hmmextra
import datetime
import os
import random
import pybb.suppress as suppress
import pybb.math.ncluster as ncluster
from ghmm import *
import numpy

maxModels = 2
minModels = 2
splitLen = 10
compress = 2
#st = "2010-01-01 00:00:00"
#et = "2010-01-01 00:13:20"
st = "2008-03-17 06:00:00"
et = "2008-03-17 18:00:00"
periodStart = datetime.datetime.strptime("07:50:00", "%H:%M:%S")
periodEnd = datetime.datetime.strptime("14:00:00", "%H:%M:%S")

#sensors = [[70, 71, 72, 73, 82], \
sensors =  [[70, 71, 72, 73, 82], \
           [63, 62, 61, 60, 54], \
           [53, 52, 51, 50, 44], \
           [43, 24, 42, 41, 34], \
           [40, 33, 31, 32, 30], \
           [81, 82, 83, 90], \
           [90, 93, 101, 102]]

sensors = [[90, 93, 101, 102]]

validDays = [0, 1, 2, 3, 4, 5, 6]

writeLocation = "../../runs/small/models/"
dataDirectory = "../../data/real/small/"
neighborhoodLocation = "../../data/generated/clean/neighborclusters.txt"
bestData = None
bestModels = None
bestStates = None
bestOut = None

if __name__ == "__main__":

    #Generate the data first.
    st = datetime.datetime.strptime(st, "%Y-%m-%d %H:%M:%S")
    et = datetime.datetime.strptime(et, "%Y-%m-%d %H:%M:%S")

    #Get the sensor blocks
    for i in range(len(sensors)):
        print "Sensors:" + str(sensors[i])

        cd, td = bbdata.getdata(st, et, \
                pStart = periodStart, \
                pEnd = periodEnd, \
                vDays = validDays, \
                comp = compress, \
                sens = sensors[i], 
                readLocation = dataDirectory)
        
        neighborclusters = ncluster.parse(neighborhoodLocation)
        local = neighborclusters[str(sensors[i])]
        cd2 = ncluster.convertNeighborhood(cd, local)
        cd2 = numpy.array(cd2, ndmin = 2)
        cd2 = cd2.T
        
        #obs = 2**len(sensors[i])
        #sData = markov_anneal.splitLocalMax(cd, td, splitLen)

        obs = 9
        
        #Use only for sensor block 90-102
        if i == len(sensors) - 1:
            obs = 16
        
        sData = markov_anneal.splitLocalMax(cd2, td, splitLen)

        print len(sData)
        
        bestSil = -1
        for n in range(minModels, maxModels + 1):
            numModels = n
            for o in range(8, obs + 1, 4):
                states = o
                bm, bd, out = markov_anneal.train(sData.values(), \
                                                numModels, \
                                                states, obs, \
                                                iterations = 20, \
                                                printBest = False,  \
                                                clustering = "kmeans", \
                                                verbose = False)
                
                """
                trainData = markov_anneal.train(sData.values()[0:700], \
                                                numModels, \
                                                states, obs, \
                                                iterations = 20, \
                                                printBest = False,  \
                                                clustering = "kmeans", \
                                                verbose = False)
                """
                
                sigma = IntegerRange(0, obs)
                bd2 = []

                for j in bd:
                    bd2 += j
                s = hmmextra.hmmSilhoutte(bd2, bm, sigma)
                f = markov_anneal._fitness(bm, bd, sigma)
            
                print "models: " + str(n) + "  states:" + str(o) + \
                    "   Silhouette:" + str(s) + "     inter-distance:" + str(f)
                
                if s > bestSil:
                    bestSil = s
                    bestModels = bm
                    bestData = bd
                    bestOut = out
                    bestStates = states
                    bestInter = f

        
        sigma = IntegerRange(0, obs)
        bd2 = []
        for j in bestData:
            bd2 += j
        s = hmmextra.hmmSilhoutte(bd2, bestModels, sigma)
        f = markov_anneal._fitness(bestModels, bestData, sigma)

        print "best models: " + str(len(bestModels)) + "   best states:" + str(bestStates) + \
            "   best Silhouette:" + str(bestSil) + "     best inter-distance:" + str(bestInter)

        oData = bbdata.Dataset(None)
        oData.sData = sData
        oData.out = bestOut
        oData.models = bestModels
        oData.obs = obs
        oData.states = bestStates
        oData.assignedData = bestData
        oData.sensors = sensors[i]
        oData.modelToMatrix(True)
        wl = writeLocation + str(sensors[i][0]) + "_" + \
              str(sensors[i][-1]) + ".dat"
        dataio.saveData(wl, oData)

