clear all;

dataLocation = 'C:\Users\JamesHoward\Documents\Dropbox\Projects\bigbrother\data\building\merl\data\merlDataClean.mat';
load(dataLocation);

%Remove the top n% of outliers and renormalize
removePercent = 0.001;
nRemove = floor(removePercent * size(data.data, 2));

[tmp, ind] = sort(data.data, 'descend');
data.data(ind(1, 1:nRemove)) = tmp(1, ind(1, nRemove + 1));
data.data(ind(1, end-nRemove:end)) = tmp(1, ind(1, end - nRemove - 1));

%Normalize
data.data = 2*(data.data - min(data.data))/(max(data.data) - min(data.data)) - 1;

horizon = 3;
train = data.data(:, 1:7800);
test = data.data(:, 7801:end);
trainTimes = data.times(:, 1:7800);
testTimes = data.times(:, 7801:end);

windowSize = 10;
numWindows = 20;
removeWindow = 18;


%Visualize raw data
% [trainMeans, trainStds] = dailyMean(train(1, :), trainTimes, data.blocksInDay, 'smooth', false);
% [testMeans, testStds] = dailyMean(test(1, :), testTimes, data.blocksInDay, 'smooth', false);
% 
% plotMean(trainMeans(data.stripDays, :), 'std', trainStds(data.stripDays, :));
% figure
% plotMean(testMeans(data.stripDays, :), 'std', testStds(data.stripDays, :));
% 
% fprintf(1, 'raw avg std ---- Train: %f     Test: %f\n', mean(trainStds(data.stripDays, :)), mean(testStds(data.stripDays, :)));

%==========================================================================
%==========================================================================
%==========================================================================
%==========================================================================

%Setup a simple forecasting model
% model = bcf.models.Average(data.blocksInDayh);
% model.train(train);

svmParam = '-s 4 -t 2 -q';
svmWindow = 5;
model = bcf.models.SVM(svmParam, svmWindow);
model.train(train);

mTrain = model.forecastAll(train(1, :), horizon);
resTrain = train - mTrain;
mTest = model.forecastAll(test(1, :), horizon);
resTest = test - mTest;

plot(1:1:200, [test(200:399); mTest(200:399)]);

%sax.sax_demo(resTrain(:, 1:500))

trainRmse = errperf(train(horizon + 1:end), mTrain(horizon + 1:end), 'rmse');
testRmse = errperf(test(horizon + 1:end), mTest(horizon + 1:end), 'rmse');

fprintf(1, 'Train rmse: %f    Test rmse: %f\n', trainRmse, testRmse);

%Visualize the train residual and the test residual
[trainMeans, trainStds] = dailyMean(resTrain(1, :), trainTimes, data.blocksInDay, 'smooth', false);
[testMeans, testStds] = dailyMean(resTest(1, :), testTimes, data.blocksInDay, 'smooth', false);

fprintf(1, 'residual avg std ---- Train: %f     Test: %f\n', mean(trainStds(data.stripDays, :)), mean(testStds(data.stripDays, :)));

% plotMean(trainMeans(data.stripDays, :), 'std', trainStds(data.stripDays, :));
% figure
% plotMean(testMeans(data.stripDays, :), 'std', testStds(data.stripDays, :));


%Figure out a threshold for now
meanStd = mean(trainStds(4, :));

%Work on removing residuals
[window, ind, val] = simpleExtraction(resTest, windowSize, meanStd * windowSize, true);
[idx, centers] = kmeans(window, 6);
sval = silhouette(window, idx);
mean(sval)


%Plot each cluster
for i = 1:6
    index = find(idx == i);
    plotData = window(index, :);
    x = linspace(1, windowSize, windowSize);
    xflip = [x(1 : end - 1) fliplr(x)];
    for j = 1:size(plotData, 1)
        y = plotData(j, :);
        yflip = [y(1 : end - 1) fliplr(y)];
        patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
        hold on
    end
    hold off
    
    clusterDays = data.times(ind(index));
    datestr(clusterDays)
    %weekday(clusterDays)
    
    waitforbuttonpress;
    clf
end

%Plot raw data of each cluster
for i = 1:6
    index = find(idx == i);
    
    plotData = [];
    for j = 1:size(index, 1)
        currentIndex = ind(index(j));
        plotData = [plotData; test(1,currentIndex:currentIndex + windowSize - 1)]; %#ok<AGROW>
    end
    
    %plotData = window(index, :);
    x = linspace(1, windowSize, windowSize);
    xflip = [x(1 : end - 1) fliplr(x)];
    for j = 1:size(plotData, 1)
        y = plotData(j, :);
        yflip = [y(1 : end - 1) fliplr(y)];
        patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
        hold on
    end
    hold off
    
    clusterDays = data.times(ind(index));
    datestr(clusterDays)
    %weekday(clusterDays)
    
    waitforbuttonpress;
    clf
end

%==========================================================================

%Make a residual bcf

%==========================================================================

%First make an avg model
[trainResMeans, trainResStds] = dailyMean(resTrain(1, :), trainTimes, data.blocksInDay, 'smooth', false);
avgResMean = mean(trainResMeans(data.stripDays, :));
avgResStd = mean(trainResStds(data.stripDays, :));

%Make models
modelAvg = bcf.models.Average(windowSize);
modelAvg.train();
modelAvg.calculateNoiseDistribution(input, horizon);

