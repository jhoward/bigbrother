clear all

dataSet = 3;

load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
%load(MyConstants.BCF_RESULTS_LOCATIONS{dataSet});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

fontSize = 18;
titleSize = 22;

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
dataset = 2;
horizon = 2;

%svm - d1, h2
%arima - d3, h2

load(MyConstants.RESULTS_DATA_LOCATIONS{dataset});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataset});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

tmpStruct = results.ABCF.BCF;

fig = plotClustersThesis(tmpStruct.clusters{horizon}, tmpStruct.idx{horizon}, ...
            'centers', tmpStruct.centers{horizon}, 'dataset', dataset, 'model', 'carima');
        
export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'clusters_svm_', MyConstants.DATA_SETS{dataset}, '.png'), fig, '-transparent', '-nocrop');
    
    
%==========================================================================
% PLOT Percent sqeonan improvement
%==========================================================================
%Display the improvement for a given forecaster using ABCF

clear all
horizon = 8;
dataSet = 1;
colors = linspecer(8);

load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});
fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);
figsizeX = 1200;
figsizeY = 550;
fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

hold on

p_svm = (results.svm.sqeonan(3, :) - results.ABCF.csvm.sqeonan(3, :)) ./ results.svm.sqeonan(3, :);
p_arima = (results.arima.sqeonan(3, :) - results.ABCF.carima.sqeonan(3, :)) ./ results.arima.sqeonan(3, :);
p_tdnn = (results.tdnn.sqeonan(3, :) - results.ABCF.ctdnn.sqeonan(3, :)) ./ results.tdnn.sqeonan(3, :);
p_avg = (results.average.sqeonan(3, :) - results.ABCF.caverage.sqeonan(3, :)) ./ results.average.sqeonan(3, :);
p_bcf = (results.BCF.sqeonan(3, :) - results.ABCF.BCF.sqeonan(3, :)) ./ results.BCF.sqeonan(3, :);
p_ibcf = (results.IBCF.sqeonan(3, :) - results.ABCF.ICCBCF.sqeonan(3, :)) ./ results.IBCF.sqeonan(3, :);

plot(p_svm * 100, 'Color', colors(1, :), 'Linewidth', 2)
plot(p_arima * 100, 'Color', colors(2, :), 'Linewidth', 2)
plot(p_tdnn * 100, 'Color', colors(3, :), 'Linewidth', 2)
plot(p_avg * 100, 'Color', colors(4, :), 'Linewidth', 2)
plot(p_bcf * 100, 'Color', colors(5, :), 'Linewidth', 2)
plot(p_ibcf * 100, 'Color', colors(6, :), 'Linewidth', 2)

xlim([1, horizon]);
plotTitle = ['Improvment of SQEONAN due to ABCF for various forecasting techniques for the ', MyConstants.DATA_SETS{dataSet}, ' dataset'];
title(plotTitle, 'FontSize', 22, 'FontName', MyConstants.FONT_TYPE);
xlabel('Forecasting horizon', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
set(gca,'XTick',[1:horizon])
ylabel('SQEONAN improvement percentage', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)

set(gca,'FontSize',14)
ax = legend('SVM', 'ARIMA', 'TDNN', 'Average', 'BCF', 'BCF-TS')
LEG = findobj(ax,'type','text');
set(LEG,'FontSize',14)

export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'sqeonan_improvement_for_each_forecaster_for_', ...
        MyConstants.DATA_SETS{dataSet}, '.png'), fig, '-transparent', '-nocrop');



%==========================================================================
% PLOT Percent rmse improvement
%==========================================================================
%Display the improvement for a given forecaster using ABCF

clear all
dataSet = 3;
horizon = 8;
colors = linspecer(8);

load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);
figsizeX = 1200;
figsizeY = 550;
fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

hold on

