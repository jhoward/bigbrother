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

dataSet = 1;
dataWidth = 78;

dataSet = 2;
dataWidth = 72;
horizon = 10;

output = data{dataSet}.output;
input = data{dataSet}.input;

colors = {'b', 'g', 'r', 'k', 'm', 'y', 'b'};
style = {'-', '--', ':', '-.'};

lineColor = {'b' [0 0.6 0] 'r' 'k' 'b' [0 0.6 0]};
lineStyles = {'-b', '-.m', '-r', '-k', '-.b', '-m', '-.r', '-.k'};
lineWidth = [1 1 1 1 1 2]; 

%Metrics

%MSE vs time
for i = 1:6 
    plot(1:1:horizon, data{dataSet}.dataVals{i}(4, 1:horizon), lineStyles{i}, ...
        'LineWidth', lineWidth(i), 'Color', lineColor{i})
    hold on;
end
xlim([1 10]);
%ylim([7 60]);

legend('Seasonal ARIMA', 'TDNN', 'AVG', 'SVM', 'BCF', 'BCF-TS')
xlabel('Forecasting Horizon', 'FontSize', 14)
ylabel('Root mean squared error', 'FontSize', 14)
hold off;

%Max residual vs horizon
%First find the max x% residuals and avg
percentTop = 0.1;
tmpres = {};
for i = 1:length(dataOutputs)
    for j = 1:horizon
        tmp = dataOutputs{i}{j} - output; %#ok<SAGROW>
        tmp = sort(abs(tmp), 2, 'descend');
        total = floor(size(tmp, 2) * percentTop);
        %tmp(1, 1:total)
        val = sum(tmp(1:total)) / total;
        pTopVals(i, j) = val;
    end
end

for i = 1:6
    plot(1:1:horizon, pTopVals(i, :), lineStyles{i}, ...
        'LineWidth', lineWidth(i), 'Color', lineColor{i})
    hold on;
end
xlim([1 horizon]);
legend('Seasonal ARIMA', 'TDNN', 'AVG', 'SVM', 'BCF', 'BCF-TS')
xlabel('Forecasting Horizon', 'FontSize', 14)
ylabel('Top 1% Residuals', 'FontSize', 14)
hold off;

%Percent forecast under vs horizon
for i = 1:7
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


%Plot the residuals of svm model vs horizon
tmpres = zeros(length(dataOutputs{4}), size(output, 2));
for i = 1:length(dataOutputs{4})
    tmpRes(i, :) = dataOutputs{4}{i} - output; %#ok<SAGROW>
end

%make the averages
for i = 1:size(tmpRes, 1)
    tmp = reshape(tmpRes(i, :), dataWidth, size(tmpRes, 2)/dataWidth); 
    stdDay(i, :) = std(tmp'); %#ok<SAGROW>
end

plot(1:1:dataWidth, [stdDay(1, :); stdDay(5, :); stdDay(10, :)])
xlim([1 dataWidth])
legend('Horizon = 1', 'Horizon = 5', 'Horizon = 10')
xlabel('Time index for all Wednesdays', 'FontSize', 14)
ylabel('Standard deviation of residual forecasts', 'FontSize', 14)







%=================VISUALIZE NORMALIZED PROBABILITY TRANSITIONS============
width = 50;
pStart = 120;
for i = 1:4
    plot(1:1:width, bcf2Probs{1}(i, pStart:pStart + width - 1), lineStyles{i}, 'LineWidth', lineWidth(i), 'Color', lineColor{i});
    hold on;
end
xlim([1 width]);
ylim([-0.1 1.1]);
legend('Seasonal ARIMA', 'TDNN', 'AVG', 'SVM')
xlabel('Time index', 'FontSize', 14)
ylabel('Normalized posterior probability', 'FontSize', 14)
box off
hold off;


%==================PRINT ALL 1 step ahead horizons========================
for i = 1:6
    data{2}.dataVals{i}(4, 1)
end

figure
width = 50;
pStart = 295;
plot(1:1:width, [output(1, pStart:pStart + width - 1); dataOutputs{6}{3}(1, pStart:pStart + width - 1); dataOutputs{4}{3}(1, pStart:pStart + width - 1)]);
legend('Raw data', 'BCF-TS Horizon = 3', 'SVM Horizon = 3');
xlabel('Time index', 'FontSize', 14);
ylabel('Sensor counts');
xlim([1 width]);



