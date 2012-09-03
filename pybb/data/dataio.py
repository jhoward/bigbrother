"""
dataio.py

Author: James Howard

Contains all for reading and writing binary data files.
"""

import cPickle
import numpy as np
from datetime import datetime

def load_pickled_data(file_Location):
    """Loads the pickled data into memory.  
    
    Will handle anything, but the expected 
    return type is of Dataset
    """
    f = open(file_location, "rb")
    data = cPickle.load(f)
    f.close()
    return data
        

def save_data(file_Location, data):
    """Writes the data to a file.
    """
    out_file = open(file_location, "wb")
    cPickle.dump(data, out_file, 2)
    out_file.close()


def loadTrafficData(file_location):
    """Loads the raw text file data.
    
    Assumes the data is formated as date_time col_1 col_2 col_3 ... col_n
    
    Args:
        Location of file to read
        
    Returns:
        Two lists.  First list contains all date_times.  Second list contains 
        all data
    """
    data = []
    times = []
    
    f = open(file_location, "rb")
    
    for line in f:
        tmp = line.split("\t")
        times.append(datetime.strptime(tmp[0], "%m/%d/%y"))
        
        data.append(tmp[2:-1])
        
    data = np.array(data, dtype = 'i')
    times = np.array(times)
            
    return data, times


def loadOtherData(file_location, datatype = 'f'):
    """Loads data from sources of the format date time(optional) 
    information(optional)
    """
    
    data = []
    times = []
    
    f = open(file_location, "rb")
    
    for line in f:
        if line[0] != "#":
            tmp = line.strip("\n")
            tmp = tmp.split(" ")
            try:
                times.append(datetime.strptime(tmp[0] + " " + tmp[1], 
                                                "%m.%d.%Y %H:%M"))
                if len(tmp) > 2:
                    data.append(tmp[2:])
            except Exception, e:
                times.append(datetime.strptime(tmp[0], 
                                                "%m.%d.%Y"))
                if len(tmp) > 1:
                    data.append(tmp[1:])
    
    data = np.array(data, dtype = datatype)
    times = np.array(times)
    
    return data, times
    