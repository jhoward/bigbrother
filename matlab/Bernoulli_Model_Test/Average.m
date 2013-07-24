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
        
        function ll = likelihood(obj, data)
            tmp = obj.avgValues(1:1:size(data, 2)) - data;
            
            for i = 1:size(tmp, 2)
                foo = normpdf(tmp(1, i), 0, obj.noiseValues(1, i));
                tmp(1, i) = foo;
            end
            
            ll = prod(tmp, 2);
            
            %Should we threshold this here????
            if ll > 0.9999
                ll = 0.9999;
            end
            
            %if ll < 0.0001
            %    ll = 0;
            %end
            
            if isnan(ll)
                ll = 0;
            end
        end
    end
end

