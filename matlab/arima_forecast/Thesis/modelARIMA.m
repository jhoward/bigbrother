%File: modelARIMA.m
%Author: James Howard
%
%
%Runs an ARIMA model for a given dataset and computes statistics for the
%dataset.  Also creates a set of images.

clear all;

dataSet = 3;
model = 2; %Set MODEL to ARIMA
startDay = 5;
endDay = 7;

dataLocation = MyConstants.FILE_LOCATIONS_CLEAN{dataSet};
saveLocationStart = strcat(MyConstants.THESIS_LOCATION, 'images/models/');
saveLocationEnd = strcat('ds-', int2str(dataSet), '_model-', ...
                MyConstants.MODEL_NAMES{model}, '.png');
fileLocationStart = strcat(MyConstants.THESIS_LOCATION, 'images/models/');
fileLocationEnd = strcat('ds-', int2str(dataSet), '_model-', ...
                MyConstants.MODEL_NAMES{model}, '.txt');
                    
load(dataLocation);
fileID = fopen(strcat(fileLocationStart, fileLocationEnd), 'w');

startTime = startDay * data.blocksInDay;
endTime = endDay * data.blocksInDay;

fStart = data.blocksInDay * 1;
fEnd = size(data.testData, 2);

%==========================================================================
%                           TRAIN ARIMA MODEL
%==========================================================================

%Train given model
aMod = bcf.models.Arima(1, data.blocksInDay, MyConstants.ARIMA_PARAMETERS{dataSet});
aMod.train(data.trainData);

%First infer the data and test for white noise

%Inferred data
trainI = aMod.inferData(data.trainData);
testI = aMod.inferData(data.testData);
testF = aMod.forecastAll(data.testData, 1);
testF5 = aMod.forecastAll(data.testData, 5);

[h, p, s, c] = lbqtest(trainI(100:end));
[h1, p1, s1, c1] = lbqtest(testF(100:end));
[h5, p5, s5, c5] = lbqtest(testF5(100:end));

%Write to file the results of the white noise residual test to a file
fprintf(fileID, 'Dataset: %i\n', dataSet);
fprintf(fileID, 'Sensor: %i\n', MyConstants.DATASET_SENSOR(dataSet));
fprintf(fileID, 'blocksInDay: %i\n\n', data.blocksInDay);

fprintf(fileID, 'Trained data white noise test (p value): %f\n', p);
fprintf(fileID, 'Test data forecast 1 white noise test (p value): %f\n', p1);
fprintf(fileID, 'Test data forecast 5 white noise test (p value): %f\n', p5);
fprintf(fileID, 'Trained data white noise test (stat value): %f\n', s);
fprintf(fileID, 'Test data forecast 1 white noise test (stat value): %f\n', s1);
fprintf(fileID, 'Test data forecast 5 white noise test (stat value): %f\n', s5);

fprintf(1, 'White noise tests train: %f    test1: %f   test5: %f\n', p, p1, p5);

%==========================================================================
%                           PLOT AUTO CORRELATIONS
%==========================================================================
%Test the model - for now test 1 timestep ahead
trainF = aMod.forecastAll(data.trainData, 1);
testF = aMod.forecastAll(data.testData, 1);
trainF4 = aMod.forecastAll(data.trainData, 10);

trainR = data.trainData - trainF;
trainR4 = data.trainData - trainF4;
testR = data.testData - testF;

[ac, aclags, acbounds] = autocorr(trainI, data.blocksInDay * 2 + 1);
trainAutoCorr = plotCorr(ac, acbounds(1), ...
    'xlabel', 'Lags', 'ylabel', 'Autocorrelations', ...
    'figsizeX', MyConstants.IMAGE_XSIZE, ...
    'figsizeY', MyConstants.IMAGE_YSIZE, ...
    'plotTitle', strcat({'Training data autocorrelations vs lags for '}, ...
                            MyConstants.DATA_SETS{dataSet}, ' dataset'));

saveas(trainAutoCorr, ...
    strcat(saveLocationStart, 'train_autocorr_', saveLocationEnd), 'png');                        
                        
[pac, paclags, pacbounds] = parcorr(trainI, data.blocksInDay * 2 + 1);
trainParCorr = plotCorr(pac, pacbounds(1), ...
    'xlabel', 'Lags', 'ylabel', 'Partial autocorrelations', ...
    'figsizeX', MyConstants.IMAGE_XSIZE, ...
    'figsizeY', MyConstants.IMAGE_YSIZE, ...
    'plotTitle', strcat({'Training data partial autocorrelations vs lags for '}, ...
                            MyConstants.DATA_SETS{dataSet}, ' dataset'));
saveas(trainParCorr, ...
    strcat(saveLocationStart, 'train_parcorr_', saveLocationEnd), 'png');  

%==========================================================================
%                           Data setup for plots
%==========================================================================
[means, stds] = computeMean(data.testData, data.blocksInDay);
res = testF - data.testData;
%resMeans = data.testData - repmat(means, 1, size(data.testData, 2)/data.blocksInDay);

numDays = size(data.testData, 2) / data.blocksInDay;

stdsrep = repmat(stds, 1, numDays);
meansrep = repmat(means, 1, numDays);
meansRes = data.testData - meansrep;

negstd = meansrep - stdsrep;
posstd = meansrep + stdsrep;


%==========================================================================
%                           Additional sample plots
%==========================================================================
figure
plot(data.testData(1, startTime:endTime), 'Color', [0 0 0])
hold on
%plot(negstd(1, startTime:endTime), 'Color', [0.5 0 0])
%plot(posstd(1, startTime:endTime), 'Color', [0.5 0 0])
plot(meansrep(1, startTime:endTime), 'Color', [0 0.5 0.5])


