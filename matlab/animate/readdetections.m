clear all
close all

alldetectiontimes = [];
allsensoridsdetections = [];
alldetections = [];
allscores = [];

disp('This program reads the detections in the text files and puts');
disp(' it into a Matlab .mat file');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We will create and write out the following data
%   sensorlist(1..numsensors)  - an array of sensor ids
%   alldetectiontimes(1..numhits)  - a sorted array of times for all detections
%   allsensoridsdetections(1..numhits)   - the sensor ids at the center of
%      the detection neighborhoods
%   alldetections(1..numhits)   - the ids of the detected patterns
%   allscores(1..numhits)   - the scores of the detected patterns

disp('Enter starting and dates, in the form yyyy-mm-dd HH:MM:SS.');
% startdate = input('Start date: ', 's');
startdate = '2010-01-01 00:00:00';
starttime = datenum(startdate, 'yyyy-mm-dd HH:MM:SS');
% enddate = input('End date: ', 's');
enddate = '2010-01-02 00:00:00';
endtime = datenum(enddate, 'yyyy-mm-dd HH:MM:SS');

% read sensor data
disp('Reading detections ...');
sensorcount = 0;
hittimes = zeros(1,1000000);        % preallocate a large array
detectionids = zeros(1,1000000);        % preallocate a large array
myscores = zeros(1,1000000);        % preallocate a large array
for i=1:10
    for j=1:5
        sensorid = 10*i + j-1;
        sensorcount = sensorcount+1;
        sensorlist(sensorcount) = sensorid;
        filename = sprintf('../data/generated/noise_less/detections/detections%d.txt', sensorid);
        fid = fopen(filename);
        if fid ~= -1
            fprintf('Reading file %s ...\n', filename);
            
            nHits = 0;
            while ~feof(fid)
                myindex = fscanf(fid, '%d', 1);     % Read and ignore leading index
                
                idPattern = fscanf(fid, '%d', 1);     % The pattern number
               
                score = fscanf(fid, '%f', 1);     % Score (strength) of pattern

                % Get rest of line as a string - this is date and time
                datetime = fgetl(fid);
                
                % Convert to datetime to #days since 1/1/0000
                t = datenum(datetime, 'yyyy-mm-dd HH:MM:SS');

                if t < starttime   continue;    end
                if t > endtime     break;       end
                
                nHits = nHits + 1;
                hittimes(nHits) = t;
                detectionids(nHits) = idPattern;
                myscores(nHits) = score;
            end
            fclose(fid);
            
            alldetectiontimes = [alldetectiontimes, hittimes(1:nHits)];
            allsensoridsdetections = [allsensoridsdetections; sensorlist(sensorcount)*ones(nHits,1)];
            alldetections = [alldetections, detectionids(1:nHits)];
            allscores = [allscores, myscores(1:nHits)];
        else
            fprintf('Hey - can''t open file %s!\n', filename);
        end
        
    end
end
disp('Done reading detections');

disp('Sorting times...');
[alldetectiontimes, IX] = sort(alldetectiontimes);
allsensoridsdetections = allsensoridsdetections(IX);
alldetections = alldetections(IX);
allscores = allscores(IX);

disp('Saving detections ...');
save detections sensorlist alldetectiontimes allsensoridsdetections alldetections allscores

