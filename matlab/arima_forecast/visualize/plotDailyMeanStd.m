%visualizeDataset
clear all;
%load('./data/brownData.mat');
load('./data/merlData.mat');

dayOfWeek = 4;
sensor = 33;

[means, stds] = dailyMean(data.data(sensor, :), data.times, data.blocksInDay, 'smooth', false);


xvals = 1:1:data.blocksInDay;
xvals = [xvals, fliplr(xvals)];
y1 = means(dayOfWeek, :) - stds(dayOfWeek, :);
y2 = means(dayOfWeek, :) + stds(dayOfWeek, :);
yvals = [y1, fliplr(y2)];
tmp = fill(xvals, yvals, [0.7, 0, 0]);
set(tmp,'EdgeColor',[0.7, 0, 0],'FaceAlpha',0.5,'EdgeAlpha',0.5);
hold on;
plot(1:1:data.blocksInDay, means(dayOfWeek, :), 'LineWidth', 2, 'Color', [0, 0, 1]); 
xlim([1, data.blocksInDay]);
xlabel('Time of day', 'FontSize', 14)
ylabel('Sensor activations', 'FontSize', 14)
set(gca,'XTick',[]);