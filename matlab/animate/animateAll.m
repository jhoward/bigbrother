% Plots an animation of the sensor hits on the map.
% Also shows a "waterfall" display of all the hits
% Also shows any detected patterns.
%  Bill Hoff   February 2010
clear all
close all

% Outline of program:
%
% Read background image, sensor locations
% 
% Set up user interface
% 
% while true
%   allow user to change data filenames
%   pause till they hit read

% Read raw sensor data (mat file)
% Read raw detections data (mat file)
%
% while true
%   allow user to change starttime, endtime of data
%   pause till they hit load

% Extract data from starttime to endtime
% 
% while true
% 	allow user to change play starttime, play endtime, speed
% 	pause till they hit go
% 
% 	t = playstarttime
% 	while t < playendtime
% 		create waterfall image, load it
% 		load background image
% 		draw blanksensors
% 		draw active sensors
% 		print day/time, frame number
% 		t = t + speed
% 	end
% end

%% Read data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read background image
Ibkgnd = imread('simulation/images/map_color.bmp');
%Ibkgnd = zeros(size(Ibkgnd));      % uncomment if you want black bkgnd

% import x,y locations of sensors (in pixels)
xy = xlsread('simulation/layouts/xysensor.xls');

% Add this offset to sensor positions
offsetx = 115;
offsety = 4;

% Default names for data files
filenameSensorData = '../data/generated/noise_all/sensor_data.mat';
filenameDetectionData = 'detections.mat';


% This is the basic unit of time, in units of days
unitTime = (datenum('00:00:02') - datenum('00:00:00'));


%% Set up user interface

% This is the speed of the playback:
%  Positive = forward, negative = backward
%  The value is the number of frames to advance
%  Fractional values allowed (means slow speed)
speed = 1;

fRead = false;    % True if files have been read in


% Create a figure window for the controls
scrsz = get(0,'ScreenSize');
figure('Position', ...
    [20 scrsz(4)-80 400 370])    % [left, bottom, width, height]

% Create some GUI controls
uicontrol('Style', 'text', ...
    'String', 'Sensor data file',...
    'Position', [20 343 100 15]);
h9 = uicontrol('Style', 'edit', ...
    'String', filenameSensorData,...
    'Position', [25 313 350 30], ... 
    'Callback', 'filenameSensorData = get(h9,''String'');');
uicontrol('Style', 'text', ...
    'String', 'Detections data file',...
    'Position', [20 283 100 15]);
h10 = uicontrol('Style', 'edit', ...
    'String', filenameDetectionData,...
    'Position', [25 253 350 30], ...
    'Callback', 'filenameDetectionData = get(h10,''String'');');
h11 = uicontrol('Style', 'pushbutton', ...
    'String', 'Read', ...
    'Position', [20 220 40 20], ...
    'Callback', 'fRead = true;');

uicontrol('Style', 'text', ...
    'String', 'Data start date time',...
    'Position', [20 200 140 15]);
h7 = uicontrol('Style', 'edit', ...
    'String', '2010-01-01 00:00:00',...
    'Position', [170 193 180 30], ...
    'Callback', 'startdateData = get(h7,''String''); ');
uicontrol('Style', 'text', ...
    'String', 'Data end date time',...
    'Position', [20 160 140 15]);
h8 = uicontrol('Style', 'edit', ...
    'String', '2010-01-02 00:00:00',...
    'Position', [170 153 180 30], ...
    'Callback', 'enddateData = get(h8,''String''); ');
h6 = uicontrol('Style', 'pushbutton', ...
    'String', 'Load', ...
    'Position', [20 130 40 20], ...
    'ForegroundColor', [0.5 0.5 0.5], ...
    'Callback', 'fLoad = true;');

uicontrol('Style', 'text', ...
    'String', 'Play start date time',...
    'Position', [20 110 140 15]);
h1 = uicontrol('Style', 'edit', ...
    'String', '2010-01-01 00:00:00',...
    'Position', [170 100 180 30], ...
    'Callback', 'startdatePlay = get(h1,''String''); ');
uicontrol('Style', 'text', ...
    'String', 'Play end date time',...
    'Position', [20 75 140 15]);
h2 = uicontrol('Style', 'edit', ...
    'String', '2010-01-02 00:00:00',...
    'Position', [170 65 180 30], ...
    'Callback', 'enddatePlay = get(h2,''String''); ');
uicontrol('Style', 'text', ...
    'String', 'Speed',...
    'Position', [20 43 40 15]);
h3 = uicontrol('Style', 'text', ...
    'String', sprintf('%.1f',speed), ...
    'Position', [65 43 40 15]);
