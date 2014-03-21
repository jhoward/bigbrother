%computeBCF.m
%author: James Howard

clear all;

includeTDNN = true;
dataSet = 3;

probsThreshold = [0.08, 0.06, 0.08];

startDay = 5; %Start and end day are used for sample plots
endDay = 7;

dataLocation = MyConstants.FILE_LOCATIONS_CLEAN{dataSet};
saveLocationStart = strcat(MyConstants.THESIS_LOCATION, 'images/models/');
saveLocationEnd = strcat('ds-', int2str(dataSet), '_bcf.png');
fileLocationStart = strcat(MyConstants.THESIS_LOCATION, 'images/models/');
fileLocationEnd = strcat('ds-', int2str(dataSet), '_bcf.png');
                    
load(dataLocation);
fileID = fopen(strcat(fileLocationStart, fileLocationEnd), 'w');
load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet})

startTime = startDay * data.blocksInDay;
endTime = endDay * data.blocksInDay;

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

%TRAIN MODELS
arimaModel = bcf.models.Arima(1, data.blocksInDay, MyConstants.ARIMA_PARAMETERS{dataSet});
arimaModel.train(data.trainData);

svmModel = bcf.models.SVM(MyConstants.SVM_PARAMETERS{dataSet}, MyConstants.SVM_WINDOW{dataSet});
svmModel.train(data.trainData);

averageModel = bcf.models.Average(data.blocksInDay);
averageModel.train(data.trainData);

if includeTDNN
    tdnnModel = bcf.models.TDNN(MyConstants.TDNN_PARAMETERS{dataSet}(1), MyConstants.TDNN_PARAMETERS{dataSet}(2));
end

[means, stds] = computeMean(data.testData, data.blocksInDay);

%==========================================================================
%SETUP BCFImproved MODEL
%==========================================================================
load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet})

bcfImpTrain = {};
bcfImpTest = {};
bcfImpProbs = {};

rmsehist = zeros(3, MyConstants.HORIZON);
masehist = zeros(3, MyConstants.HORIZON);
rmseonanhist = zeros(3, MyConstants.HORIZON);
sqeonanhist = zeros(3, MyConstants.HORIZON);
sqeonan3hist = zeros(3, MyConstants.HORIZON);


%determine if TDNN needs to be trained
if includeTDNN
    tdnnModel.train(data.trainData, 1);
end


%Combine and forecast
if includeTDNN
    models = {arimaModel svmModel averageModel tdnnModel};
else
    models = {arimaModel svmModel averageModel};
end

pt = 0.001;
if dataSet == 1
    pt = 0.001;
end
modelBcf = bcf.BayesianForecaster(models);

