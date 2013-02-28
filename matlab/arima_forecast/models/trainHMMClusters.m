clear all;
%Make multiple classes of data.
actTotal = 30;
numActs = 2;
actLength = 8;
nStates = actLength;
data = zeros(numActs * actTotal, actLength);
x = linspace(0, 4, actLength);


for i = 1:numActs*actTotal
        if floor(i/actTotal) == 0
            data(i, :) = sin(x) + 0.1*rand;
        end
        
        if floor(i/actTotal) == 2
            data(i, :) = x + 0.1*rand;
        end
end

data = num2cell(data, 2);

% for i = 1:size(data, 1)
%     data{i} = data{i}';
% end

[model llh] = hmmFit(data, nStates, 'gauss', 'nRandomRestarts', 5);