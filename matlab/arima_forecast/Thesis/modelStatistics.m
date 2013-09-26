%File: modelStatistics.m
%Author: James Howard
%
%
%Runs models for a given dataset and computes all pertinent statistics for
%that model.  Uses "cleaned" datasets to run models on.


clear all;

dataSet = 1;
model = 1;

dataLocation = MyConstants.FILE_LOCATIONS_CLEAN{dataSet};
saveLocation = strcat(MyConstants.THESIS_LOCATION, 'images/models/ds-', ...
                int2str(dataSet), '_model-', int2str(model), '.png');
fileLocation = strcat(MyConstants.THESIS_LOCATION, 'images/models/ds-', ...
                int2str(dataSet), '_model-', int2str(model), '.txt');            
                    
load(dataLocation);

%Train given model
m = bcf.models.Arima(1, 10, [1 2 3]);




%fileID = fopen(fileLocation, 'w');
% 
% tmpTitle = {'Sensor Activations vs Time of Day on '};
% plotTitle = strcat(tmpTitle, ...
%                     MyConstants.PLOT_DAYS(plotDay), 's');
% 
% %Visualize raw data
% [means, stds] = dailyMean(data.data(sensor, :), data.times, data.blocksInDay, 'smooth', false);
% fig = plotMean(means(plotDay, :), 'std', stds(plotDay, :), ...
%     'xlabel', 'Hour of Day', 'ylabel', 'Sensor Activations', ...
%     'figsizeX', MyConstants.IMAGE_XSIZE, ...
%     'figsizeY', MyConstants.IMAGE_YSIZE, ...
%     'plotTitle', plotTitle, ...
%     'startTime', data.dayTimeStart, ...
%     'endTime', data.dayTimeEnd, ...
%     'blocksInDay', data.blocksInDay);
% 
% fprintf(1, 'raw avg std %f \n', mean(stds(plotDay, :)));
% 
% saveas(fig, saveLocation, 'png');
% 
% %Write a dataset file
% fprintf(fileID, 'Total Days: %f\n', size(data.data, 2)/data.blocksInDay);
% fprintf(fileID, 'Sensor: %i\n', sensor);
% fprintf(fileID, 'blocksInDay: %i\n\n', data.blocksInDay);
% 
% tmp = [means(plotDay, :); stds(plotDay, :)];
% fprintf(fileID, '%8s %8s\r\n', 'mean(t)', 'std(t)');
% fprintf(fileID, '%8.3f  %8.3f\r\n', tmp);
