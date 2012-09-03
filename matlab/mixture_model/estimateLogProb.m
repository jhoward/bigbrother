function [px,logProb] = estimateLogProb(x, w, f, pmf)
% Estimate log probability of the dataset
% Also returns:  px = p(xi) for all xi


d = size(x,1);
m = size(x,2);
k = size(w,1);

px = zeros(m,1);

logProb = 0;
for i=1:m
    % Sum over j: p(xi,aj) = p(xi|aj)p(aj|xi)
    %  or should this be
    %   p(xi,aj) = p(xi|aj)p(aj)?
    pxi = 0;
    for j=1:k
        % Assuming the dimensions are independent, the total prob is
        % just the product of the prob for each dimension
        p = 1.0;
        for n=1:d
            v = x(n,i);     % The value of xi for this dimension
            p = p * pmf(v+1,n,j);
        end
        %pxi = pxi + p * w(j,i);     % which is right?
        pxi = pxi + p * f(j);
    end
    px(i) = log(pxi);
    logProb = logProb + log(pxi);
end     % end for i=1:m

return

