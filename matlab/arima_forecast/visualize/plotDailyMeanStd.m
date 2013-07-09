%visualizeDataset
clear all;
%load('./data/brownData.mat');
load('./data/merlData.mat');
%load('./data/denverData.mat');

dayOfWeek = 4;
%sensor = 1;

% [means, stds] = dailyMean(data.data(sensor, :), data.times, data.blocksInDay, 'smooth', true);

for sens = 38:59
    for i = 4:4
        fprintf(1, 'Sensor %i\n', sens);
        [means, stds] = dailyMean(data.data(sens, :), data.times, data.blocksInDay, 'smooth', false);
        plotMean(means(i, :), 'std', stds(dayOfWeek, :));
        waitforbuttonpress;
        close all;
    end
end

