clear all
close all

% count hits over this interval (in seconds)
intervalSec = 60*60;   

% compute interval time, in Matlab's units
intervalTime = (datenum('00:00:01') - datenum('00:00:00')) * intervalSec;

fprintf('Plotting counts for all sensors, over intervals of %d seconds\n', ...
    intervalSec);

% Read data
%   sensorlist(1..numsensors)  - an array of sensor ids
%   sensorcells{1..numsensors} - each cell is an array of hit times for each sensor
%   allsensorhits(1..numhits)  - a sorted array of hit times for all sensors
%   allsensorids(1..numhits)   - the sensor ids corresponding to the above
load sensor_data_9_10_to_12_22.mat

[day,dow] = weekday(allsensorhits(1),'long');
fprintf('Earliest day/time in the list is %s %s\n', dow, datestr(allsensorhits(1)));
[day,dow] = weekday(allsensorhits(end),'long');
fprintf('Latest  day/time in the list is %s %s\n', dow, datestr(allsensorhits(end)));

% Only look for hits between these times
% Valid times:
%starttime = datenum('09-24-2007 12:00:00');
%stoptime = datenum('09-29-2007 23:59:59');

%starttime = datenum('11-06-2007 00:00:00');     % Mote 2 was out
%stoptime = datenum('11-13-2007 23:59:59');

%starttime = datenum('11-14-2007 00:00:00');
%stoptime = datenum('11-20-2007 11:00:00');

starttime = datenum('11-14-2007 00:00:00');
stoptime = datenum('11-18-2007 23:59:59');


% Count total hits in each interval, by going through the sorted array of
% all hits, allsensorhits.

% Find the index corresponding to the start of the first interval
for indexStart=1:length(allsensorhits)
    if allsensorhits(indexStart) > starttime
        break;
    end
end

numSlots = round((stoptime - starttime)/intervalTime);
fprintf('Number of intervals: %d\n', numSlots);

intervalStartTime = starttime;
for iSlot=1:numSlots
    timeslot(iSlot) = intervalStartTime;

    intervalStopTime = intervalStartTime + intervalTime;
    
    % Find the index corresponding to the stop time for this slot
    for indexStop=indexStart:length(allsensorhits)
        if allsensorhits(indexStop) > intervalStopTime
            break;
        end
    end

    % count total number of activations for this interval
    Y(iSlot) = indexStop - indexStart;

    [day,dow] = weekday(timeslot(iSlot),'long');
	fprintf('%s  \t%s\t%4d\t', dow, datestr(timeslot(iSlot)), Y(iSlot));
    
    % Count number of hits for each sensor
    for iSensor=1:length(sensorlist)
        id = sensorlist(iSensor);
        
        count = 0;
        for i=indexStart:indexStop-1
            if allsensorids(i) == id
                count = count+1;
            end
        end
        
        fprintf('%3d', count);
    end
    fprintf('\n');

    indexStart = indexStop;
    intervalStartTime = intervalStopTime;
end

plot(Y);







