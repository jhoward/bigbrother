import math
import sys
import pybb.data.dataio as dataio
import pybb.data.bbdata as bbdata
import pybb.math.hmmextra as hmmextra
import Image
import ImageDraw
import ImageFont
import numpy
import pybb.math.analysis as analysis
import pybb.suppress as suppress
from ghmm import *
import random


def plotLines(x, ys, ranges = [[]], rangeColors=[]):
    import matplotlib.pyplot as plt
    import matplotlib.collections as collections
    
    fig = plt.figure()
    ax = fig.add_subplot(111)

    for t in range(len(ys)):
        c = getColor(t, len(ys), decimal = True)
        if len(ys[t]) == len(x):
            ax.plot(x, ys[t], color = c, linewidth = 2)

    if len(ranges[0]) > 0:
        for r in range(len(ranges)):
            c = colorList[r]
            for sec in ranges[r]:
                #Make a plot of a color based on number of ranges.
                collection = collections.BrokenBarHCollection.span_where( \
                                x[sec[0]:sec[-1]], ymin = 0, ymax = 1.0, \
                                where = x < sec[-1], \
                                facecolor = c, \
                                alpha = 0.2)
                ax.add_collection(collection)
                

    ax.set_title('Latent class strengths vs time')

    plt.show()



def _drawOneHMM(d, ad, xLoc, yLoc, modelSizeX, modelSizeY):
    """Average all assigned data associated with a model into one image.
    
    d = ImageDraw object
    ad = Assigned Data
    xLoc = value of x position of data within image
    yLoc = value of y position of data within image
    modelSizeX = number of possible sensors covered by model
    modelSizeY = number of states of model
    """
    
    image = [([0] * modelSizeX) for i in range(modelSizeY)]
    
    numImages = len(ad)
    if numImages > 100:
        numImages = 100
    
    for i in range(numImages):
        #Sum all positions
        for j in range(len(ad[i])):
            for k in range(modelSizeX):
                image[j][k] += (int(ad[i][j]) & 2**k) >> k
                
    
    for j in range(len(image)):
        for k in range(len(image[0])):
            image[j][k] /= (numImages * 1.0)
        
    #Draw the image.
    for j in range(len(image)):
        for k in range(len(image[0])):
            #c = getColor(image[j][k])
            d.point((xLoc + k, yLoc + j), \
                    fill = (255.0 * image[j][len(image[0]) - 1 - k], \
                            255.0 * image[j][len(image[0]) - 1 - k], \
                            255.0 * image[j][len(image[0]) - 1 - k]))



def drawOneHMMPreClustered(model, cluster, length = 8, points = 100):
    b = model.sample(points, length)
    width = math.log(len(cluster), 2)
    data = numpy.zeros([length, width])
    
    #Average a model
    for j in range(points):
        c = b.getSequence(j)
        
        #Convert the sequence to an array
        #Iterate over each value in the data sample
        for k in range(len(c)):
            tmpVector = numpy.zeros([1, width])
            val = c[k]

            #Convert that value to an equivalent array using cluster info
            #Iterate over each value in the cluster
            for l in range(len(cluster)):
                v = cluster[l]
                
                #If we have a match to our observation value and cluster value
                if val == v:
                    #Add the binary value of l to the sensors in tmpVector
                    for m in range(width):
                        if (l >> m) & 1 == 1:
                            tmpVector[0, width - 1 - m] += 1
            
            #Normalize tmpVector
            if numpy.max(tmpVector) > 0:
                tmpVector /= numpy.max(tmpVector)
            
            #Add the tmpVector to the data array
            data[k, :] = data[k, :] + tmpVector
        
    #Normalize the final result
    data /= (1.0 * points)
    
    return data

    
def drawHMM(numModels, obs, assignedData, \
            writeLocation = "../output/models.png", verbose = False):
    """Draws the expected value of a given model based on all the data 
    assigned to that model.  Draws all hidden markov models on the same image.
    """
    if verbose:
        print "calling drawHMM"

    spacing = 4
    height = numModels * (len(assignedData[0][0]) + spacing)
    width = int(math.log(obs, 2))

    im = Image.new("RGB", (width + 2, height))
    d = ImageDraw.Draw(im)
    for i in range(len(assignedData)):
        #Draw a given model.  
        _drawOneHMM(d, assignedData[i], 1, i * (len(assignedData[0][0]) + spacing), \
                    width, len(assignedData[0][0]))

    im.save(writeLocation, "PNG")
    del d

