clear all;

%Output data
O = 1; %Number of dimensions
T = 96; %Time series length
nex = 15; %Number of examples
ahead = 3;

x = linspace(0, 2 * pi, T);
data = sin(x);
data = repmat(data, [1 1 nex]);
noise = randn(O, T, nex) * 0.05;
trainSplit = 20;

data = data + noise;

%plot data
for i = 1:nex
    plot(x, data(1, :, i));
    hold on
end
xlim([0, 2 * pi]);

%Format the data
%Way one
%Each element of the cell array is a time step of signal dimension by
%number of samples
%total number of cells is the length of all time series
%10x1x40 cell
cdata = {};

for i = 1:size(data, 2)
    cdata{i} = reshape(data(1, i, :), size(data, 1), size(data, 3));
end

%SETUP THE MODEL
timeDelay = 5;
hiddenNodes = 6;
net = timedelaynet(1:timeDelay, hiddenNodes);
 
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

[xs, xi, ai, ts] = preparets(net, cdata(:, 1:end - ahead), cdata(:, ahead + 1:end));
netAhead = train(net, xs, ts, xi, ai);
[xs, xi, ai, ts] = preparets(net, cdata(:, 1:end - 1), cdata(:, 1 + 1:end));
net1 = train(net, xs, ts, xi, ai);

modelTDNN = bcf.models.TDNN(net1, netAhead, ahead);
%modelTDNN.calculateNoiseDistribution(data(1, 1:end, :));

hold off
for i = 1:size(data, 3)
    out = modelTDNN.forecastAll(data(:, :, i), ahead);
    plot(x, [data(1, :, i); out(1, :)]);
    hold on
end
xlim([0, 2 * pi]);
