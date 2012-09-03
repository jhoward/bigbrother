"""cluster_score.py
Author: James Howard

Short program to give the score of a given clustering
"""

import pybb.math.markov_anneal as markov_anneal
import pybb.data.dataio as dataio
import pybb.math.hmmextra as hmmextra
import os
import pybb.suppress as suppress
suppress.suppress(2)
from ghmm import *
suppress.restore(2)

readLocation = "../../runs/clean/models/"

if __name__ == "__main__":
    files = os.listdir(readLocation)

    suppress.suppress(2)
    for f in files:
        print f
        #It is a data file.
        if f.split('.')[-1] == 'dat':
        
            #Open files
            fn = dataio.loadData(readLocation + str(f))
            fn.matrixToModel(fn.modelList)
            
            sigma = IntegerRange(0, fn.obs)
            
            alldata = []
            for i in fn.assignedData:
                alldata += i
            
            print "hmm silhouette:" + str(hmmextra.hmmSilhoutte(alldata, fn.models, sigma))
            print "inter-model dist:" + str(markov_anneal._fitness(fn.models, fn.assignedData, sigma))
            print "Outliers:" + str(len(fn.out))
            print "Clusters per models:" + str([len(i) for i in fn.assignedData])
            print ""
    suppress.restore(2)