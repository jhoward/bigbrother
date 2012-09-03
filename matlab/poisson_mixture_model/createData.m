function [x,fTrue,lBackgroundTrue,lTrue,wTrue] = createData(k,d,m)
% Create synthetic data

% Probability of each combination of activities occuring (sums to 1)
% fTrue = rand(2^k,1);
fTrue = ones(2^k,1);
fTrue = fTrue/sum(fTrue);  % Force to sum to 1

% Define rate for each of the k activities, for each of the d dimensions. l
% (note "L", not "one") is of size (d,k).
lTrue = 20.0 * rand(d,k);
% Also have the background activity
%lBackgroundTrue = 1.0 * ones(d,1);
lBackgroundTrue = 4.0 * rand(d,1);

% Create binary numbers with k bits.  We'll need this later.
% z has size (2^k,k).  The rows are 0000,0001,0010,...,1111.
z = binary(k);
% Make least signif bit the leftmost, so rows are 0000,1000,0100,...,1111
z = fliplr(z);
% Transpose z, so it has size (k,2^k).  Columns are now 0000,1000,...,1111
z = z';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create observed data from ground truth params

% Pre-allocate data storage
yBackgroundTrue = zeros(d,m);   % Background activity for each point
yTrue = zeros(d,m,k);           % Foreground activities, each point
wTrue = zeros(2^k,m);   % Indicators (wbi = 1 if combination b in sample i)

for i=1:m
    li = zeros(d,1);    % Rate vector (size dx1) for this sample.
    
    % Decide which combination of activities is present in this sample.
    cdf = cumsum(fTrue);    % Get the cdf (cummulative distribution)
    
    % Ok, pick a random number between 0 and 1.
    r = rand;
    
    % Find the places in the cdf where r is bigger.
    v = (r > cdf);  % v is a vector of 1's, and then 0's
    index = find(v, 1, 'last');     % Find the index of the highest 1
    % Corresponding value of b
    if isempty(index)
        b = 1;
    else
        b = index+1;
    end
    
    zb = z(:,b);    % This is the combination we want
    wTrue(b,i) = 1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generate the background activity counts.
    v = generatePoisson(lBackgroundTrue);
    % Round to integer and clip to zero, since counts must be non-negative
    % integers.
    yBackgroundTrue(:,i) = max( zeros(d,1), round(v) );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generate the foreground activity counts.
    indices = find(zb);     % Get indices of activities that are present
    for index=1:length(indices)
        j = indices(index);
        li = lTrue(:,j);
        
        v = generatePoisson(li);
        yTrue(:,i,j) = max( zeros(d,1), round(v) );
    end
end

% disp(' ');
% yBackgroundTrue
% disp(' ');
% yTrue
% disp(' ');

%%%%%%%%%%%%%%%%%%%%
% Sum activities for each point
x = zeros(d,m);         % Actual observed counts go in here
for i=1:m
    b = find(wTrue(:,i));   % Get combination number (1..2^k)
    zb = z(:,b);
    
    indices = find(zb);     % Get indices of activities that are present
    yPresent = yTrue(:,i,indices);  % Counts from activities present
    yPresent = squeeze(yPresent);   % Collapse singleton index (i)
    
    x(:,i) = yBackgroundTrue(:,i) + sum(yPresent,2);
end

%%%%%%%%%%%%%%%%%%%%
% Since my generated values may be a little off, recalculate them based on
% the values I actually generated.
fTrue =  (1/m)*sum(wTrue,2);
lBackgroundTrue = mean(yBackgroundTrue, 2);     % Take mean of dimension 2

for j=1:k
    yj = [];  % Get all instances for activity j
    for i=1:m
        b = find(wTrue(:,i));   % Get combination number (1..2^k)
        zb = z(:,b);
        
        if zb(j)
            % Add vector for activity j, from point i
            yj = [yj yTrue(:,i,j)];
        end
    end
    
    % Calculate true mean and covariance of activity j
    lTrue(:,j) = mean(yj,2);
end


disp('Actual ground truth values:');
disp('Background (lBackgroundTrue):');
disp(lBackgroundTrue);
disp('All others (lTrue):');
disp(lTrue);
disp('A priori probabilities each combination of activities (fTrue):');
disp([ [1:2^k]'  z'   fTrue ]);
disp(' ');

return
