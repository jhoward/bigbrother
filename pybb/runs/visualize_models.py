"""
visualize_models.py

Author: James Howard

Short program to display images of all model files within a directory.
"""

import pybb.image.visualizer as visualizer
import pybb.data.dataio as dataio
import os
import pybb.suppress as suppress
import pybb.math.ncluster as ncluster

readLocation = "../../runs/small/models/"

if __name__ == "__main__":
    
    files = os.listdir(readLocation)
    for f in files:
        print f
        #It is a data file.
        if f.split('.')[-1] == 'dat':
        
            #Open files
            fn = dataio.loadData(readLocation + str(f))
            fn.matrixToModel(fn.modelList)

            #visualizer.drawHMM(len(fn.models), fn.obs, \
            #                    fn.assignedData, \
            #            writeLocation = "../../output/" + str(f.split('.')[0]) + ".png")
            
            #Grab clusters
            cc = ncluster.parse("../../data/generated/clean/neighborclusters.txt")
            """
            m = None
                                    
            for temp in range(len(fn.assignedData)):
                visualizer.drawHMMCluster(fn.assignedData[temp], fn.models, \
                                        len(fn.sensors), \
                                        writeLocation = "../../output/cluster" \
                                                + str(f.split('.')[0]) + "_" + \
                                                str(temp) + ".png", \
                                        spacing = 20, 
                                        scaling = 5)
            
            visualizer.drawHMMCluster(fn.out, fn.models, \
                                        len(fn.sensors), \
                                        writeLocation = "../../output/outliers" \
                                                + str(f.split('.')[0]) + ".png",
                                        spacing = 20,
                                        scaling = 5)
            """                            
            
            if cc.has_key(str(fn.sensors)):
                visualizer.drawHMMPreClustered(len(fn.models), \
                                fn.assignedData, cc[str(fn.sensors)], \
                                writeLocation = "../../output/" + str(f.split('.')[0]) + "_cluster.png")
            
                visualizer.drawHMMPreClusteredRaw(fn.models, \
                                cc[str(fn.sensors)], 
                                writeLocation = "../../output/" + str(f.split('.')[0]) + "_raw.png")

