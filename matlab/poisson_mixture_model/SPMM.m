% Sum of Poisson mixture model, with Expectation Maximization (EM)
% Bill Hoff
% July 2011
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

% This is used to reset the random number generator to the same sequence.
% Comment this out if you want a different random sequence each time.
%s = RandStream('swb2712','Seed',0); RandStream.setDefaultStream(s);

% I'm seeing the factorial function is very slow, so I will try this.
% Create the array "factorialValues", where factorialValues(n+1) is the
% factorial of n (that way you can accomodate the factorial of 0).
global factorialValues
factorialValues = ones(150,1);
for i=2:150
    factorialValues(i) = factorialValues(i-1)*(i-1);
end

% Define ground truth and create synthetic data
k = 2;      % This many activities (not including the background)
d = 15;      % Each data vector is d-dimensional
m = 500;     % Number of observed data vectors

%[x,fTrue,lBackgroundTrue,lTrue,wTrue] = createData(k,d,m);

[x, m] = readdata('/Users/jahoward/Documents/bigbrother/runs/small/tdMatrix.dat');

% Create binary numbers with k bits.  We'll need this later.
% z has size (2^k,k).  The rows are 0000,0001,0010,...,1111.
z = binary(k);
% Make least signif bit the leftmost, so rows are 0000,1000,0100,...,1111
z = fliplr(z);
% Transpose z, so it has size (k,2^k).  Columns are now 0000,1000,...,1111
z = z';


% Plot data points and activity centers
%plotdata(lBackgroundTrue, lTrue, x, wTrue, z);

% Compute log probability of whole dataset using true parameters
%logSumTrue = computeLogProb(lBackgroundTrue, lTrue, x, wTrue, z);
%fprintf('Log probability using true params = %g\n', logSumTrue);


pause%(1);



%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% Get initial guesses for lBackground, l, and f using one of the following
% methods.

%%%% (1) Use true values (for debugging only)
% lBackground = lBackgroundTrue; l = lTrue;  w = wTrue; f = fTrue;

%%%% (2) Use fixed values 
lBackground = 2.0*ones(d,1);    % Background activity
l = 10.0 * ones(d,k);           % All other activities
f = ones(2^k,1)/(2^k);          % a-priori probability of each combination

%%%% (3) Use random values 
% lBackground = 4.0*rand(d,1);    % Background activity
% l = 20.0 * rand(d,k);           % All other activities
% f = rand(2^k,1);                % a-priori probability of each combination
% f = f/sum(f);                   % Force to sum to 1

%%%% (4) Use kmeans
% f = ones(2^k,1)/(2^k);          % a-priori probability of each combination
% while true
%     % Get the cluster centroid locations in the matrix C.
%     % The m-by-1 vector IDX contains the cluster indices of each point.
%     [IDX,C] = kmeans(x, 2^k);
%     
%     % Sort the clusters according to total counts
%     for b=1:2^k
%         xc = x(:,IDX==b);     % Get points in this cluster
%         nCluster(b) = sum(xc(:));
%     end
%     [~,IC] = sort(nCluster);
%     
%     % Assume that the lowest count is the background
%     lBackground = C(:, IC(1));
%     
%     % Assume that the next k clusters are our k activities
%     for j=1:k
%         l(:,j) = C(:, IC(j+1));
%     end
%     
%     disp('Initial guesses:');
%     disp('Mean of background:'); disp(lBackground);
%     disp('Mean of all others:'); disp(l);
%     
%     szAns = input('Try kmeans again (y/n)? ', 's');
%     if ~strcmp(szAns, 'y')
%         break;
%     end
% end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% Main algorithm: estimate activity rate vectors and prior probabilities

% Allocate space for w(2^k,m).  These are the p(zb|xi), which are the
% probabilities that combination zb is present in point xi.  Don't need to
% initialize it because the E-step computes it, first thing.
w = zeros(2^k,m);     

