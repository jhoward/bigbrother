clear all
close all

% Read background image
Ibkgnd = imread('simulation/images/map_color.bmp');
%Ibkgnd = zeros(size(Ibkgnd));      % uncomment if you want black bkgnd
IMG_HEIGHT = size(Ibkgnd,1);
IMG_WIDTH = size(Ibkgnd, 2);

% Create waterfall image.   
% Each cell is WxH pixels.
W = 8;
H = 4;
% The image is WATER_WIDTH x WATER_HEIGHT cells.
WATER_WIDTH = 50;
WATER_HEIGHT = floor(IMG_HEIGHT/H);
Iwater = zeros(WATER_HEIGHT*H, WATER_WIDTH*W, 3);

% Ok, append to the right, a section for the waterfall plot
Ibkgnd(:, end+1:end+WATER_WIDTH*W, :) = Iwater;
imshow(Ibkgnd);

interval = 1;   % count hits over this interval (in seconds)
maxcount = 1;    % Maximum possible # hits in that interval

% import x,y locations of sensors
xy = xlsread('simulation/layouts/xysensor.xls');

% Read data
%   sensorlist(1..numsensors)  - an array of sensor ids
%   sensorcells{1..numsensors} - each cell is an array of hit times for each sensor
%   allsensorhits(1..numhits)  - a sorted array of hit times for all sensors
%   allsensorids(1..numhits)   - the sensor ids corresponding to the above
load '../data/generated/train/sensor_data.mat'

% Only look for hits between these times
starttime = datenum('01-01-2010 00:00:00');
stoptime = datenum('01-02-2010 00:00:00');

%starttime = datenum('09-26-2007 05:24:00');
%stoptime = datenum('09-26-2007 05:44:00');

%starttime = datenum('09-30-2007 5:51:00');
%stoptime = datenum('09-30-2007 5:54:00');

% compute interval time, in Matlab's units
intervalnum = (datenum('00:00:01') - datenum('00:00:00')) * interval;

% Don't draw frames if there is a gap between hits of this much or more
gapTime = (datenum('00:05:00') - datenum('00:00:00'));

% create avi file.  'Indeo5' seems to be best, but is not on Vista
aviobj = avifile('movie1.avi', ...
    'compression', 'None', ...
    'fps', 30, ...
    'keyframe', 0.05);

warning off all         % Turn off warnings about frame size

tic    % starts timer
numSlots = round((stoptime - starttime)/intervalnum);
newstop = starttime;
hitTimeLast = starttime;
for i=1:numSlots

    newstart = newstop;
    newstop = newstart + intervalnum;

    timeslot = newstart;
    Y = zeros(1,50);     %number of activations for each sensor
    for j=1:size(sensorcells,2)
        Y(j) = size(find(sensorcells{j} > newstart & sensorcells{j} <= newstop),1);
    end

    % If there are any hits, remember this time
    if max(Y) > 0    hitTimeLast = newstart;  end
    
    % Don't draw a frame if it has been a long time since the last hit.
    if (newstart - hitTimeLast) > gapTime   continue;   end
    
    % Move the waterfall image down one row.
    Ibkgnd(H+1:end, end-size(Iwater,2)+1:end, :) = ...
        Ibkgnd(1:end-H, end-size(Iwater,2)+1:end, :);
    
    % Fill in this row on the waterfall image.
    for j=1:length(Y)
        % Fill in red color
        if Y(j) > 0
            myrow(1:H, ((j-1)*W+1):(j*W), 1) = 255*ones(H,W);
        else
            myrow(1:H, ((j-1)*W+1):(j*W), 1) = zeros(H,W);
        end

        % The green and blue components are zero
        myrow(1:H, ((j-1)*W+1):(j*W), 2) = zeros(H,W);
        myrow(1:H, ((j-1)*W+1):(j*W), 3) = zeros(H,W);
    end
    Ibkgnd(1:H, end-size(Iwater,2)+1:end, :) = myrow;
    
    imshow(Ibkgnd);     % displays background image
    drawblanksensors(xy);

    drawsensors(xy,Y,maxcount);
    drawtime(timeslot);
    frame = getframe;       % grabs image from screen
    aviobj = addframe(aviobj,frame);        % add image to movie
    pause(0.1);     % may not need (seconds to pause)
end
toc   % stops timer

aviobj = close(aviobj);





