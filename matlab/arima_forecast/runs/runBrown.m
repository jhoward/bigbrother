clear all;
load('./data/brownData.mat');

%===============================SETUP DATA=================
ahead = 5;
windowSize = 10;

trainPercent = 0.7;

%Combine the data to be just the exits
%Sensors 102, 63, 30, 73            
%allData = data.data(48, :) + data.data(28, :) + data.data(34, :);
allData = data.data(48, :);

inputMax = floor((size(data.data, 2) / data.blocksInDay) * trainPercent) * data.blocksInDay;
output = allData(1, inputMax + 1:end);
nd = data.dayOfWeek;
nd(nd == 3) = 10;
nd(nd == 5) = 10;
<<<<<<< HEAD
thInput = allData(1, nd == 10);
=======
%nd(nd == 6) = 10;
thInput = allData(sensorNumber, nd == 10);
>>>>>>> blah
thTimes = data.times(1, nd == 10);
input = thInput;
%plot(input)
%xlim([1 size(input, 2)]);
<<<<<<< HEAD
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
=======

%Remove break times
%day 8
%day 16, 17

removeList = 1:1:(8 * data.blocksInDay - 1);
removeList = [removeList (9 * data.blocksInDay):1:(16 * data.blocksInDay - 1)];
removeList = [removeList (17 * data.blocksInDay):size(input, 2)];

input = input(removeList);
thTimes = thTimes(removeList);



%=======================PLOT RAW DATA==================
plot(input);
x = 1:1:data.blocksInDay;
for i = 1:data.blocksInDay:size(input, 2)
    i
    plot(x, input(1, i:i + data.blocksInDay - 1));
    ylim([0, 200]);
    waitforbuttonpress
end

%=======================ARIMA==========================
>>>>>>> blah
% %SETUP ARIMA MODEL
ar = 0;
diff = 1;
ma = 1;
sar = 0;
<<<<<<< HEAD
sdiff = data.blocksInDay;
=======
sdiff = 2 * data.blocksInDay;
>>>>>>> blah
sma = 4;

arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
            'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);

model = estimate(arimaModel, input', 'print', true);

<<<<<<< HEAD
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

=======
myModel = bcf.models.Arima(model);
%myModel.calculateNoiseDistribution(input);
predInput = myModel.forecastAll(input, 1);
%predOutput = myModel.forecastAll(output, ahead);

resInput = predInput - input;
%resOutput = predOutput - output;
res = infer(model, input');
adInput = input + res';
%Arima model accuracy
trainRmse = errperf(input(sensorNumber, sdiff:end), adInput(sensorNumber, sdiff:end), 'rmse');
maxRes = max(res);
minRes = min(res);
fprintf(1, 'Arima fit Error rates -- train rmse:%f   %f     %f\n', trainRmse, maxRes, minRes);

plot(res(576:1152))
[h, p, s, c] = lbqtest(res(300:600))
autocorr(res, [200]);
parcorr(res, [100]);
% testRmse = errperf(output(sensorNumber, sdiff:end), predOutput(sensorNumber, sdiff:end), 'rmse');
% fprintf(1, 'Arima fit Error rates -- train rmse:%f      test rmse %f\n', trainRmse, testRmse);

%=========================END ARIMA=========================
>>>>>>> blah

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

res = resInput;

[h, p, s, c] = lbqtest(resInput(1, 40:100)) 
autocorr(resInput(200:end), [200]);
parcorr(resInput(200:end), [200]);
%=========================END NEURAL NETWORK================

rd = res';
rds = smooth(rd, 0.009, 'lowess');
rds = rds';
rds2 = smooth(abs(rds), 10);
rds2 = rds2';
x = 1:1:100;
for i = 1:100:size(rds, 2)
    i
    %plot(x, abs(rds(1, i:i + 99)));
    plot(x, rds2(1, i:i + 99));
    ylim([0 100])
    waitforbuttonpress
end

%==========================FIND PEAKS=======================
winSize = 20;
[win, ind] = largestWindow(res', winSize, 30, (data.blocksInDay * 2 - 6):1:(data.blocksInDay * 2 + 6));
%[win, ind] = simpleExtraction(rds, 12, 2);
%ind = ind'
for i = 1:length(win)
    tmp = datevec(thTimes(1, ind(i)));
    fprintf(1, '%i, %i - %i:%i\n', tmp(2), tmp(3), tmp(4), tmp(5));
end

x = 1:1:50
for i = 1:length(win)
    %plot(win(i, :));
    datevec(thTimes(1, ind(i)))
    %plot(win{i});
    subplot(2, 1, 1)
    plot(x, [input(1, ind(i) - winSize/2 - 14:ind(i) + 30); predInput(1, ind(i) - winSize/2 - 14:ind(i) + 30)]);
    subplot(2, 1, 2)
    plot(win{i});
    ylim([-150 150]);
    waitforbuttonpress;
end
windows = cell2mat(win');
[idx, c] = kmeans(windows, 5);

x2 = linspace(1, winSize + 1, winSize + 1);
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

%=========================PLOT ANOMALOUS DAYS=============
ind2 = ind;
ri = [1 3 7 8 10 13];
ind2(ri) = [];
dayBlocks = data.blocksInDay;
x = linspace(1, dayBlocks, dayBlocks);
numDays = size(input, 2)/dayBlocks;
xflip = [x(1 : end - 1) fliplr(x)];
for i = 1:numDays
    y = input(1, (i-1)*dayBlocks + 1:i*dayBlocks);
    yflip = [y(1 : end - 1) fliplr(y)];
    patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
    hold on
end
xlim([1 dayBlocks]); 

for i = 1:size(ind, 2)
    dayInd = (floor(ind(i) / dayBlocks)) * dayBlocks;
    x2 = ind(i) - dayInd - winSize / 2:1:ind(i) - dayInd + winSize / 2;
    y2 = input(ind(i) - winSize / 2:ind(i) + winSize / 2);
    y2flip = [y2(1 : end - 1) fliplr(y2)];
    x2flip = [x2(1 : end - 1) fliplr(x2)];
    patch(x2flip, y2flip, 'r', 'EdgeAlpha', 0.8, 'FaceColor', 'none', 'EdgeColor', 'red');
end
xlim([1 dayBlocks]); 

for i = 1:size(ind, 2)
    x = 1:1:dayBlocks;
    %Find the day of the problem
    dayInd = (floor(ind(i) / dayBlocks)) * dayBlocks;

    if dayInd/dayBlocks <= 4
        continue
    end
    if dayInd/dayBlocks >= 28
        continue
    end
    
    plot(x, input(:, dayInd:dayInd + dayBlocks - 1)); 
    hold on;
    %plot(x, input(dayInd + 48:dayInd + 48 + 47));
    plot(x, input(dayInd - (dayBlocks * 2):dayInd - (dayBlocks * 2) + dayBlocks - 1), 'Color', 'green');
    xt = ind(i) - dayInd - winSize/2 + 1:1:ind(i) - dayInd + winSize/2 + 1;
    plot(xt, input(ind(i) - winSize/2:ind(i) + winSize/2), 'Color', 'red');
    xlim([1 dayBlocks]);
    hold off;
    waitforbuttonpress;
end

