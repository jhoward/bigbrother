%file: bcf2IBCF
%author: James Howard
%
%Compute ABCF for IBCF models

clear all;

%--------------------------------------------------------------------------
%SETUP CONSTANTS
%--------------------------------------------------------------------------
dataSet = 2;
model = 10; %Set MODEL to IBCF
horizon = 2;

dataLocation = MyConstants.FILE_LOCATIONS_CLEAN{dataSet};
load(dataLocation);
load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});

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
fValid = results.IBCF.validForecast{horizon};
validRes = validData - fValid;
fTest = results.IBCF.testForecast{horizon};
testRes = testData - fTest;
[~, validStds] = computeMean(validData, data.blocksInDay);


%--------------------------------------------------------------------------
%CLUSTER DATA
%--------------------------------------------------------------------------
%clusters
clustMin = 5;
clustMax = 10;
windowMin = 4;
windowMax = 9;
smoothAmount = 1;
verbose = true;
extractPer = 0.15;
                        
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


%==========================================================================
%IBCF
%==========================================================================

%Run on all horizons
for i = 1:MyConstants.HORIZON
    bestSqeonan = -1;
    bestSqeonan3 = -1;
    worstSqeonan = -1;
    for t = 1:maxAttempts
        validRes = validData - results.IBCF.validForecast{i};
        testRes = testData - results.IBCF.testForecast{i};


        [windows, ind, idx, centers, kdists] = ...
                             createCluster(validRes, 1, clustMin, clustMax, ...
                             extractPer, windowMin, windowMax, ...
                             smoothAmount, false); 

        models = createGaussModels(windows, idx, validRes);
        forecaster = bcf.BayesianLocalForecaster(models);


        [adjRes, p, post, l, histPost] = forecaster.forecastAll(testRes, i);
        newData = results.IBCF.testForecast{i} + adjRes;
        newRes = testData - newData;

        BCFRMSE = errperf(testData(1:end), results.IBCF.validForecast{i}(1:end), 'rmse');
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
    
    fprintf(1, 'IBCF Horizon %i\n', i);
    fprintf(1, '   RMSE - Test: %f     New: %f\n', BCFRMSE, bestNewBCFRMSE);
    fprintf(1, '   rmseonanValue - Test: %f     New: %f\n', rmseonanValue, bestNewRmseonanValue);
    fprintf(1, '   sqeonan -  Test: %f     New: %f\n', sqeonan, bestSqeonan);
    fprintf(1, '   sqeonan3 - Test: %f     New: %f\n', sqeonan3, bestSqeonan3);
    fprintf(1, '   bestImprovment: %f\n', bestSqeonan - worstSqeonan);
    
    %Save results
    results.ABCF.IBCF.mase(3, i) = newMase;
    results.ABCF.IBCF.testForecast{i} = newData;
    results.ABCF.IBCF.rmse(3, i) = newBCFRMSE;
    results.ABCF.IBCF.rmseonan(3, i) = newRmseonanValue; 
    results.ABCF.IBCF.sqeonan(3, i) = newSqeonan;
    results.ABCF.IBCF.sqeonan3(3, i) = newSqeonan3;
    results.ABCF.IBCF.clusters{i} = windows;
    results.ABCF.IBCF.idx{i} = bestIdx;
    results.ABCF.IBCF.centers{i} = centers;
    results.ABCF.IBCF.testProbs{i} = histPost;
    results.ABCF.IBCF.improvement{i} = bestSqeonan - worstSqeonan;
end

%==========================================================================
%BCF
%==========================================================================

%Run on all horizons
for i = 1:MyConstants.HORIZON
    bestSqeonan = -1;
    bestSqeonan3 = -1;
    worstSqeonan = -1;
    for t = 1:maxAttempts
        validRes = validData - results.BCF.validForecast{i};
        testRes = testData - results.BCF.testForecast{i};


        [windows, ind, idx, centers, kdists] = ...
                             createCluster(validRes, 1, clustMin, clustMax, ...
                             extractPer, windowMin, windowMax, ...
                             smoothAmount, false); 

        models = createGaussModels(windows, idx, validRes);
        forecaster = bcf.BayesianLocalForecaster(models);


        [adjRes, p, post, l, histPost] = forecaster.forecastAll(testRes, i);
        newData = results.BCF.testForecast{i} + adjRes;
        newRes = testData - newData;

        BCFRMSE = errperf(testData(1:end), results.BCF.validForecast{i}(1:end), 'rmse');
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
    
    fprintf(1, 'BCF Horizon %i\n', i);
    fprintf(1, '   RMSE - Test: %f     New: %f\n', BCFRMSE, bestNewBCFRMSE);
    fprintf(1, '   rmseonanValue - Test: %f     New: %f\n', rmseonanValue, bestNewRmseonanValue);
    fprintf(1, '   sqeonan -  Test: %f     New: %f\n', sqeonan, bestSqeonan);
    fprintf(1, '   sqeonan3 - Test: %f     New: %f\n', sqeonan3, bestSqeonan3);
    fprintf(1, '   bestImprovment: %f\n', bestSqeonan - worstSqeonan);
    
    %Save results
    results.ABCF.BCF.mase(3, i) = newMase;
    results.ABCF.BCF.testForecast{i} = newData;
    results.ABCF.BCF.rmse(3, i) = newBCFRMSE;
    results.ABCF.BCF.rmseonan(3, i) = newRmseonanValue; 
    results.ABCF.BCF.sqeonan(3, i) = newSqeonan;
    results.ABCF.BCF.sqeonan3(3, i) = newSqeonan3;
    results.ABCF.BCF.clusters{i} = windows;
    results.ABCF.BCF.idx{i} = bestIdx;
    results.ABCF.BCF.centers{i} = centers;
    results.ABCF.BCF.testProbs{i} = histPost;
    results.ABCF.BCF.improvement{i} = bestSqeonan - worstSqeonan;
