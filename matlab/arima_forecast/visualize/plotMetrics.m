function [] = plotMetrics(plottype, dataset)
    
    switch plottype
        case 'sqeonanBCF'
            plotSqeonan_BCF(dataset)
        case 'rmseBCF'
            plotRMSE_BCF(dataset)
        case 'maseBCF'
            plotMASE_BCF(dataset)
        case 'rawData'
            plotDataset(dataset)
        case 'probSample'
            plotSampleProbability(dataset)
        case 'plotSample'
            plotSample(dataset)
    end
end


function plotSqeonan_BCF(dataset)
    dataLocation = MyConstants.FILE_LOCATIONS_CLEAN{dataset};
    load(dataLocation);
    load(MyConstants.RESULTS_DATA_LOCATIONS{dataset});
    trainTestSet = 3;
    horizon = 8;
    colors = linspecer(8);

    figsizeX = 1200;
    figsizeY = 550;

    plotTitle = ['SQEONAN vs forecasting horizon for ', MyConstants.DATA_SETS{dataset}, ' dataset'];
    %set(gca,'units','pix','pos',[100,100,100 + figsizeX, 100 + figsizeY])
    fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

    %Plot metrics
    plot(results.BCF.sqeonan(trainTestSet, 1:horizon), 'Linewidth', 2, 'Color', colors(1, :));
    
    %plot(results.average.sqeonan3(trainTestSet, 1:horizon), 'Color', colors(end, :)) 
    hold on
    plot(results.ABCF.BCF.sqeonan(trainTestSet, 1:horizon), 'Linewidth', 2, 'Color', colors(2, :));
    %plot(results.ABCF.ICBCF.sqeonan3(trainTestSet, 1:horizon), 'Color', colors(1, :), 'LineWidth', 2);
    %plot(results.BCF.sqeonan3(trainTestSet, 1:horizon), 'Color', colors(2, :));
    %plot(results.svm.sqeonan3(trainTestSet, 1:horizon), 'Color', colors(3, :))
    %plot(results.tdnn.sqeonan3(trainTestSet, 1:horizon), 'Color', colors(4, :))
    %plot(results.arima.sqeonan3(trainTestSet, 1:horizon), 'Color', colors(5, :));

    xlim([1, horizon]);
    
    title(plotTitle, 'FontSize', 22, 'FontName', MyConstants.FONT_TYPE);
    xlabel('Forecasting horizon', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
    ylabel('SQEONAN', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)

    set(gca,'FontSize',14)
    
    %legend('Average', 'IBCF', 'BCF', 'SVM', 'TDNN', 'Arima');
    ax = legend('BCF', 'BCF + abcf')
    LEG = findobj(ax,'type','text');
    set(LEG,'FontSize',14)
    export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
            'sqeonan_no_abcf_', MyConstants.DATA_SETS{dataset}, '.png'), fig, '-transparent', '-nocrop');
end  


function plotRMSE_BCF(dataset)
    dataLocation = MyConstants.FILE_LOCATIONS_CLEAN{dataset};
    load(dataLocation);
    load(MyConstants.RESULTS_DATA_LOCATIONS{dataset});
    trainTestSet = 3;
    horizon = 8;
    colors = varycolor(6);

    figsizeX = 1200;
    figsizeY = 550;

    plotTitle = ['RMSE vs forecasting horizon for ', MyConstants.DATA_SETS{dataset}, ' dataset'];
    %set(gca,'units','pix','pos',[100,100,100 + figsizeX, 100 + figsizeY])
    fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

    %Plot metrics
    plot(results.tdnn.rmse(trainTestSet, 1:horizon), 'Color', [1 0 0]) 
    hold on
    plot(results.ABCF.tdnn.rmse(trainTestSet, 1:horizon), 'Color', [0 0 1]);
    %plot(results.BCF.rmse(trainTestSet, 1:horizon), 'Color', colors(2, :));
    %plot(results.svm.rmse(trainTestSet, 1:horizon), 'Color', colors(3, :))
    %plot(results.tdnn.rmse(trainTestSet, 1:horizon), 'Color', colors(4, :))
    %plot(results.arima.rmse(trainTestSet, 1:horizon), 'Color', colors(5, :));

    xlim([1, horizon]);
    
    title(plotTitle, 'FontSize', 20, 'FontName', MyConstants.FONT_TYPE);
    xlabel('Forecasting horizon', 'FontSize', 14, 'FontName', MyConstants.FONT_TYPE)
    ylabel('rmse', 'FontSize', 14, 'FontName', MyConstants.FONT_TYPE)

    legend('TDNN', 'ABCF');
    export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
            'rmse_no_abcf_', MyConstants.DATA_SETS{dataset}, '.png'), fig, '-transparent', '-nocrop');
