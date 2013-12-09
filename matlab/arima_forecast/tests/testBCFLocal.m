%Test BCFLocalforecaster
%author: james howard

clear all

numPoints = 1000;
noise = 0.5;
numActivities = 10;
actTypes = [1];
actLengths = [15];
actNoises = [0.3];

data = simulateData1d(numPoints, noise, numActivities, actTypes, actLengths, actNoises);

%Create models
for i = 1:size(data.act, 2)
    modelAvg1 = bcf.models.AvgGaussian(actLengths(1, i));
    modelAvg1.train(data.act{i}');
end

