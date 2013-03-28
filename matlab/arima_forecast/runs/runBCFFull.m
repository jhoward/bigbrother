%Run bayesian combined forcasting using a combination of multiple trained
%models. 

clear all;

%BROWN
% fileName = 'brown';
% 
% load(strcat('./data/', fileName, 'Data.mat'));
% 
% plotSize = data.blocksInDay * 2;
% sensorNumber = 3;
% ahead = 3;
% windowSize = 10;
% numErrorWindows = 10;
% 
% maxInput = data.blocksInDay * 90; %3 months or so
% outputRange = data.blocksInDay * 21; %3 weeks of output
% plotStart = data.blocksInDay * 15;
% input = data.data(sensorNumber, 1:maxInput);
% output = data.data(sensorNumber, maxInput + 1:maxInput + outputRange);

%DENVER
fileName = 'denver';

load(strcat('./data/', fileName, 'Data.mat'));

plotSize = data.blocksInDay * 2;
sensorNumber = 3;
ahead = 3;
windowSize = 10;
numErrorWindows = 10;

maxInput = data.blocksInDay * 150; %6 months or so
outputRange = data.blocksInDay * 21; %3 weeks of output
plotStart = data.blocksInDay * 17;
input = data.data(sensorNumber, 1:maxInput);
output = data.data(sensorNumber, maxInput + 1:maxInput + outputRange);


%Arima model
ar = 1;
diff = 0;
ma = 1;
sar = 0;
sdiff = 7*data.blocksInDay;
sma = 1;

arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
            'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);

model = estimate(arimaModel, input', 'print', false);

modelArima = bcf.models.Arima(model);
modelArima.calculateNoiseDistribution(input);
apredoutput = modelArima.forecastAll(output, 1);

mape = errperf(apredoutput(:, sdiff:end), output(:, sdiff:end), 'mape');
mse = errperf(apredoutput(:, sdiff:end), output(:, sdiff:end), 'mse');
rmse = errperf(apredoutput(:, sdiff:end), output(:, sdiff:end), 'rmse');

fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);

%TDNN
timeDelay = 3;
hiddenNodes = 10;
cinput = tonndata(input, true, false);
coutput = tonndata(output, true, false);

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
tdpredoutput = modelTDNN.forecastAll(output, 1);

mape = errperf(tdpredoutput(:, sdiff:end), output(:, sdiff:end), 'mape');
mse = errperf(tdpredoutput(:, sdiff:end), output(:, sdiff:end), 'mse');
rmse = errperf(tdpredoutput(:, sdiff:end), output(:, sdiff:end), 'rmse');

fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);


%TDNN number 2
timeDelay = 10;
hiddenNodes = 20;
cinput = tonndata(input, true, false);
coutput = tonndata(output, true, false);

net = timedelaynet(1:timeDelay, hiddenNodes);

net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

[xs, xi, ai, ts] = preparets(net, cinput(:, 1:end - ahead), cinput(:, ahead + 1:end));
netAhead = train(net, xs, ts, xi, ai);
[xs, xi, ai, ts] = preparets(net, cinput(:, 1:end - 1), cinput(:, 1 + 1:end));
net1 = train(net, xs, ts, xi, ai);

modelTDNN2 = bcf.models.TDNN(net1, netAhead, ahead);
modelTDNN2.calculateNoiseDistribution(input(1, 1:end));
td2predoutput = modelTDNN2.forecastAll(output, 1);

mape = errperf(td2predoutput(:, sdiff:end), output(:, sdiff:end), 'mape');
mse = errperf(td2predoutput(:, sdiff:end), output(:, sdiff:end), 'mse');
rmse = errperf(td2predoutput(:, sdiff:end), output(:, sdiff:end), 'rmse');

fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);


%TDNN number 3
timeDelay = data.blocksInDay;
hiddenNodes = 50;
cinput = tonndata(input, true, false);
coutput = tonndata(output, true, false);

net = timedelaynet(1:timeDelay, hiddenNodes);

net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

[xs, xi, ai, ts] = preparets(net, cinput(:, 1:end - ahead), cinput(:, ahead + 1:end));
netAhead = train(net, xs, ts, xi, ai);
[xs, xi, ai, ts] = preparets(net, cinput(:, 1:end - 1), cinput(:, 1 + 1:end));
net1 = train(net, xs, ts, xi, ai);

modelTDNN3 = bcf.models.TDNN(net1, netAhead, ahead);
modelTDNN3.calculateNoiseDistribution(input(1, 1:end));
td3predoutput = modelTDNN3.forecastAll(output, 1);

mape = errperf(td3predoutput(:, sdiff:end), output(:, sdiff:end), 'mape');
mse = errperf(td3predoutput(:, sdiff:end), output(:, sdiff:end), 'mse');
rmse = errperf(td3predoutput(:, sdiff:end), output(:, sdiff:end), 'rmse');

fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);



%Combine and forecast
models = {modelArima modelTDNN2};
models = {modelArima modelTDNN};
%models = {modelArima modelArima modelTDNN modelTDNN2 modelArima modelArima modelArima modelArima modelArima modelArima modelArima modelArima modelArima modelArima modelArima modelArima};
models = {modelTDNN2 modelTDNN modelTDNN3};

forecaster = bcf.BayesianForecaster(models);
[yprime, probs, ms] = forecaster.forecastAll(output, 'aggregate');
[yprime2, probs, ms] = forecaster.forecastAll(output, 'best');

mape = errperf(yprime(:, sdiff:end), output(:, sdiff:end), 'mape');
mse = errperf(yprime(:, sdiff:end), output(:, sdiff:end), 'mse');
rmse = errperf(yprime(:, sdiff:end), output(:, sdiff:end), 'rmse');

fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);

mape = errperf(yprime2(:, sdiff:end), output(:, sdiff:end), 'mape');
mse = errperf(yprime2(:, sdiff:end), output(:, sdiff:end), 'mse');
rmse = errperf(yprime2(:, sdiff:end), output(:, sdiff:end), 'rmse');

fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);

x = linspace(1, plotSize, plotSize);
plot(x, [output(:, plotStart:plotStart + plotSize - 1); yprime(:, plotStart:plotStart + plotSize - 1)]);