end 


function plotMASE_BCF(dataset)
    dataLocation = MyConstants.FILE_LOCATIONS_CLEAN{dataset};
    load(dataLocation);
    load(MyConstants.RESULTS_DATA_LOCATIONS{dataset});
    trainTestSet = 3;
    horizon = 8;
    colors = varycolor(6);

    figsizeX = 1200;
    figsizeY = 550;

    plotTitle = ['MASE vs forecasting horizon for ', MyConstants.DATA_SETS{dataset}, ' dataset'];
    %set(gca,'units','pix','pos',[100,100,100 + figsizeX, 100 + figsizeY])
    fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

    %Plot metrics
    plot(results.tdnn.mase(trainTestSet, 1:horizon), 'Color', [1 0 0]);
    
    %plot(results.average.sqeonan3(trainTestSet, 1:horizon), 'Color', colors(end, :)) 
    hold on
    plot(results.ABCF.tdnn.mase(trainTestSet, 1:horizon), 'Color', [0 0 1]);
    %plot(results.ABCF.ICBCF.sqeonan3(trainTestSet, 1:horizon), 'Color', colors(1, :), 'LineWidth', 2);
    %plot(results.BCF.sqeonan3(trainTestSet, 1:horizon), 'Color', colors(2, :));
    %plot(results.svm.sqeonan3(trainTestSet, 1:horizon), 'Color', colors(3, :))
    %plot(results.tdnn.sqeonan3(trainTestSet, 1:horizon), 'Color', colors(4, :))
    %plot(results.arima.sqeonan3(trainTestSet, 1:horizon), 'Color', colors(5, :));

    xlim([1, horizon]);
    
    title(plotTitle, 'FontSize', 20, 'FontName', MyConstants.FONT_TYPE);
    xlabel('Forecasting horizon', 'FontSize', 14, 'FontName', MyConstants.FONT_TYPE)
    ylabel('MASE', 'FontSize', 14, 'FontName', MyConstants.FONT_TYPE)

    %legend('Average', 'IBCF', 'BCF', 'SVM', 'TDNN', 'Arima');
    legend('tdnn', 'tdnn + abcf')
    export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
            'mase_', MyConstants.DATA_SETS{dataset},'_tdnn.png'), fig, '-transparent', '-nocrop');
end 



