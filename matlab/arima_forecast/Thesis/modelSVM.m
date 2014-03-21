%File: modelSVM.m
%Author: James Howard
%
%
%Runs a SVM model for a given dataset and computes statistics for the
%dataset.  Also creates a set of images.

clear all;

dataSet = 1;
model = 4; %Set model to SVM

startDay = 5; %Start and end day are used for sample plots
endDay = 7;

plotData = true;

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
%                           TRAIN SVM MODEL
%==========================================================================

%Train given model
aMod = bcf.models.SVM(MyConstants.SVM_PARAMETERS{dataSet}, MyConstants.SVM_WINDOW{dataSet});
aMod.train(data.trainData);


if plotData
    testF = aMod.forecastAll(data.testData, 2);

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
    %                          PRODUCE EXAMPLE PLOT HERE
    %==========================================================================
    fig = figure('Position', [100, 100, 100 + 2000, 100 + 750]);
    plot(data.testData(1, startTime:endTime), 'Color', [0 0 0])
    hold on
    plot(testF(1, startTime:endTime), 'Color', [0 0 1])

    xlim([1, endTime - startTime]);
    xlabel({'Time'}, 'FontSize', 16, 'FontName', MyConstants.FONT_TYPE)
    ylabel({'Scaled sensor activations'}, 'FontSize', 16, 'FontName', MyConstants.FONT_TYPE)
    title({'Example of SVM forecasting capability'}, 'FontSize', 20, 'FontName', MyConstants.FONT_TYPE);
    set(gca,'XTickLabel',[]);
    legend('Scaled raw test data', 'One step SVM forecast');
    saveas(fig, ...
        strcat(saveLocationStart, 'sample_', saveLocationEnd), 'png');
end

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
    
    [ponanValue rmseonanValue sqeonan ~] = ponan(trainRes, stds);
    rmseonanhist(1, h) = rmseonanValue;
    sqeonanhist(1, h) = sqeonan;
    
    [ponanValue rmseonanValue sqeonan ~] = ponan(validRes, stds);
    rmseonanhist(2, h) = rmseonanValue;
    sqeonanhist(2, h) = sqeonan;
    
    [ponanValue rmseonanValue sqeonan ~] = ponan(testRes, stds);
    rmseonanhist(3, h) = rmseonanValue;
    sqeonanhist(3, h) = sqeonan;

    [ponanValue rmseonanValue sqeonan ~] = ponan(trainRes, 3*stds);
    sqeonan3hist(1, h) = sqeonan;
    
    [ponanValue rmseonanValue sqeonan ~] = ponan(validRes, 3*stds);
    sqeonan3hist(2, h) = sqeonan;
    
    [ponanValue rmseonanValue sqeonan ~] = ponan(testRes, 3*stds);
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

results.svm.rmse = rmsehist;
results.svm.mase = masehist;
results.svm.rmseonan = rmseonanhist;
results.svm.sqeonan = sqeonanhist;
results.svm.sqeonan3 = sqeonan3hist;
results.svm.trainForecast = trainForecasts;
results.svm.validForecast = validForecasts;
results.svm.testForecast = testForecasts;

save(MyConstants.RESULTS_DATA_LOCATIONS{dataSet}, 'results');
