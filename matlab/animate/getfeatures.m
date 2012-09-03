% Find timed neighborhood activity features.

clear all
close all

% A loiter is a point that has the following characteristics:
%   It is active, and its neighborhood is inactive over time +-tloiter
tloiter = 30;   % seconds
floiter = ones(2*tloiter+1,1);

% A source is a point that has the following characteristics:
%   It and its neighborhood are initially inactive
%   Then it becomes active for a short time
%   Then it becomes inactive, and its neighborhood becomes active
    
% A sink is a point that has the following characteristics:
%   It is inactive, and its neighborhood is initially active
%   Then it becomes active for a short time, and the neighborhood inactive
%   Then it becomes inactive, and the neighborhood becomes inactive


% Read data
%   sensorlist(1..numsensors)  - an array of sensor ids
%   sensorcells{1..numsensors} - each cell is an array of hit times for each sensor
%   allsensorhits(1..numhits)  - a sorted array of hit times for all sensors
%   allsensorids(1..numhits)   - the sensor ids corresponding to the above
load sensor_data_02_02_to_02_05.mat

% Read data
%   neighbors(1..nsensors, 1..nsensors)  - is nonzero if i,j are neighbors
load neighbors.mat

% Read background image
Ibkgnd = im2double(imread('map.tif'));
imshow(Ibkgnd, []);

% Scale and offset for sensor locations, on this map
offsetx = 115;
offsety = 4;
scalex = 1.0;
scaley = 1.0;

% import x,y locations of sensors
sensorxy = xlsread('layout.xls', 'sensorxy', 'A2:B51');


% Only look for hits between these times
%starttime = datenum('09-24-2007 12:00:00');
%stoptime = datenum('09-29-2007 23:59:59');

%starttime = datenum('11-14-2007 00:00:00');
%stoptime = datenum('11-20-2007 11:00:00');

starttime = datenum('02-02-2008 00:00:00');
stoptime = datenum('02-05-2008 23:59:59');

% This is one second, in units of days
oneSec = (datenum('00:00:01') - datenum('00:00:00'));


% Let's build a matrix that explicitly stores the hits (0 or 1) for each
% of the 50 sensors, at each second.  The matrix is
%   hits(1:N, 1:50)
% where N is the total number of seconds from start to stop time.
N = round( (stoptime - starttime)/oneSec );
hits = zeros(N, 50);

% Go through list of all hits, and record entries in the hits matrix
indexHits = 0;
for index=1:length(allsensorhits)
    if allsensorhits(index) < starttime     continue; end
    if allsensorhits(index) > stoptime      break;    end
    
    t0 = allsensorhits(index);  % Get the time at this index
    
    % Convert to number of seconds since the starttime
    iSec = round( (t0-starttime)/oneSec );
    
    % (A check ... may not be necessary)
    if (iSec < 1) | (iSec > N)    continue;   end
    
    % Get sensor id, convert to a number from 1 to 50
    id = allsensorids(index);
    iSensor = find(sensorlist == id);
    
    hits(iSec, iSensor) = 1;
end

% Calculate the mean and variance for each sensor
hitsMean = mean(hits, 1);
hitsVar = var(hits, 0, 1);

% Subtract off the mean for each sensor
for iSensor=1:50
    hits(:,iSensor) = hits(:,iSensor) - hitsMean(iSensor);
end

% We'll build a matrix loiter(1:N, 1:50), which gives the score that
% sensor i at time t is a loiter activity.
loiter = zeros(N, 50);

for iSensor=1:50
    score = conv(hits(:,iSensor), floiter);     % convolution
    nbrs = find(neighbors(iSensor,:) > 0);
    for iNbr = 1:length(nbrs)
        scoreNeighbor = conv(hits(:,nbrs(iNbr)), floiter);
        score = score - scoreNeighbor/length(nbrs);
    end
    loiter(1:N, iSensor) = score(tloiter+1:end-tloiter);
end

% Compute the average value of "loiterness" for each sensor
loiterness = mean(loiter, 1);

% Print them
[loiterness, IX] = sort(loiterness, 'descend');
for i=1:50
    fprintf('id=%d, loiter=%f\n', sensorlist(IX(i)), loiterness(i));
end

% Display only positive values, and scale those to 0..1
loiterness = loiterness .* (loiterness>0);
loiterness = loiterness/max(loiterness);

% Display on map
r1 = 10;
for i=1:256
    if i <= 128 
        cmap(i,:) = [i/128 0 0];
    else
        cmap(i,:) = [1 (i-128)/128 0];
    end
end

for i=1:50
    x0 = scalex*sensorxy(IX(i),2) + offsetx;
    y0 = scaley*sensorxy(IX(i),1) + offsety;

    if loiterness(i) > 0
        mycolor = cmap(round(loiterness(i)*256),:);
        rectangle('Curvature', [1 1], ...
            'Position', [x0-r1 y0-r1 2*r1 2*r1], ...
            'FaceColor', mycolor);
    end
end



