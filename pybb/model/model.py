import math

class Model(object):
    
    def __init__(self):
        pass
        
    
    def set(self):
        pass
        
    def setHistory(self, length):
        """Set the default history to use for forecasting.
        """
        self.history = history

    
    def forecast(self, data, future = 1):
        """Forecast the value at some point in the future in a time series.
        
        Future = 1 corresponds to the next forecast point.
        """
        pass
        
    
    def loglikelihood(self, data):
        """From the trained noise function (Assumed Gaussian for most models),
        this function returns the likelihood of the residual 
        (forecast(x) - y).
        """
        pass
    
    
    def train_noise(self, data, history = 4):
        """Determine the parameters for the Gaussian noise function 
        describing this model for the data x
        
        history -- Minimum number of datapoints to begin forecasting
        """
        
        tmp_mean = 0.0
        tmp_var = 0.0
        total = 0

        for vec in data:
            for i in range(history, len(vec) - 1):
                f = self.forecast(vec[0:i])
                d = f - vec[i]
                tmp_mean += d
                total += 1
            
        tmp_mean = tmp_mean / (1.0 * total)
        
        for vec in data:
            for i in range(history, len(vec) - 1):
                f = self.forecast(vec[0:i])
                d = f - vec[i]
                tmp_var += (tmp_mean - d)**2
            
        tmp_var = tmp_var / (1.0 * total)
        
        self.noise_mean = tmp_mean
        self.noise_std = math.sqrt(tmp_var)
            
        
        