function plotDataset(dataset)
    load(MyConstants.FILE_LOCATIONS_CLEAN{dataset});
    load(MyConstants.RESULTS_DATA_LOCATIONS{dataset});
    plotTitle = ['Normalized per day visualization of ', MyConstants.DATA_SETS{dataset}, ' dataset'];
    
    figsizeX = 1200;
    figsizeY = 550;
    
    smoothAmount = [3, 1, 1];
    numPlots = [10, 15, 30];
    
    data.data = smooth(data.data, smoothAmount(dataset));
    data.data = data.data';
    %d = data.data;
    
    fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);
    xvals = 1:1:data.blocksInDay;
    
    tmpData = reshape(data.data, data.blocksInDay, size(data.data, 2)/data.blocksInDay);
    tmpMean = mean(tmpData, 2);
    tmpMean = tmpMean';
    tmpStd = std(tmpData, 1, 2);
    tmpStd = tmpStd';
    
    xfillVals = 1:1:data.blocksInDay;
    xfillVals = [xfillVals, fliplr(xfillVals)];

    y1 = tmpMean - tmpStd;
    y2 = tmpMean + tmpStd;
    yvals = [y1, fliplr(y2)];
    backgnd = fill(xfillVals, yvals, [0.5, 0, 0]);
    set(backgnd, 'EdgeColor', [0.5, 0, 0], 'FaceAlpha',0.5, 'EdgeAlpha',0.5);    
    
    hold on
    
    for i = 1:numPlots(dataset)
        patchline(xvals, data.data(1, data.blocksInDay * i + 1:data.blocksInDay * i + data.blocksInDay),'edgecolor','k','linewidth',1,'edgealpha',0.25);
    end
    
    patchline(xvals, tmpMean, 'edgecolor', 'b', 'linewidth', 2, 'edgealpha', 0.9)
    
    xlim([1, data.blocksInDay]);
    ylim([0, 1])
    %set(gca,'DefaultAxesFontName', 'Symbol')
    xlabel('Time of day', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
    ylabel('Total counts', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
    title(plotTitle, 'FontSize', 24, 'FontName', MyConstants.FONT_TYPE);
    set(gca,'XTickLabel',[]);
    export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'dataset_', MyConstants.DATA_SETS{dataset}, '.png'), fig, '-transparent', '-nocrop');
end


function plotSampleProbability(dataset)
    load(MyConstants.FILE_LOCATIONS_CLEAN{dataset});
    load(MyConstants.RESULTS_DATA_LOCATIONS{dataset});
    plotTitle = ['Sample ABCF residual plot for ', MyConstants.DATA_SETS{dataset}, ' dataset'];

    fStart = data.blocksInDay * 1;
    fEnd = size(data.testData, 2);

    startTime = 2240;
    endTime = 2287;

    figsizeX = 1200;
    figsizeY = 550;
    horizon = 2;
    
    fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

    arimaRes = data.testData(1, fStart:fEnd) - results.arima.testForecast{horizon};
    abcfRes = data.testData(1, fStart:fEnd) - results.ABCF.carima.testForecast{horizon};

    
    %Plot 1std
    tmpData = reshape(data.data, data.blocksInDay, size(data.data, 2)/data.blocksInDay);
    tmpMean = zeros(1, endTime - startTime + 1);
    tmpStd = std(tmpData, 1, 2);
    tmpStd = tmpStd';
    tmpStd = [tmpStd tmpStd];
    tmpStd = tmpStd(1, mod(startTime, data.blocksInDay):mod(startTime, data.blocksInDay) + (endTime - startTime));
    size(tmpStd)
    
    
    xfillVals = 1:1:data.blocksInDay;
    xfillVals = [xfillVals, fliplr(xfillVals)];

    y1 = tmpMean - tmpStd;
    y2 = tmpMean + tmpStd;
    yvals = [y1, fliplr(y2)];
    backgnd = fill(xfillVals, yvals, [0.5, 0, 0]);
    set(backgnd, 'EdgeColor', [0.5, 0, 0], 'FaceAlpha',0.5, 'EdgeAlpha',0.5);    
    hold on
    
    %Plot metrics
    plot(zeros(1, endTime - startTime + 1), 'Color', [0, 0, 0])
    hold on
    plot(arimaRes(1, startTime:endTime), 'LineWidth', 1.5, 'Color', [1, 0, 0]);
    plot(abcfRes(1, startTime:endTime), 'LineWidth', 1.5, 'Color', [0,0, 1]);


    for i = 1:size(results.ABCF.carima.testProbs{2}{2}, 1)
        plot(results.ABCF.carima.testProbs{2}{2}(i, startTime:endTime) / 10 - .45 - .1*i, 'Color', [0.5, 0.5, 0])
    end
    
    plot(results.ABCF.carima.testProbs{2}{8}(1, startTime:endTime) / 10 - .5, 'Color', [0, 0.5, 0.5])
    xlim([1, endTime-startTime]);
    
    title(plotTitle, 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE);
    xlabel('Time', 'FontSize', 16, 'FontName', MyConstants.FONT_TYPE)
    ylabel('Residual data', 'FontSize', 16, 'FontName', MyConstants.FONT_TYPE)
    
    
    set(gca, 'FontSize', 20, 'FontName', MyConstants.FONT_TYPE)
    
    legend('One std dev', 'No error', 'ARIMA Residual', 'ARIMA + ABCF Residual');
    export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
    'sample_residual_plot_dataset_', MyConstants.DATA_SETS{dataset}, '.png'), fig, '-transparent', '-nocrop');