def drawHMMPreClusteredRaw(models, cluster, length = 8, points = 100, \
                        writeLocation = "../output/modelsraw.png"):
    """Draws the expected value of a each hidden markov model from a list
    based on the model alone and cluster information for decoding"""
    
    spacing = 4
    height = len(models) * (length + spacing)
    width = math.log(len(cluster), 2)

    im = Image.new("RGB", (width, height))
    d = ImageDraw.Draw(im)
    
    for m in range(len(models)):
        data = drawOneHMMPreClustered(models[m], cluster)
        
        #Draw the image array                        
        _drawArray(d, data, 0, m * (length + spacing), scale = 1)

    im.save(writeLocation, "PNG")
    del d        
    


def drawHMMPreClustered(numModels, assignedData, cc, \
                writeLocation = "../output/models.png", verbose = False):
    """Draws the expected value of a given model based on all the data 
    assigned to that model.  Draws all hidden markov models on the same image.
    
    Aggregates based on the clustered raw input cc taken from ncluster.parse
    """
    spacing = 4
    height = numModels * (len(assignedData[0][0]) + spacing)
    width = math.log(len(cc), 2)

    im = Image.new("RGB", (width, height))
    d = ImageDraw.Draw(im)
    
    #Get the aggregates of cc values to raw values
    numValues = max(cc) + 1
    sensWidth = math.log(len(cc), 2)
    values = [[0] * int(sensWidth) for i in range(numValues)]
    
    for i in range(len(cc)):
        v = cc[i]
        tmp = i
        for j in range(len(values[v])):
            if tmp/(2**(sensWidth - 1 - j)) >= 1:
                values[v][j] += 1
                tmp -= (2**(sensWidth - 1 - j))
                
    #Average the values array
    for i in range(len(values)):
        s = sum(values[i])
        if s > 0:
            for j in range(len(values[i])):
                values[i][j] /= s*1.0
    
    print len(assignedData[0])
    
    #Iterate through each model
    for m in range(len(assignedData)):
        image = [[0] * int(sensWidth) for i in range(len(assignedData[m][0]))]
        
        #Iterate through each datapoint assigned to the model
        for i in range(len(assignedData[m])):

            #Add up all the observations at each position in the datapoints
            for j in range(len(assignedData[m][i])):
                #Sum all positions
                v = values[assignedData[m][i][j]]
                
                #Add the vector to the current image
                for k in range(len(v)):
                    image[j][k] += (v[k] / (1.0*len(assignedData[m])))
        
        print numpy.array(image)
        
        #Draw the image array                        
        _drawArray(d, numpy.array(image), 0, m * (len(assignedData[0][0]) + spacing), \
                        scale = 1)
        
    im.save(writeLocation, "PNG")
    del d

def drawRawHMM(models, obs, numberBase = 2, numInstance = 400, \
                length = 8, writeLocation = "../output/raw_models.png"):
                
    print "Drawing raw models."
    spacing = 4
    states = len(models[0].asMatrices()[0])
    height = len(models) * (length + spacing)
    width = int(math.log(obs, 2))
    
    im = Image.new("RGB", (width + 2, height))
    d = ImageDraw.Draw(im)
    
    tmp = numpy.zeros((length, width), float)
    

    for i in range(len(models)):
        
        b = models[i].sample(numInstance, length)
        
        #Average a model
        for j in range(numInstance):
            c = b.getSequence(j)
            for k in range(len(c)):
                val = c[k]
                for l in range(width):
                    sub = numberBase**(width - 1 - l)
                    if (val - sub) >= 0:
                        val = val - sub
                        tmp[k, l] += 1.0/numInstance
        
        #Draw a model
        for j in range(tmp.shape[0]):
            for k in range(tmp.shape[1]):
                #c = getColor(tmp[j, k])
                d.point((1 + k, i * (states + spacing) + j), \
                        fill = (255.0 * tmp[j, k], \
                                255.0 * tmp[j, k], \
                                255.0 * tmp[j, k]))
        
        tmp *= 0
    im.save(writeLocation, "PNG")
    del d



def drawAssignment(data, assignment, numModels):
    
    im = Image.new("RGB", (data.shape[1] + 1, data.shape[0]))
    d = ImageDraw.Draw(im)
    
    _drawData(d, data)
    
    for i in assignment:
        pass
        

