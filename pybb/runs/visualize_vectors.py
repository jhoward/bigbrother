"""
visualize_vectors.py

Author: James Howard

Program used to construct different runs and plot them.
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

#Setup variables
st = "2010-01-01 00:00:00"
et = "2010-01-01 02:00:00"

#st = "2008-03-18 02:00:00"
#dataLocation = "../../data/real/small/"
#modelLocation = "../../runs/real/models_min_3/"
#lsaLocation = "../../runs/real/data_min_3.lsa"
neighborhoodLocation =  "../../data/generated/clean/neighborclusters.txt"

modelLocation = "../../runs/clean/models_clustered/"
dataLocation = "../../data/generated/clean/"
lsaLocation = "../../runs/clean/data.lsa"

compress = 2
dVector = []
times = []
lsaVector = []
splitLength = 8
skipLength = 1
numSplits = 50
i = 0

if __name__ == "__main__":

    files = os.listdir(modelLocation)
    neighborclusters = ncluster.parse(neighborhoodLocation)
    
    #Make splits
    splits = bbdata.makeSplitsSequential(numSplits, st, \
                            splitLen = datetime.timedelta(minutes = splitLength), \
                            skip = datetime.timedelta(minutes = skipLength))
    
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
                
                #cd2 = cd
                local = neighborclusters[str(fn.sensors)]
                cd2 = ncluster.convertNeighborhood(cd, local)
                cd2 = numpy.array(cd2, ndmin = 2)
                cd2 = cd2.T
                
                sData = markov_anneal.splitLocalMax(cd2, td, splitLength)

                #print len(sData)

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

    lsaVector.append(lsaData.pwz[:, 0])
    lsaVector.append(lsaData.pwz[:, 3])

    projections = []
    for v in lsaVector:
        projections.append([])
        for d in dVector:
            projections[-1].append(analysis.lsaProjection(d, v))
    
    x = range(splitLength, numSplits + splitLength)
    x *= skipLength
    
    
    visualizer.plotLines(x, projections)
