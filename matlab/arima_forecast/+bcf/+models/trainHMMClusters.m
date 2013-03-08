clear all;
%Make multiple classes of data.
obsTotal = 30;
obsLength = 10;
nStates = 8;
data = zeros(obsTotal, obsLength);
x = linspace(0, 2*pi, obsLength);


for i = 1:obsTotal
    data(i, :) = sin(x) + 0.1*rand;
end

data = num2cell(data, 2);

for i = 1:size(data, 1)
    data{i} = data{i}';
end

[model llh] = hmmFit(data, nStates, 'gauss');

[obs hid] = hmmSample(model, 20, obsLength);

x = linspace(1, obsLength, obsLength);
xflip = [x(1 : end - 1) fliplr(x)];
for i = 1:20
    y = hid{i}
    yflip = [y(1 : end - 1) fliplr(y)];
    patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
    hold on
end