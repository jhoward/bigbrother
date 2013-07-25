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
                %First discretize the pdf
                %For now just always go from -2 to 2 by .1
                range = -2:0.04:2;
                dValues = normpdf(range, 0, obj.noiseValues(1, i));
                dValues(dValues < 0.000000001) = 0.000000001;
                dValues = dValues ./ sum(dValues);
                dValues
                tmp(1, i)
                range
                %Change this to include values equal to zero
                foo = max(find(range <= tmp(1, i))) + 1;
                foo = min([length(dValues), foo]); 
                
                
                
                tmp(1, i) = log(dValues(foo));
            end
            
            %This should be prod if I remove the sum
            ll = sum(tmp, 2);
            
            %Should we threshold this here????
            %if ll > 0.9999
            %    ll = 0.9999;
            %end
            
            %if ll < 0.0001
            %    ll = 0;
            %end
            
            if isnan(ll)
                ll = 0;
            end
        end
    end
end

