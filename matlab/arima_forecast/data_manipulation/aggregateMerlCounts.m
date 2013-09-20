
%Aggregate Brown Building counts
clear all
load('./data/merlDataRaw.mat');
%load('C:\Users\JamesHoward\Documents\Dropbox\Projects\bigbrother\data\building\sensor_data_01_01_08_to_06_09_08.mat');
%sensorlist = sensorlist;
counts = [];

%Number of seconds to aggregate
%Should make this evenly divisible by hours
aggregateAmount = 600;

startDate = '23-mar-2006 00:00:00';
endDate = '28-aug-2008 00:00:00';

sd = datenum(startDate);
ed = datenum(endDate);

dayTimeStart = '00-00-0000 07:00:00';
dayTimeEnd = '00-00-0000 20:00:00';
dayTimeStartInt = 7;
dayTimeEndInt = 20;

dayTS = datenum(dayTimeStart);
dayTE = datenum(dayTimeEnd);

dayShift = '00-00-0000 19:00:00';

daySh = datenum(dayShift);

%seconds in day = 86400
sid = 86400;
bid = sid/aggregateAmount;

dayBlocks = round((sid * (dayTE - dayTS)) / aggregateAmount);

totalBlocks = round(ed-sd)*dayBlocks;
agData = zeros(totalBlocks, length(sensors));

%Make the times array
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

%Convert the data to cell array per sensor
for s = 1:length(sensors)
    tmp = find(rawData(1, :) == sensors(s));
    tmp = rawData(2, tmp); %#ok<FNDSB>
    tmp = sort(tmp);
    tmp = datenum(tmp/86400/1000 + datenum(1970,1,1));
    tmp = tmp + daySh;
    cellData{s} = tmp; %#ok<SAGROW>
end

for s = 1:length(cellData)
    currentBlock = 1;
    currentTime = dayNums(currentBlock);
    maxTime = currentTime + (aggregateAmount / sid);
    currentBlockTotal = 0;

    for j = 1:size(cellData{s}, 2)
        if currentBlock > totalBlocks
            break
        end

        if cellData{s}(1, j) < maxTime && cellData{s}(1, j) >= currentTime
            currentBlockTotal = currentBlockTotal + 1;
        end

        if cellData{s}(1, j) > maxTime
            %fprintf(1, 'In here.');
            agData(currentBlock, s) = currentBlockTotal;
            
            %Move forward to the next pertinent block
            while maxTime < cellData{s}(1, j)
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
data.dayOfWeek = weekday(dayNums)';
data.blocksInDay = dayBlocks;
data.dayTimeStart = dayTimeStartInt;
data.dayTimeEnd = dayTimeEndInt;

save('./data/merlData.mat', 'data');

% 
%Plot each sensor
%x = 1:1:dayBlocks;
x = 1:1:dayBlocks;
xflip = [x(1 : end - 1) fliplr(x)];
for sens = 1:size(sensors, 2)
%for sens = 1:size(tl, 2)
    sensors(sens)
    val = sens;
    %val = tl(sens);
    for i = 1:(ed-sd)
        %y = agData((i-1)*dayBlocks + 1:i*dayBlocks, val)';
        y = agData((i - 1)*dayBlocks + 1:i*dayBlocks, val)';
        yflip = [y(1 : end - 1) fliplr(y)];
        patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
        hold on
    end
    xlim([1 dayBlocks]);
    ylim([0 150]);
    hold off
    waitforbuttonpress;
    plot(zeros(dayBlocks, 1));
end
