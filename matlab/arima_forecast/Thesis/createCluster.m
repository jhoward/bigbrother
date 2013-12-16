function [windows, ind, idx, centers, kdists] = createCluster(data, ...
                            extractType, clustMin, clustMax, ...
                            extractPer, windowMin, windowMax, ...
                            smoothAmount, verbose)
    
    %Perform an exhaustive search for the best clusters
    %Uses silhoutette score to rank clusterings
    %TODO make other extraction types beyone just type one work.

    numAvgRuns = 10;
    bestWS = windowMin;
    bestNumClusters = clustMin;
    bestSilhouette = 0;
    threshMin = 1;
    threshMax = 1;
    meanStd = std(data);
    
    for ws = windowMin:1:windowMax
        for numClusters = clustMin:clustMax
            for thresholdMult = threshMin:threshMax
                avgSilh = 0;

                %currentThreshold = meanStd * ws * (thresholdMult * 0.1 + threshAdd);
                numExtractions = floor(size(data, 2) / ws * extractPer);
                
                if extractType == 1
                    [windows, ~] = largestWindow(data, ws, numExtractions, false, smoothAmount);
                elseif extractType == 2
                    [windows, ~] = windowExtraction(data, ws, numExtractions, smoothAmount);
                elseif extractType == 3
                    [windows, ~] = simpleExtraction(data, ws, currentThreshold, true, true);
                end
                
                
                %Average a few runs
                for av = 1:numAvgRuns
                    %Cluster and compute
                    [idx, centers] = kmeans2(windows, numClusters, 'minCl', clustMin, 'outFrac', 0.1);
                    
                    if size(centers, 1) < clustMin
                        continue
                    end
                    
                    sval = silhouette(windows, idx);
                    currentSilh = mean(sval); 
                    
                    avgSilh = avgSilh + currentSilh;
                end
                
                avgSilh = avgSilh / numAvgRuns;
                
                if avgSilh > bestSilhouette
                    bestWS = ws;
                    bestNumClusters = numClusters;
                    bestSilhouette = avgSilh;

                    if verbose
                        fprintf(1, 'New best silh: %f   ws: %i   clus: %i\n', ...
                            bestSilhouette, bestWS, bestNumClusters);
                    end
                end
            end
        end
    end
    
    %Take the best from multiple clusterings
    bestSilhouette = 0;
    bestIdx = 0;
    bestCenters = 0;
    bestKDists = 0;
    
    %Extract the best
    numExtractions = floor(size(data, 2) / bestWS * extractPer);
    
    if extractType == 1
        [windows, ind] = largestWindow(data, bestWS, numExtractions, false, smoothAmount);
    end
    
    for av = 1:numAvgRuns
    
        [idx, centers, kdists] = kmeans2(windows, bestNumClusters, 'minCl', clustMin, 'outFrac', 0.1);
        sval = silhouette(windows, idx);
        
        if mean(sval) > bestSilhouette
            bestIdx = idx;
            bestCenters = centers;
            bestKDists = kdists;
            bestSilhouette = mean(sval);
        end
    end

    if verbose
        fprintf(1, 'Final Silhouette score: %f\n', bestSilhouette);
    end
    
    idx = bestIdx;
    centers = bestCenters;
    kdists = bestKDists;
end

