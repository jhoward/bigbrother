function y = posspdf(x,lambda)
%POISSPDF Poisson probability density function.
%	Y = POISSPDF(X,LAMBDA) returns the Poisson probability density 
%	function with parameter LAMBDA at the values in X.
%
%	The size of Y is the common size of X and LAMBDA. A scalar input   
%	functions as a constant matrix of the same size as the other input.	 
%
%	Note that the density function is zero unless X is an integer.

%	References:
%	   [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%	   Functions", Government Printing Office, 1964, 26.1.22.

%	Copyright (c) 1993 by The MathWorks, Inc.
%	$Revision: 1.1 $  $Date: 1993/05/24 18:55:56 $

if nargin <  2, 
    error('Requires two input arguments.'); 
end

[errorcode x lambda] = distcheck(2,x,lambda);

if errorcode > 0
    error('The arguments must be the same size or be scalars.');
end

y = zeros(size(x));

k1 = find(lambda <= 0);
if any(k1) 
    y(k1) = NaN * ones(size(k1));
end 

k = find(x >= 0 & x == round(x) & lambda > 0);
if any(k)
    y(k) = exp(-lambda(k) + x(k) .* log(lambda(k)) - gammaln(x(k) + 1));
end