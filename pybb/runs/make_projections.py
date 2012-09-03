"""
make_projections.py

Author: James Howard

Program used to make a set of classified projected data.
"""

import pybb.data.bbdata as bbdata
import pybb.data.projections as projections
import pybb.data.dataio as dataio
import datetime
import pybb.math.analysis as analysis
        
dataDirectory = "../../data/real/small/"
modelDirectory = "../../runs/real/models_min_3/"
neighborhoodLocation = "../../data/generated/clean/neighborclusters.txt"
lsaLocation = "../../runs/real/data_min_3.lsa"
writeLocation = "../../runs/real/projected_lunch_early.data"
        
st = "2008-03-17 00:00:00"
et = "2008-03-23 23:59:59"
splitLength = 8
minBehavior = 0

if __name__ == "__main__":
    
    origList = []
    projList = []
    timeVec = []
    classList = []
    lsaData = dataio.loadData(lsaLocation)
    
    splits = bbdata.makeSplits(40, st, et, valid = [0, 2, 4], \
                    splitLen = datetime.timedelta(minutes = splitLength), \
                    sPeriod = "12:05:00", \
                    ePeriod = "12:20:00")
                    
    dvec, tvec = projections.makeModelCounts(splits, modelDirectory, dataDirectory, \
                                        neighborhoodLocation, minBehavior)
    
    origList += dvec
    timeVec += tvec
    tmpP = analysis.projectList(dvec, lsaData.pwz)
    projList += tmpP
    classList += projections.classify(tmpP, 0)
    
    print "Half Way"
    """
    splits = bbdata.makeSplits(40, st, et, valid = [0, 2, 4], \
                    splitLen = datetime.timedelta(minutes = splitLength), \
                    sPeriod = "18:00:00", \
                    ePeriod = "18:50:00")
                    
    dvec, tvec = projections.makeModelCounts(splits, modelDirectory, dataDirectory, \
                                        neighborhoodLocation, minBehavior)
                                        
    origList += dvec
    timeVec += tvec
    tmpP = analysis.projectList(dvec, lsaData.pwz)
    projList += tmpP
    classList += projections.classify(tmpP, 1)
    """
    d = bbdata.Dataset([])
    d.projList = projList
    d.origList = origList
    d.classList = classList
    d.timeVec = timeVec

    dataio.saveData(writeLocation, d)