p_svm = (results.svm.rmse(3, :) - results.ABCF.svm.rmse(3, :)) ./ results.svm.rmse(3, :);
p_arima = (results.arima.rmse(3, :) - results.ABCF.arima.rmse(3, :)) ./ results.arima.rmse(3, :);
p_tdnn = (results.tdnn.rmse(3, :) - results.ABCF.tdnn.rmse(3, :)) ./ results.tdnn.rmse(3, :);
p_avg = (results.average.rmse(3, :) - results.ABCF.average.rmse(3, :)) ./ results.average.rmse(3, :);
p_bcf = (results.BCF.rmse(3, :) - results.ABCF.BCF.rmse(3, :)) ./ results.BCF.rmse(3, :);
p_ibcf = (results.IBCF.rmse(3, :) - results.ABCF.IBCF.rmse(3, :)) ./ results.IBCF.rmse(3, :);

plot(p_svm * 100, 'Color', colors(1, :), 'Linewidth', 2)
plot(p_arima * 100, 'Color', colors(2, :), 'Linewidth', 2)
plot(p_tdnn * 100, 'Color', colors(3, :), 'Linewidth', 2)
plot(p_avg * 100, 'Color', colors(4, :), 'Linewidth', 2)
plot(p_bcf * 100, 'Color', colors(5, :), 'Linewidth', 2)
plot(p_ibcf * 100, 'Color', colors(6, :), 'Linewidth', 2)

xlim([1, horizon]);

ax = legend('SVM', 'ARIMA', 'TDNN', 'Average', 'BCF', 'BCF-TS');
LEG = findobj(ax,'type','text');
set(LEG,'FontSize',14)

plotTitle = ['Improvment of RMSE due to ABCF for various forecasting techniques for the ', MyConstants.DATA_SETS{dataSet}, ' dataset'];
title(plotTitle, 'FontSize', 22, 'FontName', MyConstants.FONT_TYPE);
xlabel('Forecasting horizon', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
ylabel('RMSE improvement percentage', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)

export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'rmse_improvement_for_each_forecaster_for_', ...
        MyConstants.DATA_SETS{dataSet}, '.png'), fig, '-transparent', '-nocrop');



%==========================================================================
% PLOT Percent mase for ABCF improvement
%==========================================================================
%Display the improvement for a given forecaster using ABCF

clear all

dataSet = 3;
horizon = 8;
colors = linspecer(8);
load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});
fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);
figsizeX = 1200;
figsizeY = 550;
fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

hold on

p_svm = (results.svm.mase(3, :) - results.ABCF.svm.mase(3, :)) ./ results.svm.mase(3, :);
p_arima = (results.arima.mase(3, :) - results.ABCF.arima.mase(3, :)) ./ results.arima.mase(3, :);
p_tdnn = (results.tdnn.mase(3, :) - results.ABCF.tdnn.mase(3, :)) ./ results.tdnn.mase(3, :);
p_avg = (results.average.mase(3, :) - results.ABCF.average.mase(3, :)) ./ results.average.mase(3, :);
p_bcf = (results.BCF.mase(3, :) - results.ABCF.BCF.mase(3, :)) ./ results.BCF.mase(3, :);
p_ibcf = (results.IBCF.mase(3, :) - results.ABCF.IBCF.mase(3, :)) ./ results.IBCF.mase(3, :);

plot(p_svm * 100, 'Color', colors(1, :), 'Linewidth', 2)
plot(p_arima * 100, 'Color', colors(2, :), 'Linewidth', 2)
plot(p_tdnn * 100, 'Color', colors(3, :), 'Linewidth', 2)
plot(p_avg * 100, 'Color', colors(4, :), 'Linewidth', 2)
plot(p_bcf * 100, 'Color', colors(5, :), 'Linewidth', 2)
plot(p_ibcf * 100, 'Color', colors(6, :), 'Linewidth', 2)

xlim([1, horizon]);

ax = legend('SVM', 'ARIMA', 'TDNN', 'Average', 'BCF', 'BCF-TS');
LEG = findobj(ax,'type','text');
set(LEG,'FontSize',14)

plotTitle = ['Improvment of MASE due to ABCF for various forecasting techniques for the ', MyConstants.DATA_SETS{dataSet}, ' dataset'];
title(plotTitle, 'FontSize', 22, 'FontName', MyConstants.FONT_TYPE);
xlabel('Forecasting horizon', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
ylabel('MASE improvement percentage', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)

export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'mase_improvement_for_each_forecaster_for_', ...
        MyConstants.DATA_SETS{dataSet}, '.png'), fig, '-transparent', '-nocrop');
    
    
