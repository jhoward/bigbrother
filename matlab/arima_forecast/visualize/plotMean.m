function [] = plotMean(means, varargin)
%Function to plot the mean, standard deviation, and min/max values

%Varagin can allow for a std parameter and a minmax parameter
%example:
%plotMean(means, 'std', stds, 'minmax', minmax)

if nargin < 1
   error(message('plotMean - Not enough inputs'))
end

parser = inputParser;
parser.CaseSensitive = false;
parser.addOptional('std', zeros(size(means)));
parser.addOptional('minmax', zeros(size(means)));

try 
  parser.parse(varargin{:});
catch exception
  exception.throwAsCaller();
end

dataLen = size(means, 2);
stds = parser.Results.std;
minmaxes = parser.Results.minmax;


xvals = 1:1:dataLen;
xvals = [xvals, fliplr(xvals)];
y1 = means - stds;
y2 = means + stds;
yvals = [y1, fliplr(y2)];
tmp = fill(xvals, yvals, [0.7, 0, 0]);
set(tmp,'EdgeColor',[0.7, 0, 0],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(1:1:dataLen, means, 'LineWidth', 2, 'Color', [0, 0, 1]); 
xlim([1, dataLen]);
xlabel('Time of day', 'FontSize', 14)
ylabel('Sensor activations', 'FontSize', 14)
set(gca,'XTick',[]);

end

