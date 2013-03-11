classdef Model
    %Model object - used for representing timeseries
    properties
        %forecast noise is presumed to be multivariate gaussian
        fnMu
        fnSigma
    end
    
    methods
        function trainNoise(obj, data, history)
            tmpMean = 0;
            tmpVar = 0;
            total = 0;
            
            obj.fnMu = 0;
            obj.fnSigma = 1;
        end
    end
    
end

