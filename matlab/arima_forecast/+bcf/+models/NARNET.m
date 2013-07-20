classdef NARNET < bcf.models.Model
    %TDNNMODEL time delayed neural network model
    properties
        net
    end
    
    methods        
        function obj = NARNET(net)
            obj.net = net;
        end
        
        function val = forecast(obj, data, ahead)
            val = 1;
        end
        
        function train(obj, data)
        end
        
        function output = forecastAll(obj, data, ahead, varargin)
            if ~iscell(data)
                data = num2cell(data);
            end
            output = bcf.forecast.narForecast(obj.net, data, ahead);
        end
        
        function calculateNoiseDistribution(obj, data)
            out = obj.forecastAll(data, 1);
            res = data - out;
            pd =  fitdist(res', 'Normal');
            obj.noiseMu = pd.mean;
            obj.noiseSigma = pd.std^2;
        end
        
        function prob = probabilityNoise(obj, data)
            prob = mvnpdf(data, obj.noiseMu, obj.noiseSigma);
        end
    end
    
end

