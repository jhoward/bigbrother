clear all
close all

tic

%Program to perform closest pattern matching
%Program will create a .mat file when finished for use with synthPlotter.m
K = 10;

%Load the data
load mat/toyData.mat

startTime = datenum(beginTime);
stopTime = datenum(endTime);

interval = (datenum('00:00:01') - datenum('00:00:00'));

%Find the starting range
startIndex = find(data(:,1) > startTime & ...
                  data(:,1) <= (startTime + interval));
endIndex = startIndex + K - 1;
numSlots = size(data, 1) - endIndex;
predictedData = zeros(numSlots - K, size(data, 2));

if startIndex
    for x = 1:numSlots
        startIndex = startIndex + 1;
        endIndex = endIndex + 1;
        runningPattern = data(startIndex:endIndex, :);
        predictedData(endIndex - K, 1) = data(endIndex, 1);
        
        for y = 2:size(data, 2)
            
            %Run simple closest pattern matching algorithm
            val = scpm(data, runningPattern, 10000, y, 1, endIndex - 1, 0); 
            predictedData( endIndex - K, y) = val;
        end;
    end;
end;

disp('Creating sensorcells list');

%Reconstruct a mat file for visualization
%Generate SensorCells

D = size(sensorcells, 2);

for i = 2:D+1
    tmp = [];
    amt = 1;
    for j = 1:size(predictedData, 1)
        if predictedData(j,i) == 1
            tmp(amt) = predictedData(j,1);
            amt = amt + 1;
        end;
    end;
    sensorcells{D + i - 1} = (tmp');
end;    



%Generate SensorList
for i = 1:D
    sensorlist(D + i) = 100 + i;
end;

toc

save mat/synthDataTrained.mat data predictedData ...
                              sensorcells sensorlist beginTime endTime