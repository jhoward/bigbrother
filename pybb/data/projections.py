import pybb.data.bbdata as bbdata
import pybb.math.ncluster as ncluster
import os
import datetime
import pybb.data.dataio as dataio
import pybb.math.analysis as analysis
import numpy
import pybb.math.markov_anneal as markov_anneal

def makeModelCounts(splits, modelLocation, dataLocation, \
                    neighborhoodLocation = None, minBehavior = 0, \
                    compress = 2, splitLength = 8):
    """
    Makes a set of counts for a given dataset and models.  
    
    Neighborhood location specifies if the models and data need to be preclustered.
    
    Returns the datavector and the associated split times.
    """
    files = os.listdir(modelLocation)
    
    neighborhood = False
    dVector = []
    times = []
    
    if neighborhoodLocation:
        neighborclusters = ncluster.parse(neighborhoodLocation)
        neighborhood = True
        
    #Iterate over splits.
    for s in splits:
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
                
                
                cd2 = cd
                if neighborhood:
                    local = neighborclusters[str(fn.sensors)]
                    cd2 = ncluster.convertNeighborhood(cd, local)
                
                cd2 = numpy.array(cd2, ndmin = 2)
                cd2 = cd2.T

                sData = markov_anneal.splitLocalMax(cd2, td, splitLength)

                try:
                    val, counts = analysis.ratio(sData.values(), fn.models)
                except:
                    counts = [0] * len(fn.models)
                    val = [0] * len(fn.models)
                tmpDoc += counts

        if len(tmpDoc) >= minBehavior:
            dVector.append(tmpDoc)
            times.append(oldSplit)

        oldSplit = newSplit
        
    return dVector, times
    
    
def classify(veclist, value):
    #put the value at the start of every vector in veclist
    
    c = list(veclist)
    
    for v in c:
        v.insert(0, value)
        
    return c