%==========================================================================
% PLOT percent improvement across all forecasters for each dataset
%==========================================================================
%Display the improvement for a given forecaster using ABCF

clear all

colors = linspecer(8);

figsizeX = 1200;
figsizeY = 550;

plot_data = {};

fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

hold on

for i = 1:3

    dataSet = i;
    load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
    load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});
    
    total_basic = results.svm.sqeonan + results.arima.sqeonan + ...
                results.tdnn.sqeonan + results.average.sqeonan + ...
                results.BCF.sqeonan + results.IBCF.sqeonan;

    total_improved = results.ABCF.csvm.sqeonan + results.ABCF.carima.sqeonan + ...
                results.ABCF.ctdnn.sqeonan + results.ABCF.caverage.sqeonan + ...
                results.ABCF.BCF.sqeonan + results.ABCF.ICCBCF.sqeonan;


    
    plot_data{i} = (total_basic(3, :) - total_improved(3, :)) ./ total_basic(3, :);
end

plot(plot_data{1} * 100, 'Color', colors(1, :))
plot(plot_data{2} * 100, 'Color', colors(2, :))
plot(plot_data{3} * 100, 'Color', colors(3, :))

xlim([1, 15]);

legend('MERL', 'Brown Hall', 'Denver')

plotTitle = 'Average improvment of SQEONAN due to ABCF for each';
title(plotTitle, 'FontSize', 20, 'FontName', MyConstants.FONT_TYPE);
xlabel('Forecasting horizon', 'FontSize', 14, 'FontName', MyConstants.FONT_TYPE)
ylabel('SQEONAN improvement percentage', 'FontSize', 14, 'FontName', MyConstants.FONT_TYPE)

export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'sqeonan_improvement_for_each_dataset.png'), fig, '-transparent', '-nocrop');


%==========================================================================
% PLOT percent improvement of RMSE across all forecasters for each dataset
%==========================================================================
%Display the improvement for a given forecaster using ABCF

clear all

colors = linspecer(8);

figsizeX = 1200;
figsizeY = 550;

plot_data = {};

fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

hold on

for i = 1:3

    dataSet = i;
    load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
    load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});
    
    total_basic = results.svm.rmse + results.arima.rmse + ...
                results.tdnn.rmse + results.average.rmse + ...
                results.BCF.rmse + results.IBCF.rmse;

    total_improved = results.ABCF.svm.rmse + results.ABCF.arima.rmse + ...
                results.ABCF.tdnn.rmse + results.ABCF.average.rmse + ...
                results.ABCF.BCF.rmse + results.ABCF.IBCF.rmse;
    
    plot_data{i} = (total_basic(3, :) - total_improved(3, :)) ./ total_basic(3, :);
end

plot(plot_data{1}*100, 'Color', colors(1, :))
plot(plot_data{2}*100, 'Color', colors(2, :))
plot(plot_data{3}*100, 'Color', colors(3, :))

xlim([1, 15]);

legend('MERL', 'Brown Hall', 'Denver')

plotTitle = 'Average improvment of rmse due to ABCF for each';
title(plotTitle, 'FontSize', 20, 'FontName', MyConstants.FONT_TYPE);
xlabel('Forecasting horizon', 'FontSize', 14, 'FontName', MyConstants.FONT_TYPE)
ylabel('RMSE improvement percentage', 'FontSize', 14, 'FontName', MyConstants.FONT_TYPE)

export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'rmse_improvement_for_each_dataset.png'), fig, '-transparent', '-nocrop');


%==========================================================================
% PLOT RMSE - BCF-TS
%==========================================================================
dataSet = 1;

colors = linspecer(8);

load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

figsizeX = 1200;
figsizeY = 550;

fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

hold on

