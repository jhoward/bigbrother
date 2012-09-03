% Plot correlations between sensors
clear all
close all

% Read background image
%Ibkgnd = imread('map_gray.tif');
%I = zeros(size(Ibkgnd,1),size(Ibkgnd,2));

% Scale and offset for sensor locations, on this map
offsetx = 115;
offsety = 4;
scalex = 1.0;
scaley = 1.0;

% import x,y locations of sensors
%sensorxy = xlsread('layout.xls', 'sensorxy', 'A2:B51');


% Read data
%   sensorlist(1..numsensors)  - an array of sensor ids
%   sensorcells{1..numsensors} - each cell is an array of hit times for each sensor
%   allsensorhits(1..numhits)  - a sorted array of hit times for all sensors
%   allsensorids(1..numhits)   - the sensor ids corresponding to the above
load mat/synthData.mat

% Only look for hits between these times
%starttime = datenum('02-02-2008 00:00:00');
%stoptime = datenum('02-05-2008 23:59:59');

starttime = datenum(beginTime);
stoptime = datenum(endTime);

% This is one second, in units of days
oneSec = (datenum('00:00:01') - datenum('00:00:00'));

% Create a table of x,y locations for each sensor index
% for i=1:length(sensorlist)
%     id = sensorlist(i);
%     xyId(id, 2) = sensorxy(i,2);
%     xyId(id, 1) = sensorxy(i,1);
% end


% Let's build a matrix that explicitly stores the hits (0 or 1) for each
% of the 50 sensors, at each second.  The matrix is
%   hits(1:N, 1:50)
% where N is the total number of seconds from start to stop time.
N = round( (stoptime - starttime)/oneSec );
%hits = uint8(zeros(N, 50));

% Go through list of all hits, and record entries in the hits matrix
indexHits = 0;
% for index=1:length(allsensorhits)
%     if allsensorhits(index) < starttime     continue; end
%     if allsensorhits(index) > stoptime      break;    end
%     
%     t0 = allsensorhits(index);  % Get the time at this index
%     
%     % Convert to number of seconds since the starttime
%     iSec = round( (t0-starttime)/oneSec );
%     
%     % (A check ... may not be necessary)
%     if (iSec < 1) | (iSec > N)    continue;   end
%     
%     % Get sensor id, convert to a number from 1 to 50
%     id = allsensorids(index);
%     iSensor = find(sensorlist == id);
%     
%     hits(iSec, iSensor) = 1;
% end
N
size(data)
hits = data(:, 2:size(data, 2));

% Build a correlation matrix that counts how many times a hit from sensor i
% co-occurs with a hit from sensor j, at a time offset of t seconds.  The 
% matrix is
%   C(1:50, 1:50, 0:T)
% where T is the maximum offset in seconds.  Actually, since Matlab wants
% to start indices at 1, we will have to do
%   C(1:50, 1:50, 1:T+1
T = 6;
C = zeros(size(hits, 2),size(hits, 2),T+1);

for t=0:T
    for iSec=1:N-t
        for i=1:size(hits, 2)
            if hits(iSec,i) == 1
                for j=1:size(hits, 2)
                    if hits(iSec+t,j)
                        C(i,j,t+1) = C(i,j,t+1) + 1;
                    end
                end
            end
        end
    end
end

C

% Display results of raw scores
% for t=0:T
%     subplot(1,T+1, t+1), imshow(C(:,:,t+1), []);
% end


% Compute correlation coefficient.  This is given by
%  rho = cov(X,Y)/sqrt( var(X)var(Y) )
% where
%  cov(X,Y) = E[ (X-uX)(Y-uY) ] = E[XY] - E[X}E[Y]
% and
%  var(X) = E[X^2] - E^2[X}, etc

for t=0:T
    for i=1:size(hits, 2)
        for j=1:size(hits, 2)
            EXY = C(i,j,t+1)/(N);
            EX = C(i,i,1)/(N);
            EX2 = EX;   % E[X^2} same as E[X} since X is 0 or 1
            EY = C(j,j,1)/(N);
            EY2 = EY;
            rho(i,j,t+1) = (EXY - EX*EY)/sqrt( (EX2-EX^2)*(EY2-EY^2) );
        end
    end
end

rho

fprintf(1, 'Searching\n');

for t = 0:T
    for i = 1:size(hits, 2)
        for j = 1:size(hits, 2)
            
            if abs(rho(i, j, t + 1)) > 1 && abs(rho(i, j, t + 1)) < inf
                
                i
                j
                t
                rho(i, j, t+1)
            end;
        end;
    end;
end;

% Display correlation coefficients as images
% figure;
% for t=0:T
%     subplot(1,T+1, t+1), imshow(rho(:,:,t+1), []);
% end

% % Draw lines between sensors i and j for high correlation scores.
% % We'll restrict them to i~=j, t>0
% for t=1:T
%     figure, imshow(Ibkgnd), title(sprintf('Time %d seconds', t));
%     drawblanksensors(sensorxy);
% 
%     for i=1:50
%         for j=1:50
%             if i ~= j & rho(i,j,t) > 0.15
%                 %fprintf('%d %d t=%d, r=%f\n', ...
%                 %    sensorlist(i), sensorlist(j), t, rho(i,j,t));
% 
%                 x1 = scalex*sensorxy(i,2) + offsetx;
%                 y1 = scaley*sensorxy(i,1) + offsety;
% 
%                 x2 = scalex*sensorxy(j,2) + offsetx;
%                 y2 = scaley*sensorxy(j,1) + offsety;
% 
%                 line( [x1 x2], [y1 y2], 'Color', 'r');
%             end
%         end
%     end
% end

% Create a matrix of highest correlation scores.  These indicate how
% neighborly two points are.  Ignore t=0.
% rhoMax = max(rho(:,:,1:T), [], 3);
% rhoMax = rhoMax .* (rhoMax>0.02);   % Threshold these scores
% 
% neighbors = rhoMax;
% 
% disp(neighbors);
% 
% save neighbors neighbors
% 
% % Draw lines between neighbors.
% % We'll restrict the analysis to sensors i~=j, and t>0
% figure, imshow(Ibkgnd);
% 
% for i=1:50    
%     for j=1:50
%         if i==j   continue;     end
%         if rhoMax(i,j) == 0 continue;   end
%         
%         % Draw a line between sensors i and j.  
%         mythickness = 8*rhoMax(i,j);
% 
%         x1 = scalex*sensorxy(i,2) + offsetx;
%         y1 = scaley*sensorxy(i,1) + offsety;
% 
%         x2 = scalex*sensorxy(j,2) + offsetx;
%         y2 = scaley*sensorxy(j,1) + offsety;
% 
%         line( [x1 x2], [y1 y2], ...
%             'Color', 'r', ...
%             'LineWidth', mythickness);
%     end
% end
% drawblanksensors(sensorxy);



