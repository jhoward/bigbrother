function [ind, windows, values] = simpleExtraction(data, windowSize, threshold)
    numWindows = size(data) / windowSize;
    ind = [];
    windows = [];
    values = [];
    
    for i = 0:numWindows-1
        tmp = data(i*windowSize + 1:(i+1) * windowSize);
        val = sum(abs(tmp));
        
        if val > threshold
            ind = [ind; i*windowSize + 1];
            windows = [windows; tmp'];
            values = [values; val];
        end
    end
end