def drawData(data, writeLocation = "../output/data.png", gamma = 0.25):
    """Draws the data on an image with dimensions equal to the dimensions 
    of the data file.
    
    gamma is used as a type of color enhancing function to better display 
    small differences in color around values close to zero.
    
    The default color is green.
    """

    im = Image.new("RGB", (data.shape[1], data.shape[0]))
    d = ImageDraw.Draw(im)
    
    _drawData(d, data, gamma)
    
    im.save(writeLocation, "PNG")


def drawCorrelation(corrMatrix, \
                    sensorLocations="../other/bb_floor2_locations_old.txt", \
                    writeLocation = "../output/corr.png", \
                    bgImage = "../images/bb_floor2.png", \
                    sensorSize = 12, 
                    baseSize = 10, 
                    threshold = 0.15):
    """Draw a correlation image given a set of sensor locations and 
    and optionally a background image.
    
    bgImage and sensorLocations are strings to the location of the file 
    describing the necessary information.
    """
    
    im = Image.open(bgImage)
    d = ImageDraw.Draw(im)
    locations = []
    
    #Open and parse the locations file
    f = open(sensorLocations, 'r')
    
    for line in f.readlines():
        split = line.split(' ')
        locations.append((split[1], split[2], split[0]))
    
    #Draw correlation lines first so that sensors are on top
    for i in range(corrMatrix.shape[0]):
        for j in range(corrMatrix.shape[1]):
            
            if corrMatrix[i][j] > threshold:
                lw = abs(int(corrMatrix[i][j] * baseSize)) + 2

                d.line((int(locations[i][0]), int(locations[i][1]), \
                            int(locations[j][0]), int(locations[j][1])), \
                            fill = (150, 0, 0), width = lw)

    _drawSensors(d, locations, sensorSize)

    im.save(writeLocation, "PNG")
    


def drawGabrialGraph(corrMatrix, \
                    sensorLocations = "../other/bb_floor2_locations_old.txt", \
                    writeLocation = "../output/gabr.png", \
                    bgImage = "../images/bb_floor2.png", \
                    sensorSize = 12):
    """Makes a gabrial graph based on a correlation matrix, a background 
    image and a location file.
    
    TODO: Finish this function.  Needs a output save file.
    """
    
    im = Image.open(bgImage)
    d = ImageDraw.Draw(im)
    locations = []
    
    #Open and parse the locations file
    f = open(sensorLocations, 'r')
    
    for line in f.readlines():
        split = line.split(' ')
        locations.append((split[1], split[2], split[0]))
    
    #Get the locations for the nodes
    for line in f.readlines():
        split = line.split(' ')
        locations.append((split[1], split[2], split[0]))
        
    
    #Determine neighbors for a given node
    for i in range(corrMatrix.shape[0] - 1): #Sensor B
        for j in range(i + 1, corrMatrix.shape[1]): #Sensor C
            
            isNeighbor = True
            
            for k in range(corrMatrix.shape[0]): #Sensor D
                if (k != i) and (k != j):
                    
                    bc = 0
                    bd = 0
                    dc = 0
                    
                    try:                        
                        #Get max first
                        mbc = abs(corrMatrix[i][j])
                        
                        #if abs(corrMax[j][i]) > mbc:
                        #    mbc = corrMax[j][i]
                        
                        if mbc < 0.095:
                            isNeighbor = False
                            break
                        
                        #Inverse appears to work much better
                        #bc = abs(1/(corrMax[i][j]))
                        bc = abs(1/mbc)
                        bd = abs(1/(corrMax[i][k]))
                        dc = abs(1/(corrMax[j][k]))
                        
                    except:
                        continue
                                        
                    #First check triangle validity
                    if (bd < bc) and (dc < bc):
                        
                        #If that passes then sensor d may invalidate c from being a neighbor
                        #Theta given by law of cosines
                        tmp = (bd*bd - dc*dc - bc*bc)/(2*dc*bc)
                        theta = math.cosh(tmp)
                        
                        df = math.sin(theta) * dc
                        cf = math.cos(theta) * dc
                        
                        ef = abs((bc / 2) - cf)
                        
                        de = math.sqrt((cf*cf) + (ef*ef))
                        
                        if de < (bc / 2):
                            #Then d is in the circle define by b and c thus c can not be a 
                            #neighbor of d
                            isNeighbor = False
                            break
            
            if isNeighbor:
                d.line((int(locations[i][0]), int(locations[i][1]), \
                            int(locations[j][0]), int(locations[j][1])), \
                            fill = "hsl(0, 100%, 50%)", width = 6)        
    
    _drawSensors(d, locations, sensorSize)

    im.save(writeLocation, "PNG")
    del d                        


