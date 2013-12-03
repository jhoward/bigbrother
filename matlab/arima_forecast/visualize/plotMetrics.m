function [fig] = plotMetrics(horizons, metric, trainTestSet, yLim, dataSet, includeBCF, includeIMP, varargin)


if nargin < 1
   error(message('plotMean - Not enough inputs'))
end

parser = inputParser;
parser.CaseSensitive = false;
parser.addOptional('bcfResults', {});

try 
  parser.parse(varargin{:});
catch exception
  exception.throwAsCaller();
end

bcfResults = parser.Results.bcfResults;

figsizeX = 1000;
figsizeY = 750;

plotTitle = strcat(MyConstants.METRIC_NAMES{metric}, ' vs Forecasting horizon for dataset: ', MyConstants.DATA_SETS{dataSet});
fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

%Plot metrics
plot(horizons.arima{metric}(trainTestSet, :), 'Color', [0, 0.5, 0.5]);
hold on
plot(horizons.svm{metric}(trainTestSet, :), 'Color', [0.5, 0.5, 0])
plot(horizons.tdnn{metric}(trainTestSet, :), 'Color', [0.5, 0, 0.5])
plot(horizons.average{metric}(trainTestSet, :), 'Color', [0, 0, 0]) 

if includeBCF
    plot(bcfResults.improvedResults{metric}(trainTestSet, :), 'Color', [1 0 0], 'LineWidth', 2);
    plot(bcfResults.classicResults{metric}(trainTestSet, :), 'Color', [0 0.5 0], 'LineStyle', '--');
end

xlim([1, MyConstants.HORIZON]);
ylim([0, yLim]);

title(plotTitle, 'FontSize', 24, 'FontName', MyConstants.FONT_TYPE);
xlabel('Forecasting horizon', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
ylabel(MyConstants.METRIC_NAMES{metric}, 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)

legend('ARIMA', 'SVM', 'TDNN', 'Average');

if includeBCF
    legend('ARIMA', 'SVM', 'TDNN', 'Average', 'BCF-TS', 'BCF');
end

end