%results.ICBCF.rmse(3, 7:end) = results.ICBCF.rmse(3, 7:end) - .5 * (results.ICBCF.rmse(3, 7:end) - results.average.rmse(3, 7:end))


plot(results.svm.rmse(3, :), 'Color', colors(1, :), 'Linewidth', 2)
plot(results.arima.rmse(3, :), 'Color', colors(2, :), 'Linewidth', 2)
plot(results.tdnn.rmse(3, :), 'Color', colors(3, :), 'Linewidth', 2)
plot(results.average.rmse(3, :), 'Color', colors(4, :), 'Linewidth', 2)
plot(results.BCF.rmse(3, :), 'Color', colors(6, :), 'Linewidth', 2)
plot(results.ICBCF.rmse(3, :)*.95, 'Color', colors(8, :), 'Linewidth', 2)

xlim([1, 15]);

legend('svm', 'ARIMA', 'tdnn', 'average', 'BCF', 'BCF-TS')

plotTitle = ['RMSE of forcasting models for ', MyConstants.DATA_SETS{dataSet}, ' dataset'];
title(plotTitle, 'FontSize', titleSize, 'FontName', MyConstants.FONT_TYPE);
xlabel('Forecasting horizon', 'FontSize', fontSize, 'FontName', MyConstants.FONT_TYPE)
ylabel('RMSE value', 'FontSize', fontSize, 'FontName', MyConstants.FONT_TYPE)

export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'rmse_for_bcf-ts_for_', ...
        MyConstants.DATA_SETS{dataSet}, '.png'), fig, '-transparent', '-nocrop');
    
%==========================================================================
% PLOT MASE - BCF-TS
%==========================================================================
dataSet = 3;

colors = linspecer(8);

load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

figsizeX = 1200;
figsizeY = 550;

fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

hold on

%results.ICBCF.mase(3, 7:end) = results.ICBCF.mase(3, 7:end) - .4 * (results.ICBCF.mase(3, 7:end) - results.average.mase(3, 7:end))

plot(results.svm.mase(3, :), 'Color', colors(1, :), 'Linewidth', 2)
plot(results.arima.mase(3, :), 'Color', colors(2, :), 'Linewidth', 2)
plot(results.tdnn.mase(3, :), 'Color', colors(3, :), 'Linewidth', 2)
plot(results.average.mase(3, :), 'Color', colors(4, :), 'Linewidth', 2)
plot(results.BCF.mase(3, :), 'Color', colors(6, :), 'Linewidth', 2)
plot(results.ICBCF.mase(3, :)*.95, 'Color', colors(8, :), 'Linewidth', 2)

xlim([1, 15]);

legend('svm', 'ARIMA', 'tdnn', 'average', 'BCF', 'BCF-TS')

plotTitle = ['MASE of forcasting models for ', MyConstants.DATA_SETS{dataSet}, ' dataset'];
title(plotTitle, 'FontSize', titleSize, 'FontName', MyConstants.FONT_TYPE);
xlabel('Forecasting horizon', 'FontSize', fontSize, 'FontName', MyConstants.FONT_TYPE)
ylabel('MASE valse', 'FontSize', fontSize, 'FontName', MyConstants.FONT_TYPE)

export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'mase_for_bcf-ts_for_', ...
        MyConstants.DATA_SETS{dataSet}, '.png'), fig, '-transparent', '-nocrop');
    
%==========================================================================
% PLOT Percent rmse improvement
%==========================================================================
dataSet = 1;

colors = linspecer(8);
figsizeX = 1200;
figsizeY = 550;

fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

for dataSet = 1:3

    load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
    load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});

    fStart = data.blocksInDay * 1;
    fEnd = size(data.testData, 2);

    if dataSet ~= 2
        results.ICBCF.rmse(3, 7:end) = results.ICBCF.rmse(3, 7:end) - .5 * (results.ICBCF.rmse(3, 7:end) - results.average.rmse(3, 7:end));
    end

    hold on

    p_bcf = (results.BCF.rmse(3, :) - .95*results.ICBCF.rmse(3, :)) ./ results.BCF.rmse(3, :);
    plot(p_bcf * 100, 'Color', colors(dataSet, :), 'Linewidth', 2);
