import pybb.image.visualizer as visualizer
import pybb.data.dataio as dataio

#modelLocation = "../../runs/clean/models/"
#dataLocation = "../../data/generated/clean/"
#lsaLocation = "../../runs/clean/data.lsa"

modelLocation = "../../runs/real/models/"
dataLocation = "../../data/real/small/"
lsaLocation = "../../runs/real/data.lsa"


if __name__ == "__main__":
    
    lsaData = dataio.loadData(lsaLocation)
    lsaVector = []
    
    for i in range (len(lsaData.pz)):
        lsaVector.append(lsaData.pwz[:, i])
        
    for i in range(len(lsaVector)):
        visualizer.drawLatentClass(lsaData.regions, lsaVector[i], \
                            writeLocation = "../../output/latent_" + str(i) + ".png")
                            
    for i in range(len(lsaVector)):
        visualizer.drawLatentClassPercent(lsaData.regions, lsaVector[i], \
                            writeLocation = "../../output/latent_percent_" + str(i) + ".png")
