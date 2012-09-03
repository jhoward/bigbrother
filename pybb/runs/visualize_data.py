"""visualize_data.py

Author: James Howard
Date: 05.26.2011

Program to visualize when various sensors fire.
"""

import pybb.data.dataio as dataio
import pybb.data.calc as calc
import matplotlib.pyplot as plt
import numpy

dbLocation = "../../data/real/all/data.dat"

def getNumActivations(db):
    
    db.create_index('date')
    a = db._date.keys()
    a.sort()
    
    start = calc.datetonumber("2008-03-17 00:00:00")
    start /= 100000
    dailyTotal = []

    diff = a[-1] - start
    print "Total number of days:" + str(diff)
    
    for i in range(diff - 1):
        print "Days:" + str(i)
        tmp = db('date') == start + i
        total = 0
        
        for j in range(len(tmp)):
            sens = tmp.records[j]['sensor']
            date = tmp.records[j]['date']
            
            tmp2 = (db('date') == date + 1) & (db('sensor') == sens)
            
            if len(tmp2) == 1:
                total += tmp2.records[0]['index'] - tmp.records[j]['index']
                
        dailyTotal.append(total)
    print dailyTotal
        


def plotNumSensors(db):
    
    db.create_index('date')
    a = db._date.keys()
    a.sort()
    
    start = calc.datetonumber("2008-01-01 00:00:00")
    start /= 100000
    print start

    sensAll = []

    diff = a[-1] - start
    
    print diff
    
    for i in range(diff):
        tmp = db('date') == start + i
        
        sensAll.append(len(tmp))
        
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ind = numpy.arange(diff)
    
    print sensAll
    
    rect = ax.bar(ind, sensAll, 0.3, color = 'r')
    
    plt.show()
    

if __name__ == "__main__":
    data = dataio.loadData(dbLocation)
    print "Data loaded."
    #getNumActivations(data['db'])
    plotNumSensors(data['db'])