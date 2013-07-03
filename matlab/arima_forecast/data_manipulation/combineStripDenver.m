%Combine denverTraffic data and strip it.

clear all;

sensorNumber = 21;
stripDays = [4];

load('./data/brownData_01_06.mat');
data01 = data;

load('./data/brownData_09_12.mat');
data09 = data;

dataCombined = [data09.data data01.data];
timesCombined = [data09.times data01.times];

dataCombined = dataCombined(sensorNumber, :);

dayOfWeek = weekday(timesCombined);

%[means, stds] = dailyMean(dataCombined, timesCombined, data.blocksInDay, 'smooth', true);
%plotMean(means(stripDay, :), 'std', stds(stripDay, :));

%Strip down combined data to one day of the week.
for i = 1:size(stripDays, 2)
    dayOfWeek(dayOfWeek == stripDays(i)) = 10;
end

tmp = (dayOfWeek == 10);
stripData = dataCombined(tmp);
stripTimes = timesCombined(tmp);

newSize = floor(size(stripData, 2)/data.blocksInDay);
newData = stripData(:, 1:newSize*data.blocksInDay);
newTimes = stripTimes(:, 1:newSize*data.blocksInDay);

stripData = reshape(newData, data.blocksInDay, newSize)';
stripTimes = reshape(newTimes, data.blocksInDay, newSize)';

%Make a matrix of the sum of all days
daySums = sum(stripData, 2)';

%Remove zero days
nonZeroDays = daySums > 0;

stripData = stripData(nonZeroDays, :);
stripTimes = stripTimes(nonZeroDays, :);

%Concate the data back to one dataset
sd = reshape(stripData', 1, size(stripData, 1)*size(stripData, 2));
st = reshape(stripTimes', 1, size(stripTimes, 1)*size(stripTimes, 2));

sd = smooth(sd, 3)';


[means, stds] = dailyMean(sd, st, data.blocksInDay, 'smooth', false);
plotMean(means(stripDays(1), :), 'std', stds(stripDays(1), :));

data.data = sd;
data.times = st;
data.startTime = 0;
data.endTime = 0;
data.dayOfWeek = weekday(data.times);
data.sensor = sensorNumber;

save('./data/brownDataClean.mat', 'data');