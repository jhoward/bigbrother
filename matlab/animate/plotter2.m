% Plots an animation of the sensor hits on the map.
% Also shows a "waterfall" display of all the hits
%  Bill Hoff   November 2000
clear all
close all

% Read background image
Ibkgnd = imread('simulation/images/map_color.bmp');
%Ibkgnd = zeros(size(Ibkgnd));      % uncomment if you want black bkgnd

% import x,y locations of sensors (in pixels)
xy = xlsread('simulation/layouts/xyNode.xls');

% Add this offset to sensor positions
offsetx = 0;
offsety = 0;

% Read data
%   sensorlist(1..numsensors)  - an array of sensor ids
%   sensorcells{1..numsensors} - each cell is an array of hit times for each sensor
%   allsensorhits(1..numhits)  - a sorted array of hit times for all sensors
%   allsensorids(1..numhits)   - the sensor ids corresponding to the above
%load '../data/sensor_data/sensor_data_09_10_07_to_12_31_07.mat'
%load '../data/sensor_data/sensor_data_01_01_08_to_06_09_08.mat'
load 'sensor_data.mat'

% Only look for hits between these times
% disp('Enter starting and dates, in the form yyyy-mm-dd HH:MM:SS.');
% startdate = input('Start date: ', 's');
startdate = '2008-03-17 015:00:00';
%startdate = '2010-01-01 00:00:00';
starttime = datenum(startdate, 'yyyy-mm-dd HH:MM:SS');
% enddate = input('End date: ', 's');
enddate = '2008-03-17 16:00:00';
%enddate = '2010-01-01 00:17:00';
endtime = datenum(enddate, 'yyyy-mm-dd HH:MM:SS');

% This is the basic unit of time, in units of days
unitTime = (datenum('00:00:02') - datenum('00:00:00'));

% We are only interested in this group of sensors
%sensorgroup = [ 43 44 50 51 52 53 ];
%sensorgroup = [ 90 93 94 100 101 102 104];
sensorgroup = sensorlist;
M = length(sensorgroup);         % number of sensors

% Let's build a matrix that explicitly stores the hits (0 or 1) for each
% of the above sensors, at each unit of time.  The matrix is
%   hits(1:N, 1:M)
% where N is the total number of time units from start to stop time.
N = round( (endtime - starttime)/unitTime );
hits = zeros(N, M);

% Go through list of all hits, and record entries in the hits matrix
indexHits = 0;
for index=1:length(allsensorhits)
    if allsensorhits(index) < starttime     continue; end
    if allsensorhits(index) > endtime      break;    end

    t0 = allsensorhits(index);  % Get the time at this index

    % Convert to number of time units since the starttime
    iUnit = round( (t0-starttime)/unitTime );

    % (A check ... may not be necessary)
    if (iUnit < 1) | (iUnit > N)    continue;   end

    % Get sensor id, convert to a number from 1 to M
    id = allsensorids(index);
    iSensor = find(sensorgroup == id);

    hits(iUnit, iSensor) = 1;
end

IMGHEIGHT = size(Ibkgnd,1);
IMGWIDTH  = size(Ibkgnd,2);

% Create a figure window for the controls
scrsz = get(0,'ScreenSize');
figure('Position', ...
    [20 scrsz(4)-80 120 160])    % [left, bottom, width, height]

% Create some GUI buttons for playback
h1 = uicontrol('Style', 'pushbutton', ...
    'String', '< (reverse)',...
    'Position', [20 10 80 20], ...
    'Callback', 'if speed >=0 speed=-0.5; else speed=speed*2; end;');
h2 = uicontrol('Style', 'pushbutton', ...
    'String', '<< (step)',...
    'Position', [20 40 80 20], ...
    'Callback', 'speed = -1e-6;');
h3 = uicontrol('Style', 'pushbutton', ...
    'String', 'Stop',...
    'Position', [20 70 80 20], ...
    'Callback', 'speed=0;');
h4 = uicontrol('Style', 'pushbutton', ...
    'String', '>> (step)',...
    'Position', [20 100 80 20], ...
    'Callback', 'speed = 1e-6;');
h5 = uicontrol('Style', 'pushbutton', ...
    'String', '> (play)',...
    'Position', [20 130 80 20], ...
    'Callback', 'if speed <=0 speed=0.5; else speed=speed*2; end;');

% This is the speed of the playback:
%  Positive = forward, negative = backward
%  The value is the number of frames to advance
%  Fractional values allowed (means slow speed)
%  If value < 1e-5, then interpret this is as advance one frame then stop
speed = 1;

% Create a waterfall image
DT = 130;               % display +/- this time
Iwater = zeros(2*DT+1, M);

