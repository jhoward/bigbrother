function [ponanValue rmseonan sqeonan errpoints] = ponan(res, stds)
%Percent forecasts Outside Noise Against Naive (ponan)
%also computes root mean squared error outside noise againse naive
%also sum outside noise against naive
    newSize = floor(size(res, 2)/size(stds, 2));    
    newData = res(1, 1:size(stds, 2) * newSize);
    repstds = repmat(stds, 1, newSize);
    
    tmpData = abs(newData) - repstds;
    ponanValue = sum(sum(tmpData > 0)) / size(newData, 2);
    
    errpoints = (tmpData > 0);
    
    tmpData(tmpData < 0) = 0;
    sqeonan = sum(tmpData);
    %rmseonan = errperf(tmpData, zeros(size(tmpData)), 'rmse');
    
    %sqeonan = errperf(tmpData, zeros(size(tmpData)), 'rmse');
    tmpData = tmpData(tmpData > 0);
    rmseonan = errperf(tmpData, zeros(size(tmpData)), 'rmse');
end

