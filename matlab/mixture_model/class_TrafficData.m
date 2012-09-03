classdef class_TrafficData < handle
    % Holds all information about the traffic data.
    
    properties
        % Sensor names for each of the dimensions (cell array)
        sensorNames     % number of sensors is also number of dimensions
        
        % Raw data counts, size (d,nDays,24)
        Dcounts    
        
        % These are the day numbers, size (nDays).  In Matlab, day numbers
        % are the number of days since 01-01-0000.
        dNums
        
        % Data points, size (d,m) where d=dimensions, m=number of points
        xIn
        
        % These are the day numbers for each point in xIn.  Size (24*nDays)
        xDayNums
        
        % Scaled data points, such that the range is 0..M-1
        x
        
        % Scaling information for each dimension
        dMin, dMax      % min, max value along each dimension
        dScale
            
        % This is the averaged counts for each hour of each day of the
        % week, size (d,7,24)
        Dweek
    end
    
    methods
        %%%%%%%%%%%%%%
        % Constructor
        function obj = class_TrafficData(szDirectory,M)
            % Read traffic data from the give directory.
            szFileName = sprintf('%s/countData.mat', szDirectory);
            
            % Load in count data.  Should be in these variables:
            %  allFileNames - cell array, 1..d
            %  D - count data, size (d,365,24)
            %  dayNums - number of each day of the year (size 1..365)
            load(szFileName);
            
            % Number of sensors (this will be the #dimensions of our datapoints)
            d = length(allFileNames);
            obj.sensorNames = allFileNames;  % these are our sensors
            
            % Ok, let's eliminate those days where some of the sensors weren't working.
            % If any of the sensors 1..d have zero counts for a day, eliminate that
            % day.
            goodDays = [];      % these will be the valid days, in the range 1..365
            for iDay=1:365
                [minVal, indices] = min(D(:,iDay,:));
                if minVal == 0
                    % One of the sensors has a zero count for that day
                    %         fprintf('Day %d (%s)has a zero count', iDay, ...
                    %             datestr(dayNums(iDay), 'mmm dd yyyy') );
                    %         fprintf(' sensor(s): '); disp(indices(:,1,1));
                else
                    goodDays = [goodDays iDay];
                end
            end
            nGoodDays = length(goodDays);
            fprintf('We have %d good days left in the year\n', nGoodDays);
            
            % Compress count data to eliminate bad days
            obj.Dcounts = D(:,goodDays,:);
            obj.dNums = dayNums(goodDays);
            
            % Ok, now reformat the counts to make array xIn, size(d,m).
            % Horizontally, the data will be:
            %  hour1,day1 ... hour24,day1, hour1,day2 ... hour24,day2, ...
            m = nGoodDays*24;
            obj.xIn = zeros(d,m);
            for iDay=1:nGoodDays
                for n=1:d
                    i = (iDay-1)*24 + 1;    % starting index
                    obj.xIn(n,i:i+23) = obj.Dcounts(n,iDay,:);
                    
                    % Also save the day number for each point in xIn
                    obj.xDayNums(i:i+23) = obj.dNums(iDay) + (0:23)/24;
                end
            end
            
            % Transform data so that each dimension spans range 0..M-1
            obj.dMin = min(obj.xIn,[],2);     % minimum value along each dimension
            obj.dMax = max(obj.xIn,[],2);     % maximum value along each dimension
            obj.dScale = (M-1) ./ (obj.dMax-obj.dMin);  % scale factor to apply to each dimension

            % Subtract off dMin from each dimension, then multiply each dimension by
            % dScale, then finally round to integer.
            obj.x = round( (obj.xIn-repmat(obj.dMin,1,m)) .* repmat(obj.dScale,1,m) );
            
%{
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Let's compute the pmf for each hour of each
            % day of the week.
            keyboard
            obj.Dweek = zeros(M,7,24);
            for i=1:m
                % Get the hour (0..23) of this point
                h = mod(i,24);  $$$$$$$$$$$$$$$$$$
                
                % Get the day of the week (1..7)
                dowString = datestr(obj.xDayNums(i), 'ddd');
                switch dowString
                    case 'Sun'
                        dow = 1;
                    case 'Mon'
                        dow = 2;
                    case 'Tue'
                        dow = 3;
                    case 'Wed'
                        dow = 4;
                    case 'Thu'
                        dow = 5;
                    case 'Fri'
                        dow = 6;
                    case 'Sat'
                        dow = 7;
                end
                
                for n=1:d
                    v = obj.x(n,i);     % Get count
                    obj.Dweek(v+1, dow, h+1) = obj.Dweek(n+1, dow, h+1)+1;
                end
            end

            % Normalize so that each column sums to 1
            for dow=1:7
                for h=0:23
                    obj.Dweek(:, dow, h+1) = obj.Dweek(:, dow, h+1) / ...
                        sum(obj.Dweek(:, dow, h+1));
                end
            end
%}            
                
        end  % end constructor
 
        
        function AnalyzeResults(obj,w,pmf,px)
            d = size(obj.x,1);      % Number of dimensions
            m = size(obj.x,2);      % Number of points
            k = size(w,1);          % Number of activities
            
            % This holds the estimated activity at each time
            a = zeros(size(obj.x,2),1);
            
            % Print hour across the top
            fprintf('ddd mmm dd yyyy: ');
            for ih=0:23
                fprintf('%2d ', ih);
            end
            fprintf('\n');
            
            for iDay = 1:length(obj.dNums)
                fprintf('%s: ', datestr(obj.dNums(iDay), 'ddd mmm dd yyyy') );
                i = (iDay-1)*24 + 1;    % index into x
                
                for ih=0:23
                    [~,j] = max(w(:,i+ih));
                    fprintf('%2d ', j);
                    a(i+ih) = j;
                end
                fprintf('\n');
            end
            
            % Look at autocorrelation scores from activity j1 to j2
            aScores = zeros(k,k);
            for i=2:m
                % Make sure there is less than one day between i-1 and i
                if obj.xDayNums(i) - obj.xDayNums(i-1) < 1
                    j1 = a(i-1);
                    j2 = a(i);
                    aScores(j1,j2) = aScores(j1,j2) + 1;
                end
            end
            fprintf('\nAutocorrelation counts:\n   ');
            for j=1:k
                fprintf(' %3d', j); % Print activity # across top
            end
            fprintf('\n');
            for j1=1:k
                fprintf('%2d:', j1);
                for j2=1:k
                    fprintf(' %3d', aScores(j1,j2));
                end
                fprintf('\n');
            end  
                
            % Display unusual (low probability) points
            [~, indSorted] = sort(px,'ascend');
            fprintf('\nLowest probability points:\n');
            for ind=1:10
                i = indSorted(ind);
                fprintf('\nPoint %d, log(p)=%f, date %s:\n', i, px(i), ...
                    datestr(obj.xDayNums(i), 'ddd mmm dd yyyy  HH:MM:SS'));
                
                % Display best match
                [wSorted,indicesSorted] = sort(w(:,i), 'descend');
                j1 = indicesSorted(1);
                fprintf('  activity %2d, p=%f\n', j1, wSorted(1));
                
                figure(3);
                P = pmf(:,:,j1);
                RGB(:,:,1) = P/2;  RGB(:,:,2) = P/2; RGB(:,:,3) = P/2;
                % Draw actual counts into the image
                for n=1:size(obj.x,1)
                    v = obj.x(n,i);     % The count
                    RGB(v+1,n,1) = RGB(v+1,n,1)+0.5;
                end
                subplot(1,2,1), imshow(RGB);
                title(sprintf('%d (%.2f)', j1, wSorted(1) ));

%{
                % Display pmf of typical hour
                % Get the hour (0..23)
                h = mod(i,24);
                
                % Get the day of the week (1..7)
                dowString = datestr(obj.xDayNums(i), 'ddd');
                switch dowString
                    case 'Sun'
                        dow = 1;
                    case 'Mon'
                        dow = 2;
                    case 'Tue'
                        dow = 3;
                    case 'Wed'
                        dow = 4;
                    case 'Thu'
                        dow = 5;
                    case 'Fri'
                        dow = 6;
                    case 'Sat'
                        dow = 7;
                end
                P = obj.Dweek(:,dow,h);
                RGB(:,:,1) = P/2;  RGB(:,:,2) = P/2; RGB(:,:,3) = P/2;
                % Draw actual counts into the image
                for n=1:d
                    v = obj.x(n,i);     % The count
                    RGB(v+1,n,1) = RGB(v+1,n,1)+0.5;
                end
                subplot(1,2,2), imshow(RGB);
%}
                pause
            end

            fprintf('\n');
        end  % end function PrintResults
            
    end  % end methods
    
end

