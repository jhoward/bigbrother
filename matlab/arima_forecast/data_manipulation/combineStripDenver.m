%Combine denverTraffic data and strip it.

clear all;

sensorNumber = 4;
stripDays = 4;

load('./data/denverData.mat');

dataCombined = data.data;
timesCombined = data.times;

dataCombined = dataCombined(sensorNumber, :);

dayOfWeek = weekday(timesCombined);

%[means, stds] = dailyMean(dataCombined, timesCombined, data.blocksInDay, 'smooth', true);
%plotMean(means(stripDay, :), 'std', stds(stripDay, :));

%Strip down combined data to one day of the week.

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

data.data = sd;
data.times = st;
data.startTime = 0;
data.endTime = 0;
data.dayOfWeek = weekday(data.times);
data.sensor = sensorNumber;
data.stripDays = [stripDay];

save('./data/denverDataClean.mat', 'data');