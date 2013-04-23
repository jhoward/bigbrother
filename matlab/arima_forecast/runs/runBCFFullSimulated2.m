clear all;
load('./data/simulatedData.mat');

%SETUP DATA
plotSize = data.blocksInDay;
sensorNumber = 1;
ahead = 1;
windowSize = 10;

trainPercent = 0.7;

inputMax = floor((size(data.data, 2) / data.blocksInDay) * trainPercent) * data.blocksInDay;
input = data.data(sensorNumber, 1:inputMax);
output = data.data(sensorNumber, inputMax + 1:end);

%=======================ARIMA==========================

%SETUP ARIMA MODEL
ar = 1;
diff = 0;
ma = 1;
sar = 0;
sdiff = data.blocksInDay;
sma = 1;

arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
            'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);

model = estimate(arimaModel, input', 'print', false);

myModel = bcf.models.Arima(model);
myModel.calculateNoiseDistribution(input);
predInput = myModel.forecastAll(input, ahead);
predOutput = myModel.forecastAll(output, ahead);
resInput = predInput - input;
resOutput = predOutput - output;

%Arima model accuracy
trainRmse = errperf(input(sensorNumber, sdiff:end), predInput(sensorNumber, sdiff:end), 'rmse');
testRmse = errperf(output(sensorNumber, sdiff:end), predOutput(sensorNumber, sdiff:end), 'rmse');
fprintf(1, 'Arima fit Error rates -- train rmse:%f      test rmse %f\n', trainRmse, testRmse);

%=========================END ARIMA=========================

%Setup the times.
iIndex = find(data.actTimes < (inputMax - data.blocksInDay - data.actLength) & data.actTimes > sdiff);
iTimes = data.actTimes(iIndex);
iTypes = data.actTypes(iIndex);
oIndex = find(data.actTimes > (inputMax + sdiff + 1) & data.actTimes < (size(data.data, 2) - data.blocksInDay - data.actLength));
oTimes = data.actTimes(oIndex);
oTypes = data.actTypes(oIndex);
oTimes = oTimes - inputMax;

iActs = {};
oActs = {};

al = data.actLength + 3;
x = linspace(1, al, al);

%Get all residual activities from this and the next day
%TODO MAKE THIS MULTIVARIATE
actTypes = unique(data.actTypes);
for i = 1:size(actTypes, 2)
    tmpIndex = find(iTypes == actTypes(1, i));
    iActs{2 * i - 1} = ones(1 ,al, size(tmpIndex, 2));
    iActs{2 * i} = ones(1, al, size(tmpIndex, 2));
    for j = 1:size(tmpIndex, 2)
        iActs{2 * i - 1}(1, :, j) = resInput(1, iTimes(tmpIndex(j)):iTimes(tmpIndex(j)) + al - 1);
        iActs{2 * i}(1, :, j) = resInput(1, iTimes(tmpIndex(j)) + data.blocksInDay:iTimes(tmpIndex(j)) + data.blocksInDay + al - 1);
    end
end

%Get all residual activities from this and the next day
actTypes = unique(data.actTypes);
for i = 1:size(actTypes, 2)
    tmpIndex = find(oTypes == actTypes(1, i));
    oActs{2 * i - 1} = ones(1, al, size(tmpIndex, 2));
    oActs{2 * i} = ones(1, al, size(tmpIndex, 2));
    for j = 1:size(tmpIndex, 2)
        oActs{2 * i - 1}(1, :, j) = resOutput(1, oTimes(tmpIndex(j)):oTimes(tmpIndex(j)) + al - 1);
        oActs{2 * i}(1, :, j) = resOutput(1, oTimes(tmpIndex(j)) + data.blocksInDay:oTimes(tmpIndex(j)) + data.blocksInDay + al - 1);
    end
end

%================================PLOTTING==============================
%Plot the input activities
for i = 1:length(oActs)
    tmpData = oActs{i};
    for j = 1:size(tmpData, 3)
        plot(x, tmpData(1, :, j));
        hold on;
    end
    hold off
    waitforbuttonpress;
end

%===============================END PLOTTING===========================


% =========================TRAIN MODELS===================================

modelHMMS = {};

for i = 1:length(oActs)    
    modelHMMS{i} = bcf.models.HMM(al + 22, 2);
    modelHMMS{i}.train(oActs{i});
    modelHMMS{i}.calculateNoiseDistribution(oActs{i});

    modelHMMS{i}.prior(modelHMMS{i}.prior < 0.01) = 0.01;
    modelHMMS{i}.prior = normalize(modelHMMS{i}.prior);
end

modelGaussian = bcf.models.Gaussian(myModel.noiseMu, myModel.noiseSigma);
modelGaussian.calculateNoiseDistribution(resInput);
%==========================END TRAIN===================================


%=============================PLOT Forecasts on Models==================
for i = 1:length(oActs)
    for j = 1:size(oActs{i}, 3)
        tmpForecast = modelHMMS{i}.forecastAll(oActs{i}(:, :, j), 1, 'window', 4);
        plot(x, [oActs{i}(1, :, j); tmpForecast(1, :)]);
        hold on
    end
    hold off
    waitforbuttonpress;
end
%=============================END PLOT===================================


%=============================PERFORM FORECASTS========================

models = modelHMMS;
models{length(models) + 1} = modelGaussian;

forecaster = bcf.BayesianForecaster(models);
[fInput, probsInput, ms] = forecaster.forecastAll(resInput, 'aggregate');
[fOutput, probsOutput, ms] = forecaster.forecastAll(resOutput, 'aggregate');

gaussInput = modelGaussian.forecastAll(resInput, ahead);
gaussOutput = modelGaussian.forecastAll(resOutput, ahead);

totalInput = predInput - fInput;
totalOutput = predOutput - fOutput;

%============================END FORECASTS=============================


%=============================DETERMINE SCORES=========================

rmse = errperf(predInput(:, sdiff:end), input(:, sdiff:end), 'rmse');
fprintf(1, 'Arima Input data Error rates -- rmse:%f\n', rmse);

rmse = errperf(gaussInput(:, sdiff:end), resInput(:, sdiff:end), 'rmse');
fprintf(1, 'Gauss fit res data Error rates -- rmse:%f\n', rmse);

rmse = errperf(fInput(:, sdiff:end), resInput(:, sdiff:end), 'rmse');
fprintf(1, 'Combined fit res input data Error rates -- rmse:%f\n', rmse);
 
rmse = errperf(predOutput(:, sdiff:end), output(:, sdiff:end), 'rmse');
fprintf(1, 'Arima Input data Error rates -- rmse:%f\n', rmse);

rmse = errperf(gaussOutput(:, sdiff:end), resOutput(:, sdiff:end), 'rmse');
fprintf(1, 'Gauss fit res data Error rates -- rmse:%f\n', rmse);

rmse = errperf(fOutput(:, sdiff:end), resOutput(:, sdiff:end), 'rmse');
fprintf(1, 'Combined fit res input data Error rates -- rmse:%f\n', rmse);
 
%==============================PLOT RESULTS===============================


xPlot = linspace(1, 100, 100);
for i = 1:size(oTimes, 2)
    t = oTimes(i);
    plot(xPlot, [output(t - 20:t + 79); predOutput(t - 20: t + 79); totalOutput(t - 20: t + 79)]);
end



% plotStart = 2250 + data.blocksInDay;
% plotSize = 100;
% rOut = res(:, plotStart:plotStart + plotSize - 1);
% 
% fOut = modelHMM.forecastAll(rOut, 1, 'window', 3);
% 

% 
% x = linspace(1, plotSize, plotSize);
% plot(x, [rOut(1, :); yprime(1, :)]);
% plot(x, [rOut(1, :); fOut(1, :)]);
% 
% plot(x, [res(1, plotStart:plotStart + plotSize - 1); yprime(1, plotStart:plotStart + plotSize - 1)]);
% 
% rmse = errperf(yprime(:, sdiff:end), res(:, sdiff:end), 'rmse');
% fprintf(1, 'Residual Error rates Combined -- rmse:%f\n', rmse);
% 
% total = predinput - yprime;
% 
% rmse = errperf(total(:, sdiff:end), input(:, sdiff:end), 'rmse');
% fprintf(1, 'New Error rates -- rmse:%f\n', rmse);
% 
% %Calculate residual during the new forecast spots
% yForecast = [];
% aData = [];
% aForecast = [];
% for i = 1:size(dTimes, 2)
%     st = dTimes(i);
%     yForecast = [yForecast total(st + data.blocksInDay - 5:st + data.blocksInDay + data.actLength + 5)]; 
%     aData = [aData input(st + data.blocksInDay - 5:st + data.blocksInDay + data.actLength + 5)];
%     aForecast = [aForecast predinput(st + data.blocksInDay - 5:st + data.blocksInDay + data.actLength + 5)];
% end
% rmse = errperf(aData(:, sdiff:end), yForecast(:, sdiff:end), 'rmse');
% fprintf(1, 'Anomaly error rates adjusted -- rmse:%f\n', rmse);
% rmse = errperf(aData(:, sdiff:end), aForecast(:, sdiff:end), 'rmse');
% fprintf(1, 'Anomaly error rates base -- rmse:%f\n', rmse);
% 
% %Print out all the forecasts in dTimes
% x = linspace(1, plotSize, plotSize);
% for i = 1:size(dTimes, 2)
%     dTimes(i)
%     %plotStart = dTimes(i) + data.blocksInDay - 30;
%     plotStart = dTimes(i) - 30;
%     plot(x, [input(:, plotStart:plotStart + plotSize - 1); predinput(:, plotStart:plotStart + plotSize - 1); total(:, plotStart:plotStart + plotSize - 1)]);
%     waitforbuttonpress
% end
% 
% plotStart = 1740
% x = linspace(1, plotSize, plotSize);
% plot(x, [input(:, plotStart:plotStart + plotSize - 1); predinput(:, plotStart:plotStart + plotSize - 1); total(:, plotStart:plotStart + plotSize - 1)]);
