%file: bcf2ARIMA
%author: James Howard
%
%Compute the activity recongition improved BCF for ARIMA models

clear all;

dataSet = 1;
model = 2; %Set MODEL to ARIMA
horizon = 1;

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

for ws = 14:-1:12
    
    fprintf(1, 'Windowsize: %i\n', ws);
    
    for smoothAmount = 1:1
        for numClusters = 4:12
            for thresholdMult = 8:14
                avgSilh = 0;
                
                %smooth
                %resRunTest = smooth(resTest, smoothAmount)';
                resRunTest = resTest;
                
                %Compute threshold
                [testMeans, testStds] = dailyMean(resRunTest(1, :), resTimes, data.blocksInDay, 'smooth', false);
                meanStd = mean(testStds(data.stripDays, :));
                currentThreshold = meanStd * ws * (thresholdMult * 0.1 + 0.3);

                %extract
                [windows, ind, val] = simpleExtraction(resRunTest, ws, currentThreshold, true);
                
                %TODO Fix number of windows extracted
                %[windows, ind] = windowExtraction(resRunTest, ws, 50);
                
                if size(windows, 1) < minWindows;
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
currentThreshold = meanStd * bestWS * (bestThresholdMult * 0.1 + 0.3);

% %Work on removing residuals
[windows, ind, val] = simpleExtraction(resRunTest, bestWS, currentThreshold, true);
%[windows, ind] = windowExtraction(resRunTest, bestWS, 50);
% 
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

%Now make an avg model of the anomalies
index = find(idx == 2);
clustData = windows(index, :);
%clustData2 = repmat(clustData, [1 1 size(clustData, 1)]);
clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));

modelAvg2 = bcf.models.AvgGaussian(bestWS);
modelAvg2.train(clustData);

backModel = bcf.models.AvgGaussian(1);
backModel.noiseValues = std(resTest);
backModel.avgValues = mean(resTest);

models = {modelAvg1; modelAvg2; backModel};

forecaster = bcf.BayesianLocalForecaster(models);
forecaster.forecastAll(resTest(78:78*10), 1, 'aggregate')
