function [IDX, C] = kmeans(X, K)
%KMEANS K-means clustering.
%   [IDX, C] = KMEANS(X, K) partitions the N points (each of which is
%   P-dimensional) in the P-by-N data matrix X into K clusters.
%
%   It returns the K cluster centroid locations in the P-by-K matrix C.
%   The N-by-1 vector IDX contains the cluster indices of each point.

[P,N] = size(X);
IDX =zeros(N,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pick random starting seeds.  The seeds are chosen from the input points.
% We'll choose more than K at first, and then eliminate ones that are too 
% close until we get down to K. 
kinitial = 7*K;
perm = randperm(N);
perm = perm(1:kinitial);
C = X(:,perm);

% Eliminate ones that are too close - look at pair-wise distances
while kinitial>K
    D = 1e10 * ones(kinitial,kinitial);
    for i=1:kinitial
        for j=i+1:kinitial
            D(i,j) = norm(C(:,i)-C(:,j));
        end
    end
    
    % Find the minimum pair-wise distance (if there's more than one pair
    % with exactly the same distance, just take the first)
    [~,i2] = find( D == min(min(D)) );
    
    % Eliminate seed i2
    C(:,i2(1)) = [];
    kinitial = kinitial-1;
end


for iter=1:30
    %fprintf('Start of iteration %d\n', iter);

    % The new centers will be found by averaging the points 
    % that are assigned to that center.
    new_C = zeros(P,K);
    nptsC = zeros(K,1);     % number of points in each center
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 1:  assign points to clusters
    
    % For each point ...
    for i=1:N
        % For each cluster ...
        distClusterMin = 1e10;
        for j=1:K
            % Compute distance from point i to cluster j.  
            dist = norm(X(:,i)-C(:,j));
            %fprintf('     dist = %f\n', dist);
            
            if dist < distClusterMin
                distClusterMin = dist;
                idClusterMin = j;
            end  
        end
        
        % Point i is closest to the cluster with id idClusterMin.
        IDX(i) = idClusterMin;
%         fprintf('point %d is closest to cluster %d, dist = %f\n', ...
%             i, idClusterMin, distClusterMin);
        
        % Add this point to that cluster.
        new_C(:,idClusterMin) = new_C(:,idClusterMin) + X(:,i);
        
        % Increment count of points in this cluster
        nptsC(idClusterMin) = nptsC(idClusterMin) + 1;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 2:  Compute cluster centers

    for j=1:K
        if nptsC(j) > 0
            new_C(:,j) = new_C(:,j)/nptsC(j);
        else
            new_C(:,j) = C(:,j);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isequal(C, new_C)
        break;      % stop if no more changes
    else
        C = new_C;
    end
end


return
