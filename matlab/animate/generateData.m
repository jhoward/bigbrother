clear all;
close all;

N = 1000;
D = 7;

nLoiter = 40;
mLoiter = 6;
stdLoiter = 1;
nWalkRight = 40;
mWalkRight = 6;
stdWalkRight = 1;
nWalkLeft = 40;
mWalkLeft = 5;
stdWalkLeft = 1;

noisePercent = 0;

makeSensorHits = 1;

%If this is set to zero, don't include time.
includeTime = 1;

%In seconds
mTimeInterval = 1;
stdTimeInterval = 0;

%Swap Columns makes an ordering of 5, 2, 4, 1, 3
swapColumns = 1;

%The maximum future offset used for correlation calculation
corrOffset = 3;

sensorlist = zeros(1,D);

%Create data array
data = zeros(N, D + includeTime);

%-----------Create data------------

%Loitering
for i = 1:nLoiter

  %Pick length (Normally distributed)
	len = ceil(mLoiter + stdLoiter*randn(1));

	if len < 0 
		len = 0;
	end;

	%Pick starting location
	startN = ceil(rand(1)*(N - len));

	%Pick dimension
	startD = ceil(rand(1)*D);

	%Create Data (Make this a function sometime)
	for j = 0:len
		data(startN + j, startD + includeTime) = 1;
	end;
end;


%Walk Right
for i = 1:nWalkRight

	%Pick walk length (Nomally distributed)
	len = round(mWalkRight + stdWalkRight*randn(1));

	if len < 0
		len = 0;
	end;

	%Pick starting location
	startN = ceil(rand(1)*(N - len));

	%Pick starting dimension
	startD = ceil(rand(1)*(D - len));

	if startD <= 0
		startD = 1;
	end;

	%Create data
	for j = 0:len
		
		if (startD + j) <= D
			data(startN + j, startD + j + includeTime) = 1;
		end;
	end;
end;

%Walk Left
for i = 1:nWalkLeft

	%Pick walk length (Nomally distributed)
	len = round(mWalkLeft + stdWalkLeft*randn(1));

	if len < 0
		len = 0;
	end;

	%Pick starting location
	startN = ceil(rand(1)*(N - len));

	%Pick starting dimension
	startD = floor(rand(1)*(D - len));

	if startD <= 0
		startD = 0;
	end;

	startD = D - startD;

	%Create data
	for j = 0:len
		
		if (startD - j) >= 1
			data(startN + j, startD - j + includeTime) = 1;
		end;
	end;
end;


%Include noise
%Each point has a noise percent of having its bit flipped
for i = 1:N
    for j = (1 + includeTime):(D + includeTime)
        if rand(1) <= noisePercent
            data(i,j) = mod(data(i,j) + 1, 2);
        end;
    end;
end;


%Include time
if includeTime > 0
    runningTime = now;
    beginTime = datestr(runningTime, 31);
    for i = 1:N
        data(i, includeTime) = runningTime;
        addedSeconds = mTimeInterval + stdTimeInterval*randn(1);
        
        addedSeconds = floor(addedSeconds);
        if addedSeconds < 1
            addedSeconds = 1;
        end;
        
        %Add time in seconds.  The divide by 86400 is num seconds in a day
        runningTime = runningTime + addedSeconds/86400;
    end;
    endTime = datestr(runningTime, 31);
end;

%Run the correlation calculation
correlationMatrix = calcCorrelation(data, corrOffset);

save mat/synthData.mat data beginTime endTime correlationMatrix


