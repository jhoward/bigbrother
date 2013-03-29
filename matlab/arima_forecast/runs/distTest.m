clear all;
%Distribution test
points = 1000;
dist = [[2 0.3]; [5 5]; [4 3]];
distProb = [0.1 0.45 0.45];
%data = zeros(size(dist, 1) + 2, size(dist, 1));
data = zeros(size(dist, 1) + 2, points);
h = 2;

x = linspace(-2, 12, points);
for i = 1:size(dist, 1)
    data(i, :) = mvnpdf(x', dist(i, 1), dist(i, 2));
    data(end - 1, :) = data(end - 1, :) + (distProb(i) .* mvnpdf(x', dist(i, 1), dist(i, 2)))';
end

%Kernel estimate
for i = 1:size(dist, 1)
    data(end, :) = data(end, :) + (distProb(1, i) .* kernel((x), dist(i, 1), dist(i, 2), h))';
end

plot(x, data);

xmax = dist(:, 1)';
dataMax = zeros(1, size(dist, 1));

for i = 1:size(dist, 1)
    dataMax(1, :) = dataMax(1, :) + (distProb(1, i) .* kernel((xmax), dist(i, 1), dist(i, 2), 1))';
end

[val, ind] = max(dataMax);

m = bcf.forecast.combineNormal(dist, distProb, h);

fprintf(1, 'Max is at %f.  Value is %f  combineNormal returns %f\n', dist(ind, 1), val, m);

fprintf(1, 'Current approach Expected Value:%f\n', 2*.1 + 5*.45 + 4*.45);
%eMax = (dataMax ./ sum(dataMax)) * dist(:, 1);
%fprintf(1, 'Expected Value using only maxes: %f \n', eMax);
dDist = data(end - 1, :);
eMax = (dDist ./ sum(dDist)) * x';
fprintf(1, 'Expected Value using whole sample space: %f \n', eMax);

