clear all;
close all;

mean = 5;

xvals = 0:mean*3;
pdf = posspdf(xvals, mean);plot(xvals, pdf);
pdf2 = myposspdf(xvals, mean);figure,plot(xvals, pdf2);
cdf = posscdf(xvals, mean);

for n = 1:10000
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
    
    if k > length(xvals)
        k = length(xvals);
    end

    data(n) = xvals(k);
end

h = hist(data, xvals);
figure,plot(h);
