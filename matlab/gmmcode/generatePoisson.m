function v = generatePoisson(r)
% Generate a vector of values at random according to a Poisson
% distribution.  Each component vi of the vector (assumed independent) is a
% sample of a Poisson distribution with rate parameter ri.

% % Link to the array "factorialValues", where factorialValues(n+1) is the
% % factorial of n (that way you can accomodate the factorial of 0).
% global factorialValues

d = length(r);  % Number of dimensions in the vector.
v = zeros(d,1);

for i=1:d
    ri = r(i);
    
    % For large rate, the normal distribution (with mean=r and variance=r)
    % is a good approximation to the Poisson and avoids overflow.
    if ri > 100
        vi = ri + sqrt(ri)*randn(1);
        if vi < 0
            vi = 0;
        end
    else
        % Create the pdf for all possible values of vi.
        VMAX = round(3*ri);     % Truncate beyond 3*lambda
        pdf = zeros(VMAX+1,1);
        vVals = 0:VMAX;
        for j=1:VMAX+1
            vj = vVals(j);
            %pdf(j) = (ri^vj)*exp(-ri)/factorialValues(vj+1);
            pdf(j) = evaluatePoisson(vj,ri);
        end
        
        % Construct the cdf (cummulative distribution)
        cdf = cumsum(pdf);
        
        u = rand;       % get number between 0 and 1
        
        % Find the closest value to x in the cdf table
        %[~,index] = min(abs(u-cdf));
        %keyboard
        
        temp = u>cdf;       % get 1's where u is greater than Cw
        ind = find(temp, 1, 'last'); % get highest index

        % Corresponding value of k
        if isempty(ind)
            k = 1;
        else
            k = ind+1;
        end
        
        if k >= size(vVals, 2)
            k = size(vVals, 2) - 1;
        end;

        vi = vVals(k);
    end
    
    v(i) = vi;
end
