function [means, stds] = computeMean(data, blocksInDay)
%For a dataset compute the mean and standard deviation given a "day" length
    newSize = floor(size(data, 2)/blocksInDay);    
    newData = data(1, 1:blocksInDay * newSize);
    tmpData = reshape(newData, blocksInDay, newSize);
    means = mean(tmpData, 2)';
    stds = std(tmpData, 1, 2)';
end

