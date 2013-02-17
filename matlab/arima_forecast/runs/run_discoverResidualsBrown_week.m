%%%%
%Discover a set of residuals for all days of the week.  Residuals are
%extracted and then clustered.
%%%%
clear all
load './data/brownCounts.mat'

sensor = 22;

data = agData(:, sensor);
days = dayOfWeek;

ar = 1;
diff = 0;
ma = 1;
sar = 0;
sdiff = blocksInDay;
sma = 1;

dayIndex = find(dayOfWeek == 2);
dayData = data(dayIndex, :);
dayNums = dayNums(dayIndex);

arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
            'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);

model = estimate(arimaModel, dayData, 'print', false);
res = infer(model, dayData);
fitdist(res, 'normal')

%First just extract into a set of different days
%daysData = reshape(data, blocksInDay, size(data, 1)/blocksInDay);
%daysData = daysData';

myForecast = forecast_101011(dayData, model.AR{1}, model.MA{1}, model.SMA{1}, 144, 288, 288 + 144);
myForecast = myForecast(2:145);

fcast = zeros(144, 1);
fcast2 = zeros(144, 1);
tmp = zeros(length(dayData), 1);
% 
% tic
% for i = 1:144
%     fcast(i, 1) = forecast(model, 1, 'Y0', dayData(1:287 + i, 1), 'E0', tmp(1:287 + i, 1));
% end
% toc
% 
% tic
% for i = 1:144
%     icast(i, 1) = forecastArima(model, 1, 'Y0', dayData(1:287 + i, 1));
% end
% toc

%Compute residuals
realData = dayData(288:288 + 143);
myResidual = realData - myForecast;
myTotal = sum(abs(myResidual));
myMax = max(abs(myResidual));

fResidual = realData - fcast;
fTotal = sum(abs(fResidual));
fMax = max(abs(fResidual));

iResidual = realData - icast;
iTotal = sum(abs(iResidual));
iMax = max(abs(iResidual));

fprintf(1, 'myForecast - sum: %f      max: %f\n', myTotal, myMax);
fprintf(1, 'matlab forecast - sum: %f      max: %f\n', fTotal, fMax);
fprintf(1, 'impMatlabForecast - sum: %f      max: %f\n', iTotal, iMax);

