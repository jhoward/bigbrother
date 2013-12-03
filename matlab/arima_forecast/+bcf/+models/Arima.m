classdef Arima < bcf.models.Model
    %Arima model container to make it work with our BCF model
    
    properties
        model
        blocksInDay
    end
    
    methods
        function obj = Arima(model, blocksInDay, varargin)
            %if varargin is not empty then an arima model is created using
            %parameters specified by varargin{1}
            %
            %varargin{1} = 1X6 array of the six values for an seasonal
            %arima model.
            obj.model = model;
            obj.blocksInDay = blocksInDay;
            
            
            if ~isempty(varargin) 
                t = varargin{1};
                obj.model = arima('ARLags', 1:t(1), 'D', t(2), ...
                    'MALags', 1:t(3), 'SARLags', 1:t(4), ...
                    'Seasonality', t(5), 'SMALags', 1:t(6)); 
            end
        end
        
        
        
        function val = forecastSingle(obj, data, ahead)
            val = obj.mu;
        end
        
        
        function train(obj, data, varargin)
            obj.model = estimate(obj.model, data', 'print', false);
        end
        
        function inferedData = inferData(obj, data)
            inferedData = infer(obj.model, data');
        end
        
        
        function output = forecastAll(obj, data, ahead, varargin)
            output = bcf.forecast.arimaForecast(obj.model, ahead, data');
        end
        
        
        function prob = probabilityNoise(obj, data)
            data = data .* obj.noiseMult;
            prob = mvnpdf(data', obj.noiseMu^2, obj.noiseSigma);
        end
        
        
        function calculateNoiseDistribution(obj, data, ahead)
            out = obj.forecastAll(data, ahead);
            res = data - out;
            res = res .* obj.noiseMult;
            tmpRes = reshape(res, size(res, 1), obj.blocksInDay, size(res, 2)/obj.blocksInDay);
            tmpRes = tmpRes .* obj.noiseMult;
            
            pd =  fitdist(res', 'Normal');
            obj.noiseMu = pd.mean;
            obj.noiseSigma = pd.std;
            obj.dayNoiseMu = mean(tmpRes, 3);
            obj.dayNoiseSigma = std(tmpRes, 0, 3);
        end
    end
end


