function value = mase(x, y)
%Compute the Mean Absolut Scaled Error (MASE) between an dataset x and a 
%set of forecast values y

e = sum(abs(x - y));
naiveDiff = sum(abs(x(1:end - 1) - x(2:end)));
naiveDiff = naiveDiff * (size(x, 2) / (size(x, 2) - 1));

value = e / naiveDiff;
end

