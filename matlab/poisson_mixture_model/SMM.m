% Summed mixture model algorithm.
% Bill Hoff
% July 2011
%
% Here is the model and the notation:
%  We have k underlying activities, plus an additional background activity.
%  We have m observed data vectors xi, each is d dimensional. Let yj be the
%  data vector produced by activity j. Each yj is generated
%  by its own probability distribution.  Then any point is
%    xi = y0 + a1i y1 + a2i y2 + ... + aki yk
%  where aji = 1 if activity j occured in data sample i.
% We define a combination of activities as a binary number zb, where b goes
% from 1 to 2^k.  Let fb be the a-priori probability of the combination zb
% occuring. Let wbi = the probability that sample i has combination b.

clear all
close all

% This is used to reset the random number generator to the same sequence.
% Comment this out if you want a different random sequence each time.
%s = RandStream('swb2712','Seed',0); RandStream.setDefaultStream(s);

k = 2;      % Specify # activities (not including the background)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize some classes.

% Probability distribution of the mixture model.
%pModel = class_Gaussian(k);
pModel = class_Poisson(k);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create binary numbers with k bits.  We'll need this later.
% z has size (2^k,k).  The rows are 0000,0001,0010,...,1111.
z = binary(k);
% Make least signif bit the leftmost, so rows are
% 0000,1000,0100,...,1111
z = fliplr(z);
% Transpose z, so it has size (k,2^k).  Columns are now
% 0000,1000,...,1111
z = z';
            
%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define ground truth and create synthetic data
d = 6;      % Each data vector is d-dimensional
m = 200;     % Number of observed data vectors
x = createData(pModel, k,d,m);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}

%%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read data from text file
x = readData('/Users/jahoward/Documents/bigbrother/runs/small/tdMatrix.dat');
d = size(x,1);
m = size(x,2);
fprintf('Read in %d points, each %d dimensional\n', m, d);

disp([ mean(x(:,1:25), 2), mean(x(:,26:50), 2), ...
    mean(x(:,51:75), 2) ]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%}

% Print and plot ground truth data if it exists
printTrue(pModel);
plotGroundTruthData(pModel, x);


% Compute log probability of whole dataset using true parameters (if known)
logProbTrue = computeLogProbTrue(pModel, x);
if ~isempty(logProbTrue)
    fprintf('Log probability of whole dataset using ground truth: %g\n', ...
        logProbTrue);
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% Get initial guesses for the mixture components.
% Possible methods are:  'true', 'fixed', 'random', 'kmeans'
setInitialGuesses(pModel, 'random', x);

disp('Initial guesses for model params:');
printEstimated(pModel);
pause

%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% Main algorithm

tic     % Start timer
logSumLast = -1e10;
for iterMain=1:40
    fprintf('Main loop iteration %d\n', iterMain); 
    
    % Compute log probability of whole dataset using current parameters
    logSum = computeLogProb(pModel, x);
    fprintf('Log probability using currest estimated params = %g\n', logSum);
    
    % Quit if total probability isn't changing anymore
    if abs(logSum-logSumLast)/abs(logSumLast) < 1e-5
        break;
    else
        logSumLast = logSum;
    end
    
    % Plot current data
    figure(2), plotCurrentData(pModel, x);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do E-step: Estimate all w, assuming you know the parameters of the
    % mixture components.
    %fprintf('\nDoing E-step ...\n\n');
    for i=1:m
        % Compute p(xi,zb) = p(xi|zb) p(zb) for all values of b
        pxizb = zeros(2^k,1);
        for b=1:2^k
            p = getPxGivenZb(pModel, x(:,i), b);
            pxizb(b) = p * pModel.f(b);
        end

        %%%%%%%%%%%%%%
        % Compute wbi = p(zb|xi) for all values of b.
        % This is  p(zb|xi) = p(xi|zb)p(zb)/sum_b[p(xi|zb)p(zb)]
        pModel.w(:,i) = pxizb/sum(pxizb);
    end     % end for i=1:m
%     fprintf('End of E-step\n');
%     disp('w:');  disp(pModel.w); disp(' ');
%     pause
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do M-step:  Estimate the means of the mixture components, 
    % assuming you know w. This is done using an iterative algorithm.
    % If the k activities are independent, then the mean of their sum
    % is the sum of their means.
    sumMeanBackground = zeros(d,1);
    sumMean = zeros(d,k);
    
    NMSTEP = 30;
    for iterMstep=1:NMSTEP        
        % Pick a random instantiation of assignments.  Namely, each point
        % is assigned to a combination, based on its p(zb|xi)
        wTrial = zeros(2^k,m);
        
        for i=1:m
            r = rand;
            cdf = cumsum(pModel.w(:,i));
            
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
        
        % Estimate the means of the components given this assignment.
        % Form the matrix equation Ar = v, where
        %  A has size m,(k+1).  Each row is the aTrue for point i.
        %  r has size (k+1),d. Each row is the unknown mean of activity j.
        %  v has size m,d.  Each row is the observed counts.
        A = zeros(m,k+1);
        for i=1:m
            b = find(wTrial(:,i));   % Get combination number
            zb = z(:,b);        % zb(j)=1 if j is present
            A(i, :) = [1 zb'];
        end
        v = x';
        
        r = zeros(k+1,d);
        for n=1:d
            % This is better than doing r=A\v or r=pinv(A)*v,
            % because it ensures that the result is nonnegative.
            r(:,n) = lsqnonneg(A,v(:,n));
        end

        meanBackgroundTrial = r(1,:)';  % The mean of background activity
        meanTrial = r(2:end,:)';     % Each column is the mean of activity j

        sumMeanBackground = sumMeanBackground + meanBackgroundTrial;
        sumMean = sumMean + meanTrial;
    end
    
    meanBackground = sumMeanBackground/NMSTEP;
    meanForeground = sumMean/NMSTEP;
    
    % Update the means of the components
    updateMeans(pModel, meanBackground, meanForeground, x);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Second M-step:  Estimate a-priori probabilities f from w. 
    pModel.f = (1/m)*sum(pModel.w,2);

end     % for iterMain
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All done, print results

printTrue(pModel);
printEstimated(pModel);

% Plot final results
figure(2), plotCurrentData(pModel, x);