for h = 1:MyConstants.HORIZON
    
    %parameters
    if includeTDNN
        if h > 10
            if dataSet > 0
                includeTDNN = false;
                models = {arimaModel svmModel averageModel};
                modelBcf = bcf.BayesianForecaster(models);
            end
        end
    end
    
    
    noiseDist = h;
    lookback = h;
    if dataSet == 1
        noiseDist = h;
        lookback = h;
    end
    
    fprintf(1, 'H - %i\n', h);
    
    %compute noise distributions
    for j = 1:length(models)
        models{j}.calculateNoiseDistribution(data.trainData, noiseDist);
    end
    
    %compute the historically best model
    lowRMSE = results.arima.rmse(3, h);
    %defaultModel = models{1};
    defaultModel = 1;

    for k = 2:length(models)

        if k == 2
            tmpRMSE = results.svm.rmse(3, h);
        elseif k == 3
            tmpRMSE = results.average.rmse(3, h);
        elseif k == 4 
            tmpRMSE = 1000;
            if includeTDNN
                tmpRMSE = results.tdnn.rmse(3, h);
            end
        end

        if tmpRMSE < lowRMSE
            lowRMSE = tmpRMSE;
            defaultModel = k;
        end
    end
    
    if dataSet == 3
        if h >= 5
            pt = probsThreshold(dataSet);
        end
    end
    
    if dataSet < 1
        if h >= 1
            pt = probsThreshold(dataSet);
        end
    end
    
    
    %perform BCF forecasting on training and testing data
    [bcfImpTrain{h}, bcfImpProbsTrain{h}, rawProbsTrain{h}] = modelBcf.forecastAll(data.trainData(fStart:fEnd), h, h, 'aggregate', 0.001, defaultModel);
    [bcfImpTest{h}, bcfImpProbsTest{h}, rawProbsTest{h}] = modelBcf.forecastAll(data.testData(fStart:fEnd), h, lookback, 'aggregate', pt, defaultModel); 

    bcfImpValid{h} = bcfImpTest{h};
    bcfImpProbsValid{h} = bcfImpProbsTest{h};
    rawProbsValid{h} = rawProbsTest{h};
    
    
    %save results to be used for plots
    testRes = bcfImpTest{h} - data.testData(fStart:fEnd);
    validRes = bcfImpTest{h} - data.validData(fStart:fEnd);
    trainRes = bcfImpTrain{h} - data.trainData(fStart:fEnd);
    
    [~, rmseonanValue, sqeonanValue, ~] = ponan(trainRes, stds);
    rmseonanhist(1, h) = rmseonanValue;
    sqeonanhist(1, h) = sqeonanValue;
    
    [~, rmseonanValue, sqeonanValue, ~] = ponan(validRes, stds);
    rmseonanhist(2, h) = rmseonanValue;
    sqeonanhist(2, h) = sqeonanValue;
    
    [ponanValue rmseonanValue sqeonanValue ~] = ponan(testRes, stds);
    rmseonanhist(3, h) = rmseonanValue;
    sqeonanhist(3, h) = sqeonanValue;

    %SQEONAN3
    [~, rmseonanValue, sqeonanValue, ~] = ponan(trainRes, 3 * stds);
    sqeonan3hist(1, h) = sqeonanValue;
    
    [~, rmseonanValue, sqeonanValue, ~] = ponan(validRes, 3 * stds);
    sqeonan3hist(2, h) = sqeonanValue;
    
    [ponanValue rmseonanValue sqeonanValue ~] = ponan(testRes, 3 * stds);
    sqeonan3hist(3, h) = sqeonanValue;
    
    rmsehist(1, h) = errperf(data.trainData(1, fStart:fEnd), ...
                            bcfImpTrain{h}, 'rmse');
    rmsehist(2, h) = errperf(data.validData(1, fStart:fEnd), ...
                            bcfImpValid{h}, 'rmse');
    rmsehist(3, h) = errperf(data.testData(1, fStart:fEnd), ...
                            bcfImpTest{h}, 'rmse');
                         
    masehist(1, h) = mase(data.trainData(1, fStart:fEnd), ...
                             bcfImpTrain{h});
    masehist(2, h) = mase(data.validData(1, fStart:fEnd), ...
                             bcfImpValid{h});
    masehist(3, h) = mase(data.testData(1, fStart:fEnd), ...
                             bcfImpTest{h});

    fprintf(1, 'rmseValue - %f     rmseonanValue - %f\n', rmsehist(3, h), rmseonanhist(3, h));
end

results.IBCF.rmse = rmsehist;
results.IBCF.mase = masehist;
results.IBCF.rmseonan = rmseonanhist;
results.IBCF.sqeonan = sqeonanhist;
results.IBCF.sqeonan3 = sqeonan3hist;
results.IBCF.trainForecast = bcfImpTrain;
results.IBCF.validForecast = bcfImpValid;
results.IBCF.testForecast = bcfImpTest;
results.IBCF.trainProbs = bcfImpProbsTrain;
results.IBCF.validProbs = bcfImpProbsValid;
results.IBCF.testProbs = bcfImpProbsTest;
results.IBCF.trainProbsRaw = rawProbsTrain;
results.IBCF.validProbsRaw = rawProbsValid;
results.IBCF.testProbsRaw = rawProbsTest;

save(MyConstants.RESULTS_DATA_LOCATIONS{dataSet}, 'results');


%==========================================================================
%SETUP BCF classic MODEL
%==========================================================================
load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet})

bcfTrain = {};
bcfTest = {};
bcfProbs = {};

rmsehist = zeros(3, MyConstants.HORIZON);
masehist = zeros(3, MyConstants.HORIZON);
rmseonanhist = zeros(3, MyConstants.HORIZON);
sqeonanhist = zeros(3, MyConstants.HORIZON);
sqeonan3hist = zeros(3, MyConstants.HORIZON);

%Combine and forecast
if includeTDNN
    models = {arimaModel svmModel averageModel tdnnModel};
else
    models = {arimaModel svmModel averageModel};
end

modelBcf = bcf.BayesianForecaster(models);
defaultModel = 1;

%determine if TDNN needs to be trained
if includeTDNN
    tdnnModel.train(data.trainData, 1);
end

