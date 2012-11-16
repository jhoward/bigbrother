%%%%
%Discover a set of residuals for all days of the week.  Residuals are
%extracted and then clustered.
%%%%
clear all
load './data/brownData.mat'

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
model.AR(1)

myForecast = forecast_101011(dayData, model.AR{1}, model.MA{1}, model.SMA{1}, 144, 288, 288 + 5*144);

fcast = zeros(144, 1);
tmp = zeros(length(dayData), 1);
tic
for i = 1:144
    fcast(i, 1) = forecast(model, 1, 'Y0', dayData(1:287 + i, 1), 'E0', tmp(1:287 + i, 1));
end
toc

tic
for i = 1:5*144
    fcast(i, 1) = forecastArima(model, 1, 'Y0', dayData(1:287 + i, 1), 'E0', tmp(1:287 + i, 1));
end
toc
