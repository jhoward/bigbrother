clear all;
window = 5;
dataSize = 100;

%Dataset
x=1:1:dataSize;
nn = randn(1, dataSize);
x = x + nn;

data              = x(1:end-1);
output            = x(2:end);
dataWindows       = zeros(window, dataSize - 1 - window);
for i = 1:dataSize - 1 - window
    dataWindows(:, i) = data(1, i:i + window - 1);
end
outputWindows     = x(1 + window:end);

trainDataLength   = round(length(data)*70/100);
trainWinLength    = trainDataLength - window;
trainOutput       = output(1 + window:trainDataLength);
trainWin          = dataWindows(:, 1:trainWinLength);
testOutput        = output(trainDataLength+1 + window:end);
testWinLength     = dataSize - trainDataLength - window;
testWin           = dataWindows(trainDataLength+1:end);

options = ' -s 3 -t 2 -c 1 -p 0.001 -h 0';
model   = svmtrain(TrainingSetLabels, TrainingSet, options);

[predicted_label, accuracy, decision_values] = svmpredict(TestSetLabels,TestSet, model);

predicted_label
accuracy
decision_values