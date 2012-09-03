% LLE ALGORITHM (using K nearest neighbors)
%
% [Y] = lle(X,K,dmax)
%
% X = data as D x N matrix (D = dimensionality, N = #points)
% K = number of neighbors
% dmax = max embedding dimensionality
% Y = embedding as dmax x N matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear all;

load mat/synthData.mat

K = 2;
d = 3;

patHeight = 3;

X = [];

%Make an array with only unique patterns
%This is an O(n^2) implementation because we don't have hash tables

for i = 1:size(data, 1) - patHeight + 1
    
    runVector = [];    
    
    for j = 1:patHeight     
        vector = data(i+j - 1, 2:size(data, 2));
        runVector = [runVector vector];
    end;
    
    %Check if run vector is currently in historic data
    found = 0;
    
    for j = 1:size(X, 1)
        
        if runVector == X(j, :)
            found = 1;
            break;
        end;
    end;
    
    %if not found, add the pattern
    if found == 0
        X = [X; runVector];
    end;
end;
            
X = X';

[D,N] = size(X);

fprintf(1,'LLE running on %d points in %d dimensions\n',N,D);


% STEP1: COMPUTE PAIRWISE DISTANCES & FIND NEIGHBORS 
fprintf(1,'-->Finding %d nearest neighbours.\n',K);

X2 = sum(X.^2,1);

distance = repmat(X2,N,1)+repmat(X2',1,N)-2*X'*X;

[sorted,index] = sort(distance);
neighborhood = index(2:(1+K),:);

% STEP2: SOLVE FOR RECONSTRUCTION WEIGHTS
fprintf(1,'-->Solving for reconstruction weights.\n');

if(K>D) 
  fprintf(1,'   [note: K>D; regularization will be used]\n'); 
  tol=1e-3; % regularlizer in case constrained fits are ill conditioned
else
  tol=0;
end


W = zeros(K,N);
for ii=1:N
   z = -1*X(:,neighborhood(:,ii))+repmat(X(:,ii),1,K); % shift ith pt to origin
   C = z'*z;                                        % local covariance
   C = C + eye(K,K)*tol*trace(C);                   % regularlization (K>D)
   W(:,ii) = C\ones(K,1);                           % solve Cw=1
   W(:,ii) = W(:,ii)/sum(W(:,ii));                  % enforce sum(w)=1
   
   for k = 1:size(W, 1)
       if W(k, ii) < 0 || isnan(W(k, ii))
           ii
           z
           C
           W(:, ii)
           break
       end;
   end;
   
   
end;

% STEP 3: COMPUTE EMBEDDING FROM EIGENVECTS OF COST MATRIX M=(I-W)'(I-W)
fprintf(1,'-->Computing embedding.\n');

% M=eye(N,N); % use a sparse matrix with storage for 4KN nonzero elements
M = sparse(1:N,1:N,ones(1,N),N,N,4*K*N); 
for ii=1:N
   w = W(:,ii);
   jj = neighborhood(:,ii);
   M(ii,jj) = M(ii,jj) - w';
   M(jj,ii) = M(jj,ii) - w;
   M(jj,jj) = M(jj,jj) + w*w';
end;

fprintf(1, 'Hello\n');

% CALCULATION OF EMBEDDING
options.disp = 0; options.isreal = 1; options.issym = 1; 
[Y,eigenvals] = eigs(M,d+1,0,options);
Y = Y(:,2:d+1)'*sqrt(N); % bottom evect is [1,1,1,1...] with eval 0


fprintf(1,'Done.\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


hold on;

for i = 1:7
    text(Y(1, i), Y(2, i), Y(3, i), sprintf('%d', i));
    %plot3(Y(1, i), Y(2, i), Y(3, i), '+b-');
    grid on
    axis square
end;

%Plot Y
for i = 8:size(Y, 2)
    plot3(Y(1, i), Y(2, i), Y(3, i), '*r');
    grid on
    axis square
end;

hold off;


%other possible regularizers for K>D
%  C = C + tol*diag(diag(C));                       % regularlization
%  C = C + eye(K,K)*tol*trace(C)*K;                 % regularlization
  

