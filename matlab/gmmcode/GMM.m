% Try Gaussian mixture models (GMMs)
%   Bill Hoff  May 2011
% This is a good reference:
%   http://www.autonlab.org/tutorials/gmm14.pdf

clear all
close all

% This is used to reset the random number generator to the same sequence
% s = RandStream('swb2712','Seed',0);
% RandStream.setDefaultStream(s);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create Gaussians (2D)
K = 3;              % Number of gaussians
fprintf('True Gaussians (%d):\n', K);
uK = rand(2,K);     % Means
disp('Means:'); disp(uK);
CK = zeros(2,2,K);  % Covariance matrices
for k=1:K
    sx = 0.15*rand + 0.01;
    sy = 0.15*rand + 0.01;
    CK(:,:,k) = [sx^2 0; 0 sy^2];
end
disp('Covariances:'); disp(CK);

% Weight of each Gaussian (this is the probability that it generates a
% point)
% Pw = rand(K,1);
Pw = ones(K,1)/K;
Pw = Pw/sum(Pw);    % Probability mass function
Cw = cumsum(Pw);    % Cumulative probability function

% Create some data (vectors in 2D)
N = 30;             % Number of data points
for n=1:N
    % Pick a Gaussian according to probability Pw
    u = rand;       % get number between 0 and 1
    v = u>Cw;       % get 1's where u is greater than Cw
    i = find(v, 1, 'last'); % get highest index
    
    % Corresponding value of k
    if isempty(i)
        k = 1;
    else
        k = i+1;
    end
    
    % Now generate a vector
    mu = uK(:,k)';
    Sigma = CK(:,:,k); R = chol(Sigma);
    z = mu + randn(1,2)*R;
    
    X(:,n) = z';
end

% Plot ground truth
plot(uK(1,:), uK(2,:), '*r');
hold on
for k=1:K
    pts = gaussian2D(uK(:,k), CK(:,:,k), 2);
    plot(pts(1,:), pts(2,:), 'r');
    text(uK(1,k), uK(2,k), sprintf('%d', k), 'Color', 'r');
end
plot(X(1,:), X(2,:), '.');
for n=1:N
    text(X(1,n), X(2,n), sprintf('%d', n));
end
axis equal
xlim([0 1]); ylim([0 1]);
hold off
pause

figure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate classes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while true
    
%     uKt = rand(2,K);    % Pick random starting guesses for means
%     uKt = uK + 0.4*(rand(2,K)-0.5);           % Use true means
    [~,C] = kmeans(X', K);      % Use kmeans
    uKt = C';
    
    CKt = zeros(2,2,K); % Covariances at time t
    for k=1:K
        CKt(:,:,k) = 0.01*eye(2);
    end

    Pwt = ones(3,1)/K;          % Weights at time t
    Pwx = zeros(K,N);           % This is P(w|x)
    
    
    % Compute the initial probability (likelihood) of the observed data,
    % given the estimated parameters.  Actually we will compute the log of
    % this because the products become sums, and the sums don't get so
    % small.
    Llast = 0;
    for n=1:N
        p = 0;
        for k=1:K
            u = uKt(:,k);           % Mean of class k
            C = CKt(:,:,k);         % Covariance for class k
            x = X(:,n);
            p = p + Pwt(k)*exp(-0.5*(x-u)'*inv(C)*(x-u))/sqrt(2*pi*det(C));
        end
        Llast = Llast + log(p);
    end
    Llast = Llast / N;
    fprintf('Initial log likelihood = %g\n', Llast);
    
    
    for iter=1:30
        fprintf('\nIteration %d, parameters:\n', iter);
        disp('Means:'); disp(uKt);
        disp('Covariances:'); disp(CKt);
        disp('Weights:'); disp(Pwt);
        disp('Pwx:'); disp(Pwx);
    
        % Plot current estimate
        plot(uKt(1,:), uKt(2,:), '*r');
        hold on
        for k=1:K
            pts = gaussian2D(uKt(:,k), CKt(:,:,k), 2);
            plot(pts(1,:), pts(2,:), 'r');
            text(uKt(1,k), uKt(2,k), sprintf('%d', k), 'Color', 'r');
        end
        plot(X(1,:), X(2,:), '.');
        for n=1:N
            % Print as a label, the class that this point belongs to
            [~,k] = max(Pwx(:,n));
            text(X(1,n), X(2,n), sprintf('%d', k));
        end
        axis equal
        xlim([0 1]); ylim([0 1]);
        hold off
        
        % E-step: compute "expected" classes of all datapoints
        Pwx = zeros(K,N);   % This is P(w|x)
        for n=1:N
            x = X(:,n);
            for k=1:K
                u = uKt(:,k);       % Mean of class k
                C = CKt(:,:,k);     % Covariance for class k
                if cond(C) < 1000
                    Pwx(k,n) = Pwt(k)*exp(-0.5*(x-u)'*inv(C)*(x-u))/sqrt(2*pi*det(C));
                else
                    fprintf('warning: class %d has tiny covariance:\n', k);
                    disp(C);
                end
            end
            % Normalize sum of Pwx over all w to be equal to 1
            Pwx(:,n) = Pwx(:,n)/sum(Pwx(:,n));
        end
        
        % M-step: compute maximum likelihood of params given the data's class
        % memberships
        uKt = zeros(2,K);
        CKt = zeros(2,2,K);
        Pwt = zeros(3,1);
        for k=1:K
            % Initialize covariance to a tiny amount
            CKt(:,:,k) = (1e-6)*eye(2);
            
            % Check if any points are assigned to class k (if not, leave all
            % estimates of mean, covariance, etc as zeros).
            if sum(Pwx(k,:)) < 1e-8
                continue;
            end
            
            % Mean of the kth class
            for n=1:N
                uKt(:,k) = uKt(:,k) + Pwx(k,n)*X(:,n);
            end
            uKt(:,k) = uKt(:,k)/sum(Pwx(k,:));
            
            % Covariance of the kth class
            for n=1:N
                CKt(:,:,k) = CKt(:,:,k) + ...
                    Pwx(k,n)*(X(:,n)-uKt(:,k))*(X(:,n)-uKt(:,k))';
            end
            CKt(:,:,k) = CKt(:,:,k)/sum(Pwx(k,:));

            
            % Weight of the kth class
            for n=1:N
                Pwt(k) = Pwt(k) + Pwx(k,n);
            end
            Pwt(k) = Pwt(k)/N;
        end
        
        % Convergence check.  Compute the probability of the observed data,
        % given the estimated parameters.  Actually we will compute the log of
        % this because the products become sums, and the sums don't get so
        % small.
        Lnext = 0;
        for n=1:N
            p = 0;
            x = X(:,n);
            for k=1:K
                u = uKt(:,k);           % Mean of class k
                C = CKt(:,:,k);         % Covariance for class k
                if cond(C) < 100
                    p = p + Pwt(k)*exp(-0.5*(x-u)'*inv(C)*(x-u))/sqrt(2*pi*det(C));
                end
            end
            Lnext = Lnext + log(p);
        end
        Lnext = Lnext / N;
        fprintf('Iteration %d, log likelihood = %g\n', iter, Lnext);
        
        % Stop if L is no longer changing
        if abs(Lnext-Llast) < 1e-6
            break;
        else
            Llast = Lnext;
        end
        
        pause(1);
    end
    
    szAns = input('Try this one again with different initialization (y/n)? ', 's');
    if ~strcmp(szAns, 'y')
        break;
    end
    
end

