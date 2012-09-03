import matplotlib.pyplot as mpl

def graph_periods(data, alpha = 0.3, color = 'k', newplot = True):

    xrng = len(data[0])
    xdata = range(xrng)

    if newplot:
        mpl.subplot(111)
    
    for d in data:
        mpl.plot(xdata, d, color, alpha = alpha)
        
    mpl.xlim([0, xrng - 1])