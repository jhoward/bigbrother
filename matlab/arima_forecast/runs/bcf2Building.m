%bcf2Building.m
clear all;

dataLocation = 'C:\Users\JamesHoward\Documents\Dropbox\Projects\bigbrother\data\building\merl\data\merlDataClean.mat';
%dataLocation = '/Users/jahoward/Documents/Dropbox/Projects/bigbrother/data/building/merl/data/merlDataClean.mat';

%dataLocation = './data/brownDataClean.mat';

load(dataLocation);

%Remove the top n% of outliers and renormalize
removePercent = 0.001;
nRemove = floor(removePercent * size(data.data, 2));

[tmp, ind] = sort(data.data, 'descend');
data.data(ind(1, 1:nRemove)) = tmp(1, ind(1, nRemove + 1));
data.data(ind(1, end-nRemove:end)) = tmp(1, ind(1, end - nRemove - 1));

%Normalize
data.data = 2*(data.data - min(data.data))/(max(data.data) - min(data.data)) - 1;

horizon = 1;
% train = data.data(:, 1:1716);
% test = data.data(:, 1717:end);
% trainTimes = data.times(:, 1:1716);
% testTimes = data.times(:, 1717:end);

train = data.data(:, 1:7800);
test = data.data(:, 7801:end);
trainTimes = data.times(:, 1:7800);
testTimes = data.times(:, 7801:end);

windowSize = 8;

svmParam = '-s 4 -t 2 -q';
svmWindow = 4;
model = bcf.models.SVM(svmParam, svmWindow);
model.train(train);

mTrain = model.forecastAll(train(1, :), horizon);
resTrain = train - mTrain;
mTest = model.forecastAll(test(1, :), horizon);
resTest = test - mTest;

plot(1:1:200, [test(200:399); mTest(200:399)]);

trainRmse = errperf(train(horizon + 1:end), mTrain(horizon + 1:end), 'rmse');
testRmse = errperf(test(horizon + 1:end), mTest(horizon + 1:end), 'rmse');

fprintf(1, 'Train rmse: %f    Test rmse: %f\n', trainRmse, testRmse);

%Visualize the train residual and the test residual
[trainMeans, trainStds] = dailyMean(resTrain(1, :), trainTimes, data.blocksInDay, 'smooth', false);
[testMeans, testStds] = dailyMean(resTest(1, :), testTimes, data.blocksInDay, 'smooth', false);

fprintf(1, 'residual avg std ---- Train: %f     Test: %f\n', mean(trainStds(data.stripDays, :)), mean(testStds(data.stripDays, :)));

%Figure out a threshold for now
%CHANGE AS NEEDED
meanStd = mean(trainStds(4, :));

%Work on removing residuals
[window, ind, val] = simpleExtraction(resTest, windowSize, meanStd * windowSize, true);
[idx, centers] = kmeans(window, 8);
sval = silhouette(window, idx);
mean(sval)



%Plot each cluster
for i = 1:8
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



%First make an avg model
[trainResMeans, trainResStds] = dailyMean(resTrain(1, :), trainTimes, data.blocksInDay, 'smooth', false);
avgResMean = mean(trainResMeans(data.stripDays, :));
avgResStd = mean(trainResStds(data.stripDays, :));

%Make models
modelAvg = bcf.models.Average(data.blocksInDay);
modelAvg.train(test);
modelAvg.calculateNoiseDistribution(test, horizon);

%Make a Gaussian Model
modelGaussian = bcf.models.Gaussian(mean(resTest), std(resTest));
modelGaussian.calculateNoiseDistribution(resTest);


%Now make an avg model of the anomalies
index = find(idx == 3);
clustData = window(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));

modelAvg1 = bcf.models.AvgGaussian(windowSize);
modelAvg1.train(clustData);

%Now make an avg model of the anomalies
index = find(idx == 4);
clustData = window(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));

modelAvg2 = bcf.models.AvgGaussian(windowSize);
modelAvg2.train(clustData);

%Now make an avg model of the anomalies
index = find(idx == 5);
clustData = window(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));

modelAvg3 = bcf.models.AvgGaussian(windowSize);
modelAvg3.train(clustData);

backModel = bcf.models.AvgGaussian(1);
backModel.noiseValues = [std(resTest)];
backModel.avgValues = [mean(resTest)];

models = {modelAvg1; modelAvg2; modelAvg3; backModel};

%--------------------------------------------------------------------------
%
%PERFORM BCF2
%
%--------------------------------------------------------------------------
lengths = [8 8 8 1];
modelConstants = [0.02, 0.02, 0.02, 0.01];
ahead = 1;
yp = zeros(size(resTest));

p = {};

l = {};
post = {};
for j = 1:size(lengths, 2)
    p{j} = ones(1, lengths(j));
    l{j} = ones(1, lengths(j));
    post{j} = ones(1, lengths(j));
    histPost{j} = ones(lengths(j), size(test, 2));
end

cellTotal = sum(cellfun(@sum, p));
p = cellfun(@(v)v./cellTotal, p, 'UniformOutput', false);

%TODO attempt this with model based prior later instead of prior per model
%unit. work with this being an array instead of a cell model.
%p = p ./ sum(p, 2);

