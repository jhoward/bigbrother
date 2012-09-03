function [ likelihood ] = calcLikelihood( x, z, f, d, m, k, lBackground, l)
    likelihood = 0;
    
    for i = 1:m
        % Compute p(xi,zb) = p(xi|zb) p(zb) for all values of b
        pxizb = zeros(2^k,1);
        for b = 1:size(z,2)
            zb = z(:,b);    % zb contains 1's where activity is present
            %fprintf('combination b=%d\n', b);
            %disp('zb:'); disp(zb);

            pzb = f(b);
            %fprintf('pzb = %f\n', pzb);

            % Find p(xi|zb). First find the expected rate vector, given the
            % specified combination of activities in zb. This produces a
            % (d,k) matrix where column j is either 1 if activity j is
            % present, or 0 if it is not.
            mask = ones(size(l)) * diag(zb);
            lb = mask .* l;     % Set to zero any rates not present
            lb = sum(lb,2) + lBackground;  % Sum rates along each dimension
            %disp('Expected rate vector lb:'); disp(lb);

            % For each dimension n, find the probability that count xni
            % could have been produced by a Poisson with rate parameter
            % lb(n).  The total probability for this count vector is the
            % product of all of them (assuming dimensions are independent).
            p = 1.0;
            for n = 1:d
                p = p * evaluatePoisson(x(n,i), lb(n));
            end
            %fprintf('p(xi|zb) = %f\n', p);
            pxizb(b) = p*pzb;
        end
        
        likelihood = likelihood + log(sum(pxizb));
    end
end

