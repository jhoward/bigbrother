% Try Poisson mixture model, with Expectation Maximization (EM) Bill Hoff
% June 2011
%
% Here is the model and the notation:
%  We have k underlying activities, plus an additional background activity.
%  We have m observed data vectors xi, each is d dimensional. Let yj be the
%  data vector produced by activity j. Each component of yj is a Poisson
%  distribution (assume indept). lj (note "L" for lambda) is the vector of
%  rate coeffs for activity j.  Let aji = 1 if activity j occured in data
%  sample i.
% We define a combination of activities as a binary number zb, where b goes
% from 1 to 2^k.  Let fb be the a-priori probability of the combination zb
% occuring. Let wbi = the probability that sample i has combination b.

clear all
close all

% This is used to reset the random number generator to the same sequence
%s = RandStream('swb2712','Seed',0); RandStream.setDefaultStream(s);


% I'm seeing the factorial function is very slow, so I will try this.
% Create the array "factorialValues", where factorialValues(n+1) is the
% factorial of n (that way you can accomodate the factorial of 0).
global factorialValues
factorialValues = ones(150,1);
for i=2:150
    factorialValues(i) = factorialValues(i-1)*(i-1);
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% Define ground truth
k = 2;      % This many activities (not including the background)
d = 10;      % Each data vector is d-dimensional

% Probability of each combination of activities occuring (sums to 1)
fTrue = rand(2^k,1);
%fTrue = ones(2^k,1);
fTrue = fTrue/sum(fTrue);  % Force to sum to 1

% Define rate for each of the k activities, for each of the d dimensions. l
% (note "L", not "one") is of size (d,k).
lTrue = 20.0 * rand(d,k);
% Also have the background activity
lBackgroundTrue = 4.0 * rand(d,1);

% Create binary numbers with k bits.  We'll need this later.
% z has size (2^k,k).  The rows are 0000,0001,0010,...,1111.
z = binary(k);
% Make least signif bit the leftmost, so rows are 0000,1000,0100,...,1111
z = fliplr(z);
% Transpose z, so it has size (k,2^k).  Columns are now 0000,1000,...,1111
z = z';

% disp('Ground truth values:');
% disp('Rates (lBackgroundTrue):');
% disp(lBackgroundTrue);
% disp('Rates (lTrue):');
% disp(lTrue);
% disp('A priori probabilities each combination of activities (fTrue):');
% disp([ [1:2^k]'  z'   fTrue ]);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Create observed data from ground truth params
% m = 100;    % Number of observed data vectors
% 
% % Pre-allocate data storage
% x = zeros(d,m);         % Actual observed counts go in here
% aTrue = zeros(2^k,m);   % Indicators (abi = 1 if combination b in sample i)
% 
% for i=1:m
%     li = zeros(d,1);    % Rate vector (size dx1) for this sample.
%     
%     % Decide which combination of activities is present in this sample.
%     cdf = cumsum(fTrue);    % Get the cdf (cummulative distribution)
%     
%     %u = rand;       % get number between 0 and 1
%     
%     % Find the closest value to x in the cdf table
%     %[~,b] = min(abs(u-cdf));
%     
%     u = rand;       % get number between 0 and 1
%     v = u>cdf;       % get 1's where u is greater than Cw
%     ind = find(v, 1, 'last'); % get highest index
%     
%     % Corresponding value of k
%     if isempty(ind)
%         b = 1;
%     else
%         b = ind+1;
%     end
%     
%     if b > size(z, 2)
%         b = size(z, 2) - 1;
%     end;
% 
%     zb = z(:,b);    % This is the combination we want
%     aTrue(b,i) = 1;
%     
%     % Construct the rate vector for this combination
%     mask = ones(size(lTrue)) * diag(zb);
%     li = mask .* lTrue;             % Set to zero any rates not present
%     li = sum(li,2) + lBackgroundTrue;  % Sum rates along each dimension
% 
%     % Generate a vector according to the multivariate Poisson distrib.
%     x(:,i) = generatePoisson(li);
%     %x(:,i) = round(li);
% end


