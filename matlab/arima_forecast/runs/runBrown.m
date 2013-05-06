clear all;
load('./data/brownData.mat');

%SETUP DATA
plotSize = data.blocksInDay * 2;
sensorNumber = 1;
ahead = 5;
windowSize = 10;

trainPercent = 0.7;

inputMax = floor((size(data.data, 2) / data.blocksInDay) * trainPercent) * data.blocksInDay;
input = data.data(sensorNumber, 1:inputMax);
output = data.data(sensorNumber, inputMax + 1:end);
nd = data.dayOfWeek;
nd(nd == 3) = 10;
nd(nd == 5) = 10;
monInput = data.data(sensorNumber, nd == 10);
input = monInput;
plot(input)
xlim([1 size(input, 2)]);

%=======================ARIMA==========================
% 
% %SETUP ARIMA MODEL
% ar = 1;
% diff = 0;
% ma = 1;
% sar = 0;
% sdiff = data.blocksInDay * 2;
% sma = 1;
% 
% arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
%             'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);
% 
% model = estimate(arimaModel, input', 'print', false);
% 
% myModel = bcf.models.Arima(model);
% myModel.calculateNoiseDistribution(input);
% predInput = myModel.forecastAll(input, ahead);
% %predOutput = myModel.forecastAll(output, ahead);
% 
% resInput = predInput - input;
% %resOutput = predOutput - output;
% res = infer(model, input');
% %Arima model accuracy
% trainRmse = errperf(input(sensorNumber, sdiff:end), predInput(sensorNumber, sdiff:end), 'rmse');
% fprintf(1, 'Arima fit Error rates -- train rmse:%f\n', trainRmse);
% 
% %testRmse = errperf(output(sensorNumber, sdiff:end), predOutput(sensorNumber, sdiff:end), 'rmse');
% %fprintf(1, 'Arima fit Error rates -- train rmse:%f      test rmse %f\n', trainRmse, testRmse);

%=========================END ARIMA=========================

%=========================NEURAL NETWORK====================
% 
%Format the data
%Way one
%Each element of the cell array is a time step of signal dimension by
%number of samples
%total number of cells is the length of all time series
%Length X dimension X num Examples
cdata = {};

cdata = tonndata(input, true, false);
%for i = 1:size(data, 2)
%    cdata{i} = reshape(data(1, i, :), size(data, 1), size(data, 3));
%end

%SETUP THE MODEL
timeDelay = 10;
hiddenNodes = 8;
net = timedelaynet(1:timeDelay, hiddenNodes);
 
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

%[xs, xi, ai, ts] = preparets(net, cdata(:, 1:end - ahead), cdata(:, ahead + 1:end));
%netAhead = train(net, xs, ts, xi, ai);data
[xs, xi, ai, ts] = preparets(net, cdata(:, 1:end - 1), cdata(:, 1 + 1:end));
net1 = train(net, xs, ts, xi, ai);

modelTDNN = bcf.models.TDNN(net1, net1, ahead);

%modelTDNN.calculateNoiseDistributi
predInput = modelTDNN.forecastAll(input(1, :), 1);
resInput = predInput - input;
[h, p, s, c] = lbqtest(resInput(1, 40:100))
autocorr(resInput(200:end), [200]);
parcorr(resInput(200:end), [200]);
% 
% hold off
% for i = 1:size(data, 3)
%     out = modelTDNN.forecastAll(data(:, :, i), ahead);
%     plot(x, [data(1, :, i); out(1, :)]);
%     hold on
% end
% xlim([0, 2 * pi]);

trainRmse = errperf(input(sensorNumber, 1:end), predInput(sensorNumber, 1:end), 'rmse');
fprintf(1, 'NN Error rates -- train rmse:%f\n', trainRmse);



%=========================END NEURAL NETWORK================


%=========================PLOT A COUPLE OF DAYS=============
%TYPICAL PLOTS FOR EDIFICATION
plotStart = 100;

%plot a typical window
x = linspace(1, plotSize, plotSize);
plot(x, [input(:, plotStart:plotStart + plotSize - 1); predInput(:, plotStart:plotStart + plotSize - 1)]);
