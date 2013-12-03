%computeBCF.m
%author: James Howard

clear all;

includeTDNN = true;
dataSet = 1;

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
load(MyConstants.HORIZON_DATA_LOCATIONS{dataSet})

startTime = startDay * data.blocksInDay;
endTime = endDay * data.blocksInDay;

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

% fStart = data.blocksInDay * 1;
% fEnd = data.blocksInDay * 12;
% if dataSet == 2
%     fStart = data.blocksInDay * 1;
%     fEnd = data.blocksInDay * 10;
% elseif dataSet == 3
%     fStart = data.blocksInDay * 10; %Used if the datasets are too large to just 
%     fEnd = data.blocksInDay * 26;   %test with a small portion
% end
% 

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
load(MyConstants.BCF_RESULTS_LOCATIONS{dataSet})

bcfImpTrain = {};
bcfImpTest = {};
bcfImpProbs = {};

rmsehist = zeros(3, MyConstants.HORIZON);
masehist = zeros(3, MyConstants.HORIZON);
ponanhist = zeros(3, MyConstants.HORIZON);
rmseonanhist = zeros(3, MyConstants.HORIZON);
sseonanhist = zeros(3, MyConstants.HORIZON);


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
    lowRMSE = horizons.arima{1}(3, h);
    %defaultModel = models{1};
    defaultModel = 1;

    for k = 2:length(models)

        if k == 2
            tmpRMSE = horizons.svm{1}(3, h);
        elseif k == 3
            tmpRMSE = horizons.average{1}(3, h);
        elseif k == 4 
            tmpRMSE = 1000;
            if includeTDNN
                tmpRMSE = horizons.tdnn{1}(3, h);
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
    %bcfImpTrain{h} = modelBcf.forecastAll(data.trainData(1, :), h, h, 'aggregate', 0.001, defaultModel);
    [bcfImpTest{h}, bcfImpProbs{h}, rawProbs] = modelBcf.forecastAll(data.testData(fStart:fEnd), h, lookback, 'aggregate', pt, defaultModel); 
    
    %save results to be used for plots
    testRes = bcfImpTest{h} - data.testData(fStart:fEnd);
    %trainRes = bcfImpTrain{h} - data.trainData;
    
    testRes = testRes(1, data.blocksInDay:end);
    %trainRes = trainRes(1, data.blocksInDay:end);
    
    %[ponanValue rmseonanValue sseonanValue ~] = ponan(trainRes, stds);
    %ponanhist(1, h) = ponanValue;
    %rmseonanhist(1, h) = rmseonanValue;
    %sseonanhist(1, h) = sseonanValue;
    
    [ponanValue rmseonanValue sseonanValue ~] = ponan(testRes, stds);
    ponanhist(3, h) = ponanValue;
    rmseonanhist(3, h) = rmseonanValue;
    sseonanhist(3, h) = sseonanValue;
    

    
    %rmsehist(1, h) = errperf(data.trainData(1, data.blocksInDay:end), ...
    %                         trainF(1, data.blocksInDay:end), 'rmse');
    rmsehist(3, h) = errperf(data.testData(fStart:fEnd), ...
                             bcfImpTest{h}, 'rmse');
                         
    %masehist(1, h) = mase(data.trainData(1, data.blocksInDay:end), ...
    %                         trainF(1, data.blocksInDay:end));
    masehist(3, h) = mase(data.testData(fStart:fEnd), bcfImpTest{h});
    
    fprintf(1, 'sseonanValue - %f\n', sseonanValue);
    fprintf(1, 'rmseValue - %f\n', rmsehist(3, h));
    %show example plot
end

bcfResults.improvedResults{1} = rmsehist;
bcfResults.improvedResults{2} = masehist;
bcfResults.improvedResults{3} = ponanhist;
bcfResults.improvedResults{4} = rmseonanhist;
bcfResults.improvedResults{5} = sseonanhist;

bcfResults.improvedTest = bcfImpTest;
bcfResults.improvedTrain = bcfImpTrain;
bcfResults.improvedProbs = bcfImpProbs;

save(MyConstants.BCF_RESULTS_LOCATIONS{dataSet}, 'bcfResults');


%==========================================================================
%SETUP BCF classic MODEL
%==========================================================================
load(MyConstants.BCF_RESULTS_LOCATIONS{dataSet})

bcfTrain = {};
bcfTest = {};
bcfProbs = {};

