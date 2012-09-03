import rpy2.robjects.numpy2ri
import rpy2.robjects as R
from rpy2.robjects.packages import importr
forecast = importr("forecast")

class Arima(object):
    
    def __init__(self, parameters, seasonal_parameters, lag):
        """Initialize a seasonal arima model with parameters for:
        parameters          : (ar, diff, ma)
        seasonal_parameters : (sar, sdiff, sma)
        lag                 : amount of lag in differencing
        """
        self.__parameters = parameters
        self.__seasonal_parameters = seasonal_parameters
        self.__lag = lag
        self.__data = None
        self.__trained = False
        self.__ar = 0
        self.__diff = 0
        self.__ma = 0
        self.__sar = 0
        self.__sdiff = 0
        self.__sma = 0
        
    def train(self, data):
        """Train Arima model on a set of data."""
        self.__data = data
        self.__trained = True
        
    def get_model(self):
        """Returns the number of parameters of the model and the lag"""
        return (self.__parameters, self.__seasonal_parameters, self.__lag)
        
    def get_parameters(self):
        """Returns the trained values of the parameters"""
        tmp = (self.__ar, self.__diff, self.__ma)
        stmp = (self.__sar, self.__sdiff, self.__sma)
        return (tmp, stmp, lag)
        
    def forecast(self, data):
        """Returns a list of the same length as data with 
        all values forecasted."""
        pass
        
    
