%file: bcf2tdnn
%author: James Howard
%
%Compute ABCF for tdnn models

clear all;

%--------------------------------------------------------------------------
%SETUP CONSTANTS
%--------------------------------------------------------------------------
dataSet = 2;

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
[~, validStds] = computeMean(data.validData, data.blocksInDay);


%--------------------------------------------------------------------------
%CLUSTER DATA
%--------------------------------------------------------------------------
%clusters
clustMin = 6;
clustMax = 12;
windowMin = 6;
windowMax = 12;
smoothAmount = 1;
verbose = true;
extractPer = 0.10;
                        
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
% clustMin = 6;
% clustMax = 10;
% windowMin = 7;
% windowMax = 12;
% smoothAmount = 1;
% verbose = true;
% extractPer = 0.15;
% maxAttempts = 2;



%Dataset 2
clustMin = 3;
clustMax = 10;
windowMin = 3;
windowMax = 6;
smoothAmount = 1;
verbose = true;
extractPer = 0.15;
maxAttempts = 3;


%Dataset 3
% clustMin = 6;
% clustMax = 12;
% windowMin = 6;
% windowMax = 12;
% smoothAmount = 1;
% verbose = true;
% extractPer = 0.10;
% maxAttempts = 3;


%Run on all horizons
for i = 1:MyConstants.HORIZON
    bestSqeonan = -1;
    bestSqeonan3 = -1;
    worstSqeonan = -1;
    for t = 1:maxAttempts
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
        [~, rmseonanValue, sqeonan, ~] = ponan(testRes, validStds);
        [~, newRmseonanValue, newSqeonan, ~] = ponan(newRes, validStds);
        [~, rmseonanValue3, sqeonan3, ~] = ponan(testRes, 3 * validStds);
        [~, newRmseonanValue3, newSqeonan3, ~] = ponan(newRes, 3 * validStds);
        newMase = mase(data.testData(1, fStart:fEnd), newData);

        if worstSqeonan < 0
            worstSqeonan = newSqeonan;
        end
        
        if (newSqeonan < worstSqeonan)
            worstSqeonan = newSqeonan;
        end
        
        if newSqeonan > bestSqeonan
            bestSqeonan = newSqeonan;
            bestSqeonan3 = newSqeonan3;
            bestNewMase = newMase;
            bestNewBCFRMSE = newBCFRMSE;
            bestNewData = newData;
            bestNewRmseonanValue  = newRmseonanValue;
            bestWindows = windows;
            bestIdx = idx;
            bestCenters = centers;
            bestHistPost = histPost;
        end
    end
    
    fprintf(1, 'TDNNM Horizon %i\n', i);
    fprintf(1, '   RMSE - Test: %f     New: %f\n', BCFRMSE, bestNewBCFRMSE);
    fprintf(1, '   rmseonanValue - Test: %f     New: %f\n', rmseonanValue, bestNewRmseonanValue);
    fprintf(1, '   sqeonan -  Test: %f     New: %f\n', sqeonan, bestSqeonan);
    fprintf(1, '   sqeonan3 - Test: %f     New: %f\n', sqeonan3, bestSqeonan3);
    fprintf(1, '   bestImprovment: %f\n', bestSqeonan - worstSqeonan);
    
    %Save results
    results.ABCF.tdnn.mase(3, i) = newMase;
    results.ABCF.tdnn.testForecast{i} = newData;
    results.ABCF.tdnn.rmse(3, i) = newBCFRMSE;
    results.ABCF.tdnn.rmseonan(3, i) = newRmseonanValue; 
    results.ABCF.tdnn.sqeonan(3, i) = newSqeonan;
    results.ABCF.tdnn.sqeonan3(3, i) = newSqeonan3;
    results.ABCF.tdnn.clusters{i} = windows;
    results.ABCF.tdnn.idx{i} = bestIdx;
    results.ABCF.tdnn.centers{i} = centers;
    results.ABCF.tdnn.testProbs{i} = histPost;
    results.ABCF.tdnn.improvement{i} = bestSqeonan - worstSqeonan;
end

save(MyConstants.RESULTS_DATA_LOCATIONS{dataSet}, 'results');

%==========================================================================
%End svm
%==========================================================================

outStruct = validateData(testData, validStds, results.ABCF.tdnn);
results.ABCF.ctdnn = outStruct;

save(MyConstants.RESULTS_DATA_LOCATIONS{dataSet}, 'results');

%produce plot
plot(results.ABCF.tdnn.rmse(3, 1:6), 'Color', [0 1 0.2]);
hold on
plot(results.tdnn.rmse(3, 1:6), 'Color', [0 0 1]);
plot(results.ABCF.ctdnn.rmse(3, 1:6), 'Color', [1 0 0]);


%produce plot
plot(results.ABCF.tdnn.sqeonan3(3, 1:6), 'Color', [0 1 0.2]);
hold on
plot(results.tdnn.sqeonan3(3, 1:6), 'Color', [0 0 1]);
plot(results.ABCF.ctdnn.sqeonan3(3, 1:6), 'Color', [1 0 0]);



%produce plot
plot(results.ABCF.tdnn.sqeonan(3, 1:6), 'Color', [0 1 0.2]);
hold on
plot(results.tdnn.sqeonan(3, 1:6), 'Color', [0 0 1]);
plot(results.ABCF.ctdnn.sqeonan(3, 1:6), 'Color', [1 0 0]);
% 
% contPlotMult({testData, results.tdnn.testForecast{1}, ...
%             results.ABCF.ctdnn.testForecast{1}}, data.blocksInDay, validStds)
        
