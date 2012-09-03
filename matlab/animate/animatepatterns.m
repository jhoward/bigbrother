% Animate patterns on the map
clear all
close all

disp('This program animates patterns centered at a certain sensor.');

warning off all    % disable warnings about displaying large images

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read data
%   sensorlist(1..numsensors)  - an array of sensor ids
%   sensorcells{1..numsensors} - each cell is an array of hit times for each sensor
%   allsensorhits(1..numhits)  - a sorted array of hit times for all sensors
%   allsensorids(1..numhits)   - the sensor ids corresponding to the above
%load sensor_data_09_10_07_to_12_31_07.mat
load ../data/sensor_data_01_01_08_to_06_09_08.mat

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read data
%  neighbors{1..numsensors} - each cell is an array of sensor ids
%   where the sensors are neighbors (the first id is the center)
load ../data/neighbors.mat

% Read background image
Ibkgnd = imread('../data/map_color.bmp');

% import x,y locations of sensors (in pixels)
xy = xlsread('../data/layout.xls', 'sensorxy', 'A2:B51');

% Add this offset to sensor positions
offsetx = 115;
offsety = 4;


disp('What sensor do you want to show the patterns for?');
idSensor = input('Give the id (from 10 to 104: ');

index = find(sensorlist == idSensor);     % get corresponding index 1..50
sensorgroup = neighbors{index};
fprintf('Neighborhood at this sensor:  '), disp(sensorgroup);

% Get the patterns to be detected.  The patterns should be stored in the folder
% "patterns".  There is a file for each sensor, with the name "sensor[id].mat".
filename = sprintf('../patterns/patterns%d.mat', idSensor);
if exist(filename, 'file') == 0
    fprintf('Hey!  Can''t read file %s\n', filename);
    pause;
end

% This loads in the patterns to be detected:  patterns(K,T,S)
load(filename);
[K,T,S] = size(patterns);

cmap = colormap('hot');

for k=1:K
    w = squeeze(patterns(k, :, :));
    figure(1), subplot(1,K,k), imshow(w, [0 1], 'InitialMagnification', 800), pause(0.1);
    colormap('hot');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Animate the pattern
    fprintf('Animating pattern %d\n', k);

%     % create avi file.  'Indeo5' seems to be best, but is not on Vista
%     aviobj = avifile(sprintf('sensor%dpattern%d.avi', idSensor, k), ...
%         'compression', 'Cinepak', ...
%         'fps', 1, ...
%         'keyframe', 0.05);

    for t=1:T
        figure(3), imshow(Ibkgnd,[]);

        text(400,50,sprintf('Pattern %d, t=%d', k, t),'VerticalAlignment','middle',...
            'FontSize',12, 'Color', 'r');

        % Draw blanksensors
        for i=1:size(xy,1)
            x0 = xy(i,2) + offsetx;
            y0 = xy(i,1) + offsety;

            rectangle('Curvature', [1 1], ...
                'Position', [x0-5 y0-5 10 10], ...
                'FaceColor', [0 0 1], ...
                'EdgeColor', [0 0 1]);
        end

        if t==1     pause;   end

        for s=1:S
            id = sensorgroup(s);
            iSensor = find(sensorlist == id);

            x0 = xy(iSensor,2) + offsetx;
            y0 = xy(iSensor,1) + offsety;

            activityLevel = patterns(k,t,s);

            % activityLevel ranges from 0..1, this should be mapped to
            % 1..length(cmap)
            myindex = 1 + round( activityLevel*(length(cmap)-1));

            rectangle('Curvature', [1 1], ...
                'Position', [x0-10 y0-10 20 20], ...
                'FaceColor', cmap(myindex,:));
        end

        frame = getframe;       % grabs image from screen
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % If you are creating a movie, uncomment the next line
        %aviobj = addframe(aviobj,frame);        % add image to movie
        % Else if you are saving individual images, uncomment the next line
        A = frame2im(frame);  imwrite(A, sprintf('s%dp%dt%d.tif', idSensor, k,t));
        
        pause(1);
    end

%     aviobj = close(aviobj);
end
