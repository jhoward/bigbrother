classdef NARNET < bcf.models.Model
    %TDNNMODEL time delayed neural network model
    properties
        net
        
    end
    
    methods        
        function obj = NARNET(net)
            obj.net = net;
        end
        
        function output = forecastAll(obj, data, ahead)
            output = bcf.forecast.narForecast(obj, data, ahead);
        end
        
        function calculateNoiseDistribution(obj, data)
            out = forecastAll(data, 1);
            res = data - out;
            pd =  fitdist(res, 'Normal');
            obj.noiseMu = pd.mean;
            obj.noiseSigma = pd.std;
        end
    end
    
end

