clear all
close all

% Read data
%   sensorlist(1..numsensors)  - an array of sensor ids
%   sensorcells{1..numsensors} - each cell is an array of hit times for each sensor
%   beginTime - time when first sensor hit occurs
%   endTime - time when last sensor hit occurs
load mat/synthDataTrainedLZW.mat


trainedData = 1;
numSensors = size(sensorlist, 2);

% Read background image
Ibkgnd = zeros([600 800 3]);
IMG_HEIGHT = size(Ibkgnd,1);
IMG_WIDTH = size(Ibkgnd, 2);

% Create waterfall image.   
% Each cell is WxH pixels.
W = 10;
H = 4;

% The image is WATER_WIDTH x WATER_HEIGHT cells.
WATER_WIDTH = numSensors;
WATER_HEIGHT = floor(IMG_HEIGHT/H);
Iwater = zeros(WATER_HEIGHT*H, WATER_WIDTH*W, 3);

% Ok, append to the right, a section for the waterfall plot
Ibkgnd(:, end+1:end+WATER_WIDTH*W, :) = Iwater;
imshow(Ibkgnd);

interval = 1;   % count hits over this interval (in seconds)
maxcount = 1;    % Maximum possible # hits in that interval

% import x,y locations of sensors
xy = xlsread('Layouts/synth_layout.xls', 'sensorxy', 'A2:B51');

% Only look for hits between these times
%starttime = datenum('03-03-2008 15:04:37');
%stoptime = datenum('03-03-2008 15:04:50');

starttime = datenum(beginTime);
stoptime = datenum(endTime);

% compute interval time, in Matlab's units
intervalnum = (datenum('00:00:01') - datenum('00:00:00')) * interval;

% Don't draw frames if there is a gap between hits of this much or more
gapTime = (datenum('00:05:00') - datenum('00:00:00'));

% create avi file.  'Indeo5' seems to be best, but is not on Vista
% compression scheme of none is required for unix and mac.
aviobj = avifile('movies/movie1.avi', ...
    'compression', 'none', ...
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
    Y = zeros(1,numSensors);     %number of activations for each sensor
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
            
            if trainedData > 0 & j > (length(Y) / 2)
                myrow(1:H, ((j-1)*W+1):(j*W), 2) = 255*ones(H,W);
                myrow(1:H, ((j-1)*W+1):(j*W), 1) = zeros(H,W);
                myrow(1:H, ((j-1)*W+1):(j*W), 3) = zeros(H,W);
            else
                myrow(1:H, ((j-1)*W+1):(j*W), 1) = 255*ones(H,W);
                myrow(1:H, ((j-1)*W+1):(j*W), 2) = zeros(H,W);
                myrow(1:H, ((j-1)*W+1):(j*W), 3) = zeros(H,W);
            end;
        else
            myrow(1:H, ((j-1)*W+1):(j*W), 1) = zeros(H,W);
            myrow(1:H, ((j-1)*W+1):(j*W), 2) = zeros(H,W);
            myrow(1:H, ((j-1)*W+1):(j*W), 3) = zeros(H,W);
        end


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