import pybb.data.dataio as dataio
import numpy
import os

dataDirectory = "../../runs/real/data_min_3.lsa"
projDirectory = "../../runs/real/projected.data"
modelDirectory = "../../runs/real/models_min_3/"


if __name__ == "__main__":

    files = os.listdir(modelDirectory)
    modelNumber = []
    for f in files:
        print f
        #It is a data file.
        if f.split('.')[-1] == 'dat':
        
            #Open files
            fn = dataio.loadData(modelDirectory + str(f))
            
            for i in range(len(fn.modelList)):
                modelNumber.append(str(f) + " -- " + str(i))
            
    data = dataio.loadData(dataDirectory)
    projected = dataio.loadData(projDirectory)
    
    values = [[] for j in range(len(projected.centers))]
    
    for j in range(len(projected.centers)):
        for i in range(len(data.pwz)):
            values[j].append(numpy.dot(projected.centers[j], data.pwz[i]))
    

    for i in range(len(values[0])):
        print str(abs(values[0][i] - values[1][i])) + "   :   " + \
                str(modelNumber[i])