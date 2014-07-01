clear all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DATASET == 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataSet = 1;

load(MyConstants.HORIZON_DATA_LOCATIONS{dataSet});
load(MyConstants.BCF_RESULTS_LOCATIONS{dataSet});

saveLocationStart = strcat(MyConstants.THESIS_LOCATION, 'images/models/');
saveLocationEnd = strcat('-ds-', int2str(dataSet), '_results.png');


trainTestSet = 1;    
metric = 1;
yLim = 0.25;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');

trainTestSet = 1;
metric = 2;
yLim = 3.5;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');

trainTestSet = 1;
metric = 3;
yLim = 0.8;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');

trainTestSet = 1;
metric = 4;
yLim = 0.25;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');

trainTestSet = 1;
metric = 5;
yLim = 0.14;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');


trainTestSet = 3;
metric = 1;
yLim = 0.25;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 2;
yLim = 3.5;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 3;
yLim = 0.8;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 4;
yLim = 0.25;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 5;
yLim = 0.15;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');


%--------------------------------------------------------------------------
%BCF Results - Dataset 1
%--------------------------------------------------------------------------

trainTestSet = 3;
metric = 1;
yLim = 0.25;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, true, false, 'bcfResults', bcfResults)
saveas(fig, ...
    strcat(saveLocationStart, 'bcf_metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 2;
yLim = 3.5;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, true, false,  'bcfResults', bcfResults)
saveas(fig, ...
    strcat(saveLocationStart, 'bcf_metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 5;
yLim = 0.15;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, true, false,  'bcfResults', bcfResults)
saveas(fig, ...
    strcat(saveLocationStart, 'bcf_metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DATASET == 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataSet = 2;

saveLocationStart = strcat(MyConstants.THESIS_LOCATION, 'images/models/');
saveLocationEnd = strcat('ds-', int2str(dataSet), '_results.png');

load(MyConstants.HORIZON_DATA_LOCATIONS{dataSet});
load(MyConstants.BCF_RESULTS_LOCATIONS{dataSet})


trainTestSet = 1;
metric = 1;
yLim = 0.25;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');

trainTestSet = 1;
metric = 2;
yLim = 2.5;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');

trainTestSet = 1;
metric = 3;
yLim = 0.8;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');

trainTestSet = 1;
metric = 4;
yLim = 0.25;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');

trainTestSet = 1;
metric = 5;
yLim = 0.25;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');


trainTestSet = 3;
metric = 1;
yLim = 0.25;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 2;
yLim = 2.5;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 3;
yLim = 0.8;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 4;
yLim = 0.25;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');


trainTestSet = 3;
metric = 5;
yLim = 0.15;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

%--------------------------------------------------------------------------
%BCF Results - Dataset 2
%--------------------------------------------------------------------------

trainTestSet = 3;
metric = 1;
yLim = 0.35;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, true, false, 'bcfResults', bcfResults)
saveas(fig, ...
    strcat(saveLocationStart, 'bcf_metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 2;
yLim = 4.5;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, true, false,  'bcfResults', bcfResults)
saveas(fig, ...
    strcat(saveLocationStart, 'bcf_metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 5;
yLim = 0.35;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, true, false,  'bcfResults', bcfResults)
saveas(fig, ...
    strcat(saveLocationStart, 'bcf_metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DATASET == 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataSet = 3;

saveLocationStart = strcat(MyConstants.THESIS_LOCATION, 'images/models/');
saveLocationEnd = strcat('ds-', int2str(dataSet), '_results.png');

load(MyConstants.HORIZON_DATA_LOCATIONS{dataSet});
load(MyConstants.BCF_RESULTS_LOCATIONS{dataSet})

trainTestSet = 1;
metric = 1;
yLim = 0.4;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');

trainTestSet = 1;
metric = 2;
yLim = 4.5;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');

trainTestSet = 1;
metric = 3;
yLim = 0.8;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');

trainTestSet = 1;
metric = 4;
yLim = 0.5;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');

trainTestSet = 1;
metric = 5;
yLim = 0.3;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-trainSet', saveLocationEnd), 'png');


trainTestSet = 3;
metric = 1;
yLim = 0.4;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 2;
yLim = 5;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 3;
yLim = 0.8;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 4;
yLim = 0.4;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');


trainTestSet = 3;
metric = 5;
yLim = 0.3;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, false, false)
saveas(fig, ...
    strcat(saveLocationStart, 'metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

%--------------------------------------------------------------------------
%BCF Results - Dataset 3
%--------------------------------------------------------------------------

trainTestSet = 3;
metric = 1;
yLim = 0.35;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, true, false, 'bcfResults', bcfResults)
saveas(fig, ...
    strcat(saveLocationStart, 'bcf_metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 2;
yLim = 4.5;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, true, false,  'bcfResults', bcfResults)
saveas(fig, ...
    strcat(saveLocationStart, 'bcf_metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

trainTestSet = 3;
metric = 5;
yLim = 0.35;
fig = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, true, false,  'bcfResults', bcfResults)
saveas(fig, ...
    strcat(saveLocationStart, 'bcf_metric_', MyConstants.METRIC_NAMES{metric}, '-testSet', saveLocationEnd), 'png');

