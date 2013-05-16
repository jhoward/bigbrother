%Aggregate Merl Data
clear all
dataLocation = './data/';

clc;

% Make a list of all file names.  Note curly brackets for cell array, to
% allow for strings of varying length in the array.
allFileNames = {
  % '0014.4F01.0000.4073.txt';
   '0014.4F01.0000.46E8.txt';
%     '0116.txt';
%     '0117.txt';
%     '0118.txt';
%     '0119.txt';
%     '0120.txt';
%     '0121.txt';
%     '0122.txt'
};

moteData = {};

%Typically takes about 10 minutes on a solidstate drive.
for n=1:length(allFileNames)
    fid = fopen(strcat(dataLocation, allFileNames{n}), 'r');
    if fid ~= -1
        fprintf('File %s \n', allFileNames{n});
    else
        error('can''t open file');
    end
    
    while ~feof(fid)
        
        useInt=true;

        %Get mote timestamp
        [moteTime] = fscanf(fid, '%s', 1);
        moteTime = str2num(moteTime); %#ok<*ST2NM>
        if (moteTime~=0) & (moteTime>100000)
            useInt=false;
            moteTime = datestr(datenum(moteTime/(86400*1000) + datenum(1970,1,1,-6,0,0)));
        end
        
        [eventType] = fscanf(fid, '%i', 1);
        if eventType==1
            eventType='Enter';
        end
        if eventType==2
            eventType='Exit ';
        end
        if eventType==20
            eventType='TIMEOUT';
        end
        if eventType==21
            eventType='JUMPS';
        end
        
        
        [eventExtra] = fscanf(fid, '%i', 1);
       if useInt==false
            fprintf(1,'%s *** %s *** %i\n',moteTime,eventType,eventExtra);
       else
            fprintf(1,'%i *** %s *** %i\n',moteTime,eventType,eventExtra);
       end
       
    end
    fprintf(1,'\n');
end

%  moteData(n) = datestr( datenum(moteTime/(86400*1000) + datenum(1970,1,1,-6,0,0)) )
     