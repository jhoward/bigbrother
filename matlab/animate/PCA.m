clear all
close all

%Load the data
load mat/synthData.mat

patHeight = 3;
dict = zeros(size(data, 1) - patHeight + 1, (size(data, 2) - 1) * patHeight);
minusDict = {};
plusDict = {};

    
%Number of dimensions to use for PCA
p = 3;

%Initialize Minus and plus dict
for i = 1:size(data, 2) - 1
    minusDict{i} = {};
    plusDict{i} = {};
end;
    


%First generate the patterns to determine PCA
for i = 1:size(data, 1) - patHeight + 1
    
    runVector = [];    
    
    for j = 1:patHeight     
        vector = data(i+j - 1, 2:size(data, 2));
        runVector = [runVector vector];
    end;
    
    if i + patHeight < size(data, 1)
        
        for k = 2:size(data, 2)
            if data(i + patHeight, k) == 0
                minusDict{k - 1}{size(minusDict{k-1}, 2) + 1} = runVector;
            else
                plusDict{k - 1}{size(plusDict{k - 1}, 2) + 1} = runVector;
            end;
        end;
    end;
    
    dict(i, :) = dict(i) + runVector;
end;

x = 4;

dict = []

for i = 1:size(plusDict{x}, 2)
    
    dict = [dict; plusDict{x}{i}];
end;

dict


%Next determine the mean vector
u = mean(dict,1);
dict = dict - repmat(u,size(dict, 1), 1);


[U,S,V] = svd(dict);

hold on;




%Run p dimensional PCA
for i = 1:size(minusDict{x}, 2)

    pointApprox = V(:, 1:p);
    point = minusDict{x}{i};
    pointApprox = pointApprox' * ((point - u)');
    pointApprox;
    plot3(pointApprox(1), pointApprox(2), pointApprox(3), '*r');
    grid on
    axis square
end;

fprintf(1, 'Ones\n');

%Run p dimensional PCA
for i = 1:size(plusDict{x}, 2)

    pointApprox = V(:, 1:p);
    point = plusDict{x}{i};
    pointApprox = pointApprox' * ((point - u)');
    pointApprox;
    plot3(pointApprox(1), pointApprox(2), pointApprox(3), '+b');
    grid on
    axis square
end;

hold off;

