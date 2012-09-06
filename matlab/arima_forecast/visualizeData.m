% visualizeData.m

clear all;
load('./data/brownData.mat');

%Get all mondays
dayIndex = find(dayOfWeek == 5);
data = agData(dayIndex, 20);
numDays = floor(size(data, 1))/blocksInDay;

x = linspace(1, blocksInDay, blocksInDay);
xflip = [x(1 : end - 1) fliplr(x)];
for i = 1:numDays
    y = data((i-1)*blocksInDay + 1:i*blocksInDay, 1)';
    yflip = [y(1 : end - 1) fliplr(y)];
    patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
    hold on
end

xlim([1 144]);
ylim([1 400]);