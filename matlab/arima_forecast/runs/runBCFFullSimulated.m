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

%Determine forecasting score.
mape = errperf(predinput(:, sdiff:end), input(:, sdiff:end), 'mape');
mse = errperf(predinput(:, sdiff:end), input(:, sdiff:end), 'mse');
rmse = errperf(predinput(:, sdiff:end), input(:, sdiff:end), 'rmse');

fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);

%TYPICAL PLOTS FOR EDIFICATION
plotStart = 3670;

%plot a typical window
x = linspace(1, plotSize, plotSize);
plot(x, [input(:, plotStart:plotStart + plotSize - 1); predinput(:, plotStart:plotStart + plotSize - 1)]);

%Generate a residual set
res = predinput - input;
%d = data.actTimes(data.actTimes > maxInput + sdiff);
dTimes = data.actTimes(data.actTimes < maxInput & data.actTimes > sdiff);
x = linspace(1, 16, 16);

for i = 1:size(dTimes, 2)
    plot(x, res(dTimes(i) + data.blocksInDay:dTimes(i) + 15 + data.blocksInDay));
    waitforbuttonpress;
end


%TRAIN TDNN
trainData = {};
%Build a dataset
for i = 1:size(dTimes, 2)
    trainData = [trainData res(dTimes(i) + data.blocksInDay:dTimes(i) + 14 + data.blocksInDay)]; %#ok<AGROW>
end


timeDelay = 6;
hiddenNodes = 20;
cinput = tonndata(trainData, true, false);

net = timedelaynet(1:timeDelay, hiddenNodes);

net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

[xs, xi, ai, ts] = preparets(net, cinput(:, 1:end - ahead), cinput(:, ahead + 1:end));
netAhead = train(net, xs, ts, xi, ai);
[xs, xi, ai, ts] = preparets(net, cinput(:, 1:end - 1), cinput(:, 1 + 1:end));
net1 = train(net, xs, ts, xi, ai);

modelTDNN = bcf.models.TDNN(net1, netAhead, ahead);
modelTDNN.calculateNoiseDistribution(input(1, 1:end));
tdpredoutput = modelTDNN.forecastAll(trainData, 1);

mape = errperf(tdpredoutput(:, sdiff:end), trainData(:, sdiff:end), 'mape');
mse = errperf(tdpredoutput(:, sdiff:end), trainData(:, sdiff:end), 'mse');
rmse = errperf(tdpredoutput(:, sdiff:end), trainData(:, sdiff:end), 'rmse');

fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);


x = linspace(1, 100, 100);
plot(x, [trainData(1:100); tdpredoutput(1:100)]);

%Train models
modelGaussian = bcf.models.Gaussian(myModel.noiseMu, myModel.noiseSigma);
modelGaussian.calculateNoiseDistribution(res);


models = {modelGaussian modelTDNN};

forecaster = bcf.BayesianForecaster(models);
[yprime, probs, ms] = forecaster.forecastAll(res, 'aggregate');
[yprime2, probs, ms] = forecaster.forecastAll(res, 'best');

mape = errperf(yprime(:, sdiff:end), res(:, sdiff:end), 'mape');
mse = errperf(yprime(:, sdiff:end), res(:, sdiff:end), 'mse');
rmse = errperf(yprime(:, sdiff:end), res(:, sdiff:end), 'rmse');

fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);

% mape = errperf(yprime2(:, sdiff:end), output(:, sdiff:end), 'mape');
% mse = errperf(yprime2(:, sdiff:end), output(:, sdiff:end), 'mse');
% rmse = errperf(yprime2(:, sdiff:end), output(:, sdiff:end), 'rmse');
% 
% fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);

x = linspace(1, plotSize, plotSize);
plot(x, [res(:, plotStart:plotStart + plotSize - 1); yprime(:, plotStart:plotStart + plotSize - 1)]);


tdpredoutput2 = modelTDNN.forecastAll(res(1, 3084:3098), 1);
x = linspace(1, 15, 15);
plot(x, [res(1, 3084:3098); tdpredoutput2(1, 1:15)]);




