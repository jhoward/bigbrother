classdef TDNN < bcf.models.Model
    %TDNNMODEL time delayed neural network model
    properties
        net
        ahead
        hiddenNodes
        timeDelay
        
    end
    
    methods        
        function obj = TDNN(timeDelay, hiddenNodes)
            obj.timeDelay = timeDelay;
            obj.hiddenNodes = hiddenNodes;
        end
        
        function train(obj, data, ahead)
            cdata = tonndata(data, true, false);
            
            obj.net = timedelaynet(1:obj.timeDelay, obj.hiddenNodes);

            obj.net.divideParam.trainRatio = 70/100;
            obj.net.divideParam.valRatio = 15/100;
            obj.net.divideParam.testRatio = 15/100;
            
            [xs, xi, ai, ts] = preparets(obj.net, cdata(:, 1:end - ahead), cdata(:, 1 + ahead:end)); 
            obj.net = train(obj.net, xs, ts, xi, ai);
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
            res = res .* obj.noiseMult;
            pd =  fitdist(res', 'Normal');
            obj.noiseMu = pd.mean;
            obj.noiseSigma = pd.std;
        end
        
        
        function prob = probabilityNoise(obj, data)
            data = data .* obj.noiseMult;
            prob = mvnpdf(data', obj.noiseMu^2, obj.noiseSigma);
        end
    end 
end