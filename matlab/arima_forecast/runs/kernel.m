function output = kernel( data, mu, sigma )
    output = (1/sigma^0.5) .* mvnpdf((data' - mu) / (sigma^0.5), 0, 1);
end

