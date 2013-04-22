function [data, times, actTimes, blocksInDay] = simulateData()
%Create simulated data.
    dayLength = 96;
    numDays = 200;
    bgSize = 10;
    bgStd = 0.1;
    bgAdjust = 1.0;
    numActs = 35;
    actLength = 15;
    actSize = 3.0;
    actStd = 0.001;
    
%     dayLength = 20;
%     numDays = 30;
%     bgSize = 10;
%     bgStd = 0;
%     numActs = 0;
%     actLength = 18;
%     actSize = 2.0;
%     actStd = 0.0;
    
    [data, times, actTimes, actTypes] = createSimulatedData(numDays, dayLength, ...
                    bgSize, bgStd, numActs, actLength, actSize, actStd, bgAdjust);
    
    blocksInDay = dayLength;
    
    sd.data = data';
    sd.times = times';
    sd.actTimes = actTimes';
    sd.blocksInDay = blocksInDay;
    sd.sensors = [1];
    sd.actLength = actLength;
    sd.actTypes = actTypes;
    data = sd;
    data.actTimes = data.actTimes'
    save('./data/simulatedData.mat', 'data');
end

function [data times actTimes actTypes] = createSimulatedData(numDays, dayLength, bgSize, bgStd, ...
                            numActs, actLength, actSize, actStd, bgAdjust)
    
    data = [];
    actTimes = [];
    actTypes = [];
    
    %Create times array
    times = linspace(0, numDays, numDays*dayLength);
    times = times';
    
                        
    for i = 1:numDays
        dayData = createBackgroundOneDay(dayLength, bgSize, bgStd, bgAdjust);
        data = [data; dayData]; %#ok<AGROW>
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

function dayData = createBackgroundOneDay(dayLength, size, std, adjust)
    
    dayData = linspace(0, pi, dayLength);
    dayData = size * sin(dayData');
    
    %add Noise
    noiseData = random('norm', 0, std, [dayLength, 1]);
    dayData = dayData + noiseData + rand * adjust;
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

