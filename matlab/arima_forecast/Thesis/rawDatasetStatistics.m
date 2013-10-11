%dataVisualization
clear all;

plotDay = 5;
dataSet = 1;
sensor = MyConstants.DATASET_SENSOR(dataSet);

dataLocation = MyConstants.FILE_LOCATIONS_RAW{dataSet};
saveLocation = strcat(MyConstants.THESIS_LOCATION, 'images/datasets/ds-', ...
                int2str(dataSet), '_day-', int2str(plotDay), '.png');
fileLocation = strcat(MyConstants.THESIS_LOCATION, 'images/datasets/ds-', ...
                int2str(dataSet), '_day-', int2str(plotDay), '.txt');            
                    
load(dataLocation);
fileID = fopen(fileLocation, 'w');

tmpTitle = {'Sensor Activations vs Time of Day on '};
plotTitle = strcat(tmpTitle, ...
                    MyConstants.PLOT_DAYS(plotDay), 's');
%for i = 80:200
%    sensor = i;
%    i            
    %Visualize raw data
    [means, stds] = dailyMean(data.data(sensor, :), data.times, data.blocksInDay, 'smooth', false);
    fig = plotMean(means(plotDay, :), 'std', stds(plotDay, :), ...
        'xlabel', 'Hour of Day', 'ylabel', 'Sensor Activations', ...
        'figsizeX', MyConstants.IMAGE_XSIZE, ...
        'figsizeY', MyConstants.IMAGE_YSIZE, ...
        'plotTitle', plotTitle, ...
        'startTime', data.dayTimeStart, ...
        'endTime', data.dayTimeEnd, ...
        'blocksInDay', data.blocksInDay);
    waitforbuttonpress;
    
%end

fprintf(1, 'raw avg std %f \n', mean(stds(plotDay, :)));

saveas(fig, saveLocation, 'png');

%Write a dataset file
fprintf(fileID, 'Total Days: %f\n', size(data.data, 2)/data.blocksInDay);
fprintf(fileID, 'Sensor: %i\n', sensor);
fprintf(fileID, 'blocksInDay: %i\n\n', data.blocksInDay);

tmp = [means(plotDay, :); stds(plotDay, :)];
fprintf(fileID, '%8s %8s\r\n', 'mean(t)', 'std(t)');
fprintf(fileID, '%8.3f  %8.3f\r\n', tmp);
