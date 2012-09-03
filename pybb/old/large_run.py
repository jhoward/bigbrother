"""
large_run.py

Author: James Howard

Used to create long runs.
"""

import markov_anneal
import dataio
import warnings
import os
import random
import suppress
warnings.simplefilter("ignore")

readLocation = "../data/sensor_data/small_54_64.dat"

splitLen = 8

if __name__ == "__main__":

    oData = dataio.loadData(readLocation)
    obs = 2**oData.data.shape[1]
    states = splitLen

    sData = markov_anneal.splitActivityMax(oData.cd[0:50000], splitLen)
    
    scores = [0, 0]
    entropys = [0, 0]
    
    for i in range(2, 26):
        print "Models:" + str(i) 
        bestScore = -1
        bestModels = []
        bestData = []
        bestOut = []
        
        for j in range(2):
            suppress.suppress(2)
            bm, bd, out = markov_anneal.train(sData, i, states, obs, \
                                    iterations = 9, outliers = False, voidOutput = False)
            suppress.restore(2)
            mea = markov_anneal.modelErrorAverage(bm, bd, obs)
            entropy = markov_anneal.assignedDataEntropy(bd, out)
            score = (2**(sum(mea)/(len(mea) * 1.0)))*entropy
            
            if bestScore == -1 or score < bestScore:
                bestScore = score
                bestEnt = entropy
    
        print "   best score:" + str(bestScore) + "   best entropy:" + str(bestEnt)
        scores.append(bestScore)
        entropys.append(bestEnt)
    
    oData.scores = scores
    oData.entropys = entropys
    dataio.saveData(readLocation, oData)