clear all;
%Visualize Simulated Data.
load('./data/simulatedData.mat');

%SETUP DATA
plotSize = data.blocksInDay * 2;
sensorNumber = 1;
ahead = 1;
windowSize = 10;
numErrorWindows = 10;

maxInput = data.blocksInDay * 70; %6 months or so
outputRange = data.blocksInDay * 129; %3 weeks of output
plotStart = data.blocksInDay * 17;
input = data.data(sensorNumber, 1:maxInput);
output = data.data(sensorNumber, maxInput + 1:maxInput + outputRange);


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
predinput = myModel.forecastAll(input, ahead);

% %Determine forecasting score.
% mape = errperf(predinput(:, sdiff:end), input(:, sdiff:end), 'mape');
% mse = errperf(predinput(:, sdiff:end), input(:, sdiff:end), 'mse');
% rmse = errperf(predinput(:, sdiff:end), input(:, sdiff:end), 'rmse');
% 
% fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);

%TYPICAL PLOTS FOR EDIFICATION
plotStart = 2700;

%plot a typical window
x = linspace(1, plotSize, plotSize);
plot(x, [input(:, plotStart:plotStart + plotSize - 1); predinput(:, plotStart:plotStart + plotSize - 1)]);

%Generate a residual set
res = predinput - input;
%d = data.actTimes(data.actTimes > maxInput + sdiff);
dTimes = data.actTimes(data.actTimes < (maxInput - data.blocksInDay - data.actLength) & data.actTimes > sdiff);
x = linspace(1, data.actLength + 1, data.actLength + 1);

for i = 1:size(dTimes, 2)
    plot(x, res(dTimes(i) + data.blocksInDay:dTimes(i) + data.actLength + data.blocksInDay));
    hold on;
end


%Train HMM
tmpData = ones(size(res, 1), data.actLength, size(dTimes, 2));

for i = 1:size(dTimes, 2)
    tmpData(:, :, i) = res(dTimes(i) + data.blocksInDay:dTimes(i) + data.blocksInDay + data.actLength - 1);
end

modelHMM = bcf.models.HMM(data.actLength + 5, 2);
modelHMM.train(tmpData);
modelHMM.calculateNoiseDistribution(tmpData);

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














models = {modelGaussian modelHMM};


forecaster = bcf.BayesianForecaster(models);
[yprime, probs, ms] = forecaster.forecastAll(res, 'aggregate');
[yprime, probs, ms] = forecaster.forecastAll(res, 'best');

mape = errperf(yprime(:, sdiff:end), res(:, sdiff:end), 'mape');
mse = errperf(yprime(:, sdiff:end), res(:, sdiff:end), 'mse');
rmse = errperf(yprime(:, sdiff:end), res(:, sdiff:end), 'rmse');

fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);

x = linspace(1, plotSize, plotSize);
plot(x, [res(:, plotStart:plotStart + plotSize - 1); yprime(:, plotStart:plotStart + plotSize - 1)]);

plotStart = 2250

total = predinput + yprime;

mape = errperf(total(:, sdiff:end), input(:, sdiff:end), 'mape');
mse = errperf(total(:, sdiff:end), input(:, sdiff:end), 'mse');
rmse = errperf(total(:, sdiff:end), input(:, sdiff:end), 'rmse');

fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);

x = linspace(1, plotSize, plotSize);
plot(x, [input(:, plotStart:plotStart + plotSize - 1); predinput(:, plotStart:plotStart + plotSize - 1); total(:, plotStart:plotStart + plotSize - 1);]);


















%Forecasting for other functions
% %TRAIN TDNN
% %Create sample set - I can do this better later.
% tmpData = ones(size(res, 1), size(dTimes, 2) * data.actLength);
% 
% for i = 1:size(dTimes, 2)
%     tmpData(:, (i - 1) * data.actLength + 1:i * data.actLength) = res(dTimes(i) + data.blocksInDay:dTimes(i) + data.blocksInDay + data.actLength - 1);
% end
% 
% trainData = mat2cell(tmpData, size(tmpData, 1), ones(size(dTimes, 2), 1) * data.actLength);
% 
% timeDelay = 6;
% hiddenNodes = 20;
% %cinput = tonndata(trainData, true, false);
% cinput = trainData;
% 
% net = timedelaynet(1:timeDelay, hiddenNodes);
% 
% net.divideParam.trainRatio = 70/100;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;
% 
% [xs, xi, ai, ts] = preparets(net, cinput(:, 1:end - ahead), cinput(:, ahead + 1:end));
% netAhead = train(net, xs, ts, xi, ai);
% [xs, xi, ai, ts] = preparets(net, cinput(:, 1:end - 1), cinput(:, 1 + 1:end));
% net1 = train(net, xs, ts, xi, ai);
% 
% modelTDNN = bcf.models.TDNN(net1, netAhead, ahead);
% modelTDNN.calculateNoiseDistribution(tmpData);
% tdpredoutput = modelTDNN.forecastAll(tmpData, 1);
% % 
% % mape = errperf(tdpredoutput(:, sdiff:end), trainData(:, sdiff:end), 'mape');
% % mse = errperf(tdpredoutput(:, sdiff:end), trainData(:, sdiff:end), 'mse');
% % rmse = errperf(tdpredoutput(:, sdiff:end), trainData(:, sdiff:end), 'rmse');
% % 
% % fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);
% % 
% 
% x = linspace(1, 100, 100);
% plot(x, [tmpData(1:100); tdpredoutput(1:100)]);