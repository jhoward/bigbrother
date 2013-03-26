classdef Model < handle
    %Model object - used for representing timeseries
    properties
        %forecast noise is presumed to be multivariate gaussian
        noiseMu
        noiseSigma
    end
    
    methods
        %Methods that should be in every model, since I don't know matlabs
        %function overloading precedence I am just commenting them and
        %including them manually in each class.  This sucks I know, but for
        %now it is good enough
        
        %function trainNoise(obj, data, history)
        %end
        
        %function val = forecast(obj, data, ahead)
        %end
    end
    
end

