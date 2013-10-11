%Combine denverTraffic data and strip it.

clear all;

sensorNumber = 4;
stripDays = [2 3 4 5];

load('./data/denverData.mat');

dataCombined = data.data;
timesCombined = data.times;

dataCombined = dataCombined(sensorNumber, :);

dayOfWeek = weekday(timesCombined);

%Strip down combined data to one day of the week.
for i = 1:size(stripDays, 2)
    dayOfWeek(dayOfWeek == stripDays(i)) = 10;
end

tmp = (dayOfWeek == 10);
stripData = dataCombined(tmp);
stripTimes = timesCombined(tmp);

dataCombined = stripData;
timesCombined = stripTimes;

newSize = floor(size(dataCombined, 2)/data.blocksInDay);
newData = dataCombined(:, 1:newSize*data.blocksInDay);
newTimes = timesCombined(:, 1:newSize*data.blocksInDay);

dataCombined = reshape(newData, data.blocksInDay, newSize)';
timesCombined = reshape(newTimes, data.blocksInDay, newSize)';

%Make a matrix of the sum of all days
daySums = sum(dataCombined, 2)';

%Remove zero days
nonZeroDays = daySums > 0;

dataCombined = dataCombined(nonZeroDays, :);
timesCombined = timesCombined(nonZeroDays, :);

%Concate the data back to one dataset
sd = reshape(dataCombined', 1, size(dataCombined, 1)*size(dataCombined, 2));
st = reshape(timesCombined', 1, size(timesCombined, 1)*size(timesCombined, 2));

%sd = smooth(sd, 3)';

[means, stds] = dailyMean(sd, st, data.blocksInDay, 'smooth', false);
plotMean(means(stripDays(1), :), 'std', stds(stripDays(1), :));


%Remove the top n% of outliers and renormalize
% removePercent = 0.001;
% nRemove = floor(removePercent * size(sd, 2));
% 
% [tmp, ind] = sort(sd, 'descend');
% sd(ind(1, 1:nRemove)) = tmp(1, ind(1, nRemove + 1));
% sd(ind(1, end-nRemove:end)) = tmp(1, ind(1, end - nRemove - 1));

%Normalize
%sd = 2*(sd - min(sd))/(max(sd) - min(sd)) - 1;
sd = sd/max(sd);

data.data = sd;
data.times = st;
data.startTime = 0;
data.endTime = 0;
data.dayOfWeek = weekday(data.times);
data.sensor = sensorNumber;
data.stripDays = stripDays;

save('./data/denverDataThesisDay.mat', 'data');