"""
make_clusters.py

Author: James Howard

Program used to make clusters for a set of data.  Saves cluster centers and information to 
the same file where data was taken from.
"""

import pycl
import pybb.data.dataio as dataio
        
dataDirectory = "../../runs/real/projected_lunch.data"
writeLocation = "../../runs/real/projected_lunch.data"
        
if __name__ == "__main__":
    
    tmpd = dataio.loadData(dataDirectory)
    data = tmpd.classList
    data = pycl.Dataset(data)

    #Try kmeans
    kmeans = pycl.Kmeans(2)
    kmeans.train(data)
    tmpd.centers = kmeans._Kmeans__centers
    tmpd.clusters = kmeans._Kmeans__clusters
    
    dataio.saveData(writeLocation, tmpd)
