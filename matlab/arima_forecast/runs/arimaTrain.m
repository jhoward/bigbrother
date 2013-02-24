%%%%
%Discover a set of residuals for all days of the week.  Residuals are
%extracted and then clustered.
%%%%
clear all

%fileName = 'simulated';
%fileName = 'brown';
fileName = 'denver';

load(strcat('./data/', fileName, 'Data.mat'));

%weeksTrain = 2;
%weeksTrain = 10;
%weeksTrain = 50;

%Generate a training and testing set.
%trainSplit = data.blocksInDay*7*weeksTrain;
sensorNumber = 3;

trainRatio = 0.7;
trainSplit = floor((size(data.data, 2) / data.blocksInDay)*trainRatio);
trainSplit = trainSplit * data.blocksInDay;

trainData = data.data(sensorNumber, 1:trainSplit);
testData = data.data(sensorNumber, trainSplit + 1:end);

ar = 1;
diff = 1;
ma = 1;
sar = 0;
sdiff = data.blocksInDay * 7;
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

save(strcat('./data/',fileName,'Run.mat'), 'data');