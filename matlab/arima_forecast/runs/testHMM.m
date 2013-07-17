clear all;

%Output data
O = 1; %Number of dimensions
T = 10; %Time series length
nex = 40; %Number of examples
x = linspace(0, pi, T);
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
xlim([0, pi]);

M = 2; %Number of Gaussians
Q = 20; %Number of states

model = bcf.models.HMM(Q, M);
model.train(data(:, :, 1:trainSplit));

model.calculateNoiseDistribution(data(:, :, trainSplit));

%Modify and test transition matrix
%model.transmat(model.transmat < 0.005) = 0.005;
%model.transmat = normalize(model.transmat, 2);
model.prior(model.prior < 0.001) = 0.001;
model.prior = normalize(model.prior);

output = data(:, :, trainSplit + 1:end);
for i = 1:1%size(output, 3)
    output(:, :, i) = model.forecastAll(output(:, :, i), 1, 'window', 4);
end

for i = 1:size(output, 3)
    plot(x, [data(:, :, trainSplit + i); output(:, :, i)]);
    hold on
end

%Test crap data
crap = -1 * (x .* x);
crapOut = model.forecastAll(crap, 1, 'window', 4);
plot(x, [crap; crapOut]);
