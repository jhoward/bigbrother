%Analyze data
%Perform metrics for our data points
clear all;

%load both datasets
load('./data/merlResults.mat')
data{1}.dataVals = dataVals;
data{1}.modelVals = modelVals;
data{1}.dataInputs = dataInputs;
data{1}.dataOutputs = dataOutputs;

load('./data/merlCleaned.mat')
data{1}.input = input;
data{1}.output = output;

load('./data/brownResults.mat')
data{2}.dataVals = dataVals;
data{2}.modelVals = modelVals;
data{2}.dataInputs = dataInputs;
data{2}.dataOutputs = dataOutputs;

load('./data/brownCleaned.mat')
data{2}.input = input;
data{2}.output = output;

dataSet = 2;
horizon = 20;

output = data{dataSet}.output;
input = data{dataSet}.input;

colors = {'b', 'g', 'r', 'k', 'm'};

%Metrics

%MSE vs time
for i = 1:5
    plot(1:1:horizon, data{dataSet}.dataVals{i}(4, 1:end), 'Color', colors{i})
    hold on;
end
xlim([1 horizon]);
legend('Seasonal ARIMA', 'TDNN', 'AVG', 'BCFNN', 'BCF')
xlabel('Forecasting Horizon', 'FontSize', 14)
ylabel('Root mean squared error', 'FontSize', 14)
hold off;

%Max residual vs horizon
for i = 1:5
    val = [data{dataSet}.dataVals{i}(5, 1:end); data{dataSet}.dataVals{i}(5, 1:end)];
    val = abs(val);
    
    plot(1:1:horizon, max(val), 'Color', colors{i})
    hold on;
end
xlim([1 horizon]);
legend('Seasonal ARIMA', 'TDNN', 'AVG', 'BCFNN', 'BCF')
xlabel('Forecasting Horizon', 'FontSize', 14)
ylabel('Max residual', 'FontSize', 14)
hold off;

ou = zeros(5, horizon)

%Percent forecast under vs horizon
for i = 1:5
    for j = 1:horizon
        tmp = data{dataSet}.dataOutputs{i}{j} - output;
        tmpou = find(tmp < 0);
        ou(i, j) = size(tmpou, 2) / size(output, 2);
    end
end


%Max residual vs horizon
for i = 1:5
    plot(1:1:horizon, ou(i, :), 'Color', colors{i})
    hold on;
end
xlim([1 horizon]);
legend('Seasonal ARIMA', 'TDNN', 'AVG', 'BCFNN', 'BCF')
xlabel('Forecasting Horizon', 'FontSize', 14)
ylabel('Pecent under forecast', 'FontSize', 14)
hold off;





%Find the top %5 residual avg vs horizon
fiveper = floor(size(output, 2) * 0.05);
topRes = zeros(5, horizon);

%Percent forecast under vs horizon
for i = 1:5
    for j = 1:horizon
        tmp = data{dataSet}.dataOutputs{i}{j} - output;
        tmp = abs(tmp);
        stmp = sort(tmp, 2, 'descend');
        topRes(i, j) = mean(stmp);
    end
end


%Max residual vs horizon
for i = 1:5
    plot(1:1:horizon, topRes(i, :), 'Color', colors{i})
    hold on;
end
xlim([1 horizon]);
legend('Seasonal ARIMA', 'TDNN', 'AVG', 'BCFNN', 'BCF')
xlabel('Forecasting Horizon', 'FontSize', 14)
ylabel('Mean top 5% residuals', 'FontSize', 14)
hold off;



%Forecasting variance for a typical day vs horizon

%Find the forecasting variance


