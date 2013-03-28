%%%%
%Compute the residuals for TDNN and NAR neural networks of various types
%%%%
clear all

%fileName = 'simulated';

%BROWN
fileName = 'brown';

load(strcat('./data/', fileName, 'Data.mat'));

plotSize = data.blocksInDay * 2;
sensorNumber = 3;
ahead = 1;
windowSize = 10;
numErrorWindows = 10;

maxInput = data.blocksInDay * 90; %3 months or so
outputRange = data.blocksInDay * 21; %3 weeks of output
plotStart = data.blocksInDay * 15;
input = data.data(sensorNumber, 1:maxInput);
output = data.data(sensorNumber, maxInput + 1:maxInput + outputRange);


%DENVER
% fileName = 'denver';
% 
% load(strcat('./data/', fileName, 'Data.mat'));
% 
% plotSize = data.blocksInDay * 2;
% sensorNumber = 3;
% ahead = 3;
% windowSize = 10;
% numErrorWindows = 10;
% 
% maxInput = data.blocksInDay * 150; %6 months or so
% outputRange = data.blocksInDay * 21; %3 weeks of output
% plotStart = data.blocksInDay * 17;
% input = data.data(sensorNumber, 1:maxInput);
% output = data.data(sensorNumber, maxInput + 1:maxInput + outputRange);

%====================================================
%one dimensional nonlinear neural network
%====================================================
% tic
% timeDelay = 3;
% hiddenNodes = 10;
% cinput = tonndata(input, true, false);
% coutput = tonndata(output, true, false);
% 
% 
% net = narnet(1:timeDelay, hiddenNodes);
% 
% net.divideParam.trainRatio = 70/100;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;
% 
% [xs, xi, ai, ts] = preparets(net, {}, {}, cinput(:, 1:end));
% 
% net = train(net, xs, ts, xi, ai);
% myModel = bcf.models.NARNET(net);
% myModel.calculateNoiseDistribution(input(1, 1:floor(end*.1)));
% predoutput = myModel.forecastAll(output, ahead);
% toc
% 
% %Determine forecasting score.
% mape = errperf(predoutput(:, timeDelay:end), output(:, timeDelay:end), 'mape');
% mse = errperf(predoutput(:, timeDelay:end), output(:, timeDelay:end), 'mse');
% rmse = errperf(predoutput(:, timeDelay:end), output(:, timeDelay:end), 'rmse');
% 
% fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);
% 
% x = linspace(1, plotSize, plotSize);
% plot(x, [output(:, plotStart:plotStart + plotSize - 1); predoutput(:, plotStart:plotStart + plotSize - 1)]);
%  
% plotMaxErrorWindows(output, predoutput, windowSize, numErrorWindows);


%====================================================
%one dimensional time delay neural network
%====================================================
% tic
% timeDelay = 3;
% hiddenNodes = 10;
% cinput = tonndata(input, true, false);
% coutput = tonndata(output, true, false);
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
% myModel = bcf.models.TDNN(net1, netAhead, ahead);
% myModel.calculateNoiseDistribution(input(1, 1:floor(end*.1)));
% 
% predoutput = myModel.forecastAll(output, ahead);
% toc
% 
% %Determine forecasting score.
% %mape = errperf(predoutput(:, timeDelay:end), output(:, timeDelay:end), 'mape');
% mape = 0;
% mse = errperf(predoutput(:, timeDelay:end), output(:, timeDelay:end), 'mse');
% rmse = errperf(predoutput(:, timeDelay:end), output(:, timeDelay:end), 'rmse');
% 
% fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);
% 
% x = linspace(1, plotSize, plotSize);
% plot(x, [output(:, plotStart:plotStart + plotSize - 1); predoutput(:, plotStart:plotStart + plotSize - 1)]);
%  
% plotMaxErrorWindows(output, predoutput, windowSize, numErrorWindows);


%====================================================
%Seasonal ARIMA model
%====================================================
ar = 1;
diff = 0;
ma = 1;
sar = 0;
sdiff = 7*data.blocksInDay;
sma = 1;

arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
            'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);

model = estimate(arimaModel, input', 'print', false);

myModel = bcf.models.Arima(model);
myModel.calculateNoiseDistribution(input);
predoutput = myModel.forecastAll(output, ahead);

%bcf.forecast.arimaForecast(model, ahead, output');

%Determine forecasting score.
%mape = errperf(predoutput(:, sdiff:end), output(:, sdiff:end), 'mape');
mape = 0
mse = errperf(predoutput(:, sdiff:end), output(:, sdiff:end), 'mse');
rmse = errperf(predoutput(:, sdiff:end), output(:, sdiff:end), 'rmse');

fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);

%plot a typical window
x = linspace(1, plotSize, plotSize);
plot(x, [output(:, plotStart:plotStart + plotSize - 1); predoutput(:, plotStart:plotStart + plotSize - 1)]);

plotMaxErrorWindows(output, predoutput, windowSize, numErrorWindows);

