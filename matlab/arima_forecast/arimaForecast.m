%Perform ARIMA forecast.
clear all
load './data/countData.mat'

data = sensors(1).data;
days = sensors(1).days;

sunIndex = find(days == 1);
data = data(sunIndex, :);

%Reshaping isn't working how I expected.  Do a stupid for loop for now.
d2 = [];
for i = 1:size(data,1)
    d2 = [d2 data(i, :)]; %#ok<AGROW>
end
data = d2';

ar = 1;
diff = 1;
ma = 1;
sar = 0;
sdiff = 24;
sma = 1;

arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
            'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);
        
model = estimate(arimaModel, data);
res = infer(model, data);

f = forecast(model, 10, 'Y0', data(1:184));
