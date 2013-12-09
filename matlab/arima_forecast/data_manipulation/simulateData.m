function [data] = simulateData()
%Create simulated data.
    dayLength = 96;
    numDays = 200;
    bgSize = 1.5;
    bgStd = 0.01;
    bgAdjust = 1.0;
    numActs = 30;
    actLength = 15;
    actSize = 1.5;
    actStd = 0.001;
    numDayActs = 0;
    dayActsSize = 3.0;
    dayActsStd = 0.01;
    
%     dayLength = 20;
%     numDays = 30;
%     bgSize = 10;
%     bgStd = 0;
%     numActs = 0;
%     actLength = 18;
%     actSize = 2.0;
%     actStd = 0.0;
    
    [sdata, meanData, times, actTimes, actTypes actDays] = createSimulatedData(numDays, dayLength, ...
                    bgSize, bgStd, numActs, actLength, actSize, actStd, bgAdjust, dayActsSize, ...
                    dayActsStd, numDayActs);
    
    blocksInDay = dayLength;
    
    sd.data = sdata';
    sd.times = times';
    sd.actTimes = actTimes';
    sd.blocksInDay = blocksInDay;
    sd.meanData = meanData';
    sd.sensors = [1];
    sd.actLength = actLength;
    sd.actTypes = actTypes;
    sd.actTimes = sd.actTimes';
    sd.actDays = actDays;
    sd.dayTypes = zeros(1, numDayActs);
    data = sd;
    save('./data/simulatedData.mat', 'data');
end

function [data meanData times actTimes actTypes actDays] = createSimulatedData(numDays, dayLength, bgSize, bgStd, ...
                            numActs, actLength, actSize, actStd, bgAdjust, dayActSize, dayActStd, numDayActs)
    
    data = [];
    actTimes = [];
    actTypes = [];
    actDays = [];
    meanData = [];
    
    %FINSIH THIS TOMORROW
    
    %Create times array
    times = linspace(0, numDays, numDays*dayLength);
    times = times';
    
                        
    for i = 1:numDays
        [dayData dayMean] = createBackgroundOneDay(dayLength, bgSize, bgStd, bgAdjust);
        meanData = [meanData; dayMean];
        data = [data; dayData]; %#ok<AGROW>
    end

    for i = 1:numDayActs
        %Pick a random day
        tmpDay = floor(rand * numDays);
        dayData = createDayAct(dayLength, dayActSize, dayActStd, 0, bgAdjust);
        data(tmpDay * dayLength + 1:tmpDay*dayLength + dayLength, :) = dayData; 
        actDays = [actDays (tmpDay * dayLength)];
    end
    
    
    possibleStartLocation = size(data, 1);
    for i = 1:numActs
        if mod(i, 2) == 0
            atype = 0;
        else
            atype = 4;
        end
        actData = createActivity(actLength, actSize, actStd, atype);
        sl = floor(rand * (possibleStartLocation - actLength));
        actTimes = [actTimes sl]; %#ok<AGROW>
        actTypes = [actTypes atype]; %#ok<AGROW>
        fprintf(1, 'Activity started at %i\n', sl);
        data(sl:sl + actLength - 1, 1) = data(sl:sl + actLength - 1, 1) + actData;
    end
    

end

function dayData = createDayAct(dayLength, dayActSize, dayActStd, dayType, dayAdjust)
    dayData = linspace(0, pi, dayLength);
    dayData = dayActSize * sin(dayData');
    
    noiseData = random('norm', 0, dayActStd, [dayLength, 1]);
    dayData = dayData + noiseData + dayAdjust;
end

function [dayData meanData] = createBackgroundOneDay(dayLength, daySize, std, adjust)
    
    %First 25 percent and last
    dayData = linspace(0, pi, dayLength);
    dayData = daySize * sin(dayData');
    
    %mid 50 percent
    index = floor(dayLength / 4);
    d = linspace(dayData(index)^0.5, (dayData(index)^0.5) / 1.2, floor(dayLength / 4));
    d2 = linspace((dayData(index)^0.5) / 1.2, dayData(index)^0.5, floor(dayLength / 4));
    d = [d d2];
    d = bsxfun(@times, d, d);
    dayData(index:index + size(d, 2) - 1, 1) = d';
    meanData = dayData + adjust;
    
    
    %add Noise
    noiseData = random('norm', 0, std, [dayLength, 1]);
    dayData = dayData + noiseData + adjust;
end

function actData = createActivity(actLength, size, std, type)
%Create a single activity.
%type 
%     0 - First half sine curve (ramp up then down)
%     1 - Second half sine curve (ramp down then up)
%     2 - Linear curve up
%     3 - Linear curve down    

    if type == 0
        actData = linspace(0, pi, actLength);
        actData = size * sin(actData');
    elseif type == 1
        actData = linspace(pi, 2 * pi, actLength);
        actData = size * sin(actData');
    elseif type == 2
        actData = linspace(0, size, actLength);
        actData = actData';
    elseif type == 3
        actData = linspace(0, -1 * size, actLength);
        actData = actData';
    elseif type == 4
        actData = linspace(0, pi, actLength);
        actData = size * sin(actData');
        tmp = linspace(actData(5), -1, actLength - 5);
        actData(6:end) = tmp';
    end
    
    noiseData = random('norm', 0, std, [actLength, 1]);
    actData = actData + noiseData;

end

