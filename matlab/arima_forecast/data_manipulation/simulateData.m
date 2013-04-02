function [data, times, actTimes, blocksInDay] = simulateData()
%Create simulated data.
    dayLength = 144;
    numDays = 30;
    bgSize = 10;
    bgStd = 0.45;
    numActs = 12;
    actLength = 18;
    actSize = 2.0;
    actStd = 0.0;
    
%     dayLength = 20;
%     numDays = 30;
%     bgSize = 10;
%     bgStd = 0;
%     numActs = 0;
%     actLength = 18;
%     actSize = 2.0;
%     actStd = 0.0;
    
    [data, times, actTimes] = createSimulatedData(numDays, dayLength, ...
                    bgSize, bgStd, numActs, actLength, actSize, actStd);
    
    blocksInDay = dayLength;
    
    sd.data = data';
    sd.times = times';
    sd.actTimes = actTimes';
    sd.blocksInDay = blocksInDay;
    sd.sensors = [1];
    data = sd;
    data.actTimes = data.actTimes'
    save('./data/simulatedData.mat', 'data');
end

function [data times actTimes] = createSimulatedData(numDays, dayLength, bgSize, bgStd, ...
                            numActs, actLength, actSize, actStd)
    
    data = [];
    actTimes = [];
    
    %Create times array
    times = linspace(0, numDays, numDays*dayLength);
    times = times';
    
                        
    for i = 1:numDays
        dayData = createBackgroundOneDay(dayLength, bgSize, bgStd);
        data = [data; dayData]; %#ok<AGROW>
    end

    possibleStartLocation = size(data, 1);
    for i = 1:numActs
        actData = createActivity(actLength, actSize, actStd, 0);
        sl = floor(rand * (possibleStartLocation - actLength));
        actTimes = [actTimes sl]; %#ok<AGROW>
        fprintf(1, 'Activity started at %i\n', sl);
        data(sl:sl + actLength - 1, 1) = data(sl:sl + actLength - 1, 1) + actData;
    end
end

function dayData = createBackgroundOneDay(dayLength, size, std)
    
    dayData = linspace(0, pi, dayLength);
    dayData = size * sin(dayData');
    
    %add Noise
    noiseData = random('norm', 0, std, [dayLength, 1]);
    dayData = dayData + noiseData;
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
    end
    
    noiseData = random('norm', 0, std, [actLength, 1]);
    actData = actData + noiseData;

end

