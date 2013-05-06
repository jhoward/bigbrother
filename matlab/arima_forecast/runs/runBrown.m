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

%=======================ARIMA==========================

%SETUP ARIMA MODEL
ar = 1;
diff = 0;
ma = 1;
sar = 0;
sdiff = data.blocksInDay * 7;
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
res = infer(model, input');
%Arima model accuracy
trainRmse = errperf(input(sensorNumber, sdiff:end), predInput(sensorNumber, sdiff:end), 'rmse');
testRmse = errperf(output(sensorNumber, sdiff:end), predOutput(sensorNumber, sdiff:end), 'rmse');
fprintf(1, 'Arima fit Error rates -- train rmse:%f      test rmse %f\n', trainRmse, testRmse);

%=========================END ARIMA=========================

%=========================NEURAL NETWORK====================




%=========================END NEURAL NETWORK================


%=========================PLOT A COUPLE OF DAYS=============
%TYPICAL PLOTS FOR EDIFICATION
plotStart = 2700;

%plot a typical window
x = linspace(1, plotSize, plotSize);
plot(x, [input(:, plotStart:plotStart + plotSize - 1); predInput(:, plotStart:plotStart + plotSize - 1)]);
