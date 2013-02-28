%%%%
%Train hidden markov models from a set residuals
%%%%
clear all

ahead = 1;

%fileName = 'simulated';
%fileName = 'brown';
fileName = 'denver';

load(strcat('./data/', fileName, 'Run.mat'));

%Remove residuals
icast = aForecast(data.model, ahead, data.testData(1, :)');
[windows, values] = maxDevWindows(icast2, data.testData, 6);

%Perform hidden markov model clustering on the windows
clusters = trainHMMClusters();

%test the value of the clusters
%Run a silhouette test on the clusters