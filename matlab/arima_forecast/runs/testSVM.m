clear all;
window = 5;
dataSize = 100;

%Dataset
x=1:1:dataSize;
nn = randn(1, dataSize);
x = x + nn;

xx=1:1:dataSize;
nn = randn(1, dataSize);
xx = xx + nn;

%plot(x)

data         = x(1:end-1);
y            = x(2:end);
xWin         = zeros(window, dataSize - 1 - window);
for i = 1:dataSize - window
    xWin(:, i) = data(1, i:i + window - 1);
end
yWin         = x(1 + window:end);

data         = xx(1:end-1);
yy           = xx(2:end);
xxWin        = zeros(window, dataSize - 1 - window);
for i = 1:dataSize - window
    xxWin(:, i) = data(1, i:i + window - 1);
end
yyWin        = xx(1 + window:end);


options = ' -s 3 -t 2';
model   = svmtrain(yWin', xWin', options);

[predOut, accuracy, decision_values] = svmpredict(yyWin', xxWin', model);

predOut

plot(1:1:(dataSize - window), [yyWin; predOut']);