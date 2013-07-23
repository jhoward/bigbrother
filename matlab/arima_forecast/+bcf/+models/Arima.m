classdef Arima < bcf.models.Model
    %GAUSSIANMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        model
        blocksInDay
    end
    
    methods
        function obj = Arima(model, blocksInDay)
            obj.model = model;
            obj.blocksInDay = blocksInDay;
        end
        
        function val = forecastSingle(obj, data, ahead)
            val = obj.mu;
        end
        
        function train(obj, data, varargin)

        end
        
        function output = forecastAll(obj, data, ahead, varargin)
            output = bcf.forecast.arimaForecast(obj.model, ahead, data');
        end
            
        function prob = probabilityNoise(obj, data)
            
            prob = mvnpdf(data, obj.noiseMu, obj.noiseSigma);
        end
        
        function calculateNoiseDistribution(obj, data, ahead)
            out = obj.forecastAll(data, ahead);
            res = data - out;
            tmpRes = reshape(res, size(res, 1), obj.blocksInDay, size(res, 2)/obj.blocksInDay);
            pd =  fitdist(res', 'Normal');
            obj.noiseMu = pd.mean;
            obj.noiseSigma = pd.std^2;
            obj.dayNoiseMu = mean(tmpRes, 3);
            obj.dayNoiseSigma = std(tmpRes, 0, 3)^2;
        end
    end
end


