"""
lsa_history.py

Author: James Howard

Program used to grab all lsa information for a dataset.  Will then produce
a graph of lsa changes over time.
"""

import os
import pybb.data.dataio as dataio
import pybb.data.detections as detections
import pybb.data.bbdata as bbdata
import pybb.math.markov_anneal as markov_anneal
import pybb.math.analysis as analysis
import pybb.image.visualizer as visualizer
import datetime
import operator
import numpy

st = "2008-02-26 07:50:00"
et = "2008-02-26 08:10:00"

st = "2010-01-01 00:00:00"
et = "2010-01-01 02:00:00"

compress = 2
splitLen = 8
window = datetime.timedelta(minutes = 8)
slide = datetime.timedelta(minutes = 1)
numVectors = 4   #Number of vectors to plot

#dataLocation = "../../data/sensor_data/2008/"
dataLocation = "../../data/generated/clean/"
modelLocation = "../../runs/clean/models/"
#lsaLocation = "../../data/sensor_data/example/data.lsa"
lsaLocation = "../../runs/clean/data.lsa"

ct = datetime.datetime.strptime(st, "%Y-%m-%d %H:%M:%S")
et = datetime.datetime.strptime(et, "%Y-%m-%d %H:%M:%S")

if __name__ == "__main__":
    
    #Import lsa information
    lsaData = dataio.loadData(lsaLocation)

    #Import all models and sData
    models = []
    yProj = [[] for i in range(numVectors)]
    xProj = []
    count = 0
    
    
    files = os.listdir(modelLocation)
    
    for f in files:
        if f.split('.')[-1] == 'dat':
        
            #Open it and grab the models and sensor list
            fn = dataio.loadData(modelLocation + str(f))
            fn.matrixToModel(fn.modelList)
            
            models.append(fn)
            
        
    #For each window, go through each sensor block and get lsa projection
    #information.
    while (ct + window < et):
        print ct
        
        tmpDoc = []
        
        #Iterate through each model
        for m in models:
            
            cd, td = bbdata.getdata(ct, ct + window, \
                                comp = compress, \
                                sens = m.sensors,
                                readLocation = dataLocation)
            
            sData = markov_anneal.splitLocalMax(cd, td, splitLen)
            
            #for each split, make a document matrix and append it to the
            #ongoing document
            try:
                val, counts = analysis.ratio(sData.values(), m.models)
            except:
                counts = [0] * len(m.models)
                val = [0] * len(m.models)

            tmpDoc += counts
        
        print tmpDoc
        
        lsaVector = []
        
        index = [ i for (i,j) in sorted(enumerate(lsaData.pz), key=operator.itemgetter(1))]

        
        #Stip down to the optimal number
        for i in range (numVectors):
            lsaVector.append(lsaData.pwz[:, index[i]])
        
        ranges = [[(0, 1)], [(0, 1)]]
        
        
        for t in range(len(lsaVector)):
            #Now project this document to each latent class and store the results
            val = analysis.lsaProjection(tmpDoc, lsaVector[t])
            
            yProj[t].append(val)
            
            
        ct += slide
        xProj.append(count)
        count += 1
        
    xProj = numpy.array(xProj)
            
    visualizer.makeLatentTimeGraph(xProj, yProj, ranges)


