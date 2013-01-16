%%%%
%Discover a set of residuals for all days of the week.  Residuals are
%extracted and then clustered.
%%%%
clear all
load './data/simulatedData.mat'

ar = 1;
diff = 0;
ma = 1;
sar = 0;
sdiff = sensorData.blocksInDay;
sma = 1;

allWindows = [];
allDayNums = [];

arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
            'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);

model = estimate(arimaModel, sensorData.data, 'print', false);
res = infer(model, sensorData.data);
fitdist(res, 'normal')

%Plot activities
for i = 1:size(sensorData.actTimes, 2)
    plot(res(sensorData.actTimes(i):sensorData.actTimes(i) + 9));
    hold on
end

%save('./data/simulatedRun.mat', 'data', 'times', 'actTimes', 'blocksInDay', 'model', 'res');