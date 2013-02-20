%%%%
%Discover a set of residuals for all days of the week.  Residuals are
%extracted and then clustered.
%%%%
clear all
load './data/simulatedData.mat'

%Generate a training and testing set.
trainSplit = data.blocksInDay*7*2;
sensorNumber = 1;

trainData = data.data(sensorNumber, 1:trainSplit);
testData = data.data(sensorNumber, trainSplit + 1:end);

ar = 1;
diff = 0;
ma = 1;
sar = 0;
sdiff = data.blocksInDay;
sma = 1;

arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
            'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);

model = estimate(arimaModel, trainData', 'print', false);
res = infer(model, trainData');
%fitdist(res, 'normal');

data.trainData = trainData;
data.testData = testData;
data.model = model;
data.res = res';
data.trainSplit = trainSplit;

%Plot activities
% for i = 1:size(data.actTimes, 2)
%     plot(res(data.actTimes(i):data.actTimes(i) + 9));
%     hold on
% end

save('./data/simulatedRun.mat', 'data');

