function p = posscdf(x,lambda)
%POISSCDF Poisson cumulative distribution function.
%	P = POISSCDF(X,LAMBDA) computes the Poisson cumulative
%	distribution function with parameter LAMBDA at the values in X.
%
%	The size of P is the common size of X and LAMBDA. A scalar input   
%	functions as a constant matrix of the same size as the other input.	 

%	References:
%	   [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%	   Functions", Government Printing Office, 1964, 26.1.22.

%	Copyright (c) 1993 by The MathWorks, Inc.
%	$Revision: 1.1 $  $Date: 1993/05/24 18:55:50 $
 
if nargin < 2, 
    error('Requires two input arguments.'); 
end

scalarlambda = (prod(size(lambda)) == 1);

[errorcode x lambda] = distcheck(2,x,lambda);

if errorcode > 0
    error('The arguments must be the same size or be scalars.');
end

% Initialize P to zero.
p = zeros(size(x));

% Return NaN if Lambda is not positive.
k = find(lambda <= 0);
if any(k)
    p(k) = NaN * ones(size(k));
end

% Compute P when X is positive.
xx = floor(x);
k = find(xx >= 0 & lambda > 0);
val = max(max(xx));

if scalarlambda
    tmp = cumsum(posspdf(0:val,lambda(1)));            
    p(k) = tmp(xx(k) + 1);
else
     i = [0:val]';
        compare = i(:,ones(size(k)));
        index(:) = xx(k);
        index = index(:,ones(size(i)))';
        lambdabig(:) = lambda(k);
        lambdabig = lambdabig(:,ones(size(i)))';
        p0 = posspdf(compare,lambdabig);
        indicator = find(compare > index);
        p0(indicator) = zeros(size(indicator));
        p(k) = sum(p0);
end 

% Make sure that round-off errors never make P greater than 1.
k = find(p > 1);
p(k) = ones(size(k));