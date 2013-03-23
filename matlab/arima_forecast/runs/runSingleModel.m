%%%%
%Compute the residuals for TDNN and NAR neural networks of various types
%%%%
clear all

%fileName = 'simulated';
%fileName = 'brown';

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
% net = train(net, xs, ts, xi, ai);
% 
% predoutput = bcf.forecast.narForecast(net, output, ahead);
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
tic
timeDelay = 3;
hiddenNodes = 10;
cinput = tonndata(input, true, false);
coutput = tonndata(output, true, false);

net = timedelaynet(1:timeDelay, hiddenNodes);

net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

[xs, xi, ai, ts] = preparets(net, cinput(:, 1:end - 1), cinput(:, 1 + 1:end));
net = train(net, xs, ts, xi, ai);

predoutput = bcf.forecast.tdnnForecast(net, output, ahead);
toc

out = output
predict = coutput;
[xs, xi, ai] = preparets(net, coutput(:, 1:end - ahead), coutput(:, 1 + ahead:end));
predict = net(xs, xi, ai);

predict = cell2mat(predict);
out(:, timeDelay + ahead + 1:end) = predict
predoutput = out


%Determine forecasting score.
mape = errperf(predoutput(:, timeDelay:end), output(:, timeDelay:end), 'mape');
mse = errperf(predoutput(:, timeDelay:end), output(:, timeDelay:end), 'mse');
rmse = errperf(predoutput(:, timeDelay:end), output(:, timeDelay:end), 'rmse');

fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);

x = linspace(1, plotSize, plotSize);
plot(x, [output(:, plotStart:plotStart + plotSize - 1); predoutput(:, plotStart:plotStart + plotSize - 1)]);
 
plotMaxErrorWindows(output, predoutput, windowSize, numErrorWindows);


%====================================================
%Seasonal ARIMA model
%====================================================
% ar = 1;
% diff = 1;
% ma = 1;
% sar = 0;
% sdiff = data.blocksInDay * 7;
% sma = 1;
% 
% arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
%             'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);
% 
% model = estimate(arimaModel, input', 'print', false);
% predoutput = bcf.forecast.arimaForecast(model, ahead + 1, output');
% 
% %Determine forecasting score.
% mape = errperf(predoutput(:, sdiff:end), output(:, sdiff:end), 'mape');
% mse = errperf(predoutput(:, sdiff:end), output(:, sdiff:end), 'mse');
% rmse = errperf(predoutput(:, sdiff:end), output(:, sdiff:end), 'rmse');
% 
% fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);
% 
% %plot a typical window
% x = linspace(1, plotSize, plotSize);
% plot(x, [output(:, plotStart:plotStart + plotSize - 1); predoutput(:, plotStart:plotStart + plotSize - 1)]);
% 
% plotMaxErrorWindows(output, predoutput, windowSize, numErrorWindows);

