function [data] = ...
                simulateData1d(numPoints, noise, numActivities, ...
                               actTypes, actLengths, actNoises)
%Generate 1 one dimensional dataset with activities and noise.


    %generate noiseData
    %For now produce a gaussian white noise for the background
    d = noise .* randn(1, numPoints);
    activities = cell(size(unique(actTypes), 2));
    activityTimes = cell(size(unique(actTypes), 2));
    
    %produce activities
    for at = 1:actTypes    
        for a = 1:numActivities
            act = generateActivity(at, actLengths(1, at), ...
                                    actNoises(1, at));
            actTime = floor(rand * numPoints) + 1;
            activities{at} = [activities{at}; act];
            activityTimes{at} = [activityTimes{at} actTime];
            
            %Set activity in data.
            d(1, actTime:actTime + actLengths(1, at) - 1) = act;
        end
    end
        
    data.data = d;
    data.actTime = activityTimes;
    data.act = activities;
    data.mean = 0;
    data.noise = noise;
    data.actLengths = actLengths;
    data.actNoises = actNoises;
    data.actTypes = actTypes;
end

function [act] = generateActivity(at, al, an)
    %For now just generate a mean shift activity
    act = 1 + 0.2 .* randn(1, al);
end
