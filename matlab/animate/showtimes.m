clear all
close all



% Read data
%   sensorlist(1..numsensors)  - an array of sensor ids
%   sensorcells{1..numsensors} - each cell is an array of hit times for each sensor
%   allsensorhits(1..numhits)  - a sorted array of hit times for all sensors
%   allsensorids(1..numhits)   - the sensor ids corresponding to the above
%load sensor_data_09_10_07_to_12_31_07.mat
load mat/sensor_data_01_01_08_to_06_09_08.mat

[day,dow] = weekday(allsensorhits(1),'long');
fprintf('Earliest day/time in the list is %s %s\n', dow, datestr(allsensorhits(1)));
[day,dow] = weekday(allsensorhits(end),'long');
fprintf('Latest  day/time in the list is %s %s\n', dow, datestr(allsensorhits(end)));

disp('Enter starting and dates, in the form yyyy-mm-dd HH:MM:SS.');
startdate = input('Start date: ', 's');
starttime = datenum(startdate, 'yyyy-mm-dd HH:MM:SS');
enddate = input('End date: ', 's');
endtime = datenum(enddate, 'yyyy-mm-dd HH:MM:SS');

N = 400;        % Number of time intervals

% compute interval time in days
intervalTime = (endtime - starttime)/N;

% interval time in seconds
intervalSec = intervalTime/(datenum('00:00:01') - datenum('00:00:00'));   

fprintf('Showing counts for all sensors, over intervals of %f seconds\n', ...
    intervalSec);


% Put the counts in a matrix
M = length(sensorlist);         % number of sensors
counts = zeros(N, M);


% Let's build a matrix that explicitly stores the hits (0 or 1) for each
% of the above sensors, at each unit of time.  The matrix is
%   hits(1:N, 1:M)
% where N is the total number of time intervals from start to stop time.
hits = zeros(N, M);

% Go through list of all hits, and record entries in the hits matrix
indexHits = 0;
for index=1:length(allsensorhits)
    if allsensorhits(index) < starttime     continue; end
    if allsensorhits(index) > endtime      break;    end

    t0 = allsensorhits(index);  % Get the time at this index

    % Convert to number of time units since the starttime
    iUnit = round( (t0-starttime)/intervalTime );

    % (A check ... may not be necessary)
    if (iUnit < 1) || (iUnit > N)    continue;   end

    % Get sensor id, convert to a number from 1 to M
    id = allsensorids(index);
    iSensor = find(sensorlist == id);

    hits(iUnit, iSensor) = hits(iUnit, iSensor) + 1;
end

% Scale each sensor (column) by the maximum number for that sensor
for i=1:M
    hits(:,i) = hits(:,i)/max(hits(:,i));
end

imshow(hits,'DisplayRange', []);

% Draw lines and text at date intervals
for i=1:N
    t = (i-1)*intervalTime + starttime;    % Get time for this row
    
    % Check for a new day
    if floor(t) > floor(t-intervalTime)
        if (1/intervalTime) > 5
            line( [0 M], [i-0.5 i-0.5], 'Color', 'r');    
        elseif datestr(t, 'ddd') == 'Sun'
            % Draw line only if Sunday
            line( [0 M], [i-0.5 i-0.5], 'Color', 'r');    
        end
        
        if (1/intervalTime) > 15
            % Print date
            szDate = sprintf('%s %s', datestr(t, 'ddd'), datestr(t, 'dd-mmm-yyyy'));
            text(M+1, i, szDate, 'VerticalAlignment', 'Top', 'FontSize', 9);
        elseif datestr(t, 'ddd') == 'Sun'
            % Print date only if Sunday
            szDate = sprintf('%s %s', datestr(t, 'ddd'), datestr(t, 'dd-mmm-yyyy'));
            text(M+1, i, szDate, 'VerticalAlignment', 'Top', 'FontSize', 9);            
        end
    end
end





