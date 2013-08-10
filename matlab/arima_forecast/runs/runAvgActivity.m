clear all;

dataLocation = 'C:\Users\JamesHoward\Documents\Dropbox\Projects\bigbrother\data\building\merl\data\merlDataClean.mat';
load(dataLocation);

data.data = 2*(data.data - min(data.data))/(max(data.data) - min(data.data)) - 1;
horizon = 4;
train = data.data(:, 1:7800);
test = data.data(:, 7801:end);
trainTimes = data.times(:, 1:7800);
testTimes = data.times(:, 7801:end);

windowSize = 18;
numWindows = 20;
removeWindow = 18;

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


%Figure out a threshold for now
meanStd = mean(trainStds(4, :));

%Work on removing residuals
%[windows, indexes] = largestWindow(resTest, windowSize, numWindows, removeWindow);
[window, ind, val] = simpleExtraction(resTest, windowSize, meanStd * windowSize);
[idx, centers] = kmeans(window, 6);
sval = silhouette(window, idx);
mean(sval)


%Plot each cluster
for i = 1:6
    index = find(idx == i);
    plotData = window(index, :);
    x = linspace(1, 18, 18);
    xflip = [x(1 : end - 1) fliplr(x)];
    for j = 1:size(plotData, 1)
        y = plotData(j, :);
        yflip = [y(1 : end - 1) fliplr(y)];
        patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
        hold on
    end
    hold off
    
    %clusterDays = allDayNums(index);
    %datestr(clusterDays)
    %weekday(clusterDays)
    
    waitforbuttonpress;
    clf
end




