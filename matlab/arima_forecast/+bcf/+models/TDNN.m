classdef TDNN < bcf.models.Model
    %TDNNMODEL time delayed neural network model
    properties
        %netAhead
        net
        ahead
    end
    
    methods        
        function obj = TDNN(net, ahead)
            obj.net = net;
            %obj.netAhead = netAhead;
            obj.ahead = ahead;
        end
        
        function val = forecastSingle(obj, data, ahead, varagin)
            %TODO Change this to handle vector values
            td = num2cell(data);
            [xs,xi,~,~] = preparets(obj.net,{},{}, td);
            if isempty(xs)
                val = obj.net({0},xi);
            else 
                val = obj.net(xs, xi);
            end
            val = cell2num(val);
        end
        
        function output = forecastAll(obj, data, ahead, varargin)
            output = bcf.forecast.tdnnForecast(obj.net, data, ahead);
        end
        
        function calculateNoiseDistribution(obj, data, ahead)
            out = obj.forecastAll(data, ahead);
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