def getColor(n, total = 255, decimal = False):
    """Returns a color triplet.

    Note that if total is not set then it is assumed to be one.  N is 
    described as the ratio of the value to get a color for out of the total 
    number of possible values.
    """

    value = round(255*n/(total * 1.0))

    #red value
    if value < 96:
        red = 0
    elif value < 160:
        red = 255/((160 - 96)*1.0) * (value - 96)
    elif value < 224:
        red = 255
    else:
        red = 255 - ((255 - 128)/((255 - 224) * 1.0) * (value - 224))


    #Green value
    if value < 32:
        green = 0
    elif value < 96:
        green = 255/((96 - 32)*1.0) * (value - 32)
    elif value < 160:
        green = 255
    elif value < 224:
        green = 255 - (255/((224 - 160) * 1.0) * (value - 160))
    else:
        green = 0


    #Blue value
    if value < 32:
        blue = 128 + (255 - 128)/((32 - 0) * 1.0) * (value - 0)
    elif value < 96:
        blue = 255
    elif value < 160:
        blue = 255 - ((255 - 0)/((160 - 96) * 1.0) * (value - 96))
    else:
        blue = 0

    if decimal:
        return (red / 255.0, green / 255.0, blue / 255.0)
    return (int(red), int(green), int(blue))
    

def _drawData(d, data, gamma = 0.25):
    """Draws the data on a given image with an image draw object d.

    Used for drawing data for any type of image of appropriate size.
    """
    for i in range(data.shape[1]):
        for j in range(data.shape[0]):
            value = data[j][i]

            d.point((i, j), fill = (0, (value**gamma)*255, 0))


def _drawSensors(d, locations, sensorSize = 10):
    """Draw sensors on a draw object d from a given locations list.

    Locations instance is: (x loc, y loc, sensor id)
    """

    for loc in locations:
        d.ellipse((int(loc[0]) - sensorSize/2, int(loc[1]) - sensorSize/2, \
                    int(loc[0]) + sensorSize/2, int(loc[1]) + sensorSize/2), \
                    fill = (50, 50, 155), outline = (50, 50, 155))

        d.text((int(loc[0]) + sensorSize/2 + 5, int(loc[1]) - sensorSize/2 - 5), \
                str(loc[2]), fill = (0, 0, 0))



def testDrawHMMCluster(fileLocation, limit = 100, cColor = (255, 255, 255)):
    """Draw the set of data associated with each hmm cluster.
    
    A cap of limit data patterns per cluster will be drawn to ensure that 
    the images are of reasonable dimensions.
    """

    oData = dataio.loadData(fileLocation)

    oData.assignedData = [oData.sData]

    for i in range(len(oData.assignedData)):
        v = len(oData.assignedData[i])
        if v > limit:
            v = limit
        ns = oData.assignedData[i][0:v]
        tmp = []
        tmp.append(ns)
        
        drawHMMCluster(tmp, oData.data.shape[1], \
                        writeLocation = "../output/cluster" + str(i) + ".png", \
                        cColor = cColor)
                        


def plotPoints(vec, centers = None, numcolors = 2):
    """Plot a set of points onto either a 2d.  Text is
    also associated with the points
    
    vec is a lists of Tuples (vector, text) -- Vectors of each point and the 
                                                    text associated with it. 

    Color will be based the first number in the list of tuples
    
    centers will be larger and of shape x.
    """

    try:
        import matplotlib.pyplot
        from mpl_toolkits.mplot3d import Axes3D
    except:
        raise ImportError, "matplotlib package not found."

    markers = ['o', '^', 'x']
    labels = ["Cluster 1", "Cluster 2", "Morning Data", "Evening Data"]
    handles = []
    count = 0
    
    fig = matplotlib.pyplot.figure()
    ax1 = fig.add_subplot(111)

    for i in range(len(vec)):
        for v in vec[i]:
            col = getColor(i, numcolors, decimal = True)
            col = (0, max(col[1] - 0.2, 0), col[2] - 0.1)
            ax1.scatter(v[1], v[2], color = col, s = 100, marker = markers[v[0]])

    matplotlib.pyplot.show()


def _drawArray(d, data, x, y, scale = 5, color = (255, 255, 255), cCluster = (0, 0, 0)):
    """_drawArray(d, data, x, y, scale=5, cluster = (0, 0, 0))
    
    Draws the contents of a given array onto a given image.  All values 
    within the array must be between 0 and 1
    """
    for j in range(data.shape[0]):
        for i in range(data.shape[1]):
            c = (int(color[0] * data[j][i]), int(color[1] * data[j][i]), \
                int(color[2] * data[j][i]))
            xp = x + scale * i
            yp = y + scale * j
            
            d.rectangle(((xp, yp), (xp + scale - 1, yp + scale - 1)), fill = c)
        
        xp = x + scale * data.shape[1]
        yp = y + scale * j
        d.rectangle(((xp, yp), (xp + scale - 1, yp + scale - 1)), fill = cCluster)
        

def _drawArrayText(d, data, x, y, values, scale=5, cCluster=(0, 0, 0), \
                    f = ImageFont.load_default()):
    """_drawClusteredArray(d, data, x, y, values, scale=5, cluster=(0, 0, 0))
    
    Draws the contents of the data array onto a given image.  Then writes the
    values given by the values array to the right hand side of the image.  
    There can only be upto two values in this array.
    """
    
    _drawArray(d, data, x, y, scale=scale, cCluster=cCluster)
    
    #Calculate text location
    sx = (data.shape[1] + 2) * scale
    th = data.shape[0] * scale
    
    #get font height
    fh = f.getsize("0.123")[1]
    
    if len(values) > 2:
        values = values[0:2]
        
    for v in range(len(values)):
        tmp = values[v]
        
        #Used to resolve a python underflow error returning negative 0.0 
        if tmp == 0:
            tmp = abs(tmp)
            
        tmp = str(tmp)
        if len(tmp) > 5:
            tmp = tmp[0:5]
        d.text((sx, y + fh * v), tmp)
        
        
def drawHMMCluster(data, models, numSensors, \
                    writeLocation = "../output/out.png", \
                    spacing = 10, numberBase = 2, \
                    scaling = 5, \
                    cColor = (0, 255, 0), cCluster = (0, 0, 0)):
    """Draw all data associated with a given hidden markov model.  
    Space the data by the value spacing.
    """
    lenInstances = 0

    #Get length of each image.
    for d in data:
        lenInstances += len(d)

    #Make the image
    iLen = lenInstances * scaling + spacing * len(data)
    if iLen == 0:
        iLen = 1
    im = Image.new("RGB", ((numSensors + 1) * scaling + 50, iLen))
    d = ImageDraw.Draw(im)

    currentY = 0

    #Draw the instances
    for i in range(len(data)):
        #Invert the data to an array.
        tmpData = bbdata.uncompressData(data[i], numSensors, numberBase)
        
        #Caluclate values
        sigma = IntegerRange(0, numberBase**numSensors)
        values = hmmextra.hmmDistAll(data[i], models, sigma)
        values.sort()
        _drawArrayText(d, tmpData, 0, currentY, values, scale = scaling, cCluster=cCluster)
        currentY += tmpData.shape[0] * scaling + spacing

    im.save(writeLocation, "PNG")


def drawLatentClass(regions, lclass, \
                        sensorLocations="../../data/locations/bb_floor2_locations_old.txt", \
                        writeLocation = "../../output/latent.png", \
                        sensorDirections = "../../data/locations/bb_floor2_draw_directions.txt", \
                        bgImage = "../../images/bb_floor2.png", \
                        sensorSize = 12, \
                        baseSize = 10, \
                        scale = 5, \
                        lengths = 8):
    """Draw a latent class on top of the given building image.  
    
    models should be a list of bbdata.Dataset object with the model variable
    filled.
    
    class should be a vector of model strengths.
    """
    
    im = Image.open(bgImage)
    d = ImageDraw.Draw(im)
    locations = []
    directions = []
    classSpot = 0
    
    #Open and parse the locations file
    f = open(sensorLocations, 'r')
    
    for line in f.readlines():
        split = line.split(' ')
        locations.append((split[1], split[2], split[0]))
        
    f = open(sensorDirections, 'r')
    
    for line in f.readlines():
        try:
            split = line.split(' ')
            directions.append(int(split[1]))
        except:
            pass
    
    _drawSensors(d, locations, sensorSize)
    
    for c in regions:
        
        c.matrixToModel(c.modelList)
        
        #Get first sensor
        sens = c.sensors[0]
        data = numpy.zeros((lengths, len(c.sensors)), float)
        
        sindex = bbdata.allSensors.index(sens)
        
        foo = locations[sindex]
        foodir = directions[sindex]
        
        x = int(foo[0])
        y = int(foo[1])
            
        if foodir == 0:
            y -= lengths * scale + sensorSize + 5
            x -= sensorSize - 5
        if foodir == 1:
            x += sensorSize + 5
            y -= sensorSize - 5
        if foodir == 2:
            y += lengths * scale + 10
            x -= sensorSize - 5
        if foodir == 3:
            x -= len(c.sensors) * scale + sensorSize + 5
            y -= sensorSize - 5   
        
        total = None
        localSum = 0
        for m in c.models:
            #Calculate array
            bar = hmmextra.generateAvgModel(m, lengths)
            
            if total == None:
                total = lclass[classSpot] * bar
            else:
                total += lclass[classSpot] * bar

            localSum += lclass[classSpot]
            classSpot += 1
            
        #Normalize
        total /= localSum
        _drawArray(d, total, x, y, scale = scale)
    
    im.save(writeLocation, "PNG")


