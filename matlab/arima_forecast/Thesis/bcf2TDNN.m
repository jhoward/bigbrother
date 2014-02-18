%file: bcf2tdnn
%author: James Howard
%
%Compute ABCF for tdnn models

clear all;

%--------------------------------------------------------------------------
%SETUP CONSTANTS
%--------------------------------------------------------------------------
dataSet = 3;

dataLocation = MyConstants.FILE_LOCATIONS_CLEAN{dataSet};
load(dataLocation);
load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});

%DON"T TOUCH FSTART AND END - I SHOULD HAVE FIXED THIS EARLIER
%Constrain the data for the purpose of makeing shorter runs
fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);


%--------------------------------------------------------------------------
%SETUP DATASETS and DEMONSTRATE
%--------------------------------------------------------------------------
demonstrateHorizon = 2;
validData = data.validData(:, fStart:fEnd);
validTimes = data.validTimes(:, fStart:fEnd);
testData = data.testData(:, fStart:fEnd);
testTimes = data.testTimes(:, fStart:fEnd);
fValid = results.tdnn.validForecast{demonstrateHorizon};
validRes = validData - fValid;
fTest = results.tdnn.testForecast{demonstrateHorizon};
testRes = testData - fTest;
[~, validStds] = computeMean(validData, data.blocksInDay);


%--------------------------------------------------------------------------
%CLUSTER DATA
%--------------------------------------------------------------------------
%clusters
clustMin = 5;
clustMax = 10;
windowMin = 6;
windowMax = 10;
smoothAmount = 1;
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
[adjRes, p, post, l, histPost] = forecaster.forecastAll(testRes, demonstrateHorizon);


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
%BEST CLUSTER ALL HORIZON
%--------------------------------------------------------------------------

%Dataset 1
% clustMin = 5;
% clustMax = 10;
% windowMin = 7;
% windowMax = 15;
% smoothAmount = 1;
% verbose = true;
% extractPer = 0.15;


%Dataset 2
% clustMin = 5;
% clustMax = 10;
% windowMin = 8;
% windowMax = 15;
% smoothAmount = 0;
% verbose = true;
% extractPer = 0.20;


%Dataset 3
clustMin = 5;
clustMax = 10;
windowMin = 5;
windowMax = 8;
smoothAmount = 1;
verbose = true;
extractPer = 0.15;


%Run on all horizons
for i = 11:MyConstants.HORIZON
    validRes = validData - results.tdnn.validForecast{i};
    testRes = testData - results.tdnn.testForecast{i};

    
    [windows, ind, idx, centers, kdists] = ...
                         createCluster(validRes, 1, clustMin, clustMax, ...
                         extractPer, windowMin, windowMax, ...
                         smoothAmount, false); 
    
    models = createGaussModels(windows, idx, validRes);
    forecaster = bcf.BayesianLocalForecaster(models);
                     
    
    [adjRes, p, post, l, histPost] = forecaster.forecastAll(testRes, i);
    newData = results.tdnn.testForecast{i} + adjRes;
    newRes = testData - newData;

    BCFRMSE = errperf(testData(1:end), results.tdnn.validForecast{i}(1:end), 'rmse');
    newBCFRMSE = errperf(testData(1:end), newData(1:end), 'rmse');
    [~, rmseonanValue, sqeonan, ~] = ponan(testRes, 3 * validStds);
    [~, newRmseonanValue, newSqeonan, ~] = ponan(newRes, 3 * validStds);

    fprintf(1, 'Horizon %i\n', i);
    fprintf(1, '   RMSE - Test: %f     New: %f\n', BCFRMSE, newBCFRMSE);
    fprintf(1, '   rmseonanValue - Test: %f     New: %f\n', rmseonanValue, newRmseonanValue);
    fprintf(1, '   sqeonan - Test: %f     New: %f\n', sqeonan, newSqeonan);

    
%     %This is here becasue for some reason after 10 (on ds3) the program crashes.  
%     for i = 11:MyConstants.HORIZON
%         testRes = testData - results.tdnn.testForecast{i};
%         newData = zeros(size(testRes));
%         BCFRMSE = errperf(testData(1:end), results.tdnn.validForecast{i}(1:end), 'rmse');
%         newBCFRMSE = BCFRMSE;
%         [~, rmseonanValue, sqeonan, ~] = ponan(testRes, 3 * validStds);
%         newRmseonanValue = rmseonanValue;
%         newSqeonan = sqeonan;
    
    %Save results
    results.ABCF.tdnn.testForecast{i} = newData;
    results.ABCF.tdnn.rmse(3, i) = newBCFRMSE;
    results.ABCF.tdnn.rmseonan(3, i) = newRmseonanValue; 
    results.ABCF.tdnn.sqeonan(3, i) = newSqeonan;
end

save(MyConstants.RESULTS_DATA_LOCATIONS{dataSet}, 'results');
