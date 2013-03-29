classdef TDNN < bcf.models.Model
    %TDNNMODEL time delayed neural network model
    properties
        netAhead
        net1
        ahead
    end
    
    methods        
        function obj = TDNN(net1, netAhead, ahead)
            obj.net1 = net1;
            obj.netAhead = netAhead;
            obj.ahead = ahead;
        end
        
        function val = forecast(obj, data, ahead)
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
        
        function output = forecastAll(obj, data, ahead)
            if ahead == 1
                net = obj.net1;
            elseif ahead == obj.ahead 
                net = obj.netAhead;
            else
                fprintf(1, 'No trained forecaster for this value of ahead\n');
                1/0;
            end
            output = bcf.forecast.tdnnForecast(net, data, ahead);
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