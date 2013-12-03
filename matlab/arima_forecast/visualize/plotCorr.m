function fig = plotCorr(data, bounds, varargin)
%Function to plot the mean, standard deviation, and min/max values

%Varagin can allow for a std parameter and a minmax parameter
%example:
%plotMean(means, 'std', stds, 'minmax', minmax)

if nargin < 1
   error(message('plotCorr - Not enough inputs'))
end

parser = inputParser;
parser.CaseSensitive = false;
parser.addOptional('figsizeX', 1000);
parser.addOptional('figsizeY', 750);
parser.addOptional('xlabel', 'xlabel');
parser.addOptional('ylabel', 'ylabel');
parser.addOptional('plotTitle', 'Data autocorrelations vs lag');
parser.addOptional('fillColor', [1, 0, 0]);
parser.addOptional('boundColor', [0, 0, 1]);

try 
  parser.parse(varargin{:});
catch exception
  exception.throwAsCaller();
end

dataLen = size(data, 1);
figsizeX = parser.Results.figsizeX;
figsizeY = parser.Results.figsizeY;
graph_xlabel = parser.Results.xlabel;
graph_ylabel = parser.Results.ylabel;
plotTitle = parser.Results.plotTitle;
fillColor = parser.Results.fillColor;
boundColor = parser.Results.boundColor;

boundValues = ones(size(data)) * bounds;

fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);
stem((0:1:(dataLen - 1))', data, 'fill', 'Color', fillColor);
hold on
plot(boundValues, 'Color', boundColor);
plot(-1 * boundValues, 'Color', boundColor);
xlim([0 dataLen - 1]);

xlabel(graph_xlabel, 'FontSize', 16, 'FontName', MyConstants.FONT_TYPE)
ylabel(graph_ylabel, 'FontSize', 16, 'FontName', MyConstants.FONT_TYPE)
title(plotTitle, 'FontSize', 20, 'FontName', MyConstants.FONT_TYPE);
