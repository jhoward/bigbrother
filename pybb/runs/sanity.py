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

dataDirectory = "../../data/generated/train/"
modelDirectory = "../../data/generated/train/models/"
writeLocation = "../../data/generated/train/data.lsa"
        
st = "2010-01-01 00:00:00"
et = "2010-01-01 05:00:00"

def makeSplits2(numSplits, st, et, \
                splitLen = datetime.timedelta(minutes = 4)):
    
    start = datetime.datetime.strptime(st, "%Y-%m-%d %H:%M:%S")
    end = datetime.datetime.strptime(et, "%Y-%m-%d %H:%M:%S")
    dif = end - start
    
    splits = []
    
    for i in range(numSplits):
        
        #Choose a starting time.
        add = int(random.random() * (dif.seconds - splitLen.seconds))
        off = datetime.timedelta(seconds = add)
        splits.append((str(start + off), str(start + off + splitLen)))
        
    return splits
    

compress = 2
splitLen = 8
numTopics = 2
validDays = [0, 1, 2, 3, 4, 5, 6]

tdMatrix = []

    
    
if __name__ == "__main__":

    files = os.listdir(modelDirectory)

    splits = makeSplits2(80, st, et)

    i = 0

    #TODO Make this into a function -- makeTDMatrix
    for s in splits:
        print i
        i+=1
        oldSplit = datetime.datetime.strptime(s[0], "%Y-%m-%d %H:%M:%S")
        newSplit = datetime.datetime.strptime(s[1], "%Y-%m-%d %H:%M:%S")
        tmpDoc = []
        
        suppress.suppress(2)
        #Get the sensor blocks
        for f in files:
            #It is a data file.
            if f.split('.')[-1] == 'dat':

                #Open it and grab the models and sensor list
                fn = dataio.loadData(modelDirectory + str(f))
                fn.matrixToModel(fn.modelList)
                cd, td = bbdata.comp(oldSplit, newSplit, \
                                    comp = compress, \
                                    sens = fn.sensors,
                                    readLocation = dataDirectory)
                                    
                sData = markov_anneal.splitLocalMax(cd, td, splitLen)
                
                #for each split, make a document matrix and append it to the
                #ongoing tdmatrix
                try:
                    val, counts = analysis.ratio(sData.values(), fn.models)
                except:
                    counts = [0] * len(fn.models)
                    val = [0] * len(fn.models)
        suppress.restore(2)
