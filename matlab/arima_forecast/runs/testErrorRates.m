clear all;
load('./data/simulatedRun.mat');

ahead = 1;

% start = randi(size(data.data, 2));
% width = 96*2;

tic
icast = aForecast(data.model, ahead, data.data(1, :)');
toc

tic
icast2 = aForecast(data.model, ahead + 10, data.data(1, :)');
toc

%errperf(icast, data.data(1, :), 'mape')
%errperf(icast2, data.data(1, :), 'mape')
start = randi(size(data.data, 2));
width = data.blocksInDay*2;

x = linspace(1, width, width + 1);
plot(x, [data.data(1, start:start + width); icast(start:start + width); icast2(1, start:start + width)]);
legend('raw', 'one ahead', '11 ahead');