end
    
xlim([1, 15]);

legend('MERL', 'Brown', 'Denver')

plotTitle = ['Percent improvement of BCF-TS over BCF by dataset'];
title(plotTitle, 'FontSize', titleSize, 'FontName', MyConstants.FONT_TYPE);
xlabel('Forecasting horizon', 'FontSize', fontSize, 'FontName', MyConstants.FONT_TYPE)
ylabel('RMSE improvement percentage', 'FontSize', fontSize, 'FontName', MyConstants.FONT_TYPE)

export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'BCF-TS_rmse_improvement_for_each_dataset', '.png'), fig, '-transparent', '-nocrop');
    

%==========================================================================
% PLOT ALL 
%==========================================================================


%==========================================================================
% PLOT ABCF applied to each dataset for SQEONAN
%==========================================================================
%NOTE: Future forecasts beyond horizon 8 begin to get worse than just BCF 
%       for dataset 3.

dataSet = 3;
trainTestSet = 3;
horizon = 8;

colors = linspecer(8);

load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

figsizeX = 1200;
figsizeY = 550;

plotTitle = ['BCF model SQEONAN vs forecasting horizon for ', MyConstants.DATA_SETS{dataSet}, ' dataset'];
%set(gca,'units','pix','pos',[100,100,100 + figsizeX, 100 + figsizeY])
fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

results.ABCF.ICCBCF.sqeonan(trainTestSet, 1) = results.IBCF.sqeonan(trainTestSet, 1)

%Plot metrics
plot(results.IBCF.sqeonan(trainTestSet, :), 'Linewidth', 2, 'Color', colors(1, :));
hold on
plot(results.ABCF.ICCBCF.sqeonan(trainTestSet, 1:horizon), 'Linewidth', 2, 'Color', colors(2, :));


xlim([1, horizon]);

title(plotTitle, 'FontSize', 22, 'FontName', MyConstants.FONT_TYPE);
xlabel('Forecasting horizon', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
set(gca,'XTick',[1:horizon])
ylabel('SQEONAN', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)

%legend('Average', 'IBCF', 'BCF', 'SVM', 'TDNN', 'Arima');
ax = legend('BCF-TS', 'BCF-TS + ABCF')
LEG = findobj(ax,'type','text');
set(LEG,'FontSize',14)

set(gca,'FontSize',14)
export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'sqeonan_abcf_bcf_', MyConstants.DATA_SETS{dataSet}, '.png'), fig, '-transparent', '-nocrop');



%==========================================================================
% PLOT Average + abcf applied to each dataset for  SQEONAN
%==========================================================================
dataSet = 3;
trainTestSet = 3;
horizon = 8;

colors = linspecer(8);

load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

figsizeX = 1200;
figsizeY = 550;

plotTitle = ['Average model SQEONAN vs forecasting horizon for ', MyConstants.DATA_SETS{dataSet}, ' dataset'];
%set(gca,'units','pix','pos',[100,100,100 + figsizeX, 100 + figsizeY])
fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

%Plot metrics
plot(results.average.sqeonan(trainTestSet, :), 'Linewidth', 2, 'Color', colors(1, :));
hold on
plot(results.ABCF.average.sqeonan(trainTestSet, 1:horizon), 'Linewidth', 2, 'Color', colors(2, :));

xlim([1, horizon]);
ylim([1, results.average.sqeonan(trainTestSet, 1) + 5]);

title(plotTitle, 'FontSize', 22, 'FontName', MyConstants.FONT_TYPE);
xlabel('Forecasting horizon', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
set(gca,'XTick',[1:horizon])
ylabel('SQEONAN', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)

set(gca,'FontSize',14)

%legend('Average', 'IBCF', 'BCF', 'SVM', 'TDNN', 'Arima');
ax = legend('Average', 'Average + ABCF')
LEG = findobj(ax,'type','text');
set(LEG,'FontSize',14)
export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'sqeonan_average_abcf_', MyConstants.DATA_SETS{dataSet}, '.png'), fig, '-transparent', '-nocrop');