end


%==========================================================================
%ICBCF
%==========================================================================

%Run on all horizons
for i = 1:MyConstants.HORIZON
    bestSqeonan = -1;
    bestSqeonan3 = -1;
    worstSqeonan = -1;
    for t = 1:maxAttempts
        validRes = validData - results.ICBCF.validForecast{i};
        testRes = testData - results.ICBCF.testForecast{i};


        [windows, ind, idx, centers, kdists] = ...
                             createCluster(validRes, 1, clustMin, clustMax, ...
                             extractPer, windowMin, windowMax, ...
                             smoothAmount, false); 

        models = createGaussModels(windows, idx, validRes);
        forecaster = bcf.BayesianLocalForecaster(models);


        [adjRes, p, post, l, histPost] = forecaster.forecastAll(testRes, i);
        newData = results.ICBCF.testForecast{i} + adjRes;
        newRes = testData - newData;

        BCFRMSE = errperf(testData(1:end), results.ICBCF.validForecast{i}(1:end), 'rmse');
        newBCFRMSE = errperf(testData(1:end), newData(1:end), 'rmse');
        [~, rmseonanValue3, sqeonan3, ~] = ponan(testRes, 3 * validStds);
        [~, newRmseonanValue3, newSqeonan3, ~] = ponan(newRes, 3 * validStds);
        [~, rmseonanValue, sqeonan, ~] = ponan(testRes, validStds);
        [~, newRmseonanValue, newSqeonan, ~] = ponan(newRes, validStds);
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
    
    fprintf(1, 'ICBCF Horizon %i\n', i);
    fprintf(1, '   RMSE - Test: %f     New: %f\n', BCFRMSE, bestNewBCFRMSE);
    fprintf(1, '   rmseonanValue - Test: %f     New: %f\n', rmseonanValue, bestNewRmseonanValue);
    fprintf(1, '   sqeonan -  Test: %f     New: %f\n', sqeonan, bestSqeonan);
    fprintf(1, '   sqeonan3 - Test: %f     New: %f\n', sqeonan3, bestSqeonan3);
    fprintf(1, '   bestImprovment: %f\n', bestSqeonan - worstSqeonan);
    
    %Save results
    results.ABCF.ICBCF.mase(3, i) = newMase;
    results.ABCF.ICBCF.testForecast{i} = newData;
    results.ABCF.ICBCF.rmse(3, i) = newBCFRMSE;
    results.ABCF.ICBCF.rmseonan(3, i) = newRmseonanValue; 
    results.ABCF.ICBCF.sqeonan(3, i) = newSqeonan;
    results.ABCF.ICBCF.sqeonan3(3, i) = newSqeonan3;
    results.ABCF.ICBCF.clusters{i} = windows;
    results.ABCF.ICBCF.idx{i} = bestIdx;
    results.ABCF.ICBCF.centers{i} = bestCenters;
    results.ABCF.ICBCF.testProbs{i} = histPost;
    results.ABCF.ICBCF.improvement{i} = bestSqeonan - worstSqeonan;
end

save(MyConstants.RESULTS_DATA_LOCATIONS{dataSet}, 'results');

%==========================================================================
%End ABCF classic
%==========================================================================

outStruct = validateData(testData, validStds, results.ABCF.ICBCF);
results.ABCF.ICCBCF = outStruct;

save(MyConstants.RESULTS_DATA_LOCATIONS{dataSet}, 'results');

%produce plot
plot(results.IBCF.rmse(3, :), 'Color', [0 1 0]);
hold on
plot(results.ICBCF.rmse(3, :), 'Color', [1 0 0]);
plot(results.BCF.rmse(3, :), 'Color', [0 1 1]);
plot(results.ABCF.ICBCF.rmse(3, :), 'Color', [0.1 0.5 0.1]);
plot(results.ABCF.ICCBCF.rmse(3, :), 'Color', [0.1 0.1 0.5]);
plot(results.svm.rmse(3, :), 'Color', [1 0 1]);


%produce plot
%plot(results.ICBCF.sqeonan3(3, :), 'Color', [1 0 0]);
%hold on
%plot(results.BCF.sqeonan3(3, :), 'Color', [0 1 1]);
plot(results.ABCF.ICBCF.sqeonan3(3, :), 'Color', [0.1 0.5 0.1]);
hold on
plot(results.ABCF.ICCBCF.sqeonan3(3, :), 'Color', [0.1 0.1 0.5]);
plot(results.svm.sqeonan3(3, :), 'Color', [1 0 1]);



%produce plot
plot(results.ICBCF.sqeonan(3, :), 'Color', [1 0 0]);
hold on
plot(results.BCF.sqeonan(3, :), 'Color', [0 1 1]);
plot(results.ABCF.ICBCF.sqeonan(3, :), 'Color', [0.1 0.5 0.1]);
plot(results.ABCF.ICCBCF.sqeonan(3, :), 'Color', [0.1 0.1 0.5]);
plot(results.svm.sqeonan(3, :), 'Color', [1 0 1]);




