% Arbitrary PMF mixture model algorithm.
% Bill Hoff
% July 2011
%
% Here is the model and the notation:
%  We have k underlying activities.
%  We have m observed data vectors xi, each is d dimensional.
%  Let wji = p(aj|xi).
%  Let fj = p(aj).
% We are trying to find the pmf of x for each activity:  p(x|aj)

clear all
close all

% This is used to reset the random number generator to the same sequence.
% Comment this out if you want a different random sequence each time.
%s = RandStream('swb2712','Seed',0); RandStream.setDefaultStream(s);

k = 24;      % Specify # activities


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get data - either create or read it in 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  Create synthetic data   %%%%%%%%%%%%%%%%%%%%%%%% 
% M = 10;      % Scale data to range 0..M-1
% m = 2000;    % # points xi
% d = 15;     % # dimensions for each xi
% classData = class_Synthetic(m,d,k,M);
% x = classData.x;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  Read data from Brown Hall sensor network  %%%%%%
% M = 8;     % Scale data to range 0..M-1
% classData = class_BrownData('../data/BrownData/3_activities_overlap',M);
% x = classData.x;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Read data from traffic dataset  %%%%%%%%%%%%
M = 15;     % Scale data to range 0..M-1
classData = class_TrafficData('data/trafficData/counts2010',M);
x = classData.x;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

m = size(x,2);      % # points xi
d = size(x,1);      % # dimensions for each xi


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize parameters

% Allocate space for w.  Each w(j,i) = wji = p(aj|xi).
w = ones(k,m)/k;

% Initialize pmfs for each activity, p(x|aj).
% Each pmf has size (M,d).
% The meaning is:  pmf(i,n,j) = probability of having i-1 counts, on
% dimension n, given activity j;  p(xn=i-1|aj)
pmf = rand(M,d,k);
for n=1:d
    for j=1:k
        pmf(:,n,j) = pmf(:,n,j)/sum(pmf(:,n,j));
    end
end

% Initialize p(aj)
f = ones(k,1);
f = f/sum(f);



%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% Main algorithm

lastLogProb = -1e9;
for iterMain=1:200
    
    % Estimate log probability of the dataset
    [px,logProb] = estimateLogProb(x, w, f, pmf);
    fprintf('Iteration %d, log probability = %g\n', iterMain, logProb);
    if abs(lastLogProb-logProb)/abs(lastLogProb) < 1e-6
        break;
    else
        lastLogProb = logProb;
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do E-step: Estimate all w, assuming you know the parameters of the
    % mixture components.
    %fprintf('\nDoing E-step ...\n\n');
    for i=1:m
        % Estimate wji = p(aj|xi), which is the probability that point xi
        % belongs to component aj.
        % This is given by
        %   p(aj|xi) = p(xi|aj)p(aj)/sumj p(xi|aj)p(aj)
        
        % Compute p(xi,aj) = p(xi|aj) p(aj) for all values of j
        pxiaj = zeros(k,1);
        for j=1:k
            
            % Assuming the dimensions are independent, the total prob is
            % just the product of the prob for each dimension
            p = 1.0;
            for n=1:d
                v = x(n,i);     % The value of xi for this dimension
                p = p * pmf(v+1,n,j);
            end
            
            pxiaj(j) = p * f(j);
        end
        
        w(:,i) = pxiaj/sum(pxiaj);
    end     % end for i=1:m
    %     fprintf('End of E-step\n');
    %     disp('w:');  disp(w); disp(' ');
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do M-step:  Estimate the pmfs of the mixture components,
    % assuming you know w. We want to find p(x|aj) for each j.
    %fprintf('\nDoing M-step ...\n\n');
    pmf = estimatePmf(x, w);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Second M-step:  Estimate a-priori probabilities f from w.
    f = (1/m)*sum(w,2);
    
    
    % Draw pmfs
    figure(2);
    for j=1:k
        if k<=6
            subplot(1,k,j), imshow(pmf(:,:,j),[]);
        else
            nRows = ceil(k/6);
            subplot(nRows,6,j), imshow(pmf(:,:,j),[]);
        end
        title(sprintf('%d (%.2f)', j, f(j)));
    end
    colormap hot
    pause(0.1);
    
end     % for iterMain


%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% All done, print results

% disp(' '), disp('Final pmf:'), disp(pmf);
fprintf('Final log probability = %g\n', logProb);

% Examine the distance between each pair of pmfs.
% We will use the symmetric Kullback–Leibler divergence measure, which is
% defined as D(P,Q)+D(Q,P), where
%  D(P,Q) = sum P(i) log( P(i)/Q(i) )
% If either P(i) or Q(i) are zero, then set it to some tiny number.
DKL = 1000 * ones(k,k);
for j1=1:k
    P = pmf(:,:,j1);    % P is size(M,d)
    for j2=j1+1:k
        Q = pmf(:,:,j2);
        
        v12 = P .* log( max(P, 1e-6)./ max(Q, 1e-6) );
        v21 = Q .* log( max(Q, 1e-6)./ max(P, 1e-6) );
        DKL(j1,j2) = sum(v12(:)) + sum(v21(:));
    end
end
minVal = min(DKL(:));
[j1,j2] = find(DKL==minVal);
fprintf('Closest two pmfs are: %d and %d, with DKL = %f\n', j1,j2,minVal);
% disp('First pmf:'), disp(pmf(:,:,j1));
% disp('Second pmf:'), disp(pmf(:,:,j2));

classData.AnalyzeResults(w,pmf,px);


