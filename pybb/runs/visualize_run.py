"""
visualize_run.py

Author: James Howard

Program to construct and visualize various runs of lsa data.
"""

import pybb.image.visualizer as visualizer
import pybb.data.dataio as dataio
import pybb.data.bbdata as bbdata
import pybb.math.markov_anneal as markov_anneal
import pybb.math.analysis as analysis
import datetime
import pybb.math.lsa as lsa
import pybb.math.ncluster as ncluster
from ghmm import *
import numpy
import operator
import os


st = "2008-03-17 00:00:00"
et = "2008-03-23 23:59:59"
periodStart = "00:00:00"
periodEnd = "23:59:59"
dataLocation = "../../data/real/small/"
modelLocation = "../../runs/real/models_min_3/"
lsaLocation = "../../runs/real/data_min_3.lsa"
neighborhoodLocation =  "../../data/generated/clean/neighborclusters.txt"

compress = 2
dVector = []
times = []
lsaVector = []
splitLength = 8
skipLength = 1
i = 0

if __name__ == "__main__":

    files = os.listdir(modelLocation)
    neighborclusters = ncluster.parse(neighborhoodLocation)
    
    splits = bbdata.makeSplits(100, st, et, valid = [0, 2, 4], \
                    splitLen = datetime.timedelta(minutes = splitLength), \
                    sPeriod = "06:00:00", \
                    ePeriod = "07:00:00")
                    
    splits += bbdata.makeSplits(100, st, et, valid = [0, 2, 4], \
                    splitLen = datetime.timedelta(minutes = splitLength), \
                    sPeriod = "18:00:00", \
                    ePeriod = "19:00:00")
    
    
    #Iterate over splits.
    for s in splits:
        print i
        i+=1
        oldSplit = datetime.datetime.strptime(s[0], "%Y-%m-%d %H:%M:%S")
        newSplit = datetime.datetime.strptime(s[1], "%Y-%m-%d %H:%M:%S")
        
        tmpDoc = []
        #Loop over all models
        for f in files:
            #It is a data file.
            if f.split('.')[-1] == 'dat':
                #Open it and grab the models and sensor list
                fn = dataio.loadData(modelLocation + str(f))
                fn.matrixToModel(fn.modelList)
            
                cd, td = bbdata.getdata(oldSplit, newSplit, \
                                    comp = compress, \
                                    sens = fn.sensors,
                                    readLocation = dataLocation)
                
                local = neighborclusters[str(fn.sensors)]
                cd2 = ncluster.convertNeighborhood(cd, local)
                cd2 = numpy.array(cd2, ndmin = 2)
                cd2 = cd2.T
                
                sData = markov_anneal.splitLocalMax(cd2, td, splitLength)

                #for each split, make a document matrix and append it to the
                #ongoing tdmatrix
                try:
                    val, counts = analysis.ratio(sData.values(), fn.models)
                except:
                    counts = [0] * len(fn.models)
                    val = [0] * len(fn.models)

                tmpDoc += counts

        #if len(tmpDoc) >= minBehaviour:
        dVector.append(tmpDoc)
        times.append(oldSplit)

        oldSplit = newSplit


    #Load plsa data
    lsaData = dataio.loadData(lsaLocation)
    
    #Take counts data and lsa data to make graph.
    index = [ i for (i,j) in sorted(enumerate(lsaData.pz), key=operator.itemgetter(1))]
    
    #numVectors = len(lsaData.pz)
    numVectors = 2
    
    lsaVector.append(lsaData.pwz[:, 3])
    lsaVector.append(lsaData.pwz[:, 4])
    
    #Stip down to the optimal number }
    #for i in range (0, numVectors):
    #    lsaVector.append(lsaData.pwz[:, index[i]])
        #lsaVector.append(lsaData.pwz[:, i])
        
    projections = []
    for v in lsaVector:
        projections.append([])
        for d in dVector:
            projections[-1].append(analysis.lsaProjection(d, v))

    pr = []
    for s in range(len(projections[0])):
        tmp = []
        for r in range(len(projections)):
            tmp.append(projections[r][s])
        pr.append(tmp)


    pointsPlot = [[] for i in range(2)]
    numtosplit = 20
    dim = 2
    for s in range(len(times)):
        spot = int(s / numtosplit)
        pointsPlot[spot].append((pr[s][0:dim], str(times[s])))
    
    visualizer.plotPoints(pointsPlot)