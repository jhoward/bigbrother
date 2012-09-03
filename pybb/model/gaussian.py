import model
import math
import random

class Gaussian(model.Model):
    def __init__(self, mean = 0.0, std = 1.0):
        self.mean = mean
        self.std = std
        self.history = 0
        
    def set(self, mean = 0.0, std = 1.0):
        self.mean = mean
        self.std = std
        
    def forecast(self, data, future = 1):
        return self.mean

    def loglikelihood(self, data):
        """Forecast for a model the probability of each observation.

        f(x) = 1/(std * sqrt(2 * pi)) * exp(-1 * ((x - mean)**2)/(2*std**2))
        """
        nc = 1 / (self.std * math.sqrt(2 * math.pi))
        e = exp(-1 * (((x - self.mean)**2)/(2*(self.std**2))))
        
        return nc * e