clear all
load('./data/merlDataRaw.mat');

%Aggregate Brown Building counts
clear all
load('./data/merlDataRaw.mat');
%load('C:\Users\JamesHoward\Documents\Dropbox\Projects\bigbrother\data\building\sensor_data_01_01_08_to_06_09_08.mat');
%sensorlist = sensorlist;
counts = [];

%Number of seconds to aggregate
%Should make this evenly divisible by hours
aggregateAmount = 900;

startDate = '23-mar-2006 00:00:00';
endDate = '11-jun-2006 00:00:00';

sd = datenum(startDate);
ed = datenum(endDate);

dayTimeStart = '00-00-0000 07:00:00';
dayTimeEnd = '00-00-0000 19:00:00';

dayTS = datenum(dayTimeStart);
dayTE = datenum(dayTimeEnd);

%seconds in day = 86400
sid = 86400;
bid = sid/aggregateAmount;

dayBlocks = round((sid * (dayTE - dayTS)) / aggregateAmount);

totalBlocks = round(ed-sd)*dayBlocks;
agData = zeros(totalBlocks, length(sensors));

% Make the daynums variable
currentBlock = 1;
currentTime = dayNums(currentBlock);
maxTime = currentTime + (aggregateAmount / sid);
currentBlockTotals = zeros(length(sensors), 1);

for j = 1:size(rawData, 2)
    if currentBlock > totalBlocks
        break
    end

    if rawData(2, j) < maxTime && rawData(2, j) >= currentTime
        sensNum = find(sensors == rawData(1, j));
        currentBlockTotals(sensNum) = currentBlockTotals(sensNum) + 1;
    end

    if rawData(2, j) > maxTime
        agData(currentBlock, :) = currentBlocksTotal;
        %Move forward to the next pertinent block
        while maxTime < rawData(2, j)
            currentBlock = currentBlock + 1;

            if currentBlock > totalBlocks
                break
            end
            currentTime = dayNums(currentBlock);
            maxTime = currentTime + (aggregateAmount / sid);
        end
        currentBlockTotal = 1;
    end  
end