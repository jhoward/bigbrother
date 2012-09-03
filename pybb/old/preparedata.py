"""
preparedata.py

Author: James Howard

NOT USED ANYMORE
Simple program that should only need to be run once for each data run.
Takes data from a given location and calls all necessary functions to 
prepare the data for being run with different hmm trails.
"""

import dataio
import bbdata

calcCombineData = True
calcCompressedData = True

combineAmount = 2
readLocation = "../data/sensor_data/ss.dat"
writeLocation = "../data/sensor_data/ss.dat"

if __name__ == "__main__":

    oData = dataio.loadData(readLocation)
    oData.ad = oData.data

    if calcCombineData:
        print "Calculating combine data with size of " + str(combineAmount)
        averagedData = bbdata.combineData(oData.data, combineAmount)
        oData.ad = averagedData
        dataio.saveData(writeLocation, oData)

    if calcCompressedData:
        print "Calculating compressed data."
        compressedData = bbdata.compressData(oData.ad)
        oData.cd = compressedData
        dataio.saveData(writeLocation, oData)