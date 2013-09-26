%File: modelARIMA.m
%Author: James Howard
%
%
%Runs an ARIMA model for a given dataset and computes statistics for the
%dataset.  Also creates a set of images.


clear all;

dataSet = 1;
model = 2;

dataLocation = MyConstants.FILE_LOCATIONS_CLEAN{dataSet};
saveLocation = strcat(MyConstants.THESIS_LOCATION, 'images/models/ds-', ...
                int2str(dataSet), '_model-', ...
                int2str(MyConstants.MODEL_NAMES{model}), '.png');
fileLocation = strcat(MyConstants.THESIS_LOCATION, 'images/models/ds-', ...
                int2str(dataSet), '_model-', ...
                int2str(MyConstants.MODEL_NAMES{model}), '.txt');            
                    
load(dataLocation);

%Train given model
aMod = bcf.models.Arima(1, 78, MyConstants.ARIMA_PARAMETERS{dataSet});
aMod.train(data.trainData);

%Test the model - for now test 1 timestep ahead
trainF = aMod.forecastAll(data.trainData, 1);
testF = aMod.forecastAll(data.testData, 1);
trainF4 = aMod.forecastAll(data.trainData, 10);

%Inferred data
trainI = aMod.inferData(data.trainData);

trainR = data.trainData - trainF;
trainR4 = data.trainData - trainF4;
testR = data.testData - testF;

[h, p, s, c] = lbqtest(testR(300:400))
autocorr(trainI, 100);
autocorr(trainR, 100);
parcorr(trainI, 100);
parcorr(trainR, 100);

%Saved the trained model
