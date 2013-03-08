classdef Model
    %Model object - used for representing timeseries
    properties
    end
    
    methods
        function trainNoise(obj, data, history)
            tmpMean = 0;
            tmpVar = 0;
            total = 0;
            
            obj.noiseMean = 0;
            obj.noiseStd = 1;
        end
    end
    
end

