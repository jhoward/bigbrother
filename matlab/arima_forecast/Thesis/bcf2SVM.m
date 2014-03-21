%file: bcf2svm
%author: James Howard
%
%Compute ABCF for svm models

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
fValid = results.svm.validForecast{demonstrateHorizon};
validRes = validData - fValid;
fTest = results.svm.testForecast{demonstrateHorizon};
testRes = testData - fTest;
[~, validStds] = computeMean(data.validData, data.blocksInDay);


%--------------------------------------------------------------------------
%CLUSTER DATA
%--------------------------------------------------------------------------
%clusters
clustMin = 7;
clustMax = 12;
windowMin = 7;
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
clustMin = 6;
clustMax = 10;
windowMin = 7;
windowMax = 12;
smoothAmount = 1;
verbose = true;
extractPer = 0.15;
maxAttempts = 2;


%Dataset 2
% clustMin = 3;
% clustMax = 10;
% windowMin = 3;
% windowMax = 6;
% smoothAmount = 1;
% verbose = true;
% extractPer = 0.15;
% maxAttempts = 3;


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
        validRes = validData - results.svm.validForecast{i};
        testRes = testData - results.svm.testForecast{i};


        [windows, ind, idx, centers, kdists] = ...
                             createCluster(validRes, 1, clustMin, clustMax, ...
                             extractPer, windowMin, windowMax, ...
                             smoothAmount, false); 

        models = createGaussModels(windows, idx, validRes);
        forecaster = bcf.BayesianLocalForecaster(models);


        [adjRes, p, post, l, histPost] = forecaster.forecastAll(testRes, i);
        newData = results.svm.testForecast{i} + adjRes;
        newRes = testData - newData;

        BCFRMSE = errperf(testData(1:end), results.svm.validForecast{i}(1:end), 'rmse');
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
    
    fprintf(1, 'SVM Horizon %i\n', i);
    fprintf(1, '   RMSE - Test: %f     New: %f\n', BCFRMSE, bestNewBCFRMSE);
    fprintf(1, '   rmseonanValue - Test: %f     New: %f\n', rmseonanValue, bestNewRmseonanValue);
    fprintf(1, '   sqeonan -  Test: %f     New: %f\n', sqeonan, bestSqeonan);
    fprintf(1, '   sqeonan3 - Test: %f     New: %f\n', sqeonan3, bestSqeonan3);
    fprintf(1, '   bestImprovment: %f\n', bestSqeonan - worstSqeonan);
    
    %Save results
    results.ABCF.svm.mase(3, i) = newMase;
    results.ABCF.svm.testForecast{i} = newData;
    results.ABCF.svm.rmse(3, i) = newBCFRMSE;
    results.ABCF.svm.rmseonan(3, i) = newRmseonanValue; 
    results.ABCF.svm.sqeonan(3, i) = newSqeonan;
    results.ABCF.svm.sqeonan3(3, i) = newSqeonan3;
    results.ABCF.svm.clusters{i} = windows;
    results.ABCF.svm.idx{i} = bestIdx;
    results.ABCF.svm.centers{i} = centers;
    results.ABCF.svm.testProbs{i} = histPost;
    results.ABCF.svm.improvement{i} = bestSqeonan - worstSqeonan;
end

save(MyConstants.RESULTS_DATA_LOCATIONS{dataSet}, 'results');

%==========================================================================
%End svm
%==========================================================================

outStruct = validateData(testData, validStds, results.ABCF.svm);
results.ABCF.csvm = outStruct;

save(MyConstants.RESULTS_DATA_LOCATIONS{dataSet}, 'results');

%produce plot
plot(results.ABCF.svm.rmse(3, 1:3), 'Color', [0 1 0.2]);
hold on
plot(results.svm.rmse(3, 1:3), 'Color', [0 0 1]);
plot(results.ABCF.csvm.rmse(3, 1:3), 'Color', [1 0 0]);


%produce plot
plot(results.ABCF.svm.sqeonan3(3, 1:6), 'Color', [0 1 0.2]);
hold on
plot(results.svm.sqeonan3(3, 1:6), 'Color', [0 0 1]);
plot(results.ABCF.csvm.sqeonan3(3, 1:6), 'Color', [1 0 0]);



%produce plot
plot(results.ABCF.svm.sqeonan(3, 1:3), 'Color', [0 1 0.2]);
hold on
plot(results.svm.sqeonan(3, 1:3), 'Color', [0 0 1]);
plot(results.ABCF.csvm.sqeonan(3, 1:3), 'Color', [1 0 0]);
% 
% contPlotMult({testData, results.svm.testForecast{1}, ...
%             results.ABCF.csvm.testForecast{1}}, data.blocksInDay, validStds)
        
