function Q = computeLogProb(lBackground, l, x, w, z)
% Compute log probability of whole dataset using the given parameters.
% Note:  this algorithm isn't really correct because all I am doing is
% taking the combination that has the maximum probability for each point.
% You should really sum over all combinations.

d = size(x,1);  % number of dimension
m = size(x,2);  % number of points

Q = 0;
for i=1:m
    xi = x(:,i);
    [~,b] = max(w(:,i));
    
    indices = find(z(:,b));             % Get activity #s
    lb = lBackground + sum(l(:,indices),2);     % Mean of this combination
    
    p = 1.0;
    for id=1:d
        p = p * evaluatePoisson(x(id,i), lb(id));
    end
    
    Q = Q + log(p);
end

return