h4 = uicontrol('Style', 'slider', ...
    'Min', 0.0, 'Max', 10.0, 'Value', speed, ...
    'Position', [130 40 120 20], ...
    'Callback', 'speed = get(h4,''Value'')^2; set(h3, ''String'', sprintf(''%.1f'',speed));');
h5 = uicontrol('Style', 'pushbutton', ...
    'String', 'Go', ...
    'Position', [20 10 40 20], ...
    'ForegroundColor', [0.5 0.5 0.5], ...
    'Callback', 'fGo = true;');
uicontrol('Style', 'text', ...
    'String', 'Set speed to zero to stop',...
    'Position', [80 13 180 15]);


%% Allow user to specify filenames

while ~fRead
    pause(0.1);
end

% Make "read" button gray (inactive) color
set(h11, 'ForegroundColor', [0.5 0.5 0.5]);
pause(0.1);


%% Read raw sensor data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read sensor data.  This is what will be loaded:
%   sensorlist(1..numsensors)  - an array of sensor ids
%   sensorcells{1..numsensors} - each cell is an array of hit times for each sensor
%   allsensorhits(1..numhits)  - a sorted array of hit times for all sensors
%   allsensorids(1..numhits)   - the sensor ids corresponding to the above
fprintf('Reading in sensor data from %s...\n', filenameSensorData);
load(filenameSensorData);

[day,dow] = weekday(allsensorhits(1),'long');
fprintf('\nEarliest sensor hit is from sensor %d on %s %s\n', ...
    allsensorids(1), dow, datestr(allsensorhits(1)));
[day,dow] = weekday(allsensorhits(end),'long');
fprintf('Latest sensor hit is from sensor %d on %s %s\n', ...
    allsensorids(end), dow, datestr(allsensorhits(end)));


%% Read raw detections data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read detection data.  This is what will be loaded:
%   sensorlist(1..numsensors)  - an array of sensor ids
%   alldetectiontimes(1..numhits)  - a sorted array of times for all detections
%   allsensoridsdetections(1..numhits) - the sensor ids at the center of
%      the neighborhoods
%   alldetections(1..numhits)   - the ids of the detected patterns
%   allscores(1..numhits)   - the scores of the detected patterns

fprintf('Reading in detections data from %s...\n', filenameDetectionData);
%load(filenameDetectionData);

%[day,dow] = weekday(allsensorhits(1),'long');
%fprintf('\nEarliest detection is centered at sensor %d on %s %s\n', ...
%    allsensoridsdetections(1), dow, datestr(alldetectiontimes(1)));
%[day,dow] = weekday(allsensorhits(end),'long');
%fprintf('Latest detection is centered at sensor %d on %s %s\n', ...
%    allsensoridsdetections(end), dow, datestr(alldetectiontimes(end)));


%% Display map and waterfall image

% We are only interested in this group of sensors
%sensorgroup = [ 43 44 50 51 52 53 ];
%sensorgroup = [ 90 93 94 100 101 102 104];
sensorgroup = sensorlist;
M = length(sensorgroup);         % number of sensors

IMGHEIGHT = size(Ibkgnd,1);
IMGWIDTH  = size(Ibkgnd,2);

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


%% Allow user to specify data start and end dates to be loaded

fLoad = false;    % True if data has been loaded
set(h6, 'ForegroundColor', 'k');    % Make "load" button regular color


% Default startdate and enddate, for data to be loaded.
% Dates should have the form  yyyy-mm-dd HH:MM:SS
starttimeData = allsensorhits(1);
startdateData = datestr(allsensorhits(1), 'yyyy-mm-dd HH:MM:SS');
% Add some days to the state date
endtimeData = starttimeData + 10;
enddateData = datestr(endtimeData, 'yyyy-mm-dd HH:MM:SS');

set(h7, 'String', startdateData);
set(h8, 'String', enddateData);

