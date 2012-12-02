%%%%
%Discover a set of residuals for all days of the week.  Residuals are
%extracted and then clustered.
%%%%
clear all
load './data/denverCounts.mat'

days = sensors(1).dayOfWeek;
data = sensors(1).data;
times = sensors(1).dayNums;
cData = zeros(size(data, 1) * size(data, 2), 1);

for i = 1:size(data, 2);


ar = 1;
diff = 1;
ma = 1;
sar = 0;
sdiff = 144;
sma = 1;

extractLength = 18;

windows = [];
cData = data;
%allDayNums = []


%First run do all days
arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
            'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);

model = estimate(arimaModel, cData, 'print', false);
res = infer(model, cData);
fitdist(res, 'normal')

removeThreshold = 1.5*(extractLength*(model.Variance^0.5));
[ind, window, val] = simpleExtraction(res(sdiff+1:end), extractLength, removeThreshold);

x = linspace(1, extractLength, extractLength + 2);

% %If known times, plot
% for i = 1:length(actTimes)
%     plot(x, res(actTimes(i):actTimes(i) + extractLength + 1));
%     hold on;
% end

for i = 1:length(ind)
    plot(x, res(ind(i):ind(i) + extractLength + 1));
    hold on;
end

% 
% for weekDay = 1:7
%     fprintf(1, 'Day of the week: %i\n', weekDay);
%     
%     dayIndex = find(days == weekDay);
%     dayData = data(dayIndex, :);
%     dayNums = sensors(1).dayNums;
%     dayNums = dayNums(dayIndex);
% 
%     %Reshaping isn't working how I expected.  Do a stupid for loop for now.
%     d2 = [];
%     for i = 1:size(dayData,1)
%         d2 = [d2 dayData(i, :)]; %#ok<AGROW>
%     end
%     dayData = d2';
% 
%     arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
%                 'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);
% 
%     model = estimate(arimaModel, dayData, 'print', false);
%     res = infer(model, dayData);
%     fitdist(res, 'normal')
% 
%     %For now slide by days
%     removeThreshold = 1.3*(extractLength*(model.Variance^0.5));
%     [ind, window, val] = simpleExtraction(res, extractLength, removeThreshold);
%     %foo = round(ind/24);
%     %foo = foo(2:end);
%     dates = datestr(dayNums(foo));
%     
%     allWindows = [allWindows; window];
%     allDayNums = [allDayNums; dayNums(foo)];
% end

% for i = 2:30
%     total = 0;
%     for j = 1:10
%         [idx, centers] = kmeans(allWindows, i);
%         s = silhouette(allWindows, idx);
%         total = total + sum(s)/length(s);
%     end
%     total = total / 10;
%     fprintf(1, 'Number clusters: %i     Avg sil score: %f\n', i, total);
% end
% 
% [idx, centers] = kmeans(allWindows, 48);
% silhouette(allWindows, idx)

% waitforbuttonpress;

%Plot each cluster
% for i = 1:48
%     index = find(idx == i);
%     plotData = allWindows(index, :);
%     x = linspace(1, 24, 24);
%     xflip = [x(1 : end - 1) fliplr(x)];
%     for j = 1:size(plotData, 1)
%         y = plotData(j, :);
%         yflip = [y(1 : end - 1) fliplr(y)];
%         patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
%         hold on
%     end
%     hold off
%     
%     clusterDays = allDayNums(index);
%     datestr(clusterDays)
%     weekday(clusterDays)
%     
%     waitforbuttonpress;
%     clf
% end
