import pybb.data.generator as generator
import matplotlib.pyplot as mpl
import numpy as np

if __name__ == "__main__":
    rdata, data, scale = generator.generate_data(periods = 5, \
                                                    period_length = 100)

    #Graph the data
    ydata = np.average(data, axis = 0)
    xdata = range(0, len(ydata))

    back_data = generator.background(1, len(ydata), 0)
    back_data = back_data + abs(np.min(rdata))
    back_data = np.average(np.floor(back_data / scale), axis = 0)


    #Generate residual
    res = ydata - back_data

    mpl.subplot(211)
    mpl.plot(xdata, ydata, linewidth = 2)
    mpl.plot(xdata, back_data, 'g', linewidth = 2)
    
    mpl.subplot(212)
    mpl.plot(xdata, res, linewidth = 2)