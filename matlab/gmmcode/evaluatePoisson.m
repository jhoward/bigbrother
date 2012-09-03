function p = evaluatePoisson(k, l)
% Evaluate the Poisson distribution with count = k and rate parameter l.
% Note the parameter is "L" not a "one".

% Link to the array "factorialValues", where factorialValues(n+1) is the
% factorial of n (that way you can accomodate the factorial of 0).
global factorialValues

% For large rate or large counts, the normal distribution (with 
% mean=l and variance=l) is a good approximation to the Poisson and 
% avoids overflow.
if l > 100 || k >= length(factorialValues)
    p = exp( -((k-l)^2)/(2*l) ) / sqrt(2*pi*l);
else
    %p = (l^k)*exp(-l)/myfactorial(k);
    p = (l^k)*exp(-l)/factorialValues(k+1);
end

end