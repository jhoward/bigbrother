clear all;

%how far to look back not actual window size.  Window size will be this
%value + 1;
minWindow = 3;
maxWindow = 9;

lengths = [10 10 5];
noiseStds = [0.2 0.2 0.5];

yA = generateData(lengths(1), 15, 1, noiseStds(1));
yB = generateData(lengths(2), 15, 2, noiseStds(2));

%%Generate model for data
modelA = Average(lengths(1));
modelA.train(yA);

modelB = Average(lengths(2));
modelB.train(yB);

models = {modelA; modelB};

y = [];
yT = [];
for i = 1:30
    type = floor(rand * 3) + 1;
    yT = [yT ones(1, lengths(type)) * type];
    y = [y generateData(lengths(type), 1, type, noiseStds(type))];
end

yp = zeros(size(y));
ybm = zeros(size(y));
ybw = zeros(size(y));

%Compute probs first
for i = maxWindow + 1:size(y, 2) - 1;
    
    %i
    %Can't comput not all models so instead we just pick from all
    %candidates.  If none are above a threshold then forecast some value
    
    currentProbs = zeros(length(models), maxWindow - minWindow);
    
    %Go through all models
    for m = 1:length(models)
        for t = minWindow:maxWindow
            currentProbs(m, t - minWindow + 1) = models{m}.likelihood(y(i - t:i));
        end
    end
    
    %forecast the data
    [~, win] = max(max(currentProbs));
    [~, m] = max(currentProbs(:, win));

    ybm(1, i + 1) = m;
    ybw(1, i + 1) = win + minWindow - 1;
    
    yp(1, i + 1) = models{m}.forecastSingle(y(i - minWindow - win + 1:i), 1);
end

plot([y(1, 2:100); yp(1, 2:100)]');