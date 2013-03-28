classdef Model < handle
    %Model object - used for representing timeseries
    properties
        %forecast noise is presumed to be multivariate gaussian
        noiseMu
        noiseSigma
    end
    
    methods(Abstract)
        output = forecastAll(obj, data, ahead)
        calculateNoiseDistribution(obj, data)
        val = forecast(obj, data, ahead)
        val = probabilityNoise(obj, data)
    end    
end
