clear all;

O = 1; %Number of dimensions
T = 10; %Time series length
nex = 40; %Number of examples
x = linspace(0, pi, T);
data = sin(x);
data = repmat(data, [1 1 nex]);
noise = randn(O, T, nex) * 0.05;
trainSplit = 20;

data = data + noise;

M = 2; %Number of Gaussians
Q = 20; %Number of states

model = bcf.models.HMM(Q, M);
model.train(data(:, :, 1:trainSplit));

model.calculateNoiseDistribution(data(:, :, trainSplit));

%Modify and test transition matrix
%model.transmat(model.transmat < 0.01) = 0.01;
%model.transmat = normalize(model.transmat, 2);

output = data(:, :, trainSplit + 1:end);
for i = 1:size(output, 3)
    output(:, :, i) = model.forecastAll(output(:, :, i), 1, 'window', 3);
end

for i = 1:size(output, 3)
    plot(x, [data(:, :, trainSplit + i); output(:, :, i)]);
    hold on
end

%Test noisy data
noisy = sin(x);
noisy = noisy + randn(O, T, 1) * 0.3;

noisyOut = model.forecastAll(noisy, 1);

plot(x, [noisy; noisyOut]);