%testMultinomial.m

clear all;

numModels = 2;
modelLen = 2;
minLen = 1;
winSize = 2;

%Index for keys is dim 1 - model        dim 2 - model offset

%Setup all possibility hash table and initialize
%Don't use num2str - it doesn't work with containers.Map

keys = {mat2str([0;0])};
values = {0};

p = containers.Map(keys, values);

for i = 1:numModels
    for j = 1:modelLen
        p(mat2str([i;j])) = 1;
    end
end

%Now count instances
foo = [2 1;2 2];

valid = getValid(foo, numModels, modelLen, minLen);