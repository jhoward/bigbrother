import numpy as np
import matplotlib.pyplot as mpl
import random

data = [0] * 100
base = [0] * 100
xaxis = [0] * 100

def a(x):
    return np.sin(x) + 1
    
def b(x):
    return 0.5 * np.sin(x) + 1
    
def c(x):
    return 0.5 * np.cos(x) + 1
    
def noise(mu = 0, sigma = 0.05):
    return random.gauss(mu, sigma)
    

if __name__ == "__main__":

    for i in range(100):
        data[i] = a(i / 100.0 * (2 * np.pi)) + noise()
        base[i] = a(i / 100.0 * (2 * np.pi))
        xaxis[i] = i / 100.0 * (2 * np.pi)
    
    #Add noise
    for i in range(8):
        data[i + 20] += b(i / 8.0 * np.pi)
        data[i + 40] += c(i / 8.0 * np.pi)
        data[i + 65] += b(i / 8.0 * np.pi)
        data[i + 68] += c(i / 8.0 * np.pi)
        
    #Graph
    mpl.subplot(211)
    mpl.plot(xaxis, data, linewidth = 4)
    mpl.xlim([0, 2 * np.pi])
    
    #Plot residual
    res = list(np.array(data) - np.array(base))
    mpl.subplot(212)
    mpl.plot(xaxis, res, linewidth = 4)
    mpl.xlim([0, 2 * np.pi])
    