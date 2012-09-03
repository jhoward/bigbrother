function correlation = calcCorrelation(data, offset)
data = data(:, 2:size(data, 2));
correlation = linearCorrelation(data, offset);
