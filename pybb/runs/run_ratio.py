"""
program to determine the basic ratios of models for data files.
"""

import dataio
import analysis
from ghmm import *
import markov_anneal
import datetime
import bbdata
import numpy


modelFile = "../data/patterns/44_53.dat"
writeLocation = "../data/other/tdMatrix.dat"

st = "2008-02-01 00:00:00"
et = "2008-03-31 23:59:59"
st = datetime.datetime.strptime(st, "%Y-%m-%d %H:%M:%S")
et = datetime.datetime.strptime(et, "%Y-%m-%d %H:%M:%S")

sensors = [53, 52, 51, 50, 44]
validDays = [0, 1, 2, 3, 4, 5, 6]
compress = 2
counts = [0] * len(validDays)
splitLen = 8
tdMatrix = []


if __name__ == "__main__":
    
    mData = dataio.loadData(modelFile)
    mData.matrixToModel(mData.modelList)
    models = mData.models

    for d in validDays:
        print "Day " + str(d)
        print "  Getting data."
        #Iterate over all valid days.
        cd, td = bbdata.comp(st, et, \
                vDays = [d], \
                comp = compress, \
                sens = sensors)
    
        print "  Splitting."
        #Get the split calculation finished.
        sData = markov_anneal.splitActivityMax(cd, td, splitLen)
        
        print "  Calculating."
        sigma = IntegerRange(0, 2**len(sensors))
        val, counts = analysis.ratio(sData.values(), models, sigma)

        tdMatrix.append(counts)
        
        
    #Save output matrix.
    foo = bbdata.Dataset(None)
    foo.tdMatrix = numpy.array(tdMatrix)
    
    dataio.saveData(writeLocation, foo)
    
        
        
        
    