"""
make_clusters.py

Author: James Howard

Program used to make clusters for a set of data.  Saves cluster centers and information to 
the same file where data was taken from.
"""

import pycl
import pybb.data.dataio as dataio
import pybb.image.visualizer as visualizer
import numpy
import pybb.math.lsa as lsa
import pybb.math.analysis as analysis
import pybb.data.projections as projections
        
dataDirectory = "../../runs/real/projected.data"
dataDirectory2 = "../../runs/real/projected_lunch_late.data"

def make_assigned(projList, numClusters = 2):
    assigned = []
    for i in range(numClusters):
        assigned.append([])

    for j in projList:
        assigned[j[0]].append(j[1:])
        
    return assigned


def classify_data(assigned, projected, centers):
    newData = []
    for i in range(2):
        newData.append([])
    
    index = 0
    
    for clust in assigned:
        for v in clust:
            #Find best cluster
            best = -1
            bestClust = 0
            for cent in range(len(centers)):
                d = pycl.dist.lp(v, centers[cent])
                if best < 0 or d < best:
                    print str(d) + "   " + str(cent)
                    best = d
                    bestClust = cent
            print "---"
                
            newData[bestClust].append(projected[index])
            index += 1
            
    return newData
    

def lsa_reduce(assigned):
    #Project to an array
    data = []
    for l in assigned:
        data += l
    
    data = numpy.array(data)
    u, s, v = lsa.lsa(data.T)
    
    return u


def apply_projection(assigned, u, startClassify = 0):
    allData = []
    
    for l in range(len(assigned)):
        tmpClust = analysis.projectList(assigned[l], u)
        projections.classify(tmpClust, l + startClassify)
        allData += tmpClust
        
    return allData
    


if __name__ == "__main__":
    
    tmpd = dataio.loadData(dataDirectory)
        
    assigned = make_assigned(tmpd.projList)
    u = lsa_reduce(assigned)
    data = apply_projection(assigned, u)
    nd = classify_data(assigned, data, tmpd.centers)
    
    #tmpd2 = dataio.loadData(dataDirectory2)
    #assigned2 = make_assigned(tmpd2.projList[:40])
    #data2 = apply_projection(assigned2, u, 2)    
    #nd2 = classify_data(assigned2, data2, tmpd.centers)

    #for l in range(len(nd)):
    #    nd[l] += nd2[l]

    t = visualizer.plotPoints(nd)

