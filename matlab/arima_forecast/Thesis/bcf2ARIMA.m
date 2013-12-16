%file: bcf2ARIMA
%author: James Howard
%
%Compute the activity recongition improved BCF for ARIMA models

clear all;

dataSet = 1;
model = 2; %Set MODEL to ARIMA
horizon = 3;

dataLocation = MyConstants.FILE_LOCATIONS_CLEAN{dataSet};
saveLocationStart = strcat(MyConstants.THESIS_LOCATION, 'images/bcfimproved/');
saveLocationEnd = strcat('ds-', int2str(dataSet), '_model-', ...
                MyConstants.MODEL_NAMES{model}, '.png');
        
load(dataLocation);
load(MyConstants.HORIZON_DATA_LOCATIONS{dataSet});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

%Setup datasets
testData = data.testData(:, fStart:fEnd);
testTimes = data.times(:, fStart:fEnd);
fTest = horizons.arima{11}{horizon};

resTest = testData - fTest;
resTimes = testTimes;

clustMin = 4;
clustMax = 6;
windowMin = 8;
windowMax = 12;
smoothAmount = 0;
verbose = true;
extractPer = 0.15;
                        
%Create the clusters.
[windows, ind, idx, centers, kdists] = ...
                         createCluster(resTest, 1, clustMin, clustMax, ...
                         extractPer, windowMin, windowMax, ...
                         smoothAmount, verbose); 

plotClusters(windows, idx, 'centers', centers);

models = createGaussModels(windows, idx);


%Create background model
backModel = bcf.models.AvgGaussian(1);
backModel.noiseValues = std(resTest);
backModel.avgValues = mean(resTest);

models = {modelAvg1; modelAvg2; modelAvg3; modelAvg4; backModel};

forecaster = bcf.BayesianLocalForecaster(models);
[adjRes, p, post, l, histPost] = forecaster.forecastAll(resTest, horizon);

adjData = fTest + adjRes;
adjResTest = resTest - adjRes;

BCFRMSE = errperf(testData(1:end), fTest(1:end), 'rmse')
modBCFRMSE = errperf(testData(1:end), adjData(1:end), 'rmse')
[ponanValue rmseonanValue sseonanValue ~] = ponan(resTest, testStds(data.stripDays, :));
[ponanValue rmseonanValue sseonanValue2 ~] = ponan(adjResTest, testStds(data.stripDays, :));
sseonanValue
sseonanValue2


st = 900;
ed = 1299;
plot(resTest(1, st:ed))
hold on
plot(adjRes(1, st:ed), 'Color', [1 0 0])



