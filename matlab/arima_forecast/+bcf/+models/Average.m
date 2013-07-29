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
            if size(data, 2) + ahead > obj.blocksInDay
                output = 0;
            else
                output = obj.avgDay(size(data, 2) + ahead);
            end
        end
            
        function prob = probabilityNoise(obj, data)
            %Computes the probability that some noise lies within this
            %models forecasted noise

            %First discretize the pdf
            %For now just always go from -2 to 2 by .1
            range = (obj.noiseMu - 2 * obj.noiseSigma):(obj.noiseSigma / 50):(obj.noiseMu + 2 * obj.noiseSigma);
            dValues = normpdf(range, obj.noiseMu, obj.noiseSigma);
            dValues(dValues < 0.000000001) = 0.000000001;
            dValues = dValues ./ sum(dValues);
            prob = zeros(size(data));
            
            for i = 1:size(data, 2)
                %Change this to include values equal to zero
                foo = max(find(range <= data(1, i))) + 1;
                foo = min([length(dValues), foo]); 
                prob(1, i) = log(dValues(foo));
            end
            %prob = normpdf(data, obj.noiseMu, obj.noiseSigma);
        end
        
        %TODO CHECK THIS VALUE
        function calculateNoiseDistribution(obj, data, ahead)
            %Computes the models distribution for common noise forecasts
            out = obj.forecastAll(data, ahead);
            res = out - data;
            tmpRes = reshape(res, size(res, 1), obj.blocksInDay, size(res, 2)/obj.blocksInDay);
            pd =  fitdist(res', 'Normal');
            obj.noiseMu = pd.mean;
            obj.noiseSigma = pd.std;
            obj.dayNoiseMu = mean(tmpRes, 3);
            obj.dayNoiseSigma = std(tmpRes, 0, 3);
        end
    end
end

