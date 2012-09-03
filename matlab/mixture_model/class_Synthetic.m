classdef class_Synthetic < handle
    % Holds all information about synthetic dataset
    
    properties
        % A priori probability of each activity, size(k,1)
        fTrue
        
        % True pmfs, size (M,d,k)
        pmfTrue
        
        % Probability of each activity for each point, size(k,m).
        wTrue    % wji = p(aj|xi)
        
        % The data points, size(d,m)
        x
    end
    
    methods
        function obj = class_Synthetic(m,d,k,M)

            % For simplicity, just use Gaussians to create the data.
            % M-1 is the maximum value of any dimension of x.
            uTrue = (M-1)*rand(d,k);   % Means of Gaussians
            
            obj.x = zeros(d,m);
            aTrue = zeros(m,1);
            for i=1:m
                % Decide which Guassian this point belongs to
                p = randperm(k);
                j = p(1);
                obj.x(:,i) = round( uTrue(:,j) + (M/4)*randn(d,1) );
                obj.x(:,i) = max( obj.x(:,i), zeros(d,1) );
                obj.x(:,i) = min( obj.x(:,i), (M-1)*ones(d,1) );
                aTrue(i) = j;
            end
            
            % Estimate true f = p(aj)
            obj.fTrue = zeros(k,1);
            for j=1:k
                obj.fTrue(j) = sum(aTrue==j);
            end
            obj.fTrue = obj.fTrue/sum(obj.fTrue);
            
            % Estimate true w.  Each w(j,i) = wji = p(aj|xi).
            obj.wTrue = zeros(k,m);
            for i=1:m
                obj.wTrue(aTrue(i),i) = 1;
            end
            
            % Estimate true pmf
            obj.pmfTrue = estimatePmf(obj.x, obj.wTrue);
            
            % Estimate true log probability of the dataset
            [~,logProbTrue] = estimateLogProb(obj.x, obj.wTrue, ...
                obj.fTrue, obj.pmfTrue);
            fprintf('True log probability = %g\n', logProbTrue);
            
            % Draw true pmfs
            figure(1);
            for j=1:k
                if k<=6
                    subplot(1,k,j), imshow(obj.pmfTrue(:,:,j),[]);
                else
                    nRows = ceil(k/6);
                    subplot(nRows,6,j), imshow(obj.pmfTrue(:,:,j),[]);
                end
                    title(sprintf('%.2f', obj.fTrue(j)));
            end
            colormap hot
            pause(0.1);
    
    
            disp(' '), disp('True pmf:'), disp(obj.pmfTrue);
            fprintf('True log probability = %g\n', logProbTrue);
            
        end  % end constructor
        
        
        function AnalyzeResults(obj,w,pmf,px)
        end
        
    end  % end methods
    
end

