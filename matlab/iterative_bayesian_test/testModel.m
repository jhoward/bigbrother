clear all;

ahead = 1;

lengths = [10 10 1];
backgroundLen = 10;
noiseStds = [0.15 0.15 0.3];
priorCDF = [0.1 0.2 1];

modelConstants = [0.01, 0.01];

yA = generateData(lengths(1), 15, 1, noiseStds(1));
yB = generateData(lengths(2), 15, 2, noiseStds(2));
yC = generateData(lengths(3), 15, 3, noiseStds(3));

%%Generate model for data
% modelA = Average(lengths(1));
% modelA.train(yA);
% 
% modelB = Average(lengths(2));
% modelB.train(yB);

%Models for HMMs
%For now reshape the data to work with HMM
tmpA = reshape(yA, 1, 10, size(yA, 2)/10);
tmpB = reshape(yB, 1, 10, size(yB, 2)/10);

modelA = HMM(lengths(1)*5, 2);
modelB = HMM(lengths(1)*5, 2);
modelA.train(tmpA);
modelB.train(tmpB);


foo = modelA.sampleData(lengths(1), 15);
tmpA = reshape(yA, 10, size(yA, 2)/10);
tmpA = tmpA';
% 
% hold on
% for i = 1:size(tmpA, 2)
%     %plot(1:1:10, tmpA(1, :, i), 'Color', 'b');
%     plot(1:1:10, tmpA(i, :), 'Color', 'b');
%     plot(1:1:10, foo(1, :, i), 'Color', 'g');
% end
% %plot(1:1:10, modelA.avgValues(1, :), 'Color', 'g');
% hold off

%Perform a forecast for each data element
hold on
for i = 1:size(tmpA, 2)
    tmpFoo = modelA.forecastAll(tmpA(i, :), 1, 'window', 0);
    plot(1:1:10, tmpA(i, :), 'Color', 'b');
    plot(1:1:10, tmpFoo(1, :), 'Color', 'g');
end
hold off


backModel = Average(1);
backModel.noiseValues = [noiseStds(1, end)];
backModel.avgValues = [0];

models = {modelA; modelB; backModel};

y = [];
yT = [];
for i = 1:50
    type = min(find(rand <= priorCDF));
    typeLen = lengths(type);
    if type == size(lengths, 2)
        typeLen = backgroundLen;
    end
    yT = [yT ones(1, typeLen) * type];
    y = [y generateData(typeLen, 1, type, noiseStds(type))];
end

yp = zeros(size(y));

p = {};

%p = ones(size(lengths));

l = {};
post = {};
for j = 1:size(lengths, 2)
    p{j} = ones(1, lengths(j));
    l{j} = ones(1, lengths(j));
    post{j} = ones(1, lengths(j));
end

cellTotal = sum(cellfun(@sum, p));
p = cellfun(@(v)v./cellTotal, p, 'UniformOutput', false);


%TODO attempt this with model based prior later instead of prior per model
%unit. work with this being an array instead of a cell model.
%p = p ./ sum(p, 2);

%Go through whole dataset
for t = 11:300%size(y, 2) - ahead
    
    %compute model likelihoods
    for m = 1:length(models)
        for j = 1:lengths(1, m)
            %l{m}(1, j) = models{m}.likelihood(y(1, t), j);
            l{m}(1, j) = models{m}.likelihood(y(1, t - j + 1:t), j);
        end    
    end
    
    %compute posteriors
    
    %p(m|y) = p(y|m)p(m)/p(y)
    for m = 1:length(models)
        for j = 1:lengths(1, m)
            post{m}(1, j) = l{m}(1, j) * p{m}(1, j);
        end
    end
    
    for m = 1:length(models)
        post{m}(post{m} <= 0.00001) = 0.00001;
    end
    
    %normalize
    cellTotal = sum(cellfun(@sum, post));
    post = cellfun(@(v)v./cellTotal, post, 'UniformOutput', false);
            
    %Update the priors
    for m = 1:length(models)
        for j = 2:lengths(1, m)
            p{m}(1, j) = post{m}(1, j - 1);
        end
        if m < length(models)
            p{m}(1, 1) = modelConstants(1, m);
        end
    end
    
    %normalize priors
    cellTotal = sum(cellfun(@sum, p));
    p = cellfun(@(v)v./cellTotal, p, 'UniformOutput', false);
    
    %forecast based weighted posteriors
    for m = 1:length(models)
        for j = 1:lengths(1, m)
            yp(1, t + ahead) = yp(1, t + ahead) + models{m}.forecastSingle(j, ahead) * post{m}(1, j);
        end
    end    
end

plot(1:1:300, [y(1, 1:300); yp(1, 1:300)]);
