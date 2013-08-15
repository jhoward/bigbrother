classdef Average < handle
    
    properties
        modelLength
        avgValues
        noiseValues
    end
    
    methods
        function obj = Average(modelLength)
            obj.modelLength = modelLength;
        end

        function train(obj, data) 
            tmp = reshape(data, size(data, 1), obj.modelLength, size(data, 2)/obj.modelLength);
            obj.avgValues = mean(tmp, 3);
            
            obj.noiseValues = std(tmp, 1, 3);
        end
        
        function output = forecastSingle(obj, offset, ahead)
            if offset + ahead > obj.modelLength
                output = 0;
            else
                output = obj.avgValues(1, offset + ahead);
            end
        end
        
        function ll = likelihood(obj, data, offset)
            ll = normpdf(data, obj.avgValues(1, offset), obj.noiseValues(1, offset));
            
            if ll <= 0.0001
                ll = 0.0001;
            end
        end
    end
end

