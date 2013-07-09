clear all;

load('./data/merlDataClean.mat');

data.data = 2*(data.data - min(data.data))/(max(data.data) - min(data.data)) - 1;
horizon = 4;
train = data.data(:, 1:7800);
test = data.data(:, 7801:end);
trainTimes = data.times(:, 1:7800);
testTimes = data.times(:, 7801:end);

%Setup a simple forecasting model
% model = bcf.models.Average(data.blocksInDay);
% model.train(train);

svmParam = '-s 4 -t 2 -q';
svmWindow = 5;
model = bcf.models.SVM(svmParam, svmWindow);
model.train(train);

mTrain = model.forecastAll(train(1, :), horizon);
resTrain = train - mTrain;
mTest = model.forecastAll(test(1, :), horizon);
resTest = test - mTest;

trainRmse = errperf(train(horizon + 1:end), mTrain(horizon + 1:end), 'rmse');
testRmse = errperf(test(horizon + 1:end), mTest(horizon + 1:end), 'rmse');

fprintf(1, 'Train rmse: %f    Test rmse: %f\n', trainRmse, testRmse);


%Visualize the train residual and the test residual
[trainMeans, trainStds] = dailyMean(resTrain(1, :), trainTimes, data.blocksInDay, 'smooth', false);
[testMeans, testStds] = dailyMean(resTest(1, :), testTimes, data.blocksInDay, 'smooth', false);

plotMean(trainMeans(data.stripDays, :), 'std', trainStds(data.stripDays, :));
figure
plotMean(testMeans(data.stripDays, :), 'std', testStds(data.stripDays, :));



