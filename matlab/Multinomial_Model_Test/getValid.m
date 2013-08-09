function [valid] = getValid(data, numModels, modelLen, minLen)
%Returns all valid possibilities for the "next" data value
    valid = {}

    %This function is pretty easy
    %Check the background model first
    
    if data(end, 1) == 1
        for i = 1:numModels
            valid{size(valid, 2) + 1} = [data [i;1]]; %#ok<AGROW>
        end
    elseif data(end, 2) == modelLen
        for i = 1:numModels
            valid{size(valid, 2) + 1} = [data [i;1]]; %#ok<AGROW>
        end
    elseif data(end, 2) >= minLen
        valid{size(valid, 2) + 1} = [data [data(end, 1);(data(end, 2) + 1)]];
    end
end