while ~fLoad
    try
        starttimeData = datenum(startdateData, 'yyyy-mm-dd HH:MM:SS');
    catch
        % Invalid start date string; restore to default
        startdateData = datestr(allsensorhits(1), 'yyyy-mm-dd HH:MM:SS');
        starttimeData = datenum(startdateData, 'yyyy-mm-dd HH:MM:SS');
        set(h7, 'String', startdateData);
    end

    if starttimeData < allsensorhits(1)     % can't be before first record
        starttimeData = allsensorhits(1);
        startdateData = datestr(starttimeData, 'yyyy-mm-dd HH:MM:SS');
        set(h7, 'String', startdateData);
    end
    if starttimeData >= allsensorhits(end)     % can't be after last record
        starttimeData = allsensorhits(end)-1;
        startdateData = datestr(starttimeData, 'yyyy-mm-dd HH:MM:SS');
        set(h7, 'String', startdateData);
    end
    
    try
        endtimeData = datenum(enddateData, 'yyyy-mm-dd HH:MM:SS');
    catch
        % Invalid end date string; restore to default
        endtimeData = starttimeData + 10;
        enddateData = datestr(endtimeData, 'yyyy-mm-dd HH:MM:SS');
        set(h8, 'String', enddateData);
    end
    
    if endtimeData <= starttimeData     % can't be before start
        endtimeData = starttimeData+10;
        enddateData = datestr(endtimeData, 'yyyy-mm-dd HH:MM:SS');
        set(h8, 'String', enddateData);
    end
    if endtimeData > allsensorhits(end)     % can't be after last record
        endtimeData = allsensorhits(end);
        enddateData = datestr(endtimeData, 'yyyy-mm-dd HH:MM:SS');
        set(h8, 'String', enddateData);
    end
    if endtimeData > starttimeData+14      % don't load too much at once
        endtimeData = starttimeData+14;
        enddateData = datestr(endtimeData, 'yyyy-mm-dd HH:MM:SS');
        set(h8, 'String', enddateData);
    end
    pause(0.1);
end

% Make "load" button gray (inactive) color
set(h6, 'ForegroundColor', [0.5 0.5 0.5]);
pause(0.1);


%% Extract the portion of the data that we are interested in

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Let's build a matrix that explicitly stores the hits (0 or 1) for each
% of the above sensors, at each unit of time.  The matrix is
%   hits(1:N, 1:M)
% where N is the total number of time units from start to stop time.
N = round( (endtimeData - starttimeData)/unitTime );
hits = uint8(zeros(N, M));

% Go through list of all hits, and record entries in the hits matrix
indexHits = 0;
for index=1:length(allsensorhits)
    if allsensorhits(index) < starttimeData     continue; end
    if allsensorhits(index) > endtimeData      break;    end

    t0 = allsensorhits(index);  % Get the time at this index

    % Convert to number of time units since the starttime
    iUnit = round( (t0-starttimeData)/unitTime );

    % (A check ... may not be necessary)
    if (iUnit < 1) | (iUnit > N)    continue;   end

    % Get sensor id, convert to a number from 1 to M
    id = allsensorids(index);
    iSensor = find(sensorgroup == id);

    hits(iUnit, iSensor) = 1;
end

% Don't need these anymore ... get rid of before we run out of memory
clear allsensorhits sensorcells allsensorids

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Let's build a matrix that explicitly stores the detections at each 
% % unit of time.  The matrix is 
% %   hits(1:N, 1:M)
% % where N is the total number of time units from start to stop time.
% %   hits(t,s) is the detection id at sensor s at time t (0 is no detection)
% N = round( (endtimeData - starttimeData)/unitTime );
% detections = uint8(zeros(N, M));
% scores = zeros(N, M);
% 
% % Go through list of all detections, and record entries in the matrix
% indexDetections = 0;
% for index=1:length(alldetectiontimes)
%     if alldetectiontimes(index) < starttimeData     continue; end
%     if alldetectiontimes(index) > endtimeData      break;    end
% 
%     t0 = alldetectiontimes(index);  % Get the time at this index
% 
%     % Convert to number of time units since the starttime
%     iUnit = round( (t0-starttimeData)/unitTime );
% 
%     % (A check ... may not be necessary)
%     if (iUnit < 1) | (iUnit > N)    continue;   end
% 
%     % Get sensor id, convert to a number from 1 to M
%     id = allsensoridsdetections(index);
%     iSensor = find(sensorgroup == id);
% 
%     detections(iUnit, iSensor) = alldetections(index);
%     scores(iUnit, iSensor) = allscores(index);
% end

    
% These are the nominal start and end times of the play sequence.
startdatePlay = startdateData;
starttimePlay = datenum(startdatePlay, 'yyyy-mm-dd HH:MM:SS');
endtimePlay = starttimePlay + datenum('00:01:00')-datenum('00:00:00');
enddatePlay = datestr(endtimePlay, 'yyyy-mm-dd HH:MM:SS');


%% Main (infinite) loop
%iptsetpref('ImshowBorder','tight');

aviobj = avifile('movie.avi','compression','None');

