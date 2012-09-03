% Plot total hits for each sensor
clear all
close all

% Read background image
Ibkgnd = im2double(rgb2gray(imread('map_color.bmp')));
I = zeros(size(Ibkgnd,1),size(Ibkgnd,2));

% Scale and offset for sensor locations, on this map
offsetx = 115;
offsety = 4;
scalex = 1.0;
scaley = 1.0;

% import x,y locations of sensors
sensorxy = xlsread('layout.xls', 'sensorxy', 'A2:B51');

% Read data
%   sensorlist(1..numsensors)  - an array of sensor ids
%   sensorcells{1..numsensors} - each cell is an array of hit times for each sensor
%   allsensorhits(1..numhits)  - a sorted array of hit times for all sensors
%   allsensorids(1..numhits)   - the sensor ids corresponding to the above
load sensor_data_9_10_to_12_22.mat

% Only look for hits between these times
%starttime = datenum('09-24-2007 12:00:00');
%stoptime = datenum('09-29-2007 23:59:59');

%starttime = datenum('11-06-2007 00:00:00');     % Mote 2 was out
%stoptime = datenum('11-13-2007 23:59:59');

starttime = datenum('11-14-2007 00:00:00');
stoptime = datenum('11-20-2007 11:00:00');

%starttime = datenum('11-26-2007 14:00:00');
%stoptime = datenum('12-01-2007 23:59:59');

% starttime = datenum('11-30-2007 12:45:00');
% stoptime = datenum('11-30-2007 13:45:00');

% Find the index corresponding to the start time
for indexStart=1:length(allsensorhits)
    if allsensorhits(indexStart) >= starttime
        break;
    end
end

% Find the index corresponding to the stop time
for indexStop=indexStart:length(allsensorhits)
    if allsensorhits(indexStop) > stoptime
        break;
    end
end

% Create a gaussian profile
r1 = 15;
halfsize = 3*r1;
g = fspecial('gaussian', 2*halfsize+1, r1);
g = g / g(halfsize+1, halfsize+1);  % Make peak=1

% Count number of hits for each sensor
for iSensor=1:length(sensorlist)
    id = sensorlist(iSensor);

    count = 0;
    for i=indexStart:indexStop-1
        if allsensorids(i) == id
            count = count+1;
        end
    end

    fprintf('Sensor %d, count = %3d\n', id, count);
    
    % Ok, add a gaussian to the map with height = count
    x0 = round(scalex*sensorxy(iSensor,2) + offsetx);
    y0 = round(scaley*sensorxy(iSensor,1) + offsety);
    
    I(y0-halfsize:y0+halfsize, x0-halfsize:x0+halfsize) = ...
        I(y0-halfsize:y0+halfsize, x0-halfsize:x0+halfsize) + ...
        count*g(:,:);
end

% Scale counts image
I = I / max(I(:));

% gamma = 0.6;
% I = I .^ gamma;
% I = I / (3050 ^ gamma);

% Ok, merge the counts image with the background image
Ibk = double(Ibkgnd>0);
Imerge = max(Ibk, I);

figure, imshow(Imerge, []);
%figure, imshow(I, []);
colormap('hot');


    