%visualizeDataset
clear all;
%load('./data/brownData.mat');
load('./data/merlData.mat');

dayOfWeek = 4;
sensor = 33;

% [means, stds] = dailyMean(data.data(sensor, :), data.times, data.blocksInDay, 'smooth', true);

for sens = 1:100
    for i = 4:4
        fprintf(1, 'Sensor %i\n', sens);
        [means, stds] = dailyMean(data.data(sens, :), data.times, data.blocksInDay, 'smooth', true);
        plotMean(means(i, :), 'std', stds(dayOfWeek, :));
        waitforbuttonpress;
        close all;
    end
end