tic     % Start timer
logSumLast = -1e10;
for iterMain=1:40
    fprintf('Main loop iteration %d\n', iterMain); 
    
    % Compute log probability of whole dataset using current parameters
    logSum = computeLogProb(lBackground, l, x, w, z);
    fprintf('Log probability using currest estimated params = %g\n', logSum);
    
    % Quit if total probability isn't changing anymore
    if abs(logSum-logSumLast)/abs(logSumLast) < 1e-5
        break;
    else
        logSumLast = logSum;
    end
    
    % Plot data points and current activity centers
    figure(2), plotdata(lBackground, l, x, w, z);    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do E-step: Estimate all w, assuming you know l and f.
    %fprintf('\nDoing E-step ...\n\n');
    for i=1:m
        % Compute p(xi,zb) = p(xi|zb) p(zb) for all values of b
        pxizb = zeros(2^k,1);
        for b=1:size(z,2)
            zb = z(:,b);    % zb contains 1's where activity is present
            pzb = f(b);
             
            % Find p(xi|zb). First find the expected rate vector, given the
            % specified combination of activities in zb.   
            indices = find(zb);     % Get indices of activities present
            lPresent = l(:,indices);
            lb = sum(lPresent,2) + lBackground;
            
            % Find the probability that vector xi could have been produced
            % by a Poisson with rate parameters lb.
            p = 1.0;
            for id=1:d
                p = p * evaluatePoisson(x(id,i), lb(id));
            end

            pxizb(b) = p*pzb;
        end

        %%%%%%%%%%%%%%
        % Compute wbi = p(zb|xi) for all values of b.
        % This is  p(zb|xi) = p(xi|zb)p(zb)/sum_b[p(xi|zb)p(zb)]
        w(:,i) = pxizb/sum(pxizb);
    end     % end for i=1:m
    %fprintf('End of E-step\n');
    %disp('w:');  disp(w); disp(' ');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do M-step:  Estimate the rates l, assuming you know w. This is
    % done using an iterative algorithm.
    sumlBackground = zeros(d,1);
    suml = zeros(d,k);
    
    NMSTEP = 30;
    for iterMstep=1:NMSTEP        
        % Pick a random instantiation of assignments.  Namely, each point
        % is assigned to a combination, based on its p(zb|xi)
        wTrial = zeros(2^k,m);
        
        for i=1:m
            r = rand;
            cdf = cumsum(w(:,i));
            
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
            wTrial(b,i) = 1;
        end
        
        % Estimate rates given this assignment.
        % Form the matrix equation Ap = q, where
        %  A has size m,(k+1).  Each row is the aTrue for point i.
        %  p has size (k+1),d. Each row is the unknown mean of activity j.
        %  q has size m,d.  Each row is the observed counts.
        A = zeros(m,k+1);
        for i=1:m
            b = find(wTrial(:,i));   % Get combination number
            zb = z(:,b);        % zb(j)=1 if j is present
            A(i, :) = [1 zb'];
        end
        q = x';
        p = A\q;

        lBackgroundTrial = p(1,:)';     % The mean of background activity
        lTrial = p(2:end,:)';     % Each column is the mean of activity j

        sumlBackground = sumlBackground + lBackgroundTrial;
        suml = suml + lTrial;
    end
    
    lBackground = sumlBackground/NMSTEP;
    l = suml/NMSTEP;

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Second M-step:  Estimate a-priori probabilities f, assuming you know
    % w. I believe that this is just fb = (1/m) sum_i wbi (should show
    % this).
    f = (1/m)*sum(w,2);
    
%     disp('Rates (lBackground):');
%     disp(lBackground);
%     disp('Rates (l):');
%     disp(l);
%     disp('A priori probabilities, each combination of activities (f):');
%     disp(f);

end     % for iterMain
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All done, print results
% disp(' ');
% disp('Ground truth values:');
% disp('Rates (lBackgroundTrue):');
% disp(lBackgroundTrue);
% disp('Rates (lTrue):');
% disp(lTrue);
% % disp('A priori probabilities, each combination of activities (fTrue):');
% % disp(fTrue);

disp(' ');
disp('Rates (lBackground):');
disp(lBackground);
disp('Rates (l):');
disp(l);
% disp('A priori probabilities, each combination of activities (f):');
% disp(f);


% Plot data points and activity centers
figure, plotdata(lBackground, l, x, w, z);

