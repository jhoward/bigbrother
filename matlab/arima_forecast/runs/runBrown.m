clear all;
load('./data/brownData.mat');

%===============================SETUP DATA=================
ahead = 5;
windowSize = 10;

trainPercent = 0.7;

%Combine the data to be just the exits
%Sensors 102, 63, 30, 73            
allData = data.data(48, :) + data.data(28, :) + data.data(34, :);

inputMax = floor((size(data.data, 2) / data.blocksInDay) * trainPercent) * data.blocksInDay;
output = allData(1, inputMax + 1:end);
nd = data.dayOfWeek;
nd(nd == 3) = 10;
nd(nd == 5) = 10;
thInput = allData(1, nd == 10);
thTimes = data.times(1, nd == 10);
input = thInput;
%plot(input)
%xlim([1 size(input, 2)]);
tmpRes = reshape(input, size(input, 1), data.blocksInDay, size(input, 2)/data.blocksInDay);
dayNoiseSigma = std(tmpRes, 0, 3);


%=========================END SETUP=====================


%======================AVG MODEL=======================
modelAvg = bcf.models.Average(data.blocksInDay);
modelAvg.train(input);
avgInput = modelAvg.forecastAll(input, ahead);
modelAvg.calculateNoiseDistribution(input, ahead);
avgRes = avgInput - input;

%Compute model accuracy
avgTrainRmse = errperf(input, avgInput, 'rmse');
avgMaxRes = max(avgRes);
avgMinRes = min(avgRes);
fprintf(1, 'Arima fit Error rates -- train rmse:%f   %f     %f\n', avgTrainRmse, avgMaxRes, avgMinRes);

%Plot average model with std around it
% plot(avgRes(500:1099));
hold on
x = 1:1:data.blocksInDay;
plot(x, modelAvg.avgDay);
plot(x, modelAvg.avgDay + modelAvg.dayNoiseSigma, 'Color', 'red');
plot(x, modelAvg.avgDay - modelAvg.dayNoiseSigma, 'Color', 'red');
xlim([1 data.blocksInDay]);
%======================================================


% =======================ARIMA==========================
% %SETUP ARIMA MODEL
ar = 0;
diff = 1;
ma = 1;
sar = 0;
sdiff = data.blocksInDay;
sma = 4;

arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
            'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);

