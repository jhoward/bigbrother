function output = kernel(data, mu, sigma, h)
    dt = (data' - mu) ./ h; 
    output = (1/h) .* (1/sigma^0.5) .* mvnpdf(dt ./ (sigma^0.5), 0, 1);
end