while true
   
    set(h5, 'ForegroundColor', 'k');    % Make "go" button regular color
    fGo = false;    % True if playback is running

    % Let user fiddle with play start and stop time
    set(h1, 'String', startdatePlay);
    set(h2, 'String', enddatePlay);
    while ~fGo
               
        try
            starttimePlay = datenum(startdatePlay, 'yyyy-mm-dd HH:MM:SS');
        catch
            % Invalid start play string; restore to default
            startdatePlay = startdateData;
            starttimePlay = datenum(startdatePlay, 'yyyy-mm-dd HH:MM:SS');
            set(h1, 'String', startdatePlay);
        end
        
        try
            endtimePlay = datenum(enddatePlay, 'yyyy-mm-dd HH:MM:SS');
        catch
            % Invalid end play string; restore to default
            endtimePlay = starttimePlay + datenum('00:01:00')-datenum('00:00:00');
            enddatePlay = datestr(endtimePlay, 'yyyy-mm-dd HH:MM:SS');
            set(h2, 'String', enddatePlay);
        end
        
        if starttimePlay < starttimeData
            starttimePlay = starttimeData;
            startdatePlay = startdateData;
            set(h1, 'String', startdatePlay);
        end
        if endtimePlay > endtimeData
            endtimePlay = endtimeData;
            enddatePlay = enddateData;
            set(h2, 'String', enddatePlay);
        end
        if endtimePlay < starttimePlay
            endtimePlay = starttimePlay + datenum('00:01:00')-datenum('00:00:00');
            enddatePlay = datestr(endtimePlay, 'yyyy-mm-dd HH:MM:SS');
            set(h2, 'String', enddatePlay);
        end
        pause(0.1);
    end

    % Make "go" button gray (inactive) color
    set(h5, 'ForegroundColor', [0.5 0.5 0.5]);
    fGo = false;

    % Get number of time units since the starttimeData
    t =(starttimePlay-starttimeData)/unitTime + 1;

    while true
        if t > (endtimePlay-starttimeData)/unitTime   break;   end

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
            x0 = xy(i,2) + offsetx;
            y0 = xy(i,1) + offsety;

            rectangle('Curvature', [1 1], ...
                'Position', [x0-5 y0-5 10 10], ...
                'FaceColor', [0 0 1], ...
                'EdgeColor', [0 0 1]);
            text(x0+6,y0+6, ...
                sprintf('%d', sensorgroup(i)), ...
                'FontSize',7, 'Color', 'b');
        end

        % Draw active sensors
        for i=1:M
            if hits(iUnit,i) > 0
                id = sensorgroup(i);
                iSensor = find(sensorlist == id);

                x0 = xy(iSensor,2) + offsetx;
                y0 = xy(iSensor,1) + offsety;

                rectangle('Curvature', [1 1], ...
                    'Position', [x0-7 y0-7 14 14], ...
                    'FaceColor', [1 0 0 ], ...
                    'EdgeColor', [1 0 0 ]);
            end
        end

%         % Draw detections
%         for i=1:M
%             if detections(iUnit,i) > 0
%                 id = sensorgroup(i);
%                 iSensor = find(sensorlist == id);
% 
%                 x0 = xy(iSensor,2) + offsetx;
%                 y0 = xy(iSensor,1) + offsety;
%                 
%                 % Higher scores -> rectangles more bold
%                 mylinewidth = 3.0*scores(iUnit,i);
%                 mycolor = [ 0 0.8 0 ];
%                 rectangle('Curvature', [0.5 0.5], ...
%                     'Position', [x0-25 y0-25 50 50], ...
%                     'LineWidth', mylinewidth, ...
%                     'EdgeColor', mycolor);
%                 
%                 text(x0-12,y0+12, ...
%                     sprintf('%d', detections(iUnit,i)), ...
%                     'FontSize',8, 'Color', [0 0.8 0 ]);
%             end
%         end
        
        % Print day and time on background image
        [day,dow] = weekday(starttimeData + iUnit*unitTime,'long');
        text(340,50,dow,'VerticalAlignment','middle',...
            'HorizontalAlignment','center',...
            'FontSize',12, 'Color', 'r');
        text(550,50,datestr(starttimeData + iUnit*unitTime, 'yyyy-mm-dd HH:MM:SS'), ...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','center',...
            'FontSize',12, 'Color', 'r');
        % Also print frame number
        text(50,50,sprintf('%5d', iUnit),'VerticalAlignment','middle',...
            'FontSize',12, 'Color', 'r');

        t = t + speed;
        if speed == 0   break;  end
        
        pause(0.01);     % seconds to pause
        
        F = getframe(figure(2));
        aviobj = addframe(aviobj,F);
    end

end

aviobj = close(aviobj);


