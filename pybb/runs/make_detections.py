"""
make_detections.py

Author: James Howard

Program used to make detections to be used by plotter.  Will make a 
detection file for each model in the given directory.
"""

import os
import pybb.data.dataio as dataio
import pybb.data.detections as detections
import pybb.data.bbdata as bbdata
import pybb.math.markov_anneal as markov_anneal
import datetime

st = "2010-01-01 00:57:00"
et = "2010-01-01 01:17:00"

compress = 2
splitLen = 8

writeLocation = "../../data/generated/noise_less/detections/"
modelLocation = "../../data/generated/clean_all/models/"
dataLocation = "../../data/generated/noise_less/"


if __name__ == "__main__":
    
    st = datetime.datetime.strptime(st, "%Y-%m-%d %H:%M:%S")
    et = datetime.datetime.strptime(et, "%Y-%m-%d %H:%M:%S")
    
    files = os.listdir(modelLocation)
    
    #Get the sensor blocks
    for f in files:
        print f
        #It is a data file.
        if f.split('.')[-1] == 'dat':
            
            #Open it and grab the models and sensor list
            fn = dataio.loadData(modelLocation + str(f))
            fn.matrixToModel(fn.modelList)
            
            print "Sensors:" + str(fn.sensors)
            cd, td = bbdata.comp(st, et, \
                    comp = compress, \
                    sens = fn.sensors,
                    readLocation = dataLocation)
                
            sData = markov_anneal.splitLocalMax(cd, td, splitLen)
        
            outFile = writeLocation + str(f.split('.')[0]) + '.txt'
        
            #Make the file.
            detections.write_detections(sData, fn.models, fileName = outFile)

