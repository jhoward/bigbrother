clear all

dataSet = 3;

load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
%load(MyConstants.BCF_RESULTS_LOCATIONS{dataSet});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

%==========================================================================
%PLOT SAMPLE ANOMALOUS EVENT
%==========================================================================

res = data.testData(1, data.blocksInDay:end) - horizons.arima{11}{3};
[means, stds] = computeMean(res, data.blocksInDay);

%Find the events - commented out once events are found
%contPlotMult({res}, data.blocksInDay, stds);

%startTime = 1489;
startTime = 769;
%startTime = 5089;
endTime = startTime + data.blocksInDay - 1;

tmpRes = res(1, startTime:endTime);
tmpStds = 1 * stds;

fig = figure('Position', [100, 100, 1100, 850]);

yMax = max(tmpRes, 2);
yMin = min(tmpRes, 2);

dataWidth = size(tmpStds, 2);

xvals = 1:1:dataWidth;
xvals = [xvals, fliplr(xvals)];

y1 = -1 * tmpStds;
y2 = tmpStds;
yvals = [y1, fliplr(y2)];
tmp = fill(xvals, yvals, [0.5, 0, 0]);
set(tmp,'EdgeColor',[0.5, 0, 0],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on

plot(tmpRes(1, 1:dataWidth), 'Color', [0 0 0])

hold off
xlim([1, dataWidth]);
ylim([-0.8, 0.8]);

xlabel('Time step', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
ylabel('Residual Counts', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
title('Demonstration of anomalous event', 'FontSize', 24, 'FontName', MyConstants.FONT_TYPE);


%==========================================================================
%HISTOGRAM OF RESIDUAL DATA
%==========================================================================
res = data.testData(1, data.blocksInDay:end) - horizons.arima{11}{3};
tmpRes = res(data.blocksInDay + 2:end);

[means, stds] = computeMean(tmpRes, data.blocksInDay);

[n, x] = hist(tmpRes, 200);
n = n/length(tmpRes)/diff(x(1:2));
bar(x,n,'hist')
hold on
m = mean(tmpRes);
s = std(tmpRes);
%plot(x, normpdf(x, m, s), 'r')
%plot(x, normpdf(x, m, s/2), 'g')
plot(x, cauchypdf(x, m, s/3.7), 'r')
cauchypdf([0.8 0.6 0.4 -0.4], m, s/3.7)


%==========================================================================
%HISTOGRAM OF INDIVIDUAL HOUR OF DATA DATA
%==========================================================================
hour = 38;
res = data.testData(1, data.blocksInDay:end) - horizons.arima{11}{3};
tmpRes = res(data.blocksInDay + 2:end);
tmpRes = reshape(tmpRes, data.blocksInDay, size(tmpRes, 2)/data.blocksInDay);

tmpRes = tmpRes(hour, :);

[means, stds] = computeMean(tmpRes, data.blocksInDay);

[n, x] = hist(tmpRes, 30);
n = n/length(tmpRes)/diff(x(1:2));

fig = figure('Position', [100, 100, 1100, 850]);
bar(x,n,'hist')
hold on
m = mean(tmpRes);
s = std(tmpRes);
plot(x, normpdf(x, m, s/1.2), 'r')
xlabel('Residual value', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
ylabel('Scaled histogram counts', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
title('Denver BCF Residual Histogram (TS 38)', 'FontSize', 24, 'FontName', MyConstants.FONT_TYPE);
%plot(x, normpdf(x, m, s), 'g')
%plot(x, cauchypdf(x, m, s/3.7), 'r')
%cauchypdf([0.8 0.6 0.4 -0.4], m, s/3.7)


%==========================================================================
% SAMPLE DATASET GRAPH
%==========================================================================

%Plot cont graph first
contPlotMult({data.testData(1, fStart:fEnd), results.arima.testForecast{2}, results.ABCF.carima.testForecast{2}}, data.blocksInDay*2, zeros(data.blocksInDay * 2, 1))


%==========================================================================
% PLOT CLUSTERS
%==========================================================================
clear all
dataset = 3;
horizon = 2;

%svm - d1, h2
%arima - d3, h2

load(MyConstants.RESULTS_DATA_LOCATIONS{dataset});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataset});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

tmpStruct = results.ABCF.csvm

fig = plotClustersThesis(tmpStruct.clusters{horizon}, tmpStruct.idx{horizon}, ...
            'centers', tmpStruct.centers{horizon}, 'dataset', dataset, 'model', 'carima');
        
export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'clusters_svm_', MyConstants.DATA_SETS{dataset}, '.png'), fig, '-transparent', '-nocrop');