%Go through whole dataset
for t = 1:1000%size(y, 2) - ahead
    
    %compute model likelihoods
    for m = 1:length(models)
        for j = 1:lengths(1, m)
            l{m}(1, j) = models{m}.likelihood(resTest(1, t), j);
            %l{m}(1, j) = models{m}.likelihood(resTest(1, t - j + 1:t), j);
        end    
    end
    
    %compute posteriors
    
    %p(m|y) = p(y|m)p(m)/p(y)
    for m = 1:length(models)
        for j = 1:lengths(1, m)
            post{m}(1, j) = l{m}(1, j) * p{m}(1, j);
        end
    end
    
    for m = 1:length(models)
        post{m}(post{m} <= 0.00001) = 0.00001;
    end
    
    %normalize
    cellTotal = sum(cellfun(@sum, post));
    post = cellfun(@(v)v./cellTotal, post, 'UniformOutput', false);
    
	%Save the posteriors
    for m = 1:length(models)
        for j = 1:lengths(1, m)
            histPost{m}(j, t) = post{m}(1, j); %#ok<SAGROW>
        end
    end
    
    %Update the priors
    for m = 1:length(models)
        for j = 2:lengths(1, m)
            p{m}(1, j) = post{m}(1, j - 1);
        end
        if m < length(models)
            p{m}(1, 1) = modelConstants(1, m);
        end
    end
    
    %normalize priors
    cellTotal = sum(cellfun(@sum, p));
    p = cellfun(@(v)v./cellTotal, p, 'UniformOutput', false);
    
    %forecast based weighted posteriors
    for m = 1:length(models)
        for j = 1:lengths(1, m)
            yp(1, t + ahead) = yp(1, t + ahead) + models{m}.forecastSingle(j, ahead) * post{m}(1, j);
        end
    end    
end

newTest = mTest + yp;
newRes = test - newTest;


% plotStart = 300;
% plotEnd = 600;
% plotRange = plotEnd - plotStart + 1;

plotStart = 761;
plotEnd = 820;
plotRange = plotEnd - plotStart + 1;

hold on
%plot(1:1:plotRange, [test(1, plotStart:plotEnd); mTest(1, plotStart:plotEnd); newTest(1, plotStart:plotEnd)]);
plot(1:1:plotRange, [resTest(1, plotStart:plotEnd); yp(1, plotStart:plotEnd)]);
for i = 1:8
    plot(1:1:plotRange, histPost{3}(i, plotStart:plotEnd) - i, 'color', 'red');
end
plot(1:1:plotRange, histPost{4}(1, plotStart:plotEnd) - 9, 'color', 'green');

xlim([1, plotRange]);

%Plot the histories of the models here
%plot(1:1:60, [resTest(1, 721:780); yp(1, 721:780)]);
%plot(1:1:60, [resTest(1, 721:780); newRes(1, 721:780)]);

%Compute the RMSE
BCFRMSE = errperf(test(1:end), mTest(1:end), 'rmse')
modBCFRMSE = errperf(test(1:end), newTest(1:end), 'rmse')

%Compute the std of testRes
resTestStd = std(resTest);
resTestMean = mean(resTest);

%Compute the RMSE of instances greater than 1 std.
goodSpots = find(abs(resTest) < resTestStd);
upperRes = abs(resTest);
tmp = find(upperRes >= resTestStd);
upperRes(goodSpots) = 0;
upperRes(tmp) = upperRes(tmp) - resTestStd;

goodSpots = find(abs(newRes) < resTestStd);
newUpperRes = abs(newRes);
tmp = find(newUpperRes >= resTestStd);
newUpperRes(goodSpots) = 0;
newUpperRes(tmp) = newUpperRes(tmp) - resTestStd;

%Compute the RMSE of instances greater than 1 std
badplaces = (abs(resTest) > resTestStd) | (abs(newRes) > resTestStd);
upperRes = resTest(badplaces);
newUpperRes = newRes(badplaces);

upperRes(upperRes <= resTestStd) = 0;
upperRes(upperRes > resTestStd) = upperRes(upperRes > resTestStd) - resTestStd;
newUpperRes(newUpperRes <= resTestStd) = 0;
newUpperRes(newUpperRes > resTestStd) = newUpperRes(newUpperRes > resTestStd) - resTestStd;

badSpotsRMSE = errperf(upperRes, zeros(size(upperRes)), 'rmse')
badSpotsBCFRMSE = errperf(newUpperRes, zeros(size(newUpperRes)), 'rmse')

plot(1:1:200, [upperRes(1, 201:400); newUpperRes(1, 201:400)])

badSpots = find(upperRes > 0);
tmp = upperRes(badSpots);

badSpots2 = find(newUpperRes > 0);
tmp2 = newUpperRes(badSpots2);

badSpotsRMSE = errperf(tmp, zeros(size(tmp)), 'rmse')
badSpots2RMSE = errperf(tmp2, zeros(size(tmp2)), 'rmse')


%Display std of residual
xvals = 1:1:plotRange;
xvals = [xvals, fliplr(xvals)];
y1 = resTestMean + ones(1, plotRange) * resTestStd * 1;
y2 = resTestMean - ones(1, plotRange) * resTestStd * 1;
%y2 = weeklyMean(dayOfWeek, :) + weeklySigma(dayOfWeek, :);
yvals = [y1, fliplr(y2)];
tmp = fill(xvals, yvals, [0.1, 0.3, 0]);
set(tmp,'EdgeColor',[0.1, 0.3, 0],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(1:1:plotRange, resTest(1, plotStart:plotEnd), 'LineWidth', 2, 'Color', [0, 0.3, 1]);
plot(1:1:plotRange, newRes(1, plotStart:plotEnd), 'LineWidth', 2, 'Color', [1, 0.3, 0]);
xlim([1, plotRange]);
%ylim([0, ysize]);
%xlabel('Time of day', 'FontSize', 14)
%ylabel('Sensor activations', 'FontSize', 14)
set(gca,'XTick',[]);





