%file: bcf2ARIMA
%author: James Howard
%
%Compute the activity recongition improved BCF for ARIMA models

clear all;

%--------------------------------------------------------------------------
%SETUP CONSTANTS
%--------------------------------------------------------------------------
dataSet = 1;
model = 2; %Set MODEL to ARIMA
horizon = 4;

dataLocation = MyConstants.FILE_LOCATIONS_CLEAN{dataSet};
load(dataLocation);
load(MyConstants.HORIZON_DATA_LOCATIONS{dataSet});

%DON"T TOUCH FSTART AND END - I SHOULD HAVE FIXED THIS EARLIER
%Constrain the data for the purpose of makeing shorter runs
fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);



%--------------------------------------------------------------------------
%SETUP DATASETS
%--------------------------------------------------------------------------
validData = data.validData(:, fStart:fEnd);
validTimes = data.validTimes(:, fStart:fEnd);
testData = data.testData(:, fStart:fEnd);
testTimes = data.testTimes(:, fStart:fEnd);
fValid = horizons.arima{11}{horizon};
validRes = validData - fValid;
fTest = horizons.arima{11}{horizon};
testRes = testData - fTest;
[~, validStds] = computeMean(validData, data.blocksInDay);


%--------------------------------------------------------------------------
%CLUSTER DATA
%--------------------------------------------------------------------------
clustMin = 4;
clustMax = 6;
windowMin = 10;
windowMax = 15;
smoothAmount = 0;
verbose = true;
extractPer = 0.2;
                        
[windows, ind, idx, centers, kdists] = ...
                         createCluster(validRes, 1, clustMin, clustMax, ...
                         extractPer, windowMin, windowMax, ...
                         smoothAmount, verbose); 
plotClusters(windows, idx, 'centers', centers);



%--------------------------------------------------------------------------
%MODEL AND FORECAST DATA
%--------------------------------------------------------------------------
models = createGaussModels(windows, idx, validRes);

forecaster = bcf.BayesianLocalForecaster(models);
[adjRes, p, post, l, histPost] = forecaster.forecastAll(testRes, horizon);


%--------------------------------------------------------------------------
%COMPUTE RESULTS
%--------------------------------------------------------------------------
newData = fTest + adjRes;
newRes = testData - newData;

BCFRMSE = errperf(testData(1:end), fTest(1:end), 'rmse');
modBCFRMSE = errperf(testData(1:end), newData(1:end), 'rmse');
[ponanValue rmseonanValue SSEONANTest ~] = ponan(testRes, 3 * validStds);
[ponanValue rmseonanValue modSSEONAN ~] = ponan(newRes, 3 * validStds);

fprintf(1, 'RMSE - Test: %f     New: %f\n', BCFRMSE, modBCFRMSE);
fprintf(1, 'SSEONAN - Test: %f     New: %f\n', SSEONANTest, modSSEONAN);


%Save dataset




%--------------------------------------------------------------------------
%DISPLAY RESULTS
%--------------------------------------------------------------------------

st = 300
ed = 399

plot(testData(:, st:ed), 'Color', [0 0 0])
hold on
plot(fTest(:, st:ed), 'Color', [0 0 1])
plot(newData(:, st:ed), 'Color', [1 0 0])


plotPonan(testRes(79:299), validStds, true)
plotPonan(newRes(79:299), validStds, true)

%Index 3200 is nice for Dataset 1
contPlotMult({testRes, newRes}, 78, 3 * validStds)

