clear all;
window = 10;
dataSize = 100;

%Dataset
x=1:1:dataSize;
nn = randn(1, dataSize);
x = x + nn;

xx=1:1:dataSize;
nn = randn(1, dataSize);
xx = xx + nn;

x = normalize(x);
xx = normalize(xx);

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

%options = ' -s 4 -t 2';
options = '-s 3 -t 2 -c 100 -p 0.001 -h 0'
model   = svmtrain(yWin', xWin', options);

[predOut, accuracy, decision_values] = svmpredict(yyWin', xxWin', model);

plot(1:1:(dataSize - window), [yyWin; predOut']);