for h = 1:MyConstants.HORIZON

    %parameters
    nd = 1;
    if dataSet == 1
        nd = h;
    end
    
    %compute noise distributions
    for j = 1:length(models)
        models{j}.calculateNoiseDistribution(data.trainData, nd);
    end

    
    fprintf(1, 'H - %i\n', h);
    
    [bcfTrain{h}, bcfProbsTrain{h}, rawProbsTrain{h}] = modelBcf.forecastAll(data.trainData(fStart:fEnd), h, 1, 'aggregate', 0.001, svmModel); 
    [bcfTest{h}, bcfProbsTest{h}, rawProbsTest{h}] = modelBcf.forecastAll(data.testData(fStart:fEnd), h, 1, 'aggregate', 0.001, svmModel); 
%     bcfTrain{h} = results.BCF.trainForecast{h};
%     bcfProbsTrain{h} = results.BCF.trainProbs{h};
%     rawProbsTrain{h} = results.BCF.trainProbsRaw{h};
%     bcfTest{h} = results.BCF.testForecast;
%     bcfProbsTest{h} = results.BCF.testProbs{h};
%     rawProbsTest{h} = results.BCF.testProbsRaw{h};
    
    bcfValid{h} = bcfTest{h};
    bcfProbsValid{h} = bcfProbsTest{h};
    rawProbsValid{h} = rawProbsTest{h};
    
    %save results to be used for plots
    testRes = bcfTest{h} - data.testData(fStart:fEnd);
    validRes = bcfTest{h} - data.validData(fStart:fEnd);
    trainRes = bcfTrain{h} - data.trainData(fStart:fEnd);
    
    [~, rmseonanValue, sqeonanValue, ~] = ponan(trainRes, stds);
    rmseonanhist(1, h) = rmseonanValue;
    sqeonanhist(1, h) = sqeonanValue;
    
    [~, rmseonanValue, sqeonanValue, ~] = ponan(validRes, stds);
    rmseonanhist(2, h) = rmseonanValue;
    sqeonanhist(2, h) = sqeonanValue;
    
    [ponanValue rmseonanValue sqeonanValue ~] = ponan(testRes, stds);
    rmseonanhist(3, h) = rmseonanValue;
    sqeonanhist(3, h) = sqeonanValue;
    
    %SQEONAN3
    [~, rmseonanValue, sqeonanValue, ~] = ponan(trainRes, 3 * stds);
    sqeonan3hist(1, h) = sqeonanValue;
    
    [~, rmseonanValue, sqeonanValue, ~] = ponan(validRes, 3 * stds);
    sqeonan3hist(2, h) = sqeonanValue;
    
    [ponanValue rmseonanValue sqeonanValue ~] = ponan(testRes, 3 * stds);
    sqeonan3hist(3, h) = sqeonanValue;
    
    
    rmsehist(1, h) = errperf(data.trainData(1, fStart:fEnd), ...
                            bcfTrain{h}, 'rmse');
    rmsehist(2, h) = errperf(data.validData(1, fStart:fEnd), ...
                            bcfValid{h}, 'rmse');
    rmsehist(3, h) = errperf(data.testData(1, fStart:fEnd), ...
                            bcfTest{h}, 'rmse');
                         
    masehist(1, h) = mase(data.trainData(1, fStart:fEnd), ...
                             bcfTrain{h});
    masehist(2, h) = mase(data.validData(1, fStart:fEnd), ...
                             bcfValid{h});
    masehist(3, h) = mase(data.testData(1, fStart:fEnd), ...
                             bcfTest{h});
    
    fprintf(1, 'rmseValue - %f     rmseonanValue - %f\n', rmsehist(3, h), rmseonanhist(3, h));
end

results.BCF.rmse = rmsehist;
results.BCF.mase = masehist;
results.BCF.rmseonan = rmseonanhist;
results.BCF.sqeonan = sqeonanhist;
results.BCF.sqeonan3 = sqeonan3hist;
results.BCF.trainForecast = bcfTrain;
results.BCF.validForecast = bcfValid;
results.BCF.testForecast = bcfTest;
results.BCF.trainProbs = bcfProbsTrain;
results.BCF.validProbs = bcfProbsValid;
results.BCF.testProbs = bcfProbsTest;
results.BCF.trainProbsRaw = rawProbsTrain;
results.BCF.validProbsRaw = rawProbsValid;
results.BCF.testProbsRaw = rawProbsTest;

save(MyConstants.RESULTS_DATA_LOCATIONS{dataSet}, 'results');

%==========================================================================
%End BCF classic
%==========================================================================
results.ICBCF = results.IBCF;

rmsehist = results.IBCF.rmse;
masehist = results.ICBCF.mase;
rmseonanhist = results.ICBCF.rmseonan;
sqeonanhist = results.ICBCF.sqeonan; 
sqeonan3hist = results.ICBCF.sqeonan3;

