"""Program to find data clusters of similar size.
"""

import pybb.data.dataio as dataio
import pybb.data.calc as calc
import datetime
import math

dbLocation = "../../data/real/small/data.dat"

window = 600
skip = 600

startDate = "2008-03-17 00:00:00"
endDate = "2008-03-30 00:00:00"

sensors =  [63, 62, 61, 60, 54, \
           53, 52, 51, 50, 44, \
           43, 24, 42, 41, 34, \
           40, 33, 31, 32, 30, \
           81, 82, 83, 90]


def makeBlocks(data, window, skip, startDate = "2008-03-17 00:00:00", \
                endDate = "2008-03-30 00:00:00", \
                sensors = [63, 62, 61, 60, 54, 53, 52, 51, 50, 44, 43, 24, \
                            42, 41, 34, 40, 33, 31, 32, 30, 81, 82, 83, 90]):

    sd = datetime.datetime.strptime(startDate, "%Y-%m-%d %H:%M:%S")
    ed = datetime.datetime.strptime(endDate, "%Y-%m-%d %H:%M:%S")
    
    sk = datetime.timedelta(seconds = skip)
    wn = datetime.timedelta(seconds = window)
    
    secondsdiff = (ed - sd).days * 86400 + (ed - sd).seconds
    
    numwindows = int((secondsdiff - window)/skip)

    blocks = [0] * numwindows

    #Iterate over all sensors
    for s in sensors:

        spoint = 0
        epoint = 0

        #Iterate over time range
        for i in range(numwindows):

            evalue = calc.datetonumber(sd + i * sk + wn)
            svalue = calc.datetonumber(sd + i * sk)
            
            #Find the first start point in the window
            while spoint < len(data[s]):
                if data[s][spoint] >= svalue:
                    break
                spoint += 1

            #Find the first end point past the window
            while True:
                if data[s][epoint] > evalue:
                    break
                epoint += 1

            #Check if spoint is valid
            if data[s][spoint] <= evalue:
                blocks[i] += epoint - spoint

    return blocks



def clusterBlocks(blocks, skip, startDate, mindata = 100, \
                    blocksize = 250, blockmax = 1200):

    #Perform simple clustering removing all data from potential clustering 
    #below minData threshold
    
    sd = datetime.datetime.strptime(startDate, "%Y-%m-%d %H:%M:%S")
    sk = datetime.timedelta(seconds = skip)
    
    numclusters = int(math.ceil((blockmax - mindata)/(1.0 * blocksize))) + 1
    
    #For now just group by simple blocks from minData to 1000
    clusters = [[] for i in range(numclusters)]
    
    for s in range(len(blocks)):
        ct = sd + sk * s
        
        #Determine cluster
        c = min(int(math.ceil((blocks[s] - mindata) / (1.0 * blocksize))), numclusters - 1)

        clusters[c].append((blocks[s], str(ct)))
        
    return clusters


if __name__ == "__main__":
    
    data = dataio.loadData(dbLocation)

    blocks = makeBlocks(data, window, skip, startDate, endDate, sensors)
    clusters = clusterBlocks(blocks, skip, startDate)
    
    
    