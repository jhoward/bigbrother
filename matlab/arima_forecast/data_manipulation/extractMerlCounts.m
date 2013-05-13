%Aggregate Merl Data
clear all

% This is number of day 1 
nDay1 = datenum('01/01/2008');

%if averagedays is 1, then compute the average day for that day of the week
%and save to data.
AVERAGEDAYS = 1;
superSampleAmount = 4; %value of one will keep data the same
blocksInDay = superSampleAmount * 24;

%dataLocation = 'C:\Users\JamesHoward\Documents\Dropbox\Projects\bigbrother\data\traffic\denver\';
dataLocation = '/Users/jahoward/Documents/Dropbox/Projects/bigbrother/data/building/merl/';

% Make a list of all file names.  Note curly brackets for cell array, to
% allow for strings of varying length in the array.
allFileNames = {
   {'0114.txt' '4503049'};
%     '0115.txt';
%     '0116.txt';
%     '0117.txt';
%     '0118.txt';
%     '0119.txt';
%     '0120.txt';
%     '0121.txt';
%     '0122.txt'
};

% Read text files and fill up the array D, size (d,365,24)
d = length(allFileNames); 
sensors = [];
rawData = [];

%Typically takes about 10 minutes on a solidstate drive.
for n=1:d
    fileName = allFileNames{n}{1};
    fileLen = str2num(allFileNames{n}{2}); %#ok<ST2NM>
    fileData = zeros(2, fileLen);
    fid = fopen(strcat(dataLocation, fileName), 'r');
    if fid ~= -1
        fprintf('File %s: ', fileName);
        sensors(n).fileName = fileName; %#ok<SAGROW>
    else
        error('can''t open file');
    end

    index = 1;
    
    while index <= fileLen
        % Each line has format: date, day, counts
        pDone = floor((index / fileLen) * 100) + 1;
        
        if mod(pDone, 5) == 0
            fprintf(1, '  %i', pDone);
        end
        inde
        
        %Get sensor number
        [sensNum, nc] = fscanf(fid, '%i', 1);
        if nc==0
            break;
        end
        
        %Get the time
        [sTime, nc] = fscanf(fid, '%s', 1);
        sTime = str2num(sTime);
        if nc==0
            break;
        end
        
        [eTime, nc] = fscanf(fid, '%s', 1);
        eTime = str2num(eTime);
        if nc==0
            break;
        end

        [~, nc] = fscanf(fid, '%s', 1);
        if nc==0
            break;
        end
        
        fileData(:, index) = [sensNum sTime];
        index = index + 1;
    end
    fprintf(1, '\n');
end