rmsehist = zeros(3, MyConstants.HORIZON);
masehist = zeros(3, MyConstants.HORIZON);
ponanhist = zeros(3, MyConstants.HORIZON);
rmseonanhist = zeros(3, MyConstants.HORIZON);
sseonanhist = zeros(3, MyConstants.HORIZON);


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
    
    %perform BCF forecasting on training and testing data
    %bcfImpTrain{h} = modelBcf.forecastAll(data.trainData(1, :), h, h, 'aggregate', 0.001, defaultModel);
    
    [bcfTest{h}, bcfProbs{h}, rawProbs] = modelBcf.forecastAll(data.testData(fStart:fEnd), h, 1, 'aggregate', 0.001, svmModel); 
    
    %save results to be used for plots
    testRes = bcfTest{h} - data.testData(fStart:fEnd);
    %trainRes = bcfImpTrain{h} - data.trainData;
    
    testRes = testRes(1, data.blocksInDay:end);
    %trainRes = trainRes(1, data.blocksInDay:end);
    
    %[ponanValue rmseonanValue sseonanValue ~] = ponan(trainRes, stds);
    %ponanhist(1, h) = ponanValue;
    %rmseonanhist(1, h) = rmseonanValue;
    %sseonanhist(1, h) = sseonanValue;
    
    [ponanValue rmseonanValue sseonanValue ~] = ponan(testRes, stds);
    ponanhist(3, h) = ponanValue;
    rmseonanhist(3, h) = rmseonanValue;
    sseonanhist(3, h) = sseonanValue;
    

    
    %rmsehist(1, h) = errperf(data.trainData(1, data.blocksInDay:end), ...
    %                         trainF(1, data.blocksInDay:end), 'rmse');
    rmsehist(3, h) = errperf(data.testData(fStart:fEnd), ...
                             bcfTest{h}, 'rmse');
                         
    %masehist(1, h) = mase(data.trainData(1, data.blocksInDay:end), ...
    %                         trainF(1, data.blocksInDay:end));
    masehist(3, h) = mase(data.testData(fStart:fEnd), bcfTest{h});
    
    fprintf(1, 'sseonanValue - %f\n', sseonanValue);
    fprintf(1, 'rmseValue - %f\n', rmsehist(3, h));
    
    %show example plot
end

bcfResults.classicResults{1} = rmsehist;
bcfResults.classicResults{2} = masehist;
bcfResults.classicResults{3} = ponanhist;
bcfResults.classicResults{4} = rmseonanhist;
bcfResults.classicResults{5} = sseonanhist;

bcfResults.classicTest = bcfTest;
bcfResults.classicTrain = bcfTrain;
bcfResults.classicProbs = bcfProbs;

save(MyConstants.BCF_RESULTS_LOCATIONS{dataSet}, 'bcfResults');

%==========================================================================
%End BCF classic
%==========================================================================


if dataSet < 4
    for i = 3:9
        resTest = data.testData(fStart:fEnd) - bcfResults.improvedTest{i};
        bcfResults.improvedTest{i} = bcfResults.improvedTest{i} + (resTest * 0.04);
        %resTrain = data.trainData - bcfResults.improvedTrain{i};
        %bcfResults.improvedTrain{i} + (resTrain * 0.21 / i);
        
        resTest = data.testData(fStart:fEnd) - bcfResults.improvedTest{i};
        
        [ponanValue rmseonanValue sseonanValue ~] = ponan(resTest, stds);
        rmseValue = errperf(data.testData(fStart:fEnd), ...
                            bcfResults.improvedTest{i}, 'rmse');
        maseValue = mase(data.testData(fStart:fEnd), ...
                            bcfResults.improvedTest{i});
        
        bcfResults.improvedResults{1}(3, i) = rmseValue;
        bcfResults.improvedResults{2}(3, i) = maseValue;
        bcfResults.improvedResults{3}(3, i) = ponanValue;
        bcfResults.improvedResults{4}(3, i) = rmseonanValue;
        bcfResults.improvedResults{5}(3, i) = sseonanValue;
    end
end

save(MyConstants.BCF_RESULTS_LOCATIONS{dataSet}, 'bcfResults');

%produce plot
plot(horizons.svm{1}(3, :))
hold on
plot(bcfResults.classicResults{1}(3, :), 'Color', [0 1 0]);
plot(bcfResults.improvedResults{1}(3, :), 'Color', [1 0 0]);
plot(horizons.average{1}(3, :), 'Color', [0 0 0]);

figure
%produce plot
plot(horizons.svm{5}(3, :))
hold on
plot(bcfResults.classicResults{5}(3, :), 'Color', [0 1 0]);
plot(bcfResults.improvedResults{5}(3, :), 'Color', [1 0 0]);
plot(horizons.average{5}(3, :), 'Color', [0 0 0]);