model = estimate(arimaModel, input', 'print', true);

modelArima = bcf.models.Arima(model, data.blocksInDay);
modelArima.calculateNoiseDistribution(input, 1);
arimaInput = modelArima.forecastAll(input, 1);

arimaResInput = arimaInput - input;
arimaInferResInput = infer(model, input');
arimaAdInput = input + arimaInferResInput';

%Arima model accuracy
arimaTrainRmse = errperf(input, arimaAdInput, 'rmse');
arimaMaxRes = max(arimaResInput);
arimaMinRes = min(arimaResInput);
fprintf(1, 'Arima fit Error rates -- train rmse:%f   %f     %f\n', arimaTrainRmse, arimaMaxRes, arimaMinRes);

% plot(arimaResInput(500:1099))
% [h, p, s, c] = lbqtest(arimaResInput(500:580))
% autocorr(arimaResInput, [100]);
% parcorr(arimaResInput, [100]);

plot(x, [dayNoiseSigma; modelArima.dayNoiseSigma; modelAvg.dayNoiseSigma]);
    

%Plot a typical set of days
pwidth = data.blocksInDay;
for i = 1:floor(size(input, 2)/pwidth) - 1
    x = 1:1:data.blocksInDay;
    plot(x, [input(1, i*pwidth + 1:i*pwidth + pwidth); arimaAdInput(1, i*pwidth + 1:i*pwidth + pwidth)]);
    hold on
    plot(x, arimaAdInput(1, i*pwidth + 1:i*pwidth + pwidth) + modelArima.dayNoiseSigma, 'Color', 'red');
    plot(x, arimaAdInput(1, i*pwidth + 1:i*pwidth + pwidth) - modelArima.dayNoiseSigma, 'Color', 'red');
    xlim([1 data.blocksInDay]);
    waitforbuttonpress
    hold off
end
% =========================END ARIMA=========================


%=========================NEURAL NETWORK====================
%Format the data
%Way one
%Each element of the cell array is a time step of signal dimension by
%number of samples
%total number of cells is the length of all time series
%Length X dimension X num Examples
cdata = {};

cdata = tonndata(input, true, false);

%Find the best parameter set
%for td = 2:10
%    for hn = 2:td
for td = 10:10
    for hn = 6:6
        fprintf(1, '%i time delay   %i hidden nodes\n', td, hn);
        %SETUP THE MODEL
        net = timedelaynet(1:td, hn);

        net.divideParam.trainRatio = 70/100;
        net.divideParam.valRatio = 15/100;
        net.divideParam.testRatio = 15/100;

        [xs, xi, ai, ts] = preparets(net, cdata(:, 1:end - 1), cdata(:, 1 + 1:end));
        net1 = train(net, xs, ts, xi, ai);
        [xs, xi, ai, ts] = preparets(net, cdata(:, 1:end - ahead), cdata(:, 1 + ahead:end));
        netahead = train(net, xs, ts, xi, ai);

        modelTDNN = bcf.models.TDNN(net1, netahead, ahead);

        predInput = modelTDNN.forecastAll(input(1, :), 1);
        resInput = predInput - input;

        trainRmse = errperf(input(sensorNumber, 1:end), predInput(sensorNumber, 1:end), 'rmse');
        fprintf(1, 'NN Error rates -- train rmse:%f\n', trainRmse);
    end
end


[h, p, s, c] = lbqtest(resInput(1, 40:100)) 
autocorr(resInput(200:end), [200]);
parcorr(resInput(200:end), [200]);
%=========================END NEURAL NETWORK================

x = linspace(1, 60, 60);
rd = res';
rds = smooth(rd, 'lowess');
%rds = smooth(input, 'lowess');
%plot(x, [rd; rds'])

%==========================FIND PEAKS=======================
[win, ind] = largestWindow(res', 12, 20);
for i = 1:length(win)
    tmp = datevec(thTimes(1, ind(i)));
    fprintf(1, '%i, %i - %i:%i\n', tmp(2), tmp(3), tmp(4), tmp(5));
end

%[win, ind] = simpleExtraction(rds, 12, 430);
for i = 1:length(win)
    %plot(win(i, :));
    datevec(thTimes(1, ind(i)))
    %plot(win{i});
    subplot(2, 1, 1)
    plot(x, [input(1, ind(i) - 25:ind(i) + 34); predInput(1, ind(i) - 25:ind(i) + 34)]);
    subplot(2, 1, 2)
    plot(win{i});
    ylim([-150 150]);
    waitforbuttonpress;
end
windows = cell2mat(win');
[idx, c] = kmeans(windows, 5);

x2 = linspace(1, 13, 13);
for i = 1:5
    fprintf(1, 'Cluster %i\n', i);
    tmp = windows(idx == i, :);
    tmpInd = ind(1, idx == i);
    for j = 1:size(tmp, 1)
        plot(x2, tmp(j, :))
        tmpTime = datevec(thTimes(1, tmpInd(j)));
        fprintf(1, '%i, %i - %i:%i\n', tmpTime(2), tmpTime(3), tmpTime(4), tmpTime(5));       
        hold on
    end
    hold off
    fprintf(1, '\n');
    waitforbuttonpress;
end
%=========================PLOT A COUPLE OF DAYS=============
%TYPICAL PLOTS FOR EDIFICATION
plotStart = 1000;

%plot a typical window
x = linspace(1, plotSize, plotSize);
plot(x, [input(:, plotStart:plotStart + plotSize - 1); predInput(:, plotStart:plotStart + plotSize - 1)]);


[h, p, s, c] = lbqtest(resInput(1, 40:100))
autocorr(resInput(200:end), [200]);
parcorr(resInput(200:end), [200]);