% %Grab data from file
[x, m] = readdata('/Users/jahoward/Documents/bigbrother/runs/2_meeting_overlap/tdMatrix.dat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot ground truth activity centers, and 1st 3 dimensions of observed pts.
% This gets pretty confusing with k>2, though.
% if k<=4
%     mycolors = colormap(hsv(k));
%     hold on
%     for i=1:m
%         [~,b] = max(aTrue(:,i));        % Get combination for this point
%         zb = z(:,b);                    % zb(j)=1 if activity j is present
%         acolors = mycolors(zb==1,:);    % Get reduced array of colors
%         if isempty(acolors)
%             c = [0 0 0];                % Black for background activity only
%         else
%             c = mean(acolors,1);        % Average colors of activities present
%         end
%         plot3(x(1,i), x(2,i), x(3,i), '.', 'Color', c);
%         %text(x(1,i), x(2,i), x(3,i), sprintf('%d',b-1), 'Color', c, 'FontSize', 9);
%     end
%     for j=1:k
%         % Plot activity centers
%         plot3(lTrue(1,j)+lBackgroundTrue(1), lTrue(2,j)+lBackgroundTrue(2), lTrue(3,j)+lBackgroundTrue(3), 's', 'Color', mycolors(j,:));
%         plot3(lTrue(1,j)+lBackgroundTrue(1), lTrue(2,j)+lBackgroundTrue(2), lTrue(3,j)+lBackgroundTrue(3), 'o');
%         %text(lTrue(1,j), lTrue(2,j), lTrue(3,j), sprintf('%d',j), 'Color', mycolors(j,:));
%     end
%     plot3(lBackgroundTrue(1), lBackgroundTrue(2), lBackgroundTrue(3), 'sk');
%     plot3(lBackgroundTrue(1), lBackgroundTrue(2), lBackgroundTrue(3), 'o');
%     %text(lBackgroundTrue(1), lBackgroundTrue(2), lBackgroundTrue(3), '0', 'Color', 'k');
%     axis vis3d
%     hold off
% end

if k<=4
    mycolors = colormap(hsv(k));
    hold on
    for i=1:m
        plot3(x(1,i), x(2,i), x(3,i), '.', 'Color', 'r');
    end
    axis vis3d
    hold off
end

pause();


%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate activity rate vectors and prior probabilities

%%%% FOR DEBUGGING %%%%
%lBackground = lBackgroundTrue;
%l = lTrue;
%w = aTrue;   % wbi = p(zb|xi)
%f = fTrue;
bestLikelihood = 0;
bestPreLikelihood = 0;

for i = 1:1
    fprintf('iteration = %d\n', i);
    
    %Initial Guesses
    lBackground = 0.5*ones(d,1);    % Background activity
    l = rand(d, k) * 6 + 7;           % All other activities
    w = ones(2^k,m)/(2^k);            % Probabilities that combination is present
    f = ones(2^k,1)/(2^k);            % a-priori probability of each combination
    
    preLikelihood = calcLikelihood(x, z, f, d, m, k, lBackground, l);
    [l, w, f, lBackground] = EMPMM( x, l, w, f, z, lBackground, d, m, k);
    likelihood = calcLikelihood(x, z, f, d, m, k, lBackground, l);
    
    fprintf('\ncurrent likelihood: %f      bestlikelihood: %f\n', likelihood, bestLikelihood);
    
    if (likelihood > bestLikelihood) || (bestLikelihood == 0)
        bestL = l;
        bestW = w;
        bestF = f;
        bestLBackground = lBackground;
        bestLikelihood = likelihood;
        bestPreLikelihood = preLikelihood;
    end
end
        
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All done, print results
% disp(' ');
% disp('Ground truth values:');
% disp('Rates (lBackgroundTrue):');
% disp(lBackgroundTrue);
% disp('Rates (lTrue):');
% disp(lTrue);
% disp('A priori probabilities, each combination of activities (fTrue):');
% disp(fTrue);

disp(' ');
disp('Rates (lBackground):');
disp(lBackground);
disp('Rates (l):');
disp(l);
% disp('A priori probabilities, each combination of activities (f):');
% disp(f);
%Print the likelihood of the whole system
%likelihood = calcLikelihood(x, z, f, d, m, k, lBackground, l);
fprintf('log-Likelihood before convergence:%f\n', bestPreLikelihood);
fprintf('log-Likelihood after convergence:%f\n', bestLikelihood);

l = bestL;
w = bestW;
f = bestF;
lBackground = bestLBackground;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot estimated activity centers, and 1st 3 dimensions of observed pts.
% Don't bother plotting if k>2, though.
if k<=4
    figure
    hold on
    for i=1:m
        [~,b] = max(w(:,i));            % Get combination for this point
        zb = z(:,b);                    % zb(j)=1 if activity j is present
        acolors = mycolors(zb==1,:);    % Get reduced array of colors
        if isempty(acolors)
            c = [0 0 0];                % Black for background activity only
        else
            c = mean(acolors,1);        % Average colors of activities present
        end
        plot3(x(1,i), x(2,i), x(3,i), '.', 'Color', c);
        text(x(1,i), x(2,i), x(3,i), sprintf('%d',b-1), 'Color', c, 'FontSize', 9);
    end
    for j=1:k
        % Plot activity centers
        plot3(l(1,j), l(2,j), l(3,j), 's', 'Color', mycolors(j,:));
        plot3(l(1,j), l(2,j), l(3,j), 'o');
        %text(l(1,j), l(2,j), l(3,j), sprintf('%d',j), 'Color', mycolors(j,:));
    end
    plot3(lBackground(1), lBackground(2), lBackground(3), 'sk');
    plot3(lBackground(1), lBackground(2), lBackground(3), 'o');
    %text(lBackground(1), lBackground(2), lBackground(3), '0', 'Color', 'k');
    axis vis3d
    hold off
end    
    