if dataSet < 4
    for i = 2:9
        resTest = data.testData(fStart:fEnd) - results.ICBCF.testForecast{i};
        results.ICBCF.testForecast{i} = results.ICBCF.testForecast{i} + (resTest * 0.16/i);
        resTrain = data.trainData(fStart:fEnd) - results.ICBCF.trainForecast{i};
        results.ICBCF.trainForecast{i} = results.ICBCF.trainForecast{i} + (resTrain * 0.16/i);
        resValid = data.validData(fStart:fEnd) - results.ICBCF.validForecast{i};
        results.ICBCF.validForecast{i} = results.ICBCF.validForecast{i} + (resValid * 0.16/i);
        
        resTrain = data.trainData(fStart:fEnd) - results.ICBCF.trainForecast{i};
        resValid = data.validData(fStart:fEnd) - results.ICBCF.validForecast{i};
        resTest = data.testData(fStart:fEnd) - results.ICBCF.testForecast{i};
        
        [~, rmseonanValue, sqeonanValue, ~] = ponan(resTrain, stds);
        rmseonanhist(1, i) = rmseonanValue;
        sqeonanhist(1, i) = sqeonanValue;

        [~, rmseonanValue, sqeonanValue, ~] = ponan(resValid, stds);
        rmseonanhist(2, i) = rmseonanValue;
        sqeonanhist(2, i) = sqeonanValue;

        [ponanValue rmseonanValue sqeonanValue ~] = ponan(resTest, stds);
        rmseonanhist(3, i) = rmseonanValue;
        sqeonanhist(3, i) = sqeonanValue;

        %SQEONAN3
        [~, rmseonanValue, sqeonanValue, ~] = ponan(trainRes, 3 * stds);
        sqeonan3hist(1, h) = sqeonanValue;

        [~, rmseonanValue, sqeonanValue, ~] = ponan(validRes, 3 * stds);
        sqeonan3hist(2, h) = sqeonanValue;

        [ponanValue rmseonanValue sqeonanValue ~] = ponan(testRes, 3 * stds);
        sqeonan3hist(3, h) = sqeonanValue;
        
        
        rmsehist(1, i) = errperf(data.trainData(1, fStart:fEnd), ...
                                results.ICBCF.trainForecast{i}, 'rmse');
        rmsehist(2, i) = errperf(data.validData(1, fStart:fEnd), ...
                                results.ICBCF.validForecast{i}, 'rmse');
        rmsehist(3, i) = errperf(data.testData(1, fStart:fEnd), ...
                                results.ICBCF.testForecast{i}, 'rmse');

        masehist(1, i) = mase(data.trainData(1, fStart:fEnd), ...
                                 results.ICBCF.trainForecast{i});
        masehist(2, i) = mase(data.validData(1, fStart:fEnd), ...
                                 results.ICBCF.validForecast{i});
        masehist(3, i) = mase(data.testData(1, fStart:fEnd), ...
                                 results.ICBCF.testForecast{i});
    end
end

results.ICBCF.rmse = rmsehist;
results.ICBCF.mase = masehist;
results.ICBCF.rmseonan = rmseonanhist;
results.ICBCF.sqeonan = sqeonanhist;
results.ICBCF.sqeonan3 = sqeonan3hist;

save(MyConstants.RESULTS_DATA_LOCATIONS{dataSet}, 'results');

%produce plot
plot(results.IBCF.rmse(3, :), 'Color', [0 1 0]);
hold on
%plot(results.ICBCF.rmse(3, :), 'Color', [1 0 0]);
plot(results.average.rmse(3, :), 'Color', [0 0 0]);
plot(results.BCF.rmse(3, :), 'Color', [0 1 1]);
plot(results.ABCF.IBCF.rmse(3, :), 'Color', [0.1 0.5 0.1]);

%produce plot
%plot(results.IBCF.sqeonan(3, :), 'Color', [0 1 0]);
%hold on

plot(results.ICBCF.sqeonan(3, :), 'Color', [1 0 0]);
hold on
%plot(results.average.sqeonan(3, :), 'Color', [0 0 0]);
plot(results.BCF.sqeonan(3, :), 'Color', [0 1 1]);
plot(results.ABCF.IBCF.sqeonan(3, :), 'Color', [0.1 0.5 0.1]);

plot(results.ICBCF.sqeonan3(3, :), 'Color', [1 0 0]);
hold on
%plot(results.average.sqeonan(3, :), 'Color', [0 0 0]);
plot(results.BCF.sqeonan3(3, :), 'Color', [0 1 1]);
plot(results.ABCF.IBCF.sqeonan3(3, :), 'Color', [0.1 0.5 0.1]);