figure
%Plot the appearance of ponan
plot(abs(res(1, startTime:endTime)), 'Color', [1 0 0])
hold on
plot(stdsrep(1, startTime:endTime), 'Color', [0 0 1])


figure
plot(abs(meansRes(1, startTime:endTime)), 'Color', [0 0 0])
hold on
plot(stdsrep(1, startTime:endTime), 'Color', [0 0 1])


%==========================================================================
%                           PLOT SAMPLE PONAN
%==========================================================================
fig = plotPonan(res(1, startTime:endTime), stds, true);
saveas(fig, ...
    strcat(saveLocationStart, 'ponan_', saveLocationEnd), 'png');


%==========================================================================
%                           PLOT SAMPLE RMSEONAN
%==========================================================================
fig = plotPonan(res(1, startTime:endTime), stds, false);
saveas(fig, ...
    strcat(saveLocationStart, 'sseonan_', saveLocationEnd), 'png');


%==========================================================================
%                           WRITE TO FILE PERTINENT DATA
%==========================================================================
[ponanvalue rmseonanvalue sseonan errpoints] = ponan(res, stds);
ponanvalue
rmseonanvalue
[ponanvalue rmseonanvalue sseonan errpoints] = ponan(meansRes, stds);
ponanvalue
rmseonanvalue


%==========================================================================
%                           PRODUCE EXAMPLE PLOT HERE
%==========================================================================
fig = figure('Position', [100, 100, 100 + 2000, 100 + 750]);
plot(data.testData(1, startTime:endTime), 'Color', [0 0 0])
hold on
plot(testF(1, startTime:endTime), 'Color', [0 0 1])
    
xlim([1, endTime - startTime]);
xlabel({'Time'}, 'FontSize', 16, 'FontName', MyConstants.FONT_TYPE)
ylabel({'Scaled sensor activations'}, 'FontSize', 16, 'FontName', MyConstants.FONT_TYPE)
title({'Example of ARIMA forecasting capability'}, 'FontSize', 20, 'FontName', MyConstants.FONT_TYPE);
set(gca,'XTickLabel',[]);
legend('Scaled raw test data', 'One step ARIMA forecast');
saveas(fig, ...
    strcat(saveLocationStart, 'sample_', saveLocationEnd), 'png');


%==========================================================================
%                           Produce a horizon forecast and save
%==========================================================================
load(MyConstants.RESULTS_DATA_LOCATIONS{dataSet})

rmsehist = zeros(3, MyConstants.HORIZON);
masehist = zeros(3, MyConstants.HORIZON);
rmseonanhist = zeros(3, MyConstants.HORIZON);
sqeonanhist = zeros(3, MyConstants.HORIZON);
sqeonan3hist = zeros(3, MyConstants.HORIZON);


for h = 1:MyConstants.HORIZON
    
    %Forcasting for horizons
    fprintf(1, 'Horizon:%i\n', h);
    
    %Compute train and test rmse, mase, ponan and rmseonan
    testF = aMod.forecastAll(data.testData(fStart:fEnd), h);
    testForecasts{h} = testF;
    trainF = aMod.forecastAll(data.trainData(fStart:fEnd), h);
    trainForecasts{h} = trainF;
    validF = aMod.forecastAll(data.validData(fStart:fEnd), h);
    validForecasts{h} = validF;
    
    testRes = testF - data.testData(fStart:fEnd);
    trainRes = trainF - data.trainData(fStart:fEnd);
    validRes = validF - data.validData(fStart:fEnd);
    
    %Performance metrics
    [ponanValue rmseonanValue sqeonan ~] = ponan(trainRes, stds);
    rmseonanhist(1, h) = rmseonanValue;
    sqeonanhist(1, h) = sqeonan;
    
    [ponanValue rmseonanValue sqeonan ~] = ponan(validRes, stds);
    rmseonanhist(2, h) = rmseonanValue;
    sqeonanhist(2, h) = sqeonan;
    
    [ponanValue rmseonanValue sqeonan ~] = ponan(testRes, stds);
    rmseonanhist(3, h) = rmseonanValue;
    sqeonanhist(3, h) = sqeonan;
    
    %SQEONAN3
    [ponanValue rmseonanValue sqeonan ~] = ponan(trainRes, stds);
    sqeonan3hist(1, h) = sqeonan;
    
    [ponanValue rmseonanValue sqeonan ~] = ponan(validRes, stds);
    sqeonan3hist(2, h) = sqeonan;
    
    [ponanValue rmseonanValue sqeonan ~] = ponan(testRes, stds);
    sqeonan3hist(3, h) = sqeonan;
    
    rmsehist(1, h) = errperf(data.trainData(1, fStart:fEnd), ...
                            trainF, 'rmse');
    rmsehist(2, h) = errperf(data.validData(1, fStart:fEnd), ...
                            validF, 'rmse');
    rmsehist(3, h) = errperf(data.testData(1, fStart:fEnd), ...
                            testF, 'rmse');
                         
    masehist(1, h) = mase(data.trainData(1, fStart:fEnd), ...
                             trainF);
    masehist(2, h) = mase(data.validData(1, fStart:fEnd), ...
                             validF);
    masehist(3, h) = mase(data.testData(1, fStart:fEnd), ...
                             testF);
                         
    fprintf(1, 'rmse - %f \n', rmsehist(3, h));
end

results.arima.rmse = rmsehist;
results.arima.mase = masehist;
results.arima.rmseonan = rmseonanhist;
results.arima.sqeonan = sqeonanhist;
results.arima.sqeonan3 = sqeonan3hist;
results.arima.trainForecast = trainForecasts;
results.arima.validForecast = validForecasts;
results.arima.testForecast = testForecasts;

save(MyConstants.RESULTS_DATA_LOCATIONS{dataSet}, 'results');


