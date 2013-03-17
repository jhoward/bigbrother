%%%%
%Compute the residuals for TDNN and NAR neural networks of various types
%%%%
clear all

%fileName = 'simulated';
%fileName = 'brown';

%DENVER
fileName = 'denver';

load(strcat('./data/', fileName, 'Data.mat'));

plotSize = data.blocksInDay;
sensorNumber = 3;

maxInput = data.blocksInDay * 150; %6 months or so
outputRange = data.blocksInDay * 14; %2 weeks of output
plotStart = data.blocksInDay * 12;
input = data.data(sensorNumber, 1:maxInput);
output = data.data(sensorNumber, maxInput + 1:maxInput + outputRange);

%====================================================
%one dimensional nonlinear neural network
%====================================================

% timeDelay = 3;
% hiddenNodes = 10;
% cinput = tonndata(input, true, false);
% coutput = tonndata(output, true, false);
% 
% net = narnet(1:timeDelay, hiddenNodes);
% 
% net.divideParam.trainRatio = 70/100;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;
% 
% [xs, xi, ai, ts] = preparets(net, {}, {}, cinput);
% net = train(net, xs, ts, xi, ai);
% 
% %Prepare output
% [oxs, oxi, oai, ots] = preparets(net, {}, {}, coutput);
% predoutput = net(oxs, oxi);
% predoutput = cell2mat(predoutput);
% 
% x = linspace(1, plotSize, plotSize);
% plot(x, [output(:, plotStart:plotStart + plotSize - 1); predoutput(:, plotStart:plotStart + plotSize - 1)]);
% 

%====================================================
%one dimensional time delay neural network
%====================================================




%====================================================
%Seasonal ARIMA model
%====================================================
ar = 1;
diff = 1;
ma = 1;
sar = 0;
sdiff = data.blocksInDay * 7;
sma = 1;

arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
            'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);

model = estimate(arimaModel, input', 'print', false);
res = infer(model, input');

predoutput = bcf.forecast.arimaForecast(model, 10, output');

x = linspace(1, plotSize, plotSize);
plot(x, [output(:, plotStart:plotStart + plotSize - 1); predoutput(:, plotStart:plotStart + plotSize - 1)]);
