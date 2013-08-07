%testMultinomial.m

numModels = 2;
modelLen = 2;
minLen = 1;
winSize = 2;

%Setup all possibility hash table and initialize
keys = {mat2str([0;0])};
values = {0};

p = containers.Map(keys, values);

for i = 1:numModels
    for j = 1:modelLen
        p(mat2str([i;j])) = 1;
    end
end

%Now count instances