%Aggregate Brown Building counts
clear all
%load('/Users/jahoward/Documents/Dropbox/Projects/bigbrother/data/building/sensor_data_01_01_08_to_06_09_08.mat');
load('C:\Users\JamesHoward\Documents\Dropbox\Projects\bigbrother\data\building\brown_hall\sensor_data_01_01_08_to_06_09_08.mat');
%sensorlist = sensorlist;
counts = [];

%Number of seconds to aggregate
%Should make this evenly divisible by hours
aggregateAmount = 900;
superSampleAmount = 2;

startDate = '01-12-2008 00:00:00';
endDate = '05-05-2008 24:00:00';

sd = datenum(startDate);
ed = datenum(endDate);

dayTimeStart = '00-00-0000 07:00:00';
dayTimeEnd = '00-00-0000 20:00:00';

%seconds in day = 86400
sid = 86400;
bid = sid/aggregateAmount;

dayBlocks = round((sid * (datenum(dayTimeEnd) - datenum(dayTimeStart))) / aggregateAmount);

%totalBlocks = round((ed-sd)*bid);
totalBlocks = round(ed-sd)*dayBlocks;
agData = zeros(totalBlocks, length(sensorlist));

ssData = zeros(totalBlocks * superSampleAmount, length(sensorlist));

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
    
    nData = agData(:, i);
    tmpData = zeros(size(agData, 1) * superSampleAmount, 1);
    count = 1;

    if superSampleAmount > 1
        for k = 1:size(nData, 1) - 1;
            tmp = linspace(nData(k, 1), nData(k + 1, 1), superSampleAmount + 1);
            tmpData(count:count+superSampleAmount - 1) = tmp(1:end - 1)';
            count = count + superSampleAmount;
        end
        
        tmp = linspace(nData(end), nData(end), superSampleAmount);
        tmpData(count:end) = tmp';
    end
    
    ssData(:, i) = tmpData(:, 1);
end

%Convert the times
ssTimes = zeros(size(dayNums, 1) * superSampleAmount, 1);
count = 1;

if superSampleAmount > 1
    for k = 1:size(dayNums, 1) - 1;
        tmp = linspace(dayNums(k, 1), dayNums(k + 1, 1), superSampleAmount + 1);
        ssTimes(count:count+superSampleAmount - 1) = tmp(1:end - 1)';
        count = count + superSampleAmount;
    end

    tmp = linspace(nData(end), nData(end), superSampleAmount);
    ssTimes(count:end) = tmp';
end


%data.data = agData';
data.data = ssData';
data.times = ssTimes';
%data.times = dayNums';
data.startTime = sd;
data.endTime = ed;
data.dayOfWeek = weekday(ssTimes)';
data.blocksInDay = dayBlocks*superSampleAmount;

save('./data/brownData.mat', 'data');

%tl = [48, 28, 11, 34];

%Plot each sensor
%x = 1:1:dayBlocks;
x = 1:1:dayBlocks*superSampleAmount;
xflip = [x(1 : end - 1) fliplr(x)];
for sens = 1:size(sensorlist, 2)
%for sens = 1:size(tl, 2)
    sens
    val = sens;
    %val = tl(sens);
    for i = 1:(ed-sd)
        %y = agData((i-1)*dayBlocks + 1:i*dayBlocks, val)';
        y = ssData((i - 1)*dayBlocks*superSampleAmount + 1:i*dayBlocks*superSampleAmount, val)';
        yflip = [y(1 : end - 1) fliplr(y)];
        patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
        hold on
    end
    xlim([1 dayBlocks*superSampleAmount]);
    hold off
    waitforbuttonpress;
    plot(x);
end

