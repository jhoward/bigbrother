classdef Model < handle
    %Model object - used for representing timeseries
    properties
        %forecast noise is presumed to be multivariate gaussian
        noiseMu
        noiseSigma
        dayNoiseMu
        dayNoiseSigma
    end
    
    methods(Abstract)
        output = forecastAll(obj, data, ahead, varargin)
        train(obj, data)
        output = forecastSingle(obj, data, ahead, varargin)
        calculateNoiseDistribution(obj, data, ahead)
        val = probabilityNoise(obj, data)
    end    
end
