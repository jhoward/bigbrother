import pybb.data.bbdata as bbdata

def convertNeighborhood(cd, clusters):
    return [clusters[i] for i in cd]


def parse(fileLocation):
    
    f = open(fileLocation)
    allN = {}   #Hash of all neighborhoods
    cs = None   #neighborhood
    nc = None   #new clusters
    cc = 0      #current cluster
    
    for g in f.readlines():
        g = g.split("=")
        if g[0].replace(" ", "") == "sensorgroup":
            l = g[1].replace(" ","")
            l = l.replace(";", "")
            l = l.replace("[", "")
            l = l.replace("]", "")
            l = l.split(",")

            if cs != None:
                allN[str(cs)] = nc
            
            cs = [int(f) for f in l]
            nc = [0] * (2**len(cs))
            
        if len(g) == 1:
            g = g[0].split(" ")
            if g[0] == "Cluster":
                cc = int(g[1])

        if g[0] == "pattern":
            val = g[1].split(" ")[0]

            try:
                tmp = []
                for t in val:
                    tmp.append(int(t))
            except:
                pass
                
            nc[bbdata.compressVector(tmp)] = cc

    if cs != None:
        allN[str(cs)] = nc    
    
    return allN
        
if __name__ == "__main__":
    print parse("../../data/generated/clean/neighborclusters.txt")