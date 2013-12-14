%file: bcf2ARIMA
%author: James Howard
%
%Compute the activity recongition improved BCF for ARIMA models

clear all;

dataSet = 1;
model = 2; %Set MODEL to ARIMA
horizon = 3;

dataLocation = MyConstants.FILE_LOCATIONS_CLEAN{dataSet};
saveLocationStart = strcat(MyConstants.THESIS_LOCATION, 'images/bcfimproved/');
saveLocationEnd = strcat('ds-', int2str(dataSet), '_model-', ...
                MyConstants.MODEL_NAMES{model}, '.png');
        
load(dataLocation);
load(MyConstants.HORIZON_DATA_LOCATIONS{dataSet});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

%Setup datasets
testData = data.testData(:, fStart:fEnd);
testTimes = data.times(:, fStart:fEnd);
fTest = horizons.arima{11}{horizon};

resTest = testData - fTest;
resTimes = testTimes;

%contPlot(resTest, 100);

%FIND MAX OUTLIERS
%Get maximum residual deviation clusters.
bestWS = 6;
bestSmoothAmount = 4;
bestNumClusters = 3;
bestThresholdMult = 1;
bestSilhouette = 0;
minClusters = 4;
minWindows = 30;
numAvgRuns = 8;

for ws = 10:-1:8
    
    fprintf(1, 'Windowsize: %i\n', ws);
    
    for smoothAmount = 1:1
        for numClusters = 4:6
            for thresholdMult = 1:1
                avgSilh = 0;
                
                %smooth
                %resRunTest = smooth(resTest, smoothAmount)';
                resRunTest = resTest;
                
                %Compute threshold
                [testMeans, testStds] = dailyMean(resRunTest(1, :), resTimes, data.blocksInDay, 'smooth', false);
                meanStd = mean(testStds(data.stripDays, :));
                currentThreshold = meanStd * ws * (thresholdMult * 0.1 + 0.01);

                %extract
                %[windows, ind, val] = simpleExtraction(resRunTest, ws, currentThreshold, true, true);
                
                %TODO Fix number of windows extracted
                %[windows, ind] = windowExtraction(resRunTest, ws, 50, true);
                [windows, ind] = largestWindow(resRunTest, ws, 60, false, true);
                
                
                if size(windows, 1) < minWindows;
                    %fprintf(1, 'Too few windows\n');
                    continue
                end
                
                %Average a few runs
                for av = 1:numAvgRuns
                    %Cluster and compute
                    [idx, centers] = kmeans2(windows, numClusters, 'minCl', 4, 'outFrac', 0.1);
                    
                    if size(centers, 1) < 4
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

%resRunTest = smooth(resTest, bestSmoothAmount)';
resRunTest = resTest;

[testMeans, testStds] = dailyMean(resRunTest(1, :), resTimes, data.blocksInDay, 'smooth', false);
meanStd = mean(testStds(data.stripDays, :));
currentThreshold = meanStd * bestWS * (bestThresholdMult * 0.1 + 0.01);

% %Work on removing residuals
%[windows, ind, val] = simpleExtraction(resRunTest, bestWS, currentThreshold, true, true);
%[windows, ind] = windowExtraction(resRunTest, bestWS, 50, true);
% 
[windows, ind] = largestWindow(resRunTest, bestWS, 60, false, true);
% 
%[idx, centers] = kmeans(windows, bestNumClusters);
[idx, centers, kdists] = kmeans2(windows, bestNumClusters, 'minCl', 4, 'outFrac', 0.1);
sval = silhouette(windows, idx);
fprintf(1, 'Centers: %i\n', size(centers, 1));
mean(sval)


plotClusters(windows, idx, 'centers', centers);


index = find(idx == 1);
clustData = windows(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));

modelAvg1 = bcf.models.AvgGaussian(bestWS);
modelAvg1.train(clustData);

index = find(idx == 2);
clustData = windows(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));

modelAvg2 = bcf.models.AvgGaussian(bestWS);
modelAvg2.train(clustData);

index = find(idx == 3);
clustData = windows(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));

modelAvg3 = bcf.models.AvgGaussian(bestWS);
modelAvg3.train(clustData);

%Now make an avg model of the anomalies
index = find(idx == 4);
clustData = windows(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));

modelAvg4 = bcf.models.AvgGaussian(bestWS);
modelAvg4.train(clustData);

%Now make an avg model of the anomalies
index = find(idx == 5);
clustData = windows(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));

modelAvg5 = bcf.models.AvgGaussian(bestWS);
modelAvg5.train(clustData);


%Now make an avg model of the anomalies
index = find(idx == 6);
clustData = windows(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));

modelAvg6 = bcf.models.AvgGaussian(bestWS);
modelAvg6.train(clustData);


backModel = bcf.models.AvgGaussian(1);
backModel.noiseValues = std(resTest);
backModel.avgValues = mean(resTest);

models = {modelAvg1; modelAvg2; modelAvg3; modelAvg4; modelAvg5; backModel};

forecaster = bcf.BayesianLocalForecaster(models);
[adjRes, p, post, l, histPost] = forecaster.forecastAll(resTest, horizon);

adjData = fTest + adjRes;
adjResTest = resTest - adjRes;

BCFRMSE = errperf(testData(1:end), fTest(1:end), 'rmse')
modBCFRMSE = errperf(testData(1:end), adjData(1:end), 'rmse')
[ponanValue rmseonanValue sseonanValue ~] = ponan(resTest, testStds(data.stripDays, :));
[ponanValue rmseonanValue sseonanValue2 ~] = ponan(adjResTest, testStds(data.stripDays, :));
sseonanValue
sseonanValue2


st = 900;
ed = 1299;
plot(resTest(1, st:ed))
hold on
plot(adjRes(1, st:ed), 'Color', [1 0 0])



