function [means, stds] = dailyMean(data, times, dayLength, varargin)
%Compute the daily average and standard deviation for each unit time for
%each day for a given dataset.  

%Varagin can allow for a smooth parameter
%example:
%dailyMean(data, times, dayLength, 'smooth', true)

if nargin < 3
   error(message('dailyMean - Not enough inputs'))
end

parser = inputParser;
parser.CaseSensitive = true;
parser.addOptional('smooth', false);

try 
  parser.parse(varargin{:});
catch exception
  exception.throwAsCaller();
end

smoothData = parser.Results.smooth;

means = zeros(7, dayLength);
stds = zeros(7, dayLength);
dayOfWeek = weekday(times);

for i = 1:7
    tmp = (dayOfWeek == i);
    tmpData = data(tmp);
    
    newSize = floor(size(tmpData, 2)/dayLength);
    newData = tmpData(:, 1:newSize*dayLength);
    if smoothData
        newData = smooth(newData)';
    end
    size(newData)
    tmpData = reshape(newData, dayLength, newSize);
    means(i, :) = mean(tmpData, 2);
    stds(i, :) = std(tmpData, 1, 2);
end


