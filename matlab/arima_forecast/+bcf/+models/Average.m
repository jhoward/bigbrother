classdef Average < bcf.models.Model
    
    properties
        avgDay              %An average day (d x blocksInDay
        blocksInDay         %length of an average day
    end
    
    methods
        function obj = Average(blocksInDay)
            obj.blocksInDay = blocksInDay;
        end

        function train(obj, data) 
            tmp = reshape(data, size(data, 1), obj.blocksInDay, size(data, 2)/obj.blocksInDay);
            obj.avgDay = mean(tmp, 3);
        end
        
        function output = forecastAll(obj, data, ahead, varargin)
            
            %Find the place in day.  Assume that data will always be given
            %starting at a day
            fTotal = size(data, 2);
            fout = repmat(obj.avgDay, [1 floor(fTotal/obj.blocksInDay) + 1]);
            
            output = fout(:, 1:fTotal);
        end
        
        function output = forecastSingle(obj, data, ahead, varargin)
            output = [];
        end
            
        function prob = probabilityNoise(obj, data)
            %Computes the probability that some noise lies within this
            %models forecasted noise
            prob = mvnpdf(data, obj.noiseMu, obj.noiseSigma);
        end
        
        function calculateNoiseDistribution(obj, data, ahead)
            %Computes the models distribution for common noise forecasts
            out = obj.forecastAll(data, ahead);
            res = out - data;
            tmpRes = reshape(res, size(res, 1), obj.blocksInDay, size(res, 2)/obj.blocksInDay);
            pd =  fitdist(res', 'Normal');
            obj.noiseMu = pd.mean;
            obj.noiseSigma = pd.std^2;
            obj.dayNoiseMu = mean(tmpRes, 3);
            obj.dayNoiseSigma = std(tmpRes, 0, 3);
        end
    end
end

