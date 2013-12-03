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
                
        function [fdata] = forecastAll(obj, data, ahead, ftype)
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
                post{j} = ones(1, ml(1, j));
                histPost{j} = ones(ml(1, j), size(data, 2));
            end
            
            %Normalize the priors
            cellTotal = sum(cellfun(@sum, p));
            p = cellfun(@(v)v./cellTotal, p, 'UniformOutput', false);
            
            fdata = [];

            
            
            
        end
    end
end