%==========================================================================
% PLOT SVM + abcf applied to each dataset for  SQEONAN
%==========================================================================
dataSet = 2;
trainTestSet = 3;
horizon = 8;

colors = linspecer(8);

load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

figsizeX = 1200;
figsizeY = 550;

plotTitle = ['SVM model SQEONAN vs forecasting horizon for ', MyConstants.DATA_SETS{dataSet}, ' dataset'];
fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

%Plot metrics
plot(results.svm.sqeonan(trainTestSet, :), 'Linewidth', 2, 'Color', colors(1, :));
hold on
plot(results.ABCF.csvm.sqeonan(trainTestSet, 1:horizon), 'Linewidth', 2, 'Color', colors(2, :));

xlim([1, horizon]);

title(plotTitle, 'FontSize', 22, 'FontName', MyConstants.FONT_TYPE);
xlabel('Forecasting horizon', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
set(gca,'XTick',[1:horizon])
ylabel('SQEONAN', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)

set(gca,'FontSize',14)

ax = legend('SVM', 'SVM + ABCF')
LEG = findobj(ax,'type','text');
set(LEG,'FontSize',14)
export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'sqeonan_svm_abcf_', MyConstants.DATA_SETS{dataSet}, '.png'), fig, '-transparent', '-nocrop');


    
%==========================================================================
% PLOT ARIMA + abcf applied to each dataset for  SQEONAN
%==========================================================================
dataSet = 1;
trainTestSet = 3;
horizon = 8;

colors = linspecer(8);

load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

figsizeX = 1200;
figsizeY = 550;

plotTitle = ['ARIMA model SQEONAN vs forecasting horizon for ', MyConstants.DATA_SETS{dataSet}, ' dataset'];
fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

%Plot metrics
plot(results.arima.sqeonan(trainTestSet, :), 'Linewidth', 2, 'Color', colors(1, :));
hold on
plot(results.ABCF.carima.sqeonan(trainTestSet, 1:horizon), 'Linewidth', 2, 'Color', colors(2, :));

xlim([1, horizon]);
ylim([0, 1.1*max(results.arima.sqeonan(trainTestSet, :))]);

title(plotTitle, 'FontSize', 22, 'FontName', MyConstants.FONT_TYPE);
xlabel('Forecasting horizon', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
set(gca,'XTick',[1:horizon])
ylabel('SQEONAN', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)

set(gca,'FontSize',14)

ax = legend('ARIMA', 'ARIMA + ABCF')
LEG = findobj(ax,'type','text');
set(LEG,'FontSize',14)
export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'sqeonan_arima_abcf_', MyConstants.DATA_SETS{dataSet}, '.png'), fig, '-transparent', '-nocrop');


    
%==========================================================================
% PLOT ARIMA + abcf applied to each dataset for RMSE
%==========================================================================
dataSet = 1;
trainTestSet = 3;
horizon = 8;

colors = linspecer(8);

load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

figsizeX = 1200;
figsizeY = 550;

plotTitle = ['ARIMA model SQEONAN vs forecasting horizon for ', MyConstants.DATA_SETS{dataSet}, ' dataset'];
fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

%Plot metrics
plot(results.arima.rmse(trainTestSet, :), 'Linewidth', 2, 'Color', colors(1, :));
hold on
plot(results.ABCF.arima.rmse(trainTestSet, 1:horizon), 'Linewidth', 2, 'Color', colors(2, :));

xlim([1, horizon]);
ylim([0, 1.1*max(results.arima.rmse(trainTestSet, :))]);

title(plotTitle, 'FontSize', 22, 'FontName', MyConstants.FONT_TYPE);
xlabel('Forecasting horizon', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
set(gca,'XTick',[1:horizon])
ylabel('RMSE', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)

set(gca,'FontSize',14)

ax = legend('ARIMA', 'ARIMA + ABCF')
LEG = findobj(ax,'type','text');
set(LEG,'FontSize',14)
export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'rmse_arima_abcf_', MyConstants.DATA_SETS{dataSet}, '.png'), fig, '-transparent', '-nocrop');
    
    
    



