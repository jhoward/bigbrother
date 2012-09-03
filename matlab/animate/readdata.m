clear all
close all

allsensorhits = [];
allsensorids = [];

disp('This program reads the raw sensor data in the text files and puts');
disp(' it into a Matlab .mat file');

disp('Enter starting and dates, in the form yyyy-mm-dd HH:MM:SS.');
startdate = input('Start date: ', 's');
starttime = datenum(startdate, 'yyyy-mm-dd HH:MM:SS');
enddate = input('End date: ', 's');
endtime = datenum(enddate, 'yyyy-mm-dd HH:MM:SS');

% read sensor data
disp('Reading sensor data ...');
sensorcount = 0;
hittimes = zeros(1,1000000);        % preallocate a large array
for i=1:10
    for j=1:5
        sensorid = 10*i + j-1;
        sensorcount = sensorcount+1;
        sensorlist(sensorcount) = sensorid;
        filename = sprintf('../data/real/small/raw/sensor%d.txt', sensorid);
        fid = fopen(filename);
        if fid ~= -1
            fprintf('Reading file %s ...\n', filename);
            
            nHits = 0;
            while ~feof(fid)
                % Read and ignore leading index
                %Uncomment when using generated data
                %myindex = fscanf(fid, '%d', 1);
                
                %if isempty(myindex)
                %    break;
                %end
                
                % Get rest of line as a string - this is date and time
                datetime = fgetl(fid);
                
                % Convert to datetime to #days since 1/1/0000
                t = datenum(datetime, 'yyyy-mm-dd HH:MM:SS');

                if t < starttime   continue;    end
                if t > endtime     break;       end
                
                nHits = nHits + 1;
                hittimes(nHits) = t;
            end
            sensorcells{sensorcount} = hittimes(1:nHits);
            fclose(fid);
            
            allsensorhits = [allsensorhits, hittimes(1:nHits)];
            allsensorids = [allsensorids; sensorlist(sensorcount)*ones(nHits,1)];
        else
            fprintf('Hey - can''t open file %s!\n', filename);
            pause
        end
        
    end
end
disp('Done reading sensor data');

disp('Sorting sensor data...');
[allsensorhits, IX] = sort(allsensorhits);
allsensorids = allsensorids(IX);

disp('Saving sensor data ...');
save sensor_data sensorlist sensorcells allsensorhits allsensorids
