function probs = myposspdf( xvals, lambda )
    probs = zeros(1, length(xvals));
    for i = 1:length(xvals)
        x = xvals(i);
        
        probs(i) = (lambda(i)^x*exp(-lambda(i)))/factorial(x);
    end
end

