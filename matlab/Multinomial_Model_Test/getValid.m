function [keys] = getValid(data, numModels, modelLen, minLen)
%Returns all valid possibilities for the "next" data value

d = zeros(size(data, 2), 2);
for g = 1:size(data)
    d(g, :) = rhash(data{1, g});
end

d
keys = '';

%Rules
%   minLen - Must have a model for at least "minLen" 
%               unless at the end of the model
                
    
    
    %Check for "minLen" contingency
    %data(1, end - minLen + 1:end)

end

