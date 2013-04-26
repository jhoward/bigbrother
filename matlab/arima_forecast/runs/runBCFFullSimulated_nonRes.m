clear all;
load('./data/simulatedData.mat');

%SETUP DATA
plotSize = data.blocksInDay;
sensorNumber = 1;
ahead = 5;
windowSize = 10;

trainPercent = 0.7;

inputMax = floor((size(data.data, 2) / data.blocksInDay) * trainPercent) * data.blocksInDay;
input = data.data(sensorNumber, 1:inputMax);
output = data.data(sensorNumber, inputMax + 1:end);

%Do this for now
data.actTimes = data.actDays;
data.actTypes = data.dayTypes;
data.actLength = data.blocksInDay;

sdiff = data.blocksInDay;

%Setup the times.
iIndex = find(data.actTimes < (inputMax - data.blocksInDay - data.actLength) & data.actTimes > sdiff);
iTimes = data.actTimes(iIndex);
iTypes = data.actTypes(iIndex);
oIndex = find(data.actTimes > (inputMax + sdiff + 1) & data.actTimes < (size(data.data, 2) - data.blocksInDay - data.actLength));
oTimes = data.actTimes(oIndex);
oTypes = data.actTypes(oIndex);
oTimes = oTimes - inputMax;

iActs = {};
inActs = {};
oActs = {};

al = data.actLength;
x = linspace(1, al, al);

%Get all residual activities from this and the next day
%TODO MAKE THIS MULTIVARIATE
actTypes = unique(data.actTypes);
for i = 1:size(actTypes, 2)
    tmpIndex = find(iTypes == actTypes(1, i));
    iActs{2 * i - 1} = [];
    iActs{2 * i} = [];
    for j = 1:size(tmpIndex, 2)
        iActs{2 * i - 1} = [iActs{2 * i - 1} input(1, iTimes(tmpIndex(j)):iTimes(tmpIndex(j)) + al - 1)];
        iActs{2 * i} = [iActs{2 * i} input(1, iTimes(tmpIndex(j)) + data.blocksInDay:iTimes(tmpIndex(j)) + data.blocksInDay + al - 1)];
    end
end

normalTimes = linspace(1, size(input, 2)/data.blocksInDay, size(input, 2)/data.blocksInDay) * data.blocksInDay;

tmp = ismember(normalTimes, iTimes);
tmp = tmp - 1;
tmp = tmp * -1;
normalTimes = normalTimes(tmp == 1);

iActs{size(iActs, 2) + 1} = [];
for i = 1:size(normalTimes, 2) - 1
    iActs{size(iActs, 2)} = [iActs{size(iActs, 2)} input(1, normalTimes(1, i):normalTimes(1, i) + data.blocksInDay - 1)];
end


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

% =========================TRAIN MODELS===================================
ar = 1;
diff = 0;
ma = 1;
sar = 0;
sdiff = 1;
sma = 1;

models = {};

for i = 1:length(iActs)
    arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
            'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);

    model = estimate(arimaModel, iActs{i}', 'print', false);

    models{i} = bcf.models.Arima(model);
    models{i}.calculateNoiseDistribution(iActs{i});
end
%==========================END TRAIN===================================

models{size(models, 2) + 1} = myModel;

%fOutput = models{3}.forecastAll(output, ahead);

%Only plot from a limited amount of time
lStart = 576;
lEnd = 1056;

%=============================PERFORM FORECASTS========================
tic
forecaster = bcf.BayesianForecaster(models);
[fInput, probsInput, ms] = forecaster.forecastAll(input, ahead, 'aggregate');
%[fOutput, probsOutput, ms] = forecaster.forecastAll(rOut, 5, 'aggregate');
[fOutput, probsOutput, ms] = forecaster.forecastAll(output, ahead, 'aggregate');
%[fOutput, probsOutput, ms] = forecaster.windowForecast(resOutput, 3, 10, ahead, 'aggregate');
%[fOutput, probsOutput, ms, windows, forecasts] = forecaster.windowForecast(rOut, 5, 15, ahead, 'aggregate');
toc

totalInput = fInput;
totalOutput = fOutput;
%============================END FORECASTS=============================


%=============================DETERMINE SCORES=========================
rmse = errperf(predInput(:, sdiff:end), input(:, sdiff:end), 'rmse');
fprintf(1, 'Arima Input data Error rates -- rmse:%f\n', rmse);

rmse = errperf(predOutput(:, sdiff:end), output(:, sdiff:end), 'rmse');
fprintf(1, 'Arima output data Error rates -- rmse:%f\n', rmse);

rmse = errperf(totalInput(:, sdiff:end), input(:, sdiff:end), 'rmse');
fprintf(1, 'Combined input data Error rates -- rmse:%f\n', rmse);
 
rmse = errperf(totalOutput(:, sdiff:end), output(:, sdiff:end), 'rmse');
fprintf(1, 'Combined output data Error rates -- rmse:%f\n', rmse);

%rmse = errperf(gaussOutput(:, sdiff:end), rOut(:, sdiff:end), 'rmse');
%fprintf(1, 'Gauss fit res data Error rates -- rmse:%f\n', rmse);

%rmse = errperf(fOutput(:, sdiff:end), rOut(:, sdiff:end), 'rmse');
%fprintf(1, 'Combined fit res input data Error rates -- rmse:%f\n', rmse);
 
%==============================PLOT RESULTS===============================


% xPlot = linspace(1, 200, 200);
% for i = 1:size(oTimes, 2)
%     t = oTimes(i);
%     plot(xPlot, [output(t - 20:t + 179); predOutput(t - 20: t + 179); totalOutput(t - 20: t + 179)]);
% end

xPlot = linspace(1, 220, 220);
for i = 1:100:size(totalOutput, 2) - 220
    plot(xPlot, [output(lStart + i:lStart + i + 219); predOutput(lStart + i:lStart + i + 219); totalOutput(:, lStart + i:lStart + i + 219)]);
    xlim([1 220]);
    waitforbuttonpress;
end