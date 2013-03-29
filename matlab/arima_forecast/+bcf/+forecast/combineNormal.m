function output = combineNormal(dist, probs, h)
    
    xmax = dist(:, 1)';
    dataMax = zeros(1, size(dist, 1));

    for i = 1:size(dist, 1)
        dataMax(1, :) = dataMax(1, :) + (probs(1, i) .* ...
                bcf.forecast.kernel((xmax), dist(i, 1), dist(i, 2), h))';
    end

    output = max(dataMax);
end

