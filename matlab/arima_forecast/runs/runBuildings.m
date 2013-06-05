%Run Buildings.  Do analysis for merl data and brownhall data

clear all;
load('./data/brownData.mat');
%load('./data/merlData.mat');

%===============================SETUP DATA=================
windowSize = 10;

trainPercent = 0.6;

%%%%%%%%%%%%%BROWN HALL%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Combine the data to be just the exits
allData = data.data(48, :);
ysize = 200;


% %%%%%%%%%%%%%%MERL DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% allData = data.data(33, :);
% ysize = 40;

%%%%%%%%%%%%%%%BOTH DATASETS%%%%%%%%%%%%%%%%%%%%%%%%
input = allData;
dayOfWeek = 4;
horizon = 20;

%=========================END SETUP=====================

%========================COMPUTE DAY OF WEEK DATA=======

%Compute each day of week into a dataset
days = unique(data.dayOfWeek);

inputWeekData = {};
inputWeekTimes = {};

for i = 1:length(days)
    tmp = (data.dayOfWeek == i);
    tmpTimes = data.times(1, tmp);
    inputWeekTimes{i} = tmpTimes; %#ok<SAGROW>
    inputWeekData{i} = input(tmp); %#ok<SAGROW>
    inputWeekData{i} = smooth(inputWeekData{i})'; %#ok<SAGROW>
end

weeklySigma = zeros(length(days), data.blocksInDay);
weeklyMean = zeros(length(days), data.blocksInDay);
for i = 1:length(days)
    newSize = floor(size(inputWeekData{i}, 2)/data.blocksInDay);
    newData = inputWeekData{i}(:, 1:newSize*data.blocksInDay);
    tmpRes = reshape(newData, size(inputWeekData{i},1), data.blocksInDay, newSize);
    weeklySigma(i, :) = std(tmpRes, 1, 3);
    weeklyMean(i, :) = mean(tmpRes, 3);
end


%======================END COMPUTE PER DAY OF WEEK=========

%=====================CLEAN DATA==========================

tmpData = inputWeekData{dayOfWeek};
numDays = floor(size(tmpData, 2))/data.blocksInDay;
inputMax = data.blocksInDay * floor(numDays * trainPercent);

input = tmpData(1, 1:inputMax);
output = tmpData(1, inputMax + 1:end);

%input = smooth(input);
%output = smooth(output);

%Save just the data
%save('./data/merlCleaned.mat', 'input', 'output');

%Save just the data
%save('./data/brownCleaned.mat', 'input', 'output');


%=====================PLOT RAW DATA=======================

xvals = 1:1:data.blocksInDay;
xvals = [xvals, fliplr(xvals)];
y1 = weeklyMean(dayOfWeek, :) - weeklySigma(dayOfWeek, :);
y2 = weeklyMean(dayOfWeek, :) + weeklySigma(dayOfWeek, :);
yvals = [y1, fliplr(y2)];
tmp = fill(xvals, yvals, [0.7, 0, 0]);
set(tmp,'EdgeColor',[0.7, 0, 0],'FaceAlpha',0.5,'EdgeAlpha',0.5);%s
hold on;
plot(1:1:data.blocksInDay, weeklyMean(dayOfWeek, :), 'LineWidth', 2, 'Color', [0, 0, 1]); 
xlim([1, data.blocksInDay]);
ylim([0, ysize]);
xlabel('Time of day', 'FontSize', 14)
ylabel('Sensor activations', 'FontSize', 14)
set(gca,'XTick',[]);

%=====================PERFORM SEASONAL ARIMA FORECASTS=====

% %%%%%%%%%%BROWN PARAMETERS%%%%%%%%
ar = 0;
diff = 1;
ma = 1;
sar = 0;
sdiff = data.blocksInDay;
sma = 4;
%%%%%%%%%%%%%BROWN PARAMETERS%%%%%%


