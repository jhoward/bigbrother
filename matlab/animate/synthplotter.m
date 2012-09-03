clear all
close all

% Read data
%   sensorlist(1..numsensors)  - an array of sensor ids
%   sensorcells{1..numsensors} - each cell is an array of hit times for each sensor
%   beginTime - time when first sensor hit occurs
%   endTime - time when last sensor hit occurs
<<<<<<< .mine
load mat/synthDataTrained.mat
=======
load mat/synthDataRandomTrainedCorrelation.mat
>>>>>>> .r85


trainedData = 1;
numSensors = size(data, 2) * 2 - 2;

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

% create avi file.  'Indeo5' seems to be best, but is not on Vista
% compression scheme of none is required for unix and mac.
aviobj = avifile('movies/movie1.avi', ...
    'compression', 'none', ...
    'fps', 30, ...
    'keyframe', 0.05);

warning off all         % Turn off warnings about frame size

tic    % starts timer

offset = find(data(:, 1) == predictedData(1, 1));

for i=1:size(predictedData, 1)

    if i + offset > size(data, 1)
        break;
    end;
    
    Y = [data(i + offset - 1, 2:size(data, 2)) ...
        predictedData(i, 2:size(predictedData, 2))];
    
    % Move the waterfall image down one row.
    Ibkgnd(H+1:end, end-size(Iwater,2)+1:end, :) = ...
        Ibkgnd(1:end-H, end-size(Iwater,2)+1:end, :);

    % Fill in this row on the waterfall image.
    for j=1:length(Y)
        % Fill in red color
        if Y(j) > 0
            
            if trainedData > 0 & j > (size(data, 2) - 1)
                myrow(1:H, ((j-1)*W+1):(j*W), 2) = 1*ones(H,W) * ...
                    predictedData(i, j - size(data, 2) + 2);
                myrow(1:H, ((j-1)*W+1):(j*W), 1) = zeros(H,W);
                myrow(1:H, ((j-1)*W+1):(j*W), 3) = zeros(H,W);
            else
                myrow(1:H, ((j-1)*W+1):(j*W), 1) = 1*ones(H,W);
                myrow(1:H, ((j-1)*W+1):(j*W), 2) = zeros(H,W);
                myrow(1:H, ((j-1)*W+1):(j*W), 3) = zeros(H,W);
            end;
        else
            myrow(1:H, ((j-1)*W+1):(j*W), 1) = zeros(H,W);
            myrow(1:H, ((j-1)*W+1):(j*W), 2) = zeros(H,W);
            myrow(1:H, ((j-1)*W+1):(j*W), 3) = zeros(H,W);
        end
    end
    
    %myrow(1:2, :, 3) = .5;
    
    Ibkgnd(1:H, end-size(Iwater,2)+1:end, :) = myrow;
    
    imshow(Ibkgnd);     % displays background image
    drawblanksensors(xy);

    drawsensors(xy,Y,maxcount);
    drawtime(predictedData(i, 1));
    frame = getframe;       % grabs image from screen
    aviobj = addframe(aviobj,frame);        % add image to movie
    pause(0.1);     % may not need (seconds to pause)
end
toc   % stops timer

aviobj = close(aviobj);