% This is the magnified waterfall image
MAG = 3;        % magnification
Iwatermag = uint8(zeros(MAG*size(Iwater,1), MAG*size(Iwater,2), 3));

% This is a composite image (background plus water)
Ishow = uint8(zeros(IMGHEIGHT, IMGWIDTH+5+size(Iwatermag,2)+5, 3));

% Load in background image and water image
Ishow(1:IMGHEIGHT, 1:IMGWIDTH, :) = Ibkgnd(:,:,:);
Ishow(1:size(Iwatermag,1), IMGWIDTH+5+1:IMGWIDTH+5+size(Iwatermag,2), :) = Iwatermag(:,:,:);
figure(2), imshow(Ishow, [], 'InitialMagnification', 80);

% % create avi file.  'Indeo5' seems to be best, but is not on Vista
 aviobj = avifile('mymovie.avi', ...
     'compression', 'None');
     %'fps', 5, ...
     %'keyframe', 0.05);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main (infinite) loop
iptsetpref('ImshowBorder','tight');
t = 1;        % This is the time index
while true
    if 0 < abs(speed) & abs(speed) <= 1e-6
        t = t + sign(speed);
    else
        t = t + speed;
    end

    if t < 1     t = 1;   end
    
    %if t > N     t = N;   end
    if t > N     break;   end   % use this to quit automatically (when making avi)

    iUnit = round(t);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create "waterfall" image
    t0 = iUnit-DT;          % start time index to display
    t1 = iUnit+DT;          % end time index to display
    LT = 2*DT+1;            % number of frames to display

    if t0<1
        n1 = 1-t0;          % number of zeros (no data)
        n2 = LT-n1;
        Iwater(1:n1,:) = zeros(n1, M);
        Iwater(n1+1:LT,:) = hits(1:t1,1:M);
    elseif t1>N
        n1 = t1-N;          % number of zeros (no data)
        n2 = LT-n1;
        Iwater(1:n2,:) = hits(t0:N,:);
        Iwater(n2+1:LT,:) = zeros(n1, M);
    else
        Iwater(:,:) = hits(t0:t1,:);
    end

    % Magnify waterfall image
    Iwm = uint8( imresize(255*Iwater, MAG) );
    Iwatermag(:,:,1) = Iwm(:,:);
    Iwatermag(:,:,2) = Iwm(:,:);
    Iwatermag(:,:,3) = Iwm(:,:);
    
    % Draw red line for current time
    Iwatermag(MAG*DT+1,:,1) = 255;
    Iwatermag(MAG*DT+1,:,2) = 0;
    Iwatermag(MAG*DT+1,:,3) = 0;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load background image and waterfall image
    Ishow(1:IMGHEIGHT, 1:IMGWIDTH, :) = Ibkgnd(:,:,:);
    Ishow(1:size(Iwatermag,1), IMGWIDTH+5+1:IMGWIDTH+5+size(Iwatermag,2), :) = Iwatermag(:,:,:);
    figure(2), imshow(Ishow, [], 'InitialMagnification', 80);
    
    % Draw blanksensors
    for i=1:size(xy,1)
        x0 = xy(i,1) + offsetx;
        y0 = xy(i,2) + offsety;

        rectangle('Curvature', [1 1], ...
            'Position', [x0-5 y0-5 10 10], ...
            'FaceColor', [0 0 1], ...
            'EdgeColor', [0 0 1]);
    end

    % Draw active sensors
    for i=1:M
        if hits(iUnit,i) > 0
            id = sensorgroup(i);
            iSensor = find(sensorlist == id);

            x0 = xy(iSensor,1) + offsetx;
            y0 = xy(iSensor,2) + offsety;

            rectangle('Curvature', [1 1], ...
                'Position', [x0-10 y0-10 20 20], ...
                'FaceColor', [1 0 0 ], ...
                'EdgeColor', [1 0 0 ]);
        end
    end

    % Print day and time on background image
    [day,dow] = weekday(starttime + iUnit*unitTime,'long');
    text(340,50,dow,'VerticalAlignment','middle',...
        'HorizontalAlignment','center',...
        'FontSize',12, 'Color', 'r');
    text(550,50,datestr(starttime + iUnit*unitTime), ...
        'VerticalAlignment','middle',...
        'HorizontalAlignment','center',...
        'FontSize',12, 'Color', 'r');
    % Also print frame number
    text(50,50,sprintf('%5d', iUnit),'VerticalAlignment','middle',...
        'FontSize',12, 'Color', 'r');
    
     frame = getframe(figure(2));       % grabs image from screen
     aviobj = addframe(aviobj,frame);        % add image to movie

    % Zero the speed if it is too low (or we are stepping)
    if abs(speed) <= 1e-6        speed = 0;    end

    pause(0.2);     % (seconds to pause) for GUI to respond
end

aviobj = close(aviobj);




