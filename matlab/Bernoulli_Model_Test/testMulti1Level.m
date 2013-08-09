%testMulti1Level.m

clear all;

lengths = [10 10 5];
noiseStds = [0.2 0.2 0.5];
cdf = [0.1 0.2 1];
ahead = 1;

yA = generateData(lengths(1), 15, 1, noiseStds(1));
yB = generateData(lengths(2), 15, 2, noiseStds(2));

%%Generate model for data
modelA = Average2(lengths(1));
modelA.train(yA);

modelB = Average2(lengths(2));
modelB.train(yB);

models = {modelA; modelB};

y = [];
yT = [];
for i = 1:100
    type = find(cdf >= rand);
    type = type(1);
    %type = floor(rand * 3) + 1;
    yT = [yT ones(1, lengths(type)) * type];
    y = [y generateData(lengths(type), 1, type, noiseStds(type))];
end

%Iterate through data and compute probabilities

maxL = 10;
tc = 21;

prior = {ones(1, 10), ones(1, 10), ones(1, 1)};
sp = sum(cellfun(@sum, prior));
prior = cellfun(@(n)n./sp, prior, 'UniformOutput', false);

%Loop through all data
for t = 1:1%size(y, 2) - horizon

    ftmp = zeros(tc, 1);
    ptmp = zeros(tc, 1);
    
    total = 1;
    %Convert the prior into a matrix 
    %do this better later
    for m = 1:size(prior, 2)
        ptmp(total:total + size(prior{m}, 2) - 1) = prior{m}'; 
        total = total + size(prior{m}, 2);
    end
    
    total = 1;
    %Forecast based on prior
    for m = 1:size(prior, 2)
        for j = 1:size(prior{m}, 2)
            ftmp(total) = models{m}.forecastSingle(j, ahead);
            total = total + 1;
        end
    end
    
    %Given p(a^(t)_(j)|x^(t), ..., x^(1))
    %then p(a^(t + 1)_(j + 1)|x^(t), ..., x^(1)) 
    
    %First compute p(x^(t + 1)|a_(j + 1), x^(t), ..., x^(1))
    p

end

