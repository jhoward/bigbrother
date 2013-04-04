function [data, times, actTimes, blocksInDay] = simulateDataTwoSet()
%Create simulated data from two processes.
    dayLength = 96;
    numDays = 100;
    p1Size = 10;
    p2Size = 5;
    p1Std = 0.5;
    p2Std = 0.3;
    
    [data, times] = createSimulatedData(numDays, dayLength, ...
                    p1Size, p2Size, p1Std, p2Std);
    
    blocksInDay = dayLength;
    
    sd.data = data;
    sd.times = times;
    sd.actTimes = [];
    sd.blocksInDay = blocksInDay;
    sd.sensors = [1];
    data = sd;
    
    save('./data/simulatedData2P.mat', 'data');
end

function [data times] = createSimulatedData(numDays, dayLength, ...
                                    p1Size, p2Size, p1Std, p2Std)
    
    data = zeros(1, dayLength * numDays);
    
    %Create times array
    times = linspace(0, numDays, numDays*dayLength);
                        
    for i = 1:numDays
        if mod(i, 2) == 0
            data(1, (i - 1) * dayLength + 1:i * dayLength) = createOneDay(dayLength, p1Size, p1Std);
        else
            data(1, (i - 1) * dayLength + 1:i * dayLength) = createOneDay(dayLength, p2Size, p2Std);
        end
    end
end

function dayData = createOneDay(dayLength, size, std)
    
    dayData = linspace(0, pi, dayLength);
    dayData = size * sin(dayData) + 1;
    
    %add Noise
    noiseData = random('norm', 0, std, [1, dayLength]);
    dayData = dayData + noiseData;
end



