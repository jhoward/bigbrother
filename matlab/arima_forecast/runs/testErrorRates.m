clear all;
load('./data/denverRun.mat');

ahead = 1;

% start = randi(size(data.data, 2));
% width = 96*2;

tic
icast = aForecast(data.model, ahead, data.testData(1, :)');
toc

tic
icast2 = aForecast(data.model, ahead + 5, data.testData(1, :)');
toc

errperf(icast, data.testData(1, :), 'mape')
errperf(icast2, data.testData(1, :), 'mape')

[windows, values] = maxDevWindows(icast2, data.testData, 6);

% start = randi(size(data.testData, 2));
% width = data.blocksInDay*3;
% 
% x = linspace(1, width, width + 1);
% plot(x, [data.testData(1, start:start + width); icast(start:start + width); icast2(1, start:start + width)]);
% legend('raw', 'one ahead', '11 ahead');


% errorData = data.testData - icast;
% 
% x = linspace(1, data.blocksInDay, data.blocksInDay);
% bid = data.blocksInDay;
% xflip = [x(1 : end - 1) fliplr(x)];
% for i = 1:size(errorData,2)/data.blocksInDay
%     y = errorData(1, (i-1)*bid + 1:i*bid);
%     yflip = [y(1 : end - 1) fliplr(y)];
%     patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
%     hold on
% end



for i = 1:10
    start = windows(i) - data.blocksInDay;
    width = data.blocksInDay*2;
    x = linspace(1, width, width + 1);
    plot(x, [data.testData(1, start:start + width); icast(start:start + width); icast2(1, start:start + width)]);
    legend('raw', 'one ahead', '6 ahead');
    waitforbuttonpress;
end