end


function plotSample(dataset)
    load(MyConstants.FILE_LOCATIONS_CLEAN{dataset});
    load(MyConstants.RESULTS_DATA_LOCATIONS{dataset});
    plotTitle = ['Example plot for ', MyConstants.DATA_SETS{dataset}, ' dataset.'];

    fStart = data.blocksInDay * 1;
    fEnd = size(data.testData, 2);

    startTime = 2240;
    endTime = 2287;

    figsizeX = 1200;
    figsizeY = 550;
    horizon = 2;
    
    fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

    test_data = data.testData(1, fStart:fEnd);
    arima_data = results.arima.testForecast{horizon};
    abcf_data = results.ABCF.carima.testForecast{horizon};

    hold on

    plot(test_data(1, startTime:endTime), 'Color', [0, 0, 0])
    plot(arima_data(1, startTime:endTime), 'LineWidth', 1.25, 'Color', [1,0, 0]);
    plot(abcf_data(1, startTime:endTime), 'LineWidth', 1.25, 'Color', [0, 0, 1])

    
    title(plotTitle, 'FontSize', 22, 'FontName', MyConstants.FONT_TYPE);
    xlabel('Time', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
    ylabel('Normalized counts', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
    
    %set(gca, 'FontSize', 20, 'FontName', MyConstants.FONT_TYPE)

    ax = legend('Raw data', 'Arima', 'Arima + ABCF');
    LEG = findobj(ax,'type','text');
    set(LEG,'FontSize',14)
    export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'sample_plot_', MyConstants.DATA_SETS{dataset}, '.png'), fig, '-transparent', '-nocrop');
end

% %==========================================================================
% %PLOT SAMPLE PROBABILITY PLOT
% %==========================================================================
% dataSet = 3;
% dataLocation = MyConstants.FILE_LOCATIONS_CLEAN{dataSet};
% load(dataLocation);
% load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet});
% trainTestSet = 3;
% 
% fStart = data.blocksInDay * 1;
% fEnd = size(data.testData, 2);
% 
% startTime = 518;
% endTime = 535;
% 
% figsizeX = 1000;
% figsizeY = 750;
% 
% plotClusters(results.ABCF.csvm.clusters{1}, results.ABCF.csvm.idx{1})
% 
% plotTitle = strcat('SQEONAN vs Forecasting horizon for dataset ', MyConstants.DATA_SETS{dataSet});
% fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);
% 
% svmRes = testData - results.svm.testForecast{1};
% abcfRes = testData - results.ABCF.csvm.testForecast{1};
% 
% %Plot metrics
% plot(svmRes(1, startTime:endTime), 'Color', [0, 0, 1])
% hold on
% plot(abcfRes(1, startTime:endTime), 'Color', [1,0, 0]);
% 
% xlim([1, endTime-startTime]);
% %ylim([0, 200]);
% 
% title(plotTitle, 'FontSize', 20, 'FontName', MyConstants.FONT_TYPE);
% xlabel('Forecasting horizon', 'FontSize', 16, 'FontName', MyConstants.FONT_TYPE)
% ylabel('SQEONAN', 'FontSize', 16, 'FontName', MyConstants.FONT_TYPE)
% 
% legend('Raw Data', 'SVM Forecast', 'SVM + ABCF');



