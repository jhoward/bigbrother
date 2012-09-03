import datetime
import pybb.data.dataio as dataio

def datetonumber(date):
    """Takes the ordinal day * 100000 + seconds in day so far."""
    try:
        date = datetime.datetime.strptime(date, "%Y-%m-%d %H:%M:%S")
    except:
        pass

    return date.toordinal() * 100000 + date.hour * 3600 + date.minute * 60 + \
            date.second
    
def numbertodate(num):
    """takes a number and returns a datetime object."""
    d = datetime.date.fromordinal(num/100000)
    hours = (num%100000)/3600
    minutes = ((num%100000)%3600)/60
    seconds = ((num%100000)%3600)%60
    
    print hours
    print num

    tmp = datetime.datetime(d.year, d.month, d.day, hours, minutes, seconds)

    return tmp


def find(i, l):
    """Find the first element in a sequential list (l) that is equal to 
    or after element i.
    
    Return the index.
    """
    
    dex = len(l)/2
    up = len(l)
    low = 0
    
    while (up - low) > 1:
        if l[dex] == i:
            return dex

        if l[dex] > i:
            up = dex
            dex = (up - low) / 2 + low

        if l[dex] < i:
            low = dex
            dex = (up - low) / 2 + low
            
    return dex + 1
    
    
if __name__ == "__main__":
    a = []
    b = []
    
    for i in range(100000):
        b.append(i)
    
    #make a file of 100000 dates
    for i in range(100000):
        a.append(datetime.datetime.now())
    
    dataio.saveData("data2.dat", b)        
        
    