%%%%%%%%MERL PARAMETERS%%%%%%%%%%%
% ar = 0;
% diff = 0;
% ma = 1;
% sar = 0;
% sdiff = data.blocksInDay;
% sma = 5;
%%%%%%%%MERL PARAMETERS%%%%%%%%%%%

%%%%%%%%%%%%TRAIN FOR TWENTY FORECAST HORIZONS%%%%%%%%%%%%%
dataVals = {zeros(6, horizon), zeros(6, horizon), zeros(6, horizon), zeros(6, horizon), zeros(6, horizon), zeros(6, horizon)};

%input(input == 0) = 1;
%input = log(input);

arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
        'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);

model = estimate(arimaModel, input', 'print', true);

modelArima = bcf.models.Arima(model, data.blocksInDay);
%modelArima.calculateNoiseDistribution(input, 1);
modelArima.calculateNoiseDistribution(input, horizon);
arimaInferResInput = infer(model, input');
%[h, p, s, c] = lbqtest(arimaInferResInput(300:400))
%autocorr(arimaInferResInput, [100]);
%parcorr(arimaInferResInput, [100]);

modelVals{1} = modelArima;

arimaInput = {};
arimaOutput = {};

for i = 1:horizon

    arimaInput{i} = modelArima.forecastAll(input, i);
    arimaOutput{i} = modelArima.forecastAll(output, i);

    arimaResInput = arimaInput{i} - input;
    arimaResOutput = arimaOutput{i} - output;

    %Arima model accuracy
    arimaTrainRmse = errperf(input(data.blocksInDay + i:end), arimaInput{i}(data.blocksInDay + i:end), 'rmse');
    arimaTrainMaxRes = max(arimaResInput);
    arimaTrainMinRes = min(arimaResInput);
    arimaTestRmse = errperf(output(data.blocksInDay + i:end), arimaOutput{i}(data.blocksInDay + i:end), 'rmse');
    arimaTestMaxRes = max(arimaResOutput);
    arimaTestMinRes = min(arimaResOutput);

    fprintf(1, '%i Arima fit Error rates -- test rmse:%f   %f     %f\n', i, arimaTestRmse, arimaTestMaxRes, arimaTestMinRes);

    dataVals{1}(1, i) = arimaTrainRmse;
    dataVals{1}(2, i) = arimaTrainMaxRes;
    dataVals{1}(3, i) = arimaTrainMinRes;
    dataVals{1}(4, i) = arimaTestRmse;
    dataVals{1}(5, i) = arimaTestMaxRes;
    dataVals{1}(6, i) = arimaTestMinRes;
end

plot(1:1:data.blocksInDay, [output(data.blocksInDay:data.blocksInDay * 2 -1); arimaOutput{15}(1, data.blocksInDay:data.blocksInDay * 2 - 1)]);
plot(1:1:horizon, [dataVals{1}(1, :); dataVals{1}(4, :)])
xlim([1, horizon]);


%plot(arimaResInput(500:1099))
% [h, p, s, c] = lbqtest(arimaResInput(400:480))
% autocorr(arimaResInput, [100]);
% parcorr(arimaResInput, [100]);
    
% 
% %Plot a typical set of days
% pwidth = data.blocksInDay;
% for i = 1:floor(size(input, 2)/pwidth) - 1
%     x = 1:1:data.blocksInDay;
%     plot(x, [input(1, i*pwidth + 1:i*pwidth + pwidth); arimaAdInput(1, i*pwidth + 1:i*pwidth + pwidth)]);
%     hold on
%     plot(x, arimaAdInput(1, i*pwidth + 1:i*pwidth + pwidth) + modelArima.dayNoiseSigma, 'Color', 'red');
%     plot(x, arimaAdInput(1, i*pwidth + 1:i*pwidth + pwidth) - modelArima.dayNoiseSigma, 'Color', 'red');
%     xlim([1 data.blocksInDay]);
%     waitforbuttonpress
%     hold off
% end

%===========================TDNN===========================
% 
% %SETUP THE MODEL
cdata = {};

cdata = tonndata(input, true, false);
td = 15;
hn = 8;

net = timedelaynet(1:td, hn);

net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;
% 
% % [xs, xi, ai, ts] = preparets(net, cdata(:, 1:end - 1), cdata(:, 1 + 1:end));
% % net1 = train(net, xs, ts, xi, ai);
% % [xs, xi, ai, ts] = preparets(net, cdata(:, 1:end - ahead), cdata(:, 1 + ahead:end));
% % netahead = train(net, xs, ts, xi, ai);
% % 
% % modelTDNN = bcf.models.TDNN(net1, netahead, ahead);
% % 
% % predInput = modelTDNN.forecastAll(input(1, :), 1);
% % resInput = predInput - input;
% % 
% % trainRmse = errperf(input(sensorNumber, 1:end), predInput(sensorNumber, 1:end), 'rmse');
% % fprintf(1, 'NN Error rates -- train rmse:%f\n', trainRmse);
% 
% 
% %%%%%%%%%%%%%%TRAIN for TWENTY FORECAST HORIZONS%%%%%%%%%%%%
% % 
% [xs, xi, ai, ts] = preparets(net, cdata(:, 1:end - 1), cdata(:, 1 + 1:end));
% net1 = train(net, xs, ts, xi, ai); 
% [xs, xi, ai, ts] = preparets(net, cdata(:, 1:end - i), cdata(:, 1 + i:end)); 
% netahead = train(net, xs, ts, xi, ai);
%modelTDNN = bcf.models.TDNN(net1, netAhead, );
% 
% bestRmse = 1;
% bestModel = 0;
% %Find the best model from some number of attempts
% for i = 1:5
%     net1 = train(net, xs, ts, xi, ai); 
%     modelTDNN = bcf.models.TDNN(net1, 1);
%     predOut = modelTDNN.forecastAll(output(1, :), 1);
%     predOut = predOut - output;
%     rmse = errperf(output(1, 1:end), predOut(1, 1:end), 'rmse');
%     rmse
%     if (i == 1) || (rmse < bestRmse)
%         bestRmse = rmse;
%         bestModel = modelTDNN;
%         i
%     end
% end
% modelTDNN.calculateNoiseDistribution(input, 1);
% modelVals{2} = bestModel;
% modelTDNN = bestModel;

    
tdnnInput = {};
tdnnOutput = {};

%THIS RUN TAKES A WHILE
for i = 3:horizon

    %COMMENT THIS OUT LATER
    [xs, xi, ai, ts] = preparets(net, cdata(:, 1:end - i), cdata(:, 1 + i:end)); 
    netahead = train(net, xs, ts, xi, ai);
    
    modelTDNN = bcf.models.TDNN(netahead, i);
    
    tdnnInput{i} = modelTDNN.forecastAll(input(1, :), i); 
    tdnnOutput{i} = modelTDNN.forecastAll(output(1, :), i); 
    tdnnResOutput = tdnnOutput{i} - output;
    tdnnResInput = tdnnInput{i} - input;

    tdnnTrainRmse = errperf(input(td + i + 1:end), tdnnInput{i}(td + i + 1:end), 'rmse');
    tdnnTrainMaxRes = max(tdnnResInput);
    tdnnTrainMinRes = min(tdnnResInput);
    tdnnTestRmse = errperf(output(td + i + 1:end), tdnnOutput{i}(td + i + 1:end), 'rmse');
    tdnnTestMaxRes = max(tdnnResOutput);
    tdnnTestMinRes = min(tdnnResOutput); 

    fprintf(1, '%i tdnn fit Error rates -- test rmse:%f   %f     %f\n', i, tdnnTestRmse, tdnnTestMaxRes, tdnnTestMinRes);

    dataVals{2}(1, i) = tdnnTrainRmse;
    dataVals{2}(2, i) = tdnnTrainMaxRes;
    dataVals{2}(3, i) = tdnnTrainMinRes;
    dataVals{2}(4, i) = tdnnTestRmse;
    dataVals{2}(5, i) = tdnnTestMaxRes;
    dataVals{2}(6, i) = tdnnTestMinRes;
end
% 
% plot(1:1:horizon, [dataVals{2}(2, :); dataVals{2}(2, :)])
% xlim([1, horizon]);


%====================AVERAGE MODEL========================

avgInput = {};
avgOutput = {};

modelAvg = bcf.models.Average(data.blocksInDay);
modelAvg.train(input);
%modelAvg.calculateNoiseDistribution(input, horizon);

modelVals{3} = modelAvg;


for i = 1:horizon
    avgInput{i} = modelAvg.forecastAll(input(1, :), i);
    avgOutput{i} = modelAvg.forecastAll(output(1, :), i); 
    avgResOutput = avgOutput{i} - output;
    avgResInput = avgInput{i} - input;

    avgTrainRmse = errperf(input(i + 1:end), avgInput{i}(i + 1:end), 'rmse');
    avgTrainMaxRes = max(avgResInput);
    avgTrainMinRes = min(avgResInput);
    avgTestRmse = errperf(output(i + 1:end), avgOutput{i}(i + 1:end), 'rmse');
    avgTestMaxRes = max(avgResOutput);
    avgTestMinRes = min(avgResOutput); 

    fprintf(1, '%i tdnn fit Error rates -- test rmse:%f   %f     %f\n', i, avgTestRmse, avgTestMaxRes, avgTestMinRes);

    dataVals{3}(1, i) = avgTrainRmse;
    dataVals{3}(2, i) = avgTrainMaxRes;
    dataVals{3}(3, i) = avgTrainMinRes;
    dataVals{3}(4, i) = avgTestRmse;
    dataVals{3}(5, i) = avgTestMaxRes;
    dataVals{3}(6, i) = avgTestMinRes;
end

plot(1:1:horizon, [dataVals{3}(1, :); dataVals{3}(4, :)])
plot(1:1:data.blocksInDay * 2, [output(1, data.blocksInDay * 1:data.blocksInDay * 3 - 1); avgOutput{5}(1, data.blocksInDay * 1:data.blocksInDay * 3 - 1)]); 
xlim([1, 20]);


%====================SVM MODEL========================

svmInput = {};
svmOutput = {};
%horizon = 20;

svmParam = '-s 4 -t 2 -q';
svmWindow = 5;

modelSVM = bcf.models.SVM(svmParam);
modelSVM.train(input, svmWindow);
modelSVM.calculateNoiseDistribution(input, horizon);

modelVals{4} = modelSVM;

for i = 1:horizon
    svmInput{i} = modelSVM.forecastAll(input(1, :), i);
    svmOutput{i} = modelSVM.forecastAll(output(1, :), i); 
    svmResOutput = svmOutput{i} - output;
    svmResInput = svmInput{i} - input;

    svmTrainRmse = errperf(input(i + 1:end), svmInput{i}(i + 1:end), 'rmse');
    svmTrainMaxRes = max(svmResInput);
    svmTrainMinRes = min(svmResInput);
    svmTestRmse = errperf(output(i + 1:end), svmOutput{i}(i + 1:end), 'rmse');
    svmTestMaxRes = max(svmResOutput);
    svmTestMinRes = min(svmResOutput); 

    fprintf(1, '%i tdnn fit Error rates -- test rmse:%f   %f     %f\n', i, svmTestRmse, svmTestMaxRes, svmTestMinRes);

    dataVals{4}(1, i) = svmTrainRmse;
    dataVals{4}(2, i) = svmTrainMaxRes;
    dataVals{4}(3, i) = svmTrainMinRes;
    dataVals{4}(4, i) = svmTestRmse;
    dataVals{4}(5, i) = svmTestMaxRes;
    dataVals{4}(6, i) = svmTestMinRes;
end

plot(1:1:horizon, [dataVals{4}(1, :); dataVals{4}(4, :)])
plot(1:1:data.blocksInDay * 2, [output(1, data.blocksInDay * 1:data.blocksInDay * 3 - 1); svmOutput{5}(1, data.blocksInDay * 1:data.blocksInDay * 3 - 1)]); 
plot(1:1:data.blocksInDay * 2, [input(1, data.blocksInDay * 1:data.blocksInDay * 3 - 1); svmInput{1}(1, data.blocksInDay * 1:data.blocksInDay * 3 - 1)]); 
%xlim([1, 20]);



%==================BCF Models============================
% bcfInput = {};
% bcfOutput = {};
% 
% %Combine and forecast
% models = {modelArima modelAvg modelTDNN};
% %models = {modelArima modelAvg};
% 
% modelBcf = bcf.BayesianForecaster(models);
% modelVals{5} = modelBcf;
% 
% for j = 1:length(models)
%         models{j}.calculateNoiseDistribution(input, 1);
% end
% 
% for i = 1:horizon
%     bcfInput{i} = modelBcf.forecastAll(input(1, :), i, i, 'aggregate');
%     bcfOutput{i} = modelBcf.forecastAll(output(1, :), i, i, 'aggregate'); 
%     bcfResOutput = bcfOutput{i} - output;
%     bcfResInput = bcfInput{i} - input;
% 
%     bcfTrainRmse = errperf(input(i + 1:end), bcfInput{i}(i + 1:end), 'rmse');
%     bcfTrainMaxRes = max(bcfResInput);
%     bcfTrainMinRes = min(bcfResInput);
%     bcfTestRmse = errperf(output(i + 1:end), bcfOutput{i}(i + 1:end), 'rmse');
%     bcfTestMaxRes = max(bcfResOutput);
%     bcfTestMinRes = min(bcfResOutput); 
% 
%     fprintf(1, '%i bcff fit Error rates -- test rmse:%f   %f     %f\n', i, bcfTestRmse, bcfTestMaxRes, bcfTestMinRes);
% 
%     dataVals{5}(1, i) = bcfTrainRmse;
%     dataVals{5}(2, i) = bcfTrainMaxRes;
%     dataVals{5}(3, i) = bcfTrainMinRes;
%     dataVals{5}(4, i) = bcfTestRmse;
%     dataVals{5}(5, i) = bcfTestMaxRes;
%     dataVals{5}(6, i) = bcfTestMinRes;
% end
% 
% plot(1:1:horizon, dataVals{5}(4, :));
% xlim([1, horizon]);

%========next bcf=====
bcf2Input = {};
bcf2Output = {};

%Combine and forecast
models = {modelArima modelAvg};

model2Bcf = bcf.BayesianForecaster(models);
modelVals{6} = model2Bcf;

lowRMSE = dataVals{modelNums(1)}(4, i);
defaultModel = modelNums(1);
%Compute best model for horizon
for k = 2:length(modelNums)
    if (dataVals{modelNums(k)}(4, i) < lowRMSE)
        defaultModel = modelNums(k);
        lowRMSE = dataVals{modelNums(k)}(4, i);
    end
end

for i = 1:horizon
    for j = 1:length(models)
        models{j}.calculateNoiseDistribution(input, i);
    end
    bcf2Input{i} = model2Bcf.forecastAll(input(1, :), i, i, 'aggregate', 0.001, defaultModel);
    bcf2Output{i} = model2Bcf.forecastAll(output(1, :), i, i, 'aggregate', 0.001, defaultModel); 
    bcfResOutput = bcf2Output{i} - output;
    bcfResInput = bcf2Input{i} - input;

    bcfTrainRmse = errperf(input(i + 1:end), bcf2Input{i}(i + 1:end), 'rmse');
    bcfTrainMaxRes = max(bcfResInput);
    bcfTrainMinRes = min(bcfResInput);
    bcfTestRmse = errperf(output(i + 1:end), bcf2Output{i}(i + 1:end), 'rmse');
    bcfTestMaxRes = max(bcfResOutput);
    bcfTestMinRes = min(bcfResOutput); 

    fprintf(1, '%i bcff fit Error rates -- test rmse:%f   %f     %f\n', i, bcfTestRmse, bcfTestMaxRes, bcfTestMinRes);

    dataVals{6}(1, i) = bcfTrainRmse;
    dataVals{6}(2, i) = bcfTrainMaxRes;
    dataVals{6}(3, i) = bcfTrainMinRes;
    dataVals{6}(4, i) = bcfTestRmse;
    dataVals{6}(5, i) = bcfTestMaxRes;
    dataVals{6}(6, i) = bcfTestMinRes;
end



%========ALL BCF=====
bcf3Input = {};
bcf3Output = {};
bcf3Probs = {};
bcf3RawProbs = {};

%Combine and forecast
models = {modelArima modelAvg modelSVM};
modelNums = [1 3 4];

model3Bcf = bcf.BayesianForecaster(models);
modelVals{7} = model3Bcf;
defaultModel = 1;

for i = 1:horizon
    for j = 1:length(models)
        models{j}.calculateNoiseDistribution(input, i);
    end
    
    lowRMSE = dataVals{modelNums(1)}(4, i);
    defaultModel = modelNums(1);
    %Compute best model for horizon
    for k = 2:length(modelNums)
        if (dataVals{modelNums(k)}(4, i) < lowRMSE)
            defaultModel = modelNums(k);
            lowRMSE = dataVals{modelNums(k)}(4, i);
        end
    end
    
    bcf3Input{i} = model3Bcf.forecastAll(input(1, :), i, i, 'aggregate', 0.001, defaultModel);
    [bcf3Output{i}, bcf3Probs{i}, bcf3RawProbs{i}] = model3Bcf.forecastAll(output(1, :), i, i, 'aggregate', 0.001, defaultModel); 
    bcfResOutput = bcf3Output{i} - output;
    bcfResInput = bcf3Input{i} - input;

    bcfTrainRmse = errperf(input(i + 1:end), bcf3Input{i}(i + 1:end), 'rmse');
    bcfTrainMaxRes = max(bcfResInput);
    bcfTrainMinRes = min(bcfResInput);
    bcfTestRmse = errperf(output(i + 1:end), bcf3Output{i}(i + 1:end), 'rmse');
    bcfTestMaxRes = max(bcfResOutput);
    bcfTestMinRes = min(bcfResOutput); 

    fprintf(1, '%i bcff fit Error rates -- test rmse:%f   %f     %f\n', i, bcfTestRmse, bcfTestMaxRes, bcfTestMinRes);

    dataVals{7}(1, i) = bcfTrainRmse;
    dataVals{7}(2, i) = bcfTrainMaxRes;
    dataVals{7}(3, i) = bcfTrainMinRes;
    dataVals{7}(4, i) = bcfTestRmse;
    dataVals{7}(5, i) = bcfTestMaxRes;
    dataVals{7}(6, i) = bcfTestMinRes;
end


plot(1:1:horizon, dataVals{7}(4, :));
xlim([1, horizon]);

dataInputs{1} = arimaInput;
dataOutputs{1} = arimaOutput;
dataInputs{2} = tdnnInput;
dataOutputs{2} = tdnnOutput;
dataInputs{3} = avgInput;
dataOutputs{3} = avgOutput;
dataInputs{4} = svmInput;
dataOutputs{4} = svmOutput;
dataInputs{5} = bcfInput;
dataOutputs{5} = bcfOutput;
dataInputs{6} = bcf2Input;
dataOutputs{6} = bcf2Output;
dataInputs{7} = bcf3Input;
dataOutputs{7} = bcf3Output;




%====%=====%=====SAVE DATA==============
save('./data/brownResults.mat', 'dataVals', 'modelVals', 'dataInputs', 'dataOutputs');


%Display probabilities
bcf3Probs{1}
plot(1:1:100, [bcf3RawProbs{1}(1, 100:199); bcf3RawProbs{1}(2, 100:199); bcf3RawProbs{1}(3, 100:199)]);
