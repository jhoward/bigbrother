%Test BCFLocalforecaster
%author: james howard

clear all

numPoints = 1000;
noise = 0.5;
numActivities = 10;
actTypes = [1]; %#ok<*NBRAK>
actLengths = [15];
actNoises = [0.3];

data = simulateData1d(numPoints, noise, numActivities, actTypes, actLengths, actNoises);

models = {};

%Create models
for i = 1:size(data.act, 2)
    models{i} = bcf.models.AvgGaussian(actLengths(1, i)); %#ok<SAGROW>
    models{i}.train(data.act{i}');
end

%Construct the background model
backModel = bcf.models.AvgGaussian(1);
backModel.noiseValues = [data.noise];
backModel.avgValues = [data.mean];

models{length(models) + 1} = backModel;

forecaster = bcf.BayesianLocalForecaster(models);
[adjData, p, post, l, histPost] = forecaster.forecastAll(data.data, 1);

newData = data.data - adjData;

