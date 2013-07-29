clear all;

%dataLocation = 'C:\Users\JamesHoward\Documents\Dropbox\Projects\bigbrother\data\building\merl\data\merlDataClean.mat';
dataLocation = '/Users/jahoward/Documents/Dropbox/Projects/bigbrother/data/building/merl/data/merlDataClean.mat';

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
train = data.data(:, 1:7800);
test = data.data(:, 7801:end);
trainTimes = data.times(:, 1:7800);
testTimes = data.times(:, 7801:end);

windowSize = 10;
numWindows = 20;


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


%==========================================================================

%Make a residual bcf

%==========================================================================

%First make an avg model
[trainResMeans, trainResStds] = dailyMean(resTrain(1, :), trainTimes, data.blocksInDay, 'smooth', false);
avgResMean = mean(trainResMeans(data.stripDays, :));
avgResStd = mean(trainResStds(data.stripDays, :));

%Make models
modelAvg = bcf.models.Average(data.blocksInDay);
modelAvg.train(test);
modelAvg.calculateNoiseDistribution(test, horizon);

%First make a Gaussian Model
modelGaussian = bcf.models.Gaussian(mean(resTest), std(resTest));
modelGaussian.calculateNoiseDistribution(resTest);


%Now make a HMM model
%Train a hidden markov model
%Make one cluster data
index = find(idx == 2);
clustData = window(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData', 1), size(clustData', 2));
clusterDays = data.times(ind(index));
M = 1; %Number of Gaussians
Q = 12; %Number of states

modelHMM = bcf.models.HMM(Q, M);
modelHMM.train(clustData(:, :, :));

modelHMM.calculateNoiseDistribution(clustData(:, :, :));


%Modify and test transition matrix
%model.transmat(model.transmat < 0.005) = 0.005;
%model.transmat = normalize(model.transmat, 2);
modelHMM.prior(modelHMM.prior < 0.01) = 0.01;
modelHMM.prior = modelHMM.prior ./ sum(modelHMM.prior);

cd2d = reshape(clustData, size(clustData, 2), size(clustData, 3));
cd2d = cd2d';
tmpOut = [];
%Plot HMM Model forecasts
for i = 1:size(cd2d, 1)
    tmpOut = [tmpOut; modelHMM.forecastAll(cd2d(i, :), 1, 'window', 4)];
end

tmpBad = modelHMM.forecastAll(resTest(1, 200:250), 1, 'window', 3);
tmpRes = resTest - tmpBad;
tmpProbs = modelHMM.probabilityNoise(tmpRes');

plot(1:1:10, cd2d, 'color', 'b')
hold on
plot(1:1:10, tmpOut, 'color', 'g')

plot(1:1:51, [resTest(1, 200:250); tmpBad]) 



%Now make a HMM model
%Train a hidden markov model
%Make one cluster data
index = find(idx == 6);
clustData = window(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData', 1), size(clustData', 2));
clusterDays = data.times(ind(index));
M = 1; %Number of Gaussians
Q = 12; %Number of states

modelHMM2 = bcf.models.HMM(Q, M);
modelHMM2.train(clustData(:, :, :));

modelHMM2.calculateNoiseDistribution(clustData(:, :, :));


%Modify and test transition matrix
%model.transmat(model.transmat < 0.005) = 0.005;
%model.transmat = normalize(model.transmat, 2);
modelHMM2.prior(modelHMM.prior < 0.01) = 0.01;
modelHMM2.prior = modelHMM.prior ./ sum(modelHMM.prior);


%Make avgModel
index = find(idx == 6);
clustData = window(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));

modelAvg = bcf.models.Average(windowSize);
modelAvg.train(clustData);

modelAvg.calculateNoiseDistribution(clustData, 1);



%Make a bcf model
%Combine and forecast
models = {modelGaussian modelHMM};

modelBcf = bcf.BayesianForecaster(models);

%[resBCFTest, probs, ~] = modelBcf.forecastAll(resTest, 1, 1, 'aggregate', 0.001, 1); 
%[resBCFTest, probs, rawProbs] = modelBcf.forecastAll(resTest, 1, 1, 'aggregate', 0.001, 1); 
[resBCFTest, probs, models, windows, modelForecasts] = modelBcf.windowForecast(resTest, 3, 10, 1, 'aggregate');

fullTest = mTest + resBCFTest;

testRmse = errperf(test(horizon + 1:end), mTest(horizon + 1:end), 'rmse');
bcfTestRmse = errperf(test(horizon + 1:end), fullTest(horizon + 1:end), 'rmse');


fprintf(1, 'Test rmse: %f    BCF test rmse: %f\n', testRmse, bcfTestRmse);

plot(1:1:51, [test(1, 330:380); fullTest(1, 330:380); mTest(1, 330:380)]);
%plot(1:1:100, [probs(:, 700:799)]);
