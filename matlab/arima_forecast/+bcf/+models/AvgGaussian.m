classdef AvgGaussian < bcf.models.Model
    
    properties
        modelLength
        avgValues
        noiseValues
    end
    
    methods
        function obj = AvgGaussian(modelLength)
            obj.modelLength = modelLength;
        end

        function train(obj, data) 
            
            if size(data, 1) > 1
                data = reshape(data', 1, size(data, 1) * size(data, 2));
            end
            
            tmp = reshape(data, size(data, 1), obj.modelLength, size(data, 2)/obj.modelLength);
            obj.avgValues = mean(tmp, 3);
            
            obj.noiseValues = std(tmp, 1, 3);
        end
        
        function output = forecastSingle(obj, offset, ahead, varargin)
            if offset + ahead > obj.modelLength
                output = 0;
            else
                output = obj.avgValues(1, offset + ahead);
            end
        end
        
        function ll = likelihood(obj, data, offset)
            if offset > obj.modelLength
                ll = 0.0001;
            else            
                %data = data .* obj.noiseMult;
                ll = normpdf(data, obj.avgValues(1, offset), obj.noiseValues(1, offset));
            end
            
            if ll <= 0.0001
                ll = 0.0001;
            end
            
           
        end
        
        
        function output = forecastAll(obj, data, ahead, varargin)
            %Find the place in day.  Assume that data will always be given
            %starting at a day
            fTotal = size(data, 2);
            fout = repmat(obj.avgDay, [1 floor(fTotal/obj.blocksInDay) + 1]);
            
            output = fout(:, 1:fTotal);
        end
        
        %TODO CHECK THIS VALUE
        function calculateNoiseDistribution(obj, data, ahead)
            %Not necessary to compute for this model.
        end
        
        function prob = probabilityNoise(obj, data)
            %Computes the probability that some noise lies within this
            %models forecasted noise
        end
    end
end

