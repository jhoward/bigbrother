%Run Buildings.  Do analysis for merl data and brownhall data

clear all;
load('./data/brownData.mat');

%===============================SETUP DATA=================
ahead = 5;
windowSize = 10;

trainPercent = 0.7;

%%%%%%%%%%%%%%BROWN HALL%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Combine the data to be just the exits
%allData = data.data(48, :) + data.data(28, :) + data.data(34, :);
allData = data.data(48, :);
numDays = floor(size(allData, 2))/data.blocksInDay;
inputMax = data.blocksInDay * floor(numDays * trainPercent);
input = allData(1, 1:inputMax);
output = allData(1, inputMax + 1:end);

%=========================END SETUP=====================

%========================COMPUTE DAY OF WEEK DATA=======

%Compute each day of week into a dataset
days = unique(data.dayOfWeek);

inputWeekData = {};
inputWeekTimes = {};

for i = 1:length(days)
    tmp = (data.dayOfWeek(1:inputMax) == i);
    tmpTimes = data.times(1, tmp);
    inputWeekTimes{i} = tmpTimes;
    inputWeekData{i} = input(tmp);
end

weeklySigma = zeros(length(days), data.blocksInDay);
for i = 1:length(days)
    newSize = floor(size(inputWeekData{i}, 2)/data.blocksInDay);
    newData = inputWeekData{i}(:, 1:newSize*data.blocksInDay);
    tmpRes = reshape(newData, size(inputWeekData{i},1), data.blocksInDay, newSize);
    weeklySigma(i, :) = std(tmpRes, 0, 3);
end

%dayNoiseSigma = std(tmpRes, 0, 3);

