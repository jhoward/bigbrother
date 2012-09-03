function [ data, means, vars, bink ] = CreateData(K, D, N)
    %Create K d-dimensional gaussians then create N data points

   %means = rand(D,K)*8 + 10;     % Means
   vars = [];
   
   means = [20  10;
            10  20;
            5   5];
            
    %Create the z array
    bink = char(dec2bin(1, K));

    for k = 2:2^K - 1
        bink = char(bink, dec2bin(k, K));
    end

    %Now create the data
    for n=1:N
        
        %Generate the combination by which to create the data
        u = floor(rand * (length(bink))) + 1;
        value = bink(u, :);

        totalMean = zeros(1, D);
        %totalVariance = zeros(D, D);

        for j = 1:K
            if value(j) == '1'
                totalMean = totalMean + means(:, j)';
                %totalVariance = totalVariance + vars(:, :, j);
            end
        end
        
        tempPoint = zeros(D, 1);
        
        for d = 1:D
            xvals = 0:totalMean(d)*3;
            cdf = posscdf(xvals, totalMean(d));
        
            % Pick a value according to probability cdf
            u = rand;       % get number between 0 and 1
            v = u>cdf;       % get 1's where u is greater than Cw
            i = find(v, 1, 'last'); % get highest index
        
            % Corresponding value of k
            if isempty(i)
                k = 1;
            else
                k = i+1;
            end
            
            tempPoint(d) = xvals(k);
        end   
        
        data(:,n) = tempPoint;
    end
end

