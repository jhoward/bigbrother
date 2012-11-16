%visualizeBrownData
%author: James Howard
clear all
load('./data/brownData.mat');

sd = datenum(startDate);
ed = datenum(endDate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Visualize all data at once for one sensor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sensor = 20; %Note this is the sensor index in the data, not the label
% x = linspace(1, blocksInDay, blocksInDay);
% xflip = [x(1 : end - 1) fliplr(x)];
% for i = 1:(ed-sd)
%     y = agData((i-1)*blocksInDay + 1:i*blocksInDay, 20)';
%     yflip = [y(1 : end - 1) fliplr(y)];
%     patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
%     hold on
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Visualize the weekend vs monday, wednesday, friday
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% startTime = 36;
% endTime = 108;
% 
% sunTimes = find(dayOfWeek == 1);
% satTimes = find(dayOfWeek == 7);
% weekendTimes = [sunTimes; satTimes];
% weekendData = agData(weekendTimes, :);
% 
% mTimes = find(dayOfWeek == 2);
% wTimes = find(dayOfWeek == 4);
% fTimes = find(dayOfWeek == 6);
% mwfTimes = [mTimes; wTimes; fTimes];
% mwfData = agData(mwfTimes, :);
% 
% tTimes = find(dayOfWeek == 3);
% thTimes = find(dayOfWeek == 5);
% tthTimes = [tTimes; thTimes];
% tthData = agData(tthTimes, :);
% 
% x = linspace(1, blocksInDay, blocksInDay);
% x = x(startTime:endTime);
% xflip = [x(1 : end - 1) fliplr(x)];
% 
% for i = 1:(size(mwfData, 1)/blocksInDay)
%     y = mwfData((i-1)*blocksInDay + 1:i*blocksInDay, 20)';
%     y = y(startTime:endTime);
%     yflip = [y(1 : end - 1) fliplr(y)];
%     patch(xflip, yflip, 'k', 'EdgeAlpha', 0.15, 'EdgeColor', [0.7, 0, 0]);
%     hold on
% end
% xlim([startTime endTime]);
% 
% for i = 1:(size(tthData, 1)/blocksInDay)
%     y = tthData((i-1)*blocksInDay + 1:i*blocksInDay, 20)';
%     y = y(startTime:endTime);
%     yflip = [y(1 : end - 1) fliplr(y)];
%     patch(xflip, yflip, 'k', 'EdgeAlpha', 0.15, 'EdgeColor', [0, 0, 0.7]);
%     hold on
% end
% xlim([startTime endTime]);
% 
% for i = 1:(size(weekendData, 1)/blocksInDay)
%     y = weekendData((i-1)*blocksInDay + 1:i*blocksInDay, 20)';
%     y = y(startTime:endTime);
%     yflip = [y(1 : end - 1) fliplr(y)];
%     patch(xflip, yflip, 'k', 'EdgeAlpha', 0.35, 'EdgeColor', [0, 0, 0]);
%     hold on
% end
% xlim([startTime endTime]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Visualize all building sum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dataSum = sum(agData, 2);
% x = linspace(1, blocksInDay, blocksInDay);
% xflip = [x(1 : end - 1) fliplr(x)];
% for i = 1:(ed-sd)
%     y = dataSum((i-1)*blocksInDay + 1:i*blocksInDay, 1)';
%     yflip = [y(1 : end - 1) fliplr(y)];
%     patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
%     hold on
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Visualize the sum of just the exit sensors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Door sensors (#30, #62, #74, #102)
dSensors = [11, 28, 35, 48]; 

totalBuilding = agData(:, dSensors);
dataSum = sum(totalBuilding, 2);

startTime = 36;
endTime = 108;

sunTimes = find(dayOfWeek == 1);
satTimes = find(dayOfWeek == 7);
weekendTimes = [sunTimes; satTimes];
weekendData = dataSum(weekendTimes, :);

mTimes = find(dayOfWeek == 2);
wTimes = find(dayOfWeek == 4);
fTimes = find(dayOfWeek == 6);
mwfTimes = [mTimes; wTimes; fTimes];
mwfData = dataSum(mwfTimes, :);

tTimes = find(dayOfWeek == 3);
thTimes = find(dayOfWeek == 5);
tthTimes = [tTimes; thTimes];
tthData = dataSum(tthTimes, :);

x = linspace(1, blocksInDay, blocksInDay);
x = x(startTime:endTime);
xflip = [x(1 : end - 1) fliplr(x)];

for i = 1:(size(mwfData, 1)/blocksInDay)
    y = mwfData((i-1)*blocksInDay + 1:i*blocksInDay, 1)';
    y = y(startTime:endTime);
    yflip = [y(1 : end - 1) fliplr(y)];
    patch(xflip, yflip, 'k', 'EdgeAlpha', 0.15, 'EdgeColor', [0.7, 0, 0]);
    hold on
end
xlim([startTime endTime]);

for i = 1:(size(tthData, 1)/blocksInDay)
    y = tthData((i-1)*blocksInDay + 1:i*blocksInDay, 1)';
    y = y(startTime:endTime);
    yflip = [y(1 : end - 1) fliplr(y)];
    patch(xflip, yflip, 'k', 'EdgeAlpha', 0.15, 'EdgeColor', [0, 0, 0.7]);
    hold on
end
xlim([startTime endTime]);

for i = 1:(size(weekendData, 1)/blocksInDay)
    y = weekendData((i-1)*blocksInDay + 1:i*blocksInDay, 1)';
    y = y(startTime:endTime);
    yflip = [y(1 : end - 1) fliplr(y)];
    patch(xflip, yflip, 'k', 'EdgeAlpha', 0.15, 'EdgeColor', [0, 0, 0]);
    hold on
end
xlim([startTime endTime]);

