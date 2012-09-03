"""
save_once.py

Author: James Howard

File to make binary data representations of all raw sensor data.
"""

import pybb.data.dataio as dataio
import pybb.data.bbparser as bbparser
import pybb.data.bbdata as bbdata
import pybb.data.calc as calc
from PyDbLite import Base
import datetime
import os

readLocation = "/Users/jahoward/Documents/bigbrother/data/real/all/raw/"
writeLocation = "/Users/jahoward/Documents/bigbrother/data/real/all/"
writeDB = "/Users/jahoward/Documents/bigbrother/data/real/all/data.dat"


def stripFiles(readDirectory, writeDirectory, startTime, endTime):
    files = os.listdir(readDirectory)
    for f in files:
        print f

        if f.split('.')[-1] == 'txt':
            stripFile(readDirectory + str(f), writeDirectory + str(f), startTime, endTime)
            
def stripFile(read, write, startTime, endTime):
    """Strip a given file to just the dates that correspond to the startTime and endTime
    """
    
    st = datetime.datetime.strptime(startTime, "%Y-%m-%d %H:%M:%S")
    et = datetime.datetime.strptime(endTime, "%Y-%m-%d %H:%M:%S")
    
    w = open(write, "w")
    d = open(read, "r").readlines()

    for timeLine in d:
        t = timeLine.split("\t")
        t = t[1].split(" ")
        t[-1] = t[-1].split("\n")[0]
        totalT = str(t[-2]) + " " + str(t[-1])
        tmp = datetime.datetime.strptime(totalT, "%Y-%m-%d %H:%M:%S")
        
        if tmp >= st and tmp <= et:
            w.write(totalT + "\n")
            

def makeFiles(read, write):
    for s in bbdata.allSensors:
    
        d = bbdata.Data()
    
        print "Parsing sensor " + str(s)
        try:
            sString = read + "sensor" + str(s) + ".txt"
            d = bbparser.rawToCompressedRaw(sString, f = "2010-01-01 00:00:00")
            d.sensor = s
        except:
            pass
        
        oString = write + "sensor" + str(s) + ".dat"
        dataio.saveData(oString, d)

        
def makeDB(read, write, startTime = "2010-01-01 00:00:00", \
            endTime = "2010-01-01 00:10:00"):
    db = Base(write)

    startTime = calc.datetonumber(startTime)
    endTime = calc.datetonumber(endTime)
    
    #Day comes from day of the week.  It is a number from 0 to 6.
    #0 = Monday 6 = Sunday.
    db.create('sensor', 'date', 'weekday', 'index', mode="override")
    db.open()
    allData = {}
    
    for i in range(len(bbdata.allSensors)):
        s = bbdata.allSensors[i]
        data = []
        print "Parsing sensor " + str(s)
        try:
            sString = read + "sensor" + str(s) + ".txt"
        
            f = open(sString).readlines()
            oldD = None
            for timeLine in f:
                tmp = timeLine.split()
                tmp = tmp[1] + " " + tmp[2]
                #tmp = tmp[0] + " " + tmp[1]
                d = datetime.datetime.strptime(tmp, "%Y-%m-%d %H:%M:%S")
                foo = calc.datetonumber(d)
                
                if foo >= startTime and foo <= endTime:
                    data.append(calc.datetonumber(d))
                
                    if d.toordinal() != oldD:
                        #Add to database
                        db.insert(s, d.toordinal(), d.weekday(), len(data) - 1)
                        oldD = d.toordinal()
                        print "   " + str(d)
        except Exception, e:
            print "Except:" + str(e)
            pass
        
        allData[s] = data
    
    allData['db'] = db
    dataio.saveData(write, allData)


if __name__ == "__main__":
    startTime = "2008-03-09 00:00:00"
    endTime = "2008-04-13 23:59:59"
    #startTime = "2010-01-01 00:00:00"
    #endTime = "2010-01-01 00:14:00"

    #makeFiles(readLocation, writeLocation)
    makeDB(readLocation, writeDB, startTime, endTime)
    #stripFiles(readLocation, writeLocation, startTime, endTime)
    




