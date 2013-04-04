%Visualize Simulated Data.
load('./data/simulatedData.mat');

%plot(data.data(1:500))

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

%predoutput = myModel.forecastAll(output, ahead);

%Determine forecasting score.
mape = errperf(predinput(:, sdiff:end), input(:, sdiff:end), 'mape');
mse = errperf(predinput(:, sdiff:end), input(:, sdiff:end), 'mse');
rmse = errperf(predinput(:, sdiff:end), input(:, sdiff:end), 'rmse');

fprintf(1, 'Error rates -- mape: %f      mse: %f       rmse:%f\n', mape, mse, rmse);

splotStart = 3100;

%plot a typical window
x = linspace(1, plotSize, plotSize);
plot(x, [input(:, plotStart:plotStart + plotSize - 1); predinput(:, plotStart:plotStart + plotSize - 1)]);

%Generate a residual set
res = predinput - input;
%d = data.actTimes(data.actTimes > maxInput + sdiff);
d = data.actTimes(data.actTimes < maxInput & data.actTimes > sdiff);
x = linspace(1, 16, 16);

for i = 1:size(d, 2)
    plot(x, res(d(i) + data.blocksInDay:d(i) + 15 + data.blocksInDay));
    waitforbuttonpress;
end


%Build a dataset



%plotMaxErrorWindows(output, predoutput, windowSize, numErrorWindows);