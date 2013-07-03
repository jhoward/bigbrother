%Aggregate Merl Data
clear all

%dataLocation = 'C:\Users\JamesHoward\Documents\Dropbox\Projects\bigbrother\data\building\merl\data\';
dataLocation = '/Users/jahoward/Documents/Dropbox/Projects/bigbrother/data/building/merl/data/';

% Make a list of all file names.  Note curly brackets for cell array, to
% allow for strings of varying length in the array.
allFileNames = {
   {'0114.txt' '4503049'};
   {'0115.txt' '9553016'};
   {'0116.txt' '7543803'};
   {'0117.txt' '5918874'};
   {'0118.txt' '6353157'};
   {'0119.txt' '5730246'};
   {'0120.txt' '6023688'};
   {'0121.txt' '6437525'};
   {'0122.txt' '1165745'};
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
        fprintf('File %s (%i)', fileName, fileLen);
        sensors(n).fileName = fileName; %#ok<SAGROW>
    else
        error('can''t open file');
    end

    index = 1;
    
    while index <= fileLen
        % Each line has format: date, day, counts
        if mod(index, 100000) == 0
            fprintf(1, '  %i', floor(index / 100000));
        end
        
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
    rawData = [fileData];
end

sensors = unique(rawData(1, :));
times = datenum(rawData(2, :)/86400/1000 + datenum(1970,1,1));

savefile = './data/merlDataRaw.mat';
%savefile = 'merlDataRaw.mat';
save(savefile, 'rawData', 'sensors', 'times');

