clear all;
load('./data/simulatedRun.mat');

ahead = 2;
total = 60;
start = 60;
mcast = zeros(total, 1);
aecast = zeros(total, 1);
ecast = zeros(total, 1);
icast = zeros(total, 1);
icast2 = zeros(total, 1);
e0 = zeros(total, 1);
errors = zeros(start - ahead, 1);

% tic
% for i = 1:total
%     tmp = forecast(data.model,ahead, 'Y0', data.data(1:start - ahead - 1 + i));
%     mcast(i) = tmp(ahead);
% end
% toc
% 
% tic
% for i = 1:total
%     tmp = forecast(model,ahead, 'Y0', data(1 + start - total + i:start - ahead - 1 + i));
%     mcast(i) = tmp(ahead);
% end
% toc
% 
% tic
% mycast = forecast_101011(data, model.AR{1}, model.MA{1}, model.SMA{1}, model.Seasonality, start, start + total - 1);
% toc

% tic
% errors = zeros(start - ahead, 1);
% for i = 1:total
%     tmp = forecast(data.model,ahead, 'Y0', data.trainData(1:start - ahead - 1 + i), 'E0', errors);
%     errors = [tmp(ahead) - data(start - ahead - 1 + i); errors];
%     aecast(i) = tmp(ahead);
% end
% toc

% tic
% for i = 1:total
%     tmp = forecast(data.model, ahead, 'Y0', data.data(1:start - ahead - 1 + i), 'E0', e0);
%     ecast(i) = tmp(ahead);
% end
% toc

tic
icast = aForecast(data.model, ahead, data.data);
toc

tic
icast2 = aForecast(data.model, ahead + 2, data.data);
toc

tic
icast3 = aForecast(data.model, ahead + 50, data.data);
toc

x = linspace(1, total, total);
%plot(x, [data.trainData(start:start + total - 1)'; icast(start:start + total - 1); mcast(1:total)']);%ecast(1:total) icast(1:total)]);
plot(x, [data.trainData(start:start + total - 1)'; icast(start:start + total - 1); icast3(start:start + total - 1)]);
