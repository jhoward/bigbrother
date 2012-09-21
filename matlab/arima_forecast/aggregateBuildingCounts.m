%Aggregate Brown Building counts
clear all
load('..\..\data\building\sensor_data_01_01_08_to_06_09_08.mat');

counts = [];

%Number of seconds to aggregate
%Should make this evenly divisible by days
aggregateAmount = 600;\


startDate = '01-09-2008 00:00:00';
endDate = '06-07-2008 23:59:59';

sd = datenum(startDate);
ed = datenum(endDate);

%seconds in day = 86400
sid = 86400;
bid = sid/aggregateAmount;

totalBlocks = (ed-sd)*bid;
agData = zeros(totalBlocks, length(sensorlist));


% Make the daynums variable
secCounting = 0:aggregateAmount:totalBlocks*aggregateAmount;
tmpVec = datevec(sd);
tmpVec = repmat(tmpVec, totalBlocks + 1, 1);
tmpVec(:, 6) = secCounting;
dayNums = datenum(tmpVec);
dayOfWeek = weekday(dayNums);

for i = 1:length(sensorlist)
    fprintf(1, 'Sensor %i\n', sensorlist(i));
    tmpData = sensorcells{i};

    currentBlock = 1;
    currentBlockTotal = 0;
    for j = 1:length(tmpData)
        tmpVec = datevec(tmpData(j));
        blocksDays = floor(tmpData(j) - sd)*bid;
        blocksCurrentDay = floor((tmpVec(4) * 3600 + tmpVec(5) * 60 + tmpVec(6)) / aggregateAmount);
        tmpBlock = blocksDays + blocksCurrentDay + 1;
        if tmpBlock < 0 
            fprintf(1, 'tmpBlock:%i\n', tmpBlock);
            continue
        end
        if tmpBlock > totalBlocks
            fprintf(1, 'maximumBlock:%i    tmpBlock:%i\n', totalBlocks, tmpBlock);
            break
        end
        
        if tmpBlock > currentBlock
            agData(currentBlock, i) = currentBlockTotal;
            currentBlock = tmpBlock;
            currentBlockTotal = 1;
        else
            currentBlockTotal = currentBlockTotal + 1;
        end
    end
end

x = linspace(1, 144, 144);
xflip = [x(1 : end - 1) fliplr(x)];
for i = 1:(ed-sd)
    y = agData((i-1)*bid + 1:i*bid, 20)';
    yflip = [y(1 : end - 1) fliplr(y)];
    patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
    hold on
end

blocksInDay = bid;

save('./data/brownData.mat', 'agData', 'dayNums', 'dayOfWeek', 'blocksInDay');
