%Aggregate Brown Building counts
clear all
load('/Users/jahoward/Documents/Dropbox/Projects/bigbrother/data/building/sensor_data_01_01_08_to_06_09_08.mat');
sensorlist = sensorlist;
counts = [];

%Number of seconds to aggregate
%Should make this evenly divisible by hours
aggregateAmount = 900;

startDate = '01-12-2008 00:00:00';
endDate = '06-07-2008 23:59:59';

sd = datenum(startDate);
ed = datenum(endDate);

dayTimeStart = '00-00-0000 07:00:00';
dayTimeEnd = '00-00-0000 19:00:00';

%seconds in day = 86400
sid = 86400;
bid = sid/aggregateAmount;

dayBlocks = round((sid * (datenum(dayTimeEnd) - datenum(dayTimeStart))) / aggregateAmount);

%totalBlocks = round((ed-sd)*bid);
totalBlocks = round(ed-sd)*dayBlocks;
agData = zeros(totalBlocks, length(sensorlist));

% Make the daynums variable
%secCounting = 0:aggregateAmount:totalBlocks*aggregateAmount - 1;
secCounting = zeros(1, totalBlocks);
dayCount = 0:aggregateAmount:dayBlocks * aggregateAmount - 1;
dayCount = dayCount + (datenum(dayTimeStart) * sid);
for d = 1:round(ed - sd)
    secCounting(1, ((d - 1) * dayBlocks) + 1:d * dayBlocks) = dayCount + ((d - 1) * sid);
end

tmpVec = datevec(sd);
tmpVec = repmat(tmpVec, totalBlocks, 1);
tmpVec(:, 6) = secCounting;
dayNums = datenum(tmpVec);
dayOfWeek = weekday(dayNums);

for i = 1:length(sensorlist)
    fprintf(1, 'Sensor %i\n', sensorlist(i));
    tmpData = sensorcells{i};
    tmpData = unique(tmpData);
    currentBlock = 1;
    currentTime = dayNums(currentBlock);
    maxTime = currentTime + (aggregateAmount / sid);
    currentBlockTotal = 0;
    for j = 1:length(tmpData)
        if currentBlock > totalBlocks
            break
        end
        
        if tmpData(j) < maxTime && tmpData(j) >= currentTime
            currentBlockTotal = currentBlockTotal + 1;
        end
        
        if tmpData(j) > maxTime
            agData(currentBlock, i) = currentBlockTotal;
            %Move forward to the next pertinent block
            while maxTime < tmpData(j)
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
end

data.data = agData';
data.times = dayNums';
data.startTime = sd;
data.endTime = ed;
data.dayOfWeek = dayOfWeek';
data.blocksInDay = dayBlocks;

save('./data/brownData.mat', 'data');


x = linspace(1, dayBlocks, dayBlocks);
xflip = [x(1 : end - 1) fliplr(x)];
for i = 1:(ed-sd)
    y = agData((i-1)*dayBlocks + 1:i*dayBlocks, 1)';
    yflip = [y(1 : end - 1) fliplr(y)];
    patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
    hold on
end

