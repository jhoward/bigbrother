function pmf = estimatePmf(x, w)
% Estimate the pmfs of the mixture components,
% assuming you know w. We want to find p(x|aj) for each j.

d = size(x,1);
m = size(x,2);
k = size(w,1);
M = max(x(:))+1;

% The meaning is:  pmf(i,n,j) = probability of having i-1 counts, on
% dimension n, given activity j;  p(xn=i-1|aj)
pmf = zeros(M,d,k);

for j=1:k
    %fprintf('Activity %d\n', j);
    
    % The set of xi's belonging to activity j are a good estimate of
    % the pmf of activity j:   p(x|aj) = {xi p(aj|xi)}
    pj = zeros(M,d);
    
    for n=1:d
        for v=1:M
            % We will find the number of occurences of value v-1 in
            % dimension n, in the entire set of points xi.
            for i=1:m
                if x(n,i) == v-1
                    % Increment count, weighted by p(aj|xi)
                    pj(v,n) = pj(v,n) + w(j,i);
                end
            end
        end
    end
    
    % Normalize.  Each column of pj should sum to 1.
    pj = pj/sum(w(j,:));
    
    % Save in the pmf structure
    pmf(:,:,j) = pj;
end
    
return