def drawLatentClassPercent(regions, lclass, \
                        sensorLocations="../../data/locations/bb_floor2_locations_old.txt", \
                        writeLocation = "../../output/latent.png", \
                        sensorDirections = "../../data/locations/bb_floor2_draw_directions.txt", \
                        bgImage = "../../images/bb_floor2.png", \
                        sensorSize = 12, \
                        baseSize = 10, \
                        length = 50, \
                        width = 20):
    """Draw a latent class on top of the given building image.  

    models should be a list of bbdata.Dataset object with the model variable
    filled.

    class should be a vector of model strengths.
    """

    im = Image.open(bgImage)
    d = ImageDraw.Draw(im)
    locations = []
    directions = []
    classSpot = 0

    #Open and parse the locations file
    f = open(sensorLocations, 'r')

    for line in f.readlines():
        split = line.split(' ')
        locations.append((split[1], split[2], split[0]))

    f = open(sensorDirections, 'r')

    for line in f.readlines():
        try:
            split = line.split(' ')
            directions.append(int(split[1]))
        except:
            pass

    _drawSensors(d, locations, sensorSize)

    for c in regions:

        c.matrixToModel(c.modelList)

        #Get first sensor
        sens = c.sensors[0]
        print sens

        sindex = bbdata.allSensors.index(sens)

        foo = locations[sindex]
        foodir = directions[sindex]

        x = int(foo[0])
        y = int(foo[1])

        if foodir == 0:
            y -= length + sensorSize + 5
            x -= sensorSize - 5
        if foodir == 1:
            x += sensorSize + 5
            y -= sensorSize - 5
        if foodir == 2:
            y += length + 10
            x -= sensorSize - 5
        if foodir == 3:
            x -= width + sensorSize + 5
            y -= sensorSize - 5   

        total = []
        localSum = 0
        for m in c.models:
            total.append(lclass[classSpot])
            classSpot += 1

        #Normalize
        total = [i / (sum(total) * 1.0) for i in total]
        
        print total
        _drawRatios(d, total, x, y, length = length, width = width)

    im.save(writeLocation, "PNG")


def _drawRatios(d, ratios, x, y, length = 50, width = 20):
    """_drawRatio(d, ratios, x, y, length = 50)

    Draws the ratios array onto a draw object at location x, y (upper left)
    """
    for i in range(len(ratios)):
        c = getColor(i, len(ratios))

        d.rectangle(((x, y + sum(ratios[0:i]) * length), \
                    (x + width, y + (sum(ratios[0:i]) + ratios[i]) * length)),
                    fill = c)


def test():
    data = [[0, .1, .71, 0], \
            [0, 1, 1, 0], \
            [1, 0, 0, 1], \
            [0.3, 0, 0, 1], \
            [0, 1, 0, 1], \
            [1, 0, .51, 0]]
    
    values = [0.543256, 0.002356754]        
    data = numpy.array(data)
    
    #Make the image
    im = Image.new("RGB", (100, 500))
    d = ImageDraw.Draw(im)
    f = ImageFont.load_default()

    _drawArrayText(d, data, 0, 0, values, cluster = (100, 0, 0))

    im.save("../../output/test.png", "PNG")
    del d



if __name__ == "__main__":
    test()

