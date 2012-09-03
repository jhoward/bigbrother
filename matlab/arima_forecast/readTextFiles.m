clear all
close all

% This is number of day 1 (the first day of 2010)
nDay1 = datenum('01/01/2010');

% Make a list of all file names.  Note curly brackets for cell array, to
% allow for strings of varying length in the array.
allFileNames = {
    '006G283P.txt';
    '006G283S.txt';
    '025A207P.txt';
    '025A207S.txt';
    %'044A2P.txt';
    %'044A2S.txt';
    '070A270P.txt';
    '070A270S.txt';
    '070A277P.txt';
    '070A277S.txt';
    '070A289P.txt';
    '070A289S.txt';
    %'076A10P.txt';
    %'076A10S.txt';
    %'083A66P.txt';
    %'083A66S.txt';
    %'225A9P.txt';
    %'225A9S.txt';
    %'270A39P.txt';
    %'270A39S.txt';
    %'285D238P.txt';
    %'285D238S.txt';
    %'470A0P.txt';
    %'470A0S.txt';
    %'470A15P.txt';
    %'470A15S.txt';
    %'470A24P.txt';
    %'470A24S.txt';
    };

%{
These are the corresponding locations:

044a	 2.24	 On SH 44, 104th Ave W/O Brighton Rd, Commerce City
076a	 10.47	 On I-76 Ne/O 88th Ave, Commerce City
270a	 0.39	 On I-270 Se/O York St, Commerce City
070a	 270.50	 On I-70 E/O SH 95, Sheridan Blvd, Denver
070a	 277.02	 On I-70 E/O Dahlia St, Denver
070a	 289.18	 On I-70 W/O SH 36, Air Park Rd, Aurora
225a	 9.90	 On I-225 S/O I-70, Aurora
025a	 207.99	 On I-25 S/O SH 6, 6th Ave, Denver
006g	 283.38	 On SH 6, 6th Ave W/O SH 88, Federal Blvd, Denver
470a	 0.00	 On SH 470 Nw/O SH 8, Morrison Rd, Morrison
470a	 15.44	 On SH 470 Nw/O SH 85, Santa Fe Dr, Littleton
470a	 24.14	 On SH 470 E/O Quebec St, Lone Tree
083a	 66.56	 On SH 83, Parker Rd S/O Quincy Ave, Aurora
285d	 238.78	 On SH 285 Se/O North Turkey Creek Rd

In addition, there were two other locations that had incomplete counts:
036b	 43.20	 On SH36 Se/O Sh 170, Mccaslin Blvd, Superior
036b	 48.04	 On SH 36 Se/O SH 121, Wadsworth Pkwy, Broomfield
%}
    
    
% Read text files and fill up the array D, size (d,365,24)
d = length(allFileNames);     % Number of sensors
D = zeros(d,365,24);

for n=1:d
    
    fileName = allFileNames{n};
    fid = fopen(fileName, 'r');
    if fid ~= -1
        fprintf('File %s: ', fileName);
    else
        error('can''t open file');
    end
            
    nDaysRead = 0;      % Just out of curiousity, count #days read
    
    while ~feof(fid)
        % Each line has format: date, day, counts
        
        [szDate, nc] = fscanf(fid, '%s', 1); % Get date in the form mm/dd/yyyy
        if nc==0
            break;
        end
        
        % Print the date if it is the first one in the file
        if nDaysRead == 0
            fprintf('%s - ', szDate);
        end
        
        % Convert date into the day of the year (1..365)
        nDay = datenum(szDate) - nDay1 + 1;
        
        % Get day of week (3 letters) and ignore
        [szDay,nc] = fscanf(fid, '%s', 1);
        if nc==0
            error('can''t read day of week');
        end
        
        % Get counts for each hour
        [data,nc] = fscanf(fid, '%d', 24);
        if nc~=24
            error('did''t read 24 hour counts');
        end
        
        % Read and discard sum of the counts for this day
        [junk,nc] = fscanf(fid, '%d', 1);
        if nc~=1
            error('did''t read summary counts');
        end
        
        D(n,nDay,:) = data;
        nDaysRead = nDaysRead + 1;
    end
    fclose(fid);
    
    fprintf('%s, %d days total\n', szDate, nDaysRead);
end


% Let's also make an array that holds the day number for each day of the
% year.  In Matlab, these are defined as the number of days since 
%  'Jan-1-0000 00:00:00'
dayNums = 0:364;
dayNums = dayNums + nDay1;


save countData allFileNames D dayNums


