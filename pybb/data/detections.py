import pybb.math.analysis as analysis
import math

def write_detections(sData, models, fileName = ""):
    """Make a detections file for a given set of sData and models."""
    
    f = open(fileName, 'w')
    line = 0
    
    for k in sData.keys():
        
        #Get the optimal model from analysis
        m, v = analysis.optimalModel(sData[k], models)
        print "Writing"
        #Write to the file.
        f.write(str(line) + " " + str(m) + " " + str(math.e**v) + " " + str(k) + "\n")
        
    