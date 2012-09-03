classdef class_Poisson < handle
    % This is a set of Poisson distributions.
    
    properties
        % factorialValues(n+1) is the factorial of n
        factorialValues = ones(150,1);
        
        % Probability of each combination of activities occuring (sum to 1)
        f, fTrue
        
        % Prob of each combination of activities occuring, for each point
        w, wTrue
        
        % Rate for each of the k activities, for each of the d dimensions.
        % l (note "L", not "one") is of size (d,k).
        l, lTrue
        
        % Also have the background activity
        lBackground, lBackgroundTrue

        z     % all binary numbers with k bits
    end  % end properties
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        function obj = class_Poisson(k)
            for i=2:150
                obj.factorialValues(i) = obj.factorialValues(i-1)*(i-1);
            end
            
            % Create binary numbers with k bits.  We'll need this later.
            % z has size (2^k,k).  The rows are 0000,0001,0010,...,1111.
            obj.z = binary(k);
            % Make least signif bit the leftmost, so rows are
            % 0000,1000,0100,...,1111
            obj.z = fliplr(obj.z);
            % Transpose z, so it has size (k,2^k).  Columns are now
            % 0000,1000,...,1111
            obj.z = obj.z';
        end  % end constructor
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Create synthetic data (if desired)
        function x = createData(obj, k,d,m)
            obj.fTrue = ones(2^k,1);
            obj.fTrue = obj.fTrue/sum(obj.fTrue);  % Force to sum to 1
            
            obj.lTrue = 20.0 * rand(d,k);
            obj.lBackgroundTrue = 4.0 * rand(d,1);
            
            % Pre-allocate data storage
            yBackgroundTrue = zeros(d,m);   % Background activity, each point
            yTrue = zeros(d,m,k);           % Foreground activities, each point
            obj.wTrue = zeros(2^k,m);   % Indicators (wbi = 1 if combination b in sample i)
            
            for i=1:m
                % Decide which combination of activities is present in this
                % sample.
                cdf = cumsum(obj.fTrue);    % Get the cdf (cummulative distribution)
                
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
                
                zb = obj.z(:,b);    % This is the combination we want
                obj.wTrue(b,i) = 1;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%
                % Generate the background activity counts.
                v = generatePoisson(obj, obj.lBackgroundTrue);
                % Round to integer and clip to zero, since counts must be
                % non-negative integers.
                yBackgroundTrue(:,i) = max( zeros(d,1), round(v) );
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%
                % Generate the foreground activity counts.
                indices = find(zb);     % Get indices of activities that are present
                for index=1:length(indices)
                    j = indices(index);
                    li = obj.lTrue(:,j);
                    
                    v = generatePoisson(obj, li);
                    yTrue(:,i,j) = max( zeros(d,1), round(v) );
                end
            end
            
            % Sum activities for each point
            x = zeros(d,m);         % Actual observed counts go in here
            for i=1:m
                b = find(obj.wTrue(:,i));   % Get combination number (1..2^k)
                zb = obj.z(:,b);
                
                indices = find(zb);     % Get indices of activities that are present
                yPresent = yTrue(:,i,indices);  % Counts from activities present
                yPresent = squeeze(yPresent);   % Collapse singleton index (i)
                
                x(:,i) = yBackgroundTrue(:,i) + sum(yPresent,2);
            end
            
            % Since my generated values may be a little off, recalculate
            % them based on the values I actually generated.
            obj.fTrue =  (1/m)*sum(obj.wTrue,2);
            obj.lBackgroundTrue = mean(yBackgroundTrue, 2);     % Take mean of dimension 2
            
            for j=1:k
                yj = [];  % Get all instances for activity j
                for i=1:m
                    b = find(obj.wTrue(:,i));   % Get combination number (1..2^k)
                    zb = obj.z(:,b);
                    
                    if zb(j)
                        % Add vector for activity j, from point i
                        yj = [yj yTrue(:,i,j)];
                    end
                end
                
                % Calculate true mean and covariance of activity j
                obj.lTrue(:,j) = mean(yj,2);
            end
        end  % end function createData
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Plot ground truth data (if it exists)
        function plotGroundTruthData(obj, x)
            if isempty(obj.lTrue)  return;  end
            
            plotData(obj, obj.lBackgroundTrue, obj.lTrue, obj.wTrue, x);
        end  % end function plotGroundTruthData

                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Plot current data
        function plotCurrentData(obj, x)
            plotData(obj, obj.lBackground, obj.l, obj.w, x);
        end  % end function plotCurrentData

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Compute log probability of the whole dataset using ground truth
        function logProbTrue = computeLogProbTrue(obj, x)
            logProbTrue = [];
            if isempty(obj.lTrue)  return;  end
            
            logProbTrue = getLogProb(obj, obj.lBackgroundTrue, ...
                obj.lTrue, obj.wTrue, x);
        end  % end function computeLogProbTrue

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Compute log probability of the whole dataset, current parameters
        function logProb = computeLogProb(obj, x)
            logProb = getLogProb(obj, obj.lBackground, ...
                obj.l, obj.w, x);
        end  % end function computeLogProb
       
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Initialize parameters
        function setInitialGuesses(obj, szMethod, x)
            d = size(x,1);      % Number of dimensions
            m = size(x,2);      % Number of points
            k = size(obj.z,1);  % Number of activities
            
            % Allocate space for w (but don't need to initialize because
            % the E-step computes it, first thing.
            obj.w = zeros(2^k,m);   % p(zb|xi)

            switch szMethod
                case 'true'
                    % Use true values (for debugging only)
                    obj.lBackground = obj.lBackgroundTrue; 
                    obj.l = obj.lTrue;  
                    obj.f = obj.fTrue;
                case 'fixed'
                    % Use same fixed values for each
                    obj.lBackground = 1.0*ones(d,1);
                    obj.l = 5.0 * ones(d,k);
                    obj.f = ones(2^k,1)/(2^k);
                case 'random'
                    % Use random values
                    obj.lBackground = 4.0*rand(d,1);
                    obj.l = 20.0 * rand(d,k);
                    obj.f = rand(2^k,1);
                    obj.f = obj.f/sum(obj.f);
                case 'kmeans'
                    obj.f = ones(2^k,1)/(2^k);

                    % Get the cluster centroid locations in the matrix C.
                    % The m-by-1 vector IDX contains the cluster indices of each point.
                    [IDX,C] = kmeans(x, 2^k);

                    % Sort the clusters according to total counts
                    for b=1:2^k
                        xc = x(:,IDX==b);     % Get points in this cluster
                        nCluster(b) = sum(xc(:));
                    end
                    [~,IC] = sort(nCluster);

                    % Assume that the lowest count is the background
                    obj.lBackground = C(:, IC(1));

                    % Assume that the next k clusters are our k activities
                    for j=1:k
                        obj.l(:,j) = C(:, IC(j+1));
                    end
                otherwise
                    error('unimplemented case');
            end  % end switch
            
        end  % end function setInitialGuesses

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Find p(xi|zb), the probability of point xi, given the 
        % combination of activities specified by b. 
        function p = getPxGivenZb(obj, xi, b)
            zb = obj.z(:,b);
            % Find the expected rate vector, given the
            % specified combination of activities in zb.   
            indices = find(zb);     % Get indices of activities present
            lPresent = obj.l(:,indices);
            lb = sum(lPresent,2) + obj.lBackground;
            
            % Find the probability that vector xi could have been produced
            % by a Poisson with rate parameters lb.
            p = 1.0;
            for id=1:length(xi)
                p = p * evaluatePoisson(obj, xi(id), lb(id));
            end
        end  % end function getPxGivenZb
           
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Update the means of the activities. 
        function updateMeans(obj, meanBackground, meanForeground, x)
            obj.lBackground = meanBackground;
            obj.l = meanForeground;
        end  % end function updateMeans
   
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Print true parameters
        function printTrue(obj)
            if isempty(obj.lTrue)  return;  end
            disp('True parameters:');
            printParams(obj, obj.lBackgroundTrue, obj.lTrue, obj.wTrue, obj.fTrue);
        end  % end function printTrue

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Print estimated parameters
        function printEstimated(obj)
            disp('Estimated parameters:');
            printParams(obj, obj.lBackground, obj.l, obj.w, obj.f);
        end  % end function printTrue
    
    end  % end methods
    
    
    methods (Access = private)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Private function, to generate a Poisson distributed vector
        function v = generatePoisson(obj, r)
            d = length(r);  % Number of dimensions in the vector.
            v = zeros(d,1);
            
            for i=1:d
                ri = r(i);
                
                % For large rate, the normal distribution (with mean=r and variance=r)
                % is a good approximation to the Poisson and avoids overflow.
                if ri > 100
                    vi = ri + sqrt(ri)*randn(1);
                    if vi < 0
                        vi = 0;
                    end
                else
                    % Create the pdf for all possible values of vi.
                    VMAX = round(3*ri);     % Truncate beyond 3*lambda
                    pdf = zeros(VMAX+1,1);
                    vVals = 0:VMAX;
                    for j=1:VMAX+1
                        vj = vVals(j);
                        pdf(j) = evaluatePoisson(obj, vj, ri);
                    end
                    
                    % Construct the cdf (cummulative distribution)
                    cdf = cumsum(pdf);
                    
                    % Ok, pick a random number between 0 and 1.
                    x = rand;
                    
                    % Find the closest value to x in the cdf table
                    [~,index] = min(abs(x-cdf));
                    
                    vi = vVals(index);
                end
                v(i) = vi;
            end
        end  % end generatePoisson

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Private function, to plot data
        function plotData(obj, lBgnd, lFgnd, w, x)
            d = size(x,1);      % Number of dimensions
            m = size(x,2);      % Number of points
            k = size(lFgnd,2);      % Number of activities
            
            if k > 2    return;     end
            
            plot(0,0,'.');      % Erase figure
            
            mycolors = colormap(hsv(k));
            hold on
            for i=1:m
                [~,b] = max(w(:,i));        % Get combination for this point
                zb = obj.z(:,b);                    % zb(j)=1 if activity j is present
                acolors = mycolors(zb==1,:);    % Get reduced array of colors
                if isempty(acolors)
                    c = [0 0 0];                % Black for background activity only
                else
                    c = mean(acolors,1);        % Average colors of activities present
                end
                if d==2
                    plot(x(1,i), x(2,i), '.', 'Color', c);
                    text(x(1,i), x(2,i), sprintf('%d',i), 'Color', c, 'FontSize', 9);
                else
                    plot3(x(1,i), x(2,i), x(3,i), '.', 'Color', c);
                    text(x(1,i), x(2,i), x(3,i), sprintf('%d',i), 'Color', c, 'FontSize', 9);
                end
            end
            for j=1:k
                % Plot activity centers
                if d==2
                    plot(lFgnd(1,j), lFgnd(2,j), 's', 'Color', mycolors(j,:));
                    plot(lFgnd(1,j)+lBgnd(1), lFgnd(2,j)+lBgnd(2), 'o');
                else
                    plot3(lFgnd(1,j), lFgnd(2,j), lFgnd(3,j), 's', 'Color', mycolors(j,:));
                    plot3(lFgnd(1,j)+lBgnd(1), lFgnd(2,j)+lBgnd(2), lFgnd(3,j)+lBgnd(3), 'o');
                end
            end
            if d==2
                plot(lBgnd(1), lBgnd(2), 'sk');
                plot(lBgnd(1), lBgnd(2), 'o');
                xlim([0 max(x(1,:))]);
                ylim([0 max(x(2,:))]);
                axis equal
            else
                plot3(lBgnd(1), lBgnd(2), lBgnd(3), 'sk');
                plot3(lBgnd(1), lBgnd(2), lBgnd(3), 'o');
                xlim([0 max(x(1,:))]);
                ylim([0 max(x(2,:))]);
                zlim([0 max(x(3,:))]);
                axis vis3d
            end
            hold off
        end  % end function plotData
 
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Private function, to compute log probability of the whole dataset
        function Q = getLogProb(obj, lBgnd, lFgnd, w, x)
            d = size(x,1);  % number of dimensions
            m = size(x,2);  % number of points

            Q = 0;
            for i=1:m
                [~,b] = max(w(:,i));

                indices = find(obj.z(:,b));             % Get activity #s
                lb = lBgnd + sum(lFgnd(:,indices),2);   % Mean of this combination

                p = 1.0;
                for id=1:d
                    p = p * evaluatePoisson(obj, x(id,i), lb(id));
                end

                Q = Q + log(p);
            end
        end  % end function getLogProb
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Private function, to evaluate the Poisson distribution with 
        % count = k and rate parameter l.
        % Note the parameter is "L" not a "one".
        function p = evaluatePoisson(obj, k, l)
            % For large rate or large counts, the normal distribution (with 
            % mean=l and variance=l) is a good approximation to the Poisson and 
            % avoids overflow.
            if l > 100 || k >= length(obj.factorialValues)
                p = exp( -((k-l)^2)/(2*l) ) / sqrt(2*pi*l);
            else
                %p = (l^k)*exp(-l)/factorial(k);
                p = (l^k)*exp(-l)/obj.factorialValues(k+1);
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Private function, to print the mixture parameters.
        function printParams(obj, lBgnd, lFgnd, w, f)
            disp('Background:');
            disp(lBgnd);
            disp('Foreground:');
            disp(lFgnd);
            disp('A priori probabilities each combination of activities:');
            disp([ [1:size(f,1)]'  obj.z'   f ]);
            disp(' ');
        end  % end function printParams
            
    end  % end methods (private)
end


