clear all;

m1 = 1;
m2 = 2;
std1 = 0.1;
std2 = 0.1;

data = zeros(1, 200);

%Make a dataset that is derived from 2 sources
for i = 1:10
    index = (i - 1) * 20 + 1;
    switch mod(i, 2)
        case 0
           data(index:index + 19) = m1 + std1*randn(1, 20);
        case 1
           data(index:index + 19) = m2 + std2*randn(1, 20);
    end
end

%make 2 gaussians
model1 = bcf.models.Gaussian(m1, std1);
model2 = bcf.models.Gaussian(m2, std2);

model1.calculateNoiseDistribution(data)
model2.calculateNoiseDistribution(data)

models = {model1 model2};

forecaster = bcf.BayesianForecaster(models);
[yprime, probs, ms] = forecaster.forecastAll(data, 'aggregate');
[yprime2, probs, ms] = forecaster.forecastAll(data, 'best');
x = linspace(1, 200, 200);
plot(x, [data; yprime; yprime2]);

% d = 8;
% s = 1;
% 
% y = data;
% y = num2cell(y);
% net = narnet(1:d, 10);
% [Xs, Xi, Ai, Ts] = preparets(net, {}, {}, y);






% [yprimeBest, ~, ~, ~, ~] = forecaster.windowForecast(data, 1, 20, 5, 'best');
% [yprime, ~, ~] = forecaster.forecast(data, 10, 5, 'best');
% 
% x = linspace(1, 200, 200);
% plot(x, [data; yprime; yprimeBest]);
% legend('data', 'window', 'bestWindow');



%=======================================================
%Make result of forecast error vs windowsize
% mWindowSize = 80;
% 
% bvalues = zeros(1, mWindowSize);
% avalues = zeros(1, mWindowSize);
% 
% for i = 1:mWindowSize
%     [yprime, ~, ~] = forecaster.forecast(data, i, 1, 'best');
%     bvalues(1, i) = errperf(yprime(:, i:end - 1), data(:, i:end - 1), 'mape');
%     [yprime, ~, ~] = forecaster.forecast(data, i, 1, 'aggregate');
%     avalues(1, i) = errperf(yprime(:, i:end - 1), data(:, i:end - 1), 'mape');
% end
% 
% x = linspace(1, mWindowSize, mWindowSize);
% plot(x, [bvalues; avalues]);
% legend('best', 'aggregate');
%=======================================================


%=======================================================
%Make result of forecast error vs forecast ahead value
% mAhead = 20;
% windowSize = 5;
% 
% bvalues = zeros(1, mAhead);
% avalues = zeros(1, mAhead);
% 
% for i = 1:mAhead
%     [yprime, ~, ~] = forecaster.forecast(data, windowSize, i, 'best');
%     bvalues(1, i) = errperf(yprime(:, i:end - 1), data(:, i:end - 1), 'mape');
%     [yprime, ~, ~] = forecaster.forecast(data, windowSize, i, 'aggregate');
%     avalues(1, i) = errperf(yprime(:, windowSize:end - i), data(:, windowSize:end - i), 'mape');
% end
% 
% x = linspace(1, mAhead, mAhead);
% plot(x, [bvalues; avalues]);
% legend('best', 'aggregate');
%=======================================================
% 
% 
%=======================================================
%Make result of forecast error vs forecast ahead and window size
% mAhead = 30;
% windowSizes = [3 6 9 12 15 20];
% 
% values = zeros(size(windowSizes, 2), mAhead);
% 
% for i = 1:mAhead
%     for j = 1:size(windowSizes, 2)
%         [yprime, ~, ~] = forecaster.forecast(data, j, i, 'aggregate');
%         values(j, i) = errperf(yprime(:, j:end - i), data(:, j:end - i), 'mape');
%     end
% end
% 
% x = linspace(1, mAhead, mAhead);
% plot(x, values);
% legend(num2str(windowSizes'));
%=======================================================




%Make same of forecast error vs forecast ahead value with sliding window
%forecast

%Make forecast with neural network model


