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


%Get all residual activities from this and the next day
actTypes = unique(data.actTypes);
for i = 1:size(actTypes)
    tmpIndex = find(iTypes == actTypes(i));
    for j = 1:size(tmpIndex, 2)
        iTypes(iTypes = actTYpes(i))
end





x = linspace(1, data.actLength + 3, data.actLength + 3);

%Plot day ahead
for i = 1:size(dTimes, 2)
    plot(x, res(dTimes(i) + data.blocksInDay:dTimes(i) + data.actLength + data.blocksInDay + 2));
    hold on;
end

%Plot day of
for i = 1:size(dTimes, 2)
    plot(x, res(dTimes(i):dTimes(i) + data.actLength + 2));
    hold on;
end


%TODO FINISH THIS PART
%Train HMM on day after
tmpData = ones(size(res, 1), data.actLength + 3, size(dTimes, 2));
tmpData2 = ones(size(res, 1), data.actLength, size(dTimes, 2));

for i = 1:size(dTimes, 2)
    tmpData(:, :, i) = res(dTimes(i) + data.blocksInDay:dTimes(i) + data.blocksInDay + data.actLength + 2);
end


for i = 1:size(dTimes, 2)
    tmpData2(:, :, i) = res(dTimes(i) + data.blocksInDay - 2:dTimes(i) + data.blocksInDay + data.actLength - 3);
end

modelHMM = bcf.models.HMM(data.actLength + 15, 2);
modelHMM.train(tmpData);
modelHMM.calculateNoiseDistribution(tmpData);

modelHMM.prior(modelHMM.prior < 0.01) = 0.01;
modelHMM.prior = normalize(modelHMM.prior);


%%Train HMM on day of error
tmpDataDay = ones(size(res, 1), data.actLength + 3, size(dTimes, 2));

for i = 1:size(dTimes, 2)
    tmpDataDay(:, :, i) = res(dTimes(i):dTimes(i) + data.actLength + 2);
end

modelHMM2 = bcf.models.HMM(data.actLength + 15, 2);
modelHMM2.train(tmpDataDay);
modelHMM2.calculateNoiseDistribution(tmpDataDay);

modelHMM2.prior(modelHMM.prior < 0.01) = 0.01;
modelHMM2.prior = normalize(modelHMM.prior);

%Test the forecast
output = tmpData;

x = linspace(1, size(tmpData, 2), size(tmpData, 2));
for i = 1:size(output, 3)
    output(:, :, i) = modelHMM.forecastAll(output(:, :, i), 1, 'window', 4);
end

for i = 1:size(output, 3)
    plot(x, [tmpData(:, :, i); output(:, :, i)]);
    hold on
end

%Test the forecast for day of
output = tmpDataDay;

x = linspace(1, size(tmpDataDay, 2), size(tmpDataDay, 2));
for i = 1:size(output, 3)
    output(:, :, i) = modelHMM2.forecastAll(output(:, :, i), 1, 'window', 4);
end

for i = 1:size(output, 3)
    plot(x, [tmpDataDay(:, :, i); output(:, :, i)]);
    hold on
end

%Train models
modelGaussian = bcf.models.Gaussian(myModel.noiseMu, myModel.noiseSigma);
modelGaussian.calculateNoiseDistribution(res);

%Determine naive forecasting scores
% %Determine forecasting score.

gaussOut = modelGaussian.forecastAll(res, 1);

rmse = errperf(predinput(:, sdiff:end), input(:, sdiff:end), 'rmse');
fprintf(1, 'Input data Error rates -- rmse:%f\n', rmse);

rmse = errperf(gaussOut(:, sdiff:end), res(:, sdiff:end), 'rmse');
fprintf(1, 'Gauss fit res data Error rates -- rmse:%f\n', rmse);

models = {modelGaussian modelHMM modelHMM2};

plotStart = 2250 + data.blocksInDay;
plotSize = 100;
rOut = res(:, plotStart:plotStart + plotSize - 1);

fOut = modelHMM.forecastAll(rOut, 1, 'window', 3);

forecaster = bcf.BayesianForecaster(models);
[yprime, probs, ms] = forecaster.forecastAll(res, 'aggregate');
%[yprime, probs, ms] = forecaster.forecastAll(rOut, 'aggregate');
%[yprime, probs, ms] = forecaster.forecastAll(res, 'best');

x = linspace(1, plotSize, plotSize);
plot(x, [rOut(1, :); yprime(1, :)]);
plot(x, [rOut(1, :); fOut(1, :)]);

plot(x, [res(1, plotStart:plotStart + plotSize - 1); yprime(1, plotStart:plotStart + plotSize - 1)]);

rmse = errperf(yprime(:, sdiff:end), res(:, sdiff:end), 'rmse');
fprintf(1, 'Residual Error rates Combined -- rmse:%f\n', rmse);

total = predinput - yprime;

rmse = errperf(total(:, sdiff:end), input(:, sdiff:end), 'rmse');
fprintf(1, 'New Error rates -- rmse:%f\n', rmse);

%Calculate residual during the new forecast spots
yForecast = [];
aData = [];
aForecast = [];
for i = 1:size(dTimes, 2)
    st = dTimes(i);
    yForecast = [yForecast total(st + data.blocksInDay - 5:st + data.blocksInDay + data.actLength + 5)]; 
    aData = [aData input(st + data.blocksInDay - 5:st + data.blocksInDay + data.actLength + 5)];
    aForecast = [aForecast predinput(st + data.blocksInDay - 5:st + data.blocksInDay + data.actLength + 5)];
end
rmse = errperf(aData(:, sdiff:end), yForecast(:, sdiff:end), 'rmse');
fprintf(1, 'Anomaly error rates adjusted -- rmse:%f\n', rmse);
rmse = errperf(aData(:, sdiff:end), aForecast(:, sdiff:end), 'rmse');
fprintf(1, 'Anomaly error rates base -- rmse:%f\n', rmse);

%Print out all the forecasts in dTimes
x = linspace(1, plotSize, plotSize);
for i = 1:size(dTimes, 2)
    dTimes(i)
    %plotStart = dTimes(i) + data.blocksInDay - 30;
    plotStart = dTimes(i) - 30;
    plot(x, [input(:, plotStart:plotStart + plotSize - 1); predinput(:, plotStart:plotStart + plotSize - 1); total(:, plotStart:plotStart + plotSize - 1)]);
    waitforbuttonpress
end

plotStart = 1740
x = linspace(1, plotSize, plotSize);
plot(x, [input(:, plotStart:plotStart + plotSize - 1); predinput(:, plotStart:plotStart + plotSize - 1); total(:, plotStart:plotStart + plotSize - 1)]);
