clear all;

lengths = [20 20 5];
noiseStds = [0.2 0.2 0.5];

yA = generateData(lengths(1), 15, 1, noiseStds(1));
yB = generateData(lengths(2), 15, 2, noiseStds(2));

%%Generate model for data
modelA = Average(lengths(1));
modelA.train(yA);

modelB = Average(lengths(2));
modelB.train(yB);

y = [];
yT = [];
for i = 1:30
    type = floor(rand * 3) + 1;
    yT = [yT ones(1, lengths(type)) * type];
    y = [y generateData(lengths(type), 1, type, noiseStds(type))];
end

%Now compute the model
%GAHHHH Rewrite this

%Compute probs first
for i = size(y, 2)
    
end