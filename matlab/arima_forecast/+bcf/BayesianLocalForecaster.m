classdef BayesianLocalForecaster < handle
    %Class for our Bayesian Local activity forecaster
    
    properties
        models = {};
        minProb;
        maxProb;
    end
    
    methods
        function obj = BayesianLocalForecaster(models)
            %The models should be from the avg gaussian model class.
            %The final model should be a length 1 distribution from the 
            %exponential family representing the background noise.
            obj.models = models;
            obj.minProb = 0.001;
            obj.maxProb = 0.999;
        end
        
        function setMinMaxProb(obj, minProb, maxProb)
            %Set the minimum and maximum values for pmodel
            obj.minProb = minProb;
            obj.maxProb = maxProb;
        end
                
        function [fdata] = forecastAll(obj, data, ahead)
            
            %First compute models lengths
            ml = zeros(1, length(obj.models));
 
            for i = 1:length(obj.models)
                ml(1, i) = obj.models{i}.modelLength;
            end
            
            %compute the constant priors
            cp = zeros(1, length(obj.models)) + 0.02;
            cp(1, end) = 0.98;
            cp = cp / sum(cp);
            
            %setup variables - likelihoods, priors, and posteriors
            p = {};
            post = {};
            l = {};
            histPost = {};
            
            for j = 1:size(ml, 2)
                p{j} = ones(1, ml(1, j));
                l{j} = ones(1, ml(1, j));
                post{j} = ones(1, ml(1, j)); %#ok<*AGROW>
                histPost{j} = ones(ml(1, j), size(data, 2)); 
            end
            
            %Normalize the priors
            cellTotal = sum(cellfun(@sum, p));
            p = cellfun(@(v)v./cellTotal, p, 'UniformOutput', false);
            
            fdata = data;

            
            %Go through whole dataset
            for t = 1:size(data, 2) - ahead

                %compute model likelihoods
                for m = 1:length(obj.models)
                    for j = 1:ml(1, m)
                        l{m}(1, j) = obj.models{m}.likelihood(data(1, t), j); 
                        %l{m}(1, j) = models{m}.likelihood(resTest(1, t - j + 1:t), j);
                    end    
                end

                %compute posteriors

                %p(m|y) = p(y|m)p(m)/p(y)
                for m = 1:length(obj.models)
                    for j = 1:ml(1, m)
                        post{m}(1, j) = l{m}(1, j) * p{m}(1, j);
                    end
                end

                for m = 1:length(obj.models)
                    post{m}(post{m} <= 0.00001) = 0.00001;
                end

                %normalize
                cellTotal = sum(cellfun(@sum, post));
                post = cellfun(@(v)v./cellTotal, post, 'UniformOutput', false);

                %Save the posteriors
                for m = 1:length(obj.models)
                    for j = 1:ml(1, m)
                        histPost{m}(j, t) = post{m}(1, j); 
                    end
                end

                %Update the priors
                for m = 1:length(obj.models)
                    for j = 2:ml(1, m)
                        p{m}(1, j) = post{m}(1, j - 1);
                    end
                    if m < length(obj.models)
                        p{m}(1, 1) = cp(1, m);
                    end
                end

                %normalize priors
                cellTotal = sum(cellfun(@sum, p));
                p = cellfun(@(v)v./cellTotal, p, 'UniformOutput', false);

                %forecast based weighted posteriors
                for m = 1:length(obj.models)
                    for j = 1:ml(1, m)
                        fdata(1, t + ahead) = fdata(1, t + ahead) + ...
                            obj.models{m}.forecastSingle(j, ahead) * post{m}(1, j);
                    end
                end    
            end
        end
    end
end