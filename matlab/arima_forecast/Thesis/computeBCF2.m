%File: computeBCF2.m
%Author: James Howard
%
%
%Runs our BCF2 model

clear all;

dataSet = 1;
horizon = 1;
windowSize = 8;

load(MyConstants.BCF_RESULTS_LOCATIONS{dataSet});
load(MyConstants.HORIZON_DATA_LOCATIONS{dataSet});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

%Smooth the data to see if we get improved results

resTest = data.testData(1, fStart:fEnd) - bcfResults.improvedTest{horizon};
%resTest = data.testData(1, fStart:fEnd) - horizons.svm{11}{horizon};
resTimes = data.testTimes(1, fStart:fEnd);

%Visualize the train residual and the test residual
%[trainMeans, trainStds] = dailyMean(resTrain(1, :), trainTimes, data.blocksInDay, 'smooth', false);
[testMeans, testStds] = dailyMean(resTest(1, :), resTimes, data.blocksInDay, 'smooth', false);
[means, stds] = computeMean(data.testData, data.blocksInDay);

fprintf(1, 'residual avg std ---- Test: %f\n', mean(testStds(6, :)));

%Figure out a threshold for now
%CHANGE AS NEEDED
meanStd = mean(testStds(6, :));

%Play with smooth level, windowSize and numClusters to find a best
%silhouette

bestWS = 6;
bestSmoothAmount = 4;
bestNumClusters = 3;
bestThresholdMult = 1;
bestSilhouette = 0;

numAvgRuns = 8;

for ws = 10:-1:9
    
    fprintf(1, 'Windowsize: %i\n', ws);
    
    for smoothAmount = 1:1
        for numClusters = 5:10
            for thresholdMult = 3:14
                avgSilh = 0;
                
                %smooth
                resRunTest = smooth(resTest, smoothAmount)';
                
                %Compute threshold
                [testMeans, testStds] = dailyMean(resRunTest(1, :), resTimes, data.blocksInDay, 'smooth', false);
                meanStd = mean(testStds(6, :));
                currentThreshold = meanStd * ws * (thresholdMult * 0.1 + 0.3);

                %extract
                [windows, ind, val] = simpleExtraction(resRunTest, ws, currentThreshold, true);
                
                %TODO Fix number of windows extracted
                %[windows, ind] = windowExtraction(resTest, windowSize, 50);
                
                if size(windows, 1) < 36
                    continue
                end
                
                %Average a few runs
                for av = 1:numAvgRuns
                    %Cluster and compute
                    [idx, centers] = kmeans2(windows, numClusters, 'minCl', 4, 'outFrac', 0.1);
                    
                    if size(centers, 1) < 5
                        continue
                    end
                    
                    sval = silhouette(windows, idx);
                    currentSilh = mean(sval); 
                    
                    avgSilh = avgSilh + currentSilh;
                end
                
                avgSilh = avgSilh / numAvgRuns;
                
                if avgSilh > bestSilhouette
                    bestWS = ws;
                    bestSmoothAmount = smoothAmount;
                    bestNumClusters = numClusters;
                    bestThresholdMult = thresholdMult;
                    bestSilhouette = avgSilh;
                    
                    fprintf(1, 'New best silh: %f   ws: %i   smooth: %i   clus: %i   thresh: %i\n', ...
                            bestSilhouette, bestWS, bestSmoothAmount, bestNumClusters, bestThresholdMult);
                end
            end
        end
    end
end

resRunTest = smooth(resTest, bestSmoothAmount)';

[testMeans, testStds] = dailyMean(resRunTest(1, :), resTimes, data.blocksInDay, 'smooth', false);
meanStd = mean(testStds(6, :));
currentThreshold = meanStd * bestWS * (bestThresholdMult * 0.1 + 0.3);

% %Work on removing residuals
[windows, ind, val] = simpleExtraction(resRunTest, bestWS, currentThreshold, true);
% %[windows, ind] = windowExtraction(resTest, windowSize, 30);
% 
% 
%[idx, centers] = kmeans(windows, bestNumClusters);
[idx, centers, kdists] = kmeans2(windows, bestNumClusters, 'minCl', 4, 'outFrac', 0.1);
sval = silhouette(windows, idx);
fprintf(1, 'Centers: %i\n', size(centers, 1));
mean(sval)
% 

%==========================================================================
%Remove outliers
%==========================================================================


%==========================================================================
%CREATE MODELS
%==========================================================================

%Make a background model
backModel = bcf.models.AvgGaussian(1);
backModel.noiseValues = [std(resRunTest)];
backModel.avgValues = [mean(resRunTest)];

%Create models for each cluster center


% %First make an avg model
% [trainResMeans, trainResStds] = dailyMean(resTrain(1, :), trainTimes, data.blocksInDay, 'smooth', false);
% avgResMean = mean(trainResMeans(data.stripDays, :));
% avgResStd = mean(trainResStds(data.stripDays, :));
% 
% %Make models
% modelAvg = bcf.models.Average(data.blocksInDay);
% modelAvg.train(test);
% modelAvg.calculateNoiseDistribution(test, horizon);
% 
% %Make a Gaussian Model
% modelGaussian = bcf.models.Gaussian(mean(resTest), std(resTest));
% modelGaussian.calculateNoiseDistribution(resTest);


%Now make an avg model of the anomalies
index = find(idx == 3);
clustData = windows(index, :); %#ok<FNDSB>
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));

modelAvg1 = bcf.models.AvgGaussian(bestWS);
modelAvg1.train(clustData);

%Now make an avg model of the anomalies
index = find(idx == 5);
clustData = windows(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));

modelAvg2 = bcf.models.AvgGaussian(bestWS);
modelAvg2.train(clustData);

%Now make an avg model of the anomalies
index = find(idx == 6);
clustData = windows(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));

modelAvg3 = bcf.models.AvgGaussian(bestWS);
modelAvg3.train(clustData);
% 
% backModel = bcf.models.AvgGaussian(1);
% backModel.noiseValues = [std(resTest)];
% backModel.avgValues = [mean(resTest)];

%models = {modelAvg1; modelAvg2; modelAvg3; backModel};
models = {modelAvg1; modelAvg2; backModel};


%--------------------------------------------------------------------------
%
%PERFORM BCF2
%
%--------------------------------------------------------------------------
lengths = zeros(1, size(centers, 1)) + size(centers, 2);
lengths(1, end) = 1;
modelConstants = ones(1, size(centers, 1));
modelConstants = modelConstants * 0.01;
modelConstants(1, end) = 0.99;

ahead = 1;
yp = zeros(size(resTest));

p = {};

l = {};
post = {};
for j = 1:size(lengths, 2)
    p{j} = ones(1, lengths(j));
    l{j} = ones(1, lengths(j));
    post{j} = ones(1, lengths(j));
    histPost{j} = ones(lengths(j), size(resTest, 2));
end

cellTotal = sum(cellfun(@sum, p));
p = cellfun(@(v)v./cellTotal, p, 'UniformOutput', false);

%TODO attempt this with model based prior later instead of prior per model
%unit. work with this being an array instead of a cell model.
%p = p ./ sum(p, 2);

%Go through whole dataset
for t = 1:size(resTest, 2) - ahead
    
    %compute model likelihoods
    for m = 1:length(models)
        for j = 1:lengths(1, m)
            l{m}(1, j) = models{m}.likelihood(resRunTest(1, t), j);
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

newTest = bcfResults.improvedTest{horizon} + yp;
newRes = data.testData(1, data.blocksInDay:end) - newTest;
horTest = bcfResults.improvedTest{horizon};


[ponanValue rmseonanValue sseonanValue ~] = ponan(resTest, stds)
[ponanValue2 rmseonanValue2 sseonanValue2 ~] = ponan(newRes, stds)

rmseValue = errperf(data.testData(fStart:fEnd), ...
                    bcfResults.improvedTest{horizon}, 'rmse');
rmseValue2 = errperf(data.testData(fStart:fEnd), ...
                    newTest, 'rmse');


index = 100;
exampleWidth = 200;

while (index + exampleWidth) < size(resRunTest, 2)
    plot(data.testData(1, fStart + index:fStart + index + exampleWidth));
    hold on
    plot(newTest(1, index:index + exampleWidth), 'Color', [1 0 0]);
    plot(horTest(1, index:index + exampleWidth), 'Color', [0 1 0]);
    xlim([1 (exampleWidth + 1)]);
    
    waitforbuttonpress;
    hold off;
    index = index + exampleWidth;
end


%Plot each cluster
for i = 1:bestNumClusters
    index = find(idx == i);
    plotData = windows(index, :);
    x = linspace(1, bestWS, bestWS);
    xflip = [x(1 : end - 1) fliplr(x)];
    for j = 1:size(plotData, 1)
        y = plotData(j, :);
        yflip = [y(1 : end - 1) fliplr(y)];
        patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
        hold on
    end
    hold off
    
    clusterDays = data.times(ind(index));
    ind(index)
    datestr(clusterDays)
    %weekday(clusterDays)
    
    waitforbuttonpress;
    clf
end

st = 100;
edPlot = 499;

subplot(1, 1)
