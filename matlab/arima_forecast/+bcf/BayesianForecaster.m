classdef BayesianForecaster < handle
    %BAYESIANFORECASTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        models = [];
    end
    
    methods
        function obj = BayesianForecaster(models)
            obj.models = models;
            obj.stds = ones(1, size(models, 2));
            obj.means = zeros(1, size(models, 2));
        end
        
        function [pmodel] = ...
                    updatepmodel(obj, data, pmodel, minProb, maxProb) 
            %Update the probabilities for all models
            nc = 1;
            
            %calculate the normalizing constant
            for k = 1:size(pmodel, 2)
                mnvpdf(data(end) - self.models[k].forecast(data)
            end
            
        end
        
        function [f pmodel] = forecastSingle(obj, data, pmodel, ftype)
            %Forecast the next point from a timeseries
            %possible types are best and aggregate
            
            
        end
        
        function [fdata probs window models] = ...
                forecast(obj, data, windowLen, ftype)
            %Perform a complete forecast for a dataset.  Initial model
            %probabilities are set to 1/numModels
            
            %Returns all forecasts for data and all probabilities of
            %forecasts
            window = 0;
            models = 0;
            
            probs = ones(size(models, 2), size(data, 2));
            fdata = zeros(size(data));
            fdata(1:windowLen) = data(1:windowLen);
            
            %Slide over all possible windows
                %obtain a forecast for each model
                %update forecast data 
                %update probabilities
            
            
        end
        
        function [fdata probs window models] = ...
                windowForecast(obj, data, minWindow, maxWindow, ftype)
            
            fdata = 0;
            probs = 0;
            window = 0;
            models = 0;
        end
    end
end

