clear all;
%Distribution test
points = 100;
dist = [[2 0.3]; [5 6]; [4 1]];
distProb = [0.1 0.45 0.45];
data = zeros(size(dist, 1) + 2, points);
h = 1.8;

x = linspace(-2, 12, points);
for i = 1:size(dist, 1)
    data(i, :) = mvnpdf(x', dist(i, 1), dist(i, 2));
    data(end - 1, :) = data(end - 1, :) + (distProb(i) .* mvnpdf(x', dist(i, 1), dist(i, 2)))';
end

%Kernel estimate
for i = 1:size(dist, 1)
    data(end, :) = data(end, :) + 1/h .* (distProb(i) .* kernel((x - dist(i, 1))/h, dist(i, 1), dist(i, 2)))';
end

%data(end, :) = kernel(x, dist(1, 1), dist(1, 2));

plot(x, data);