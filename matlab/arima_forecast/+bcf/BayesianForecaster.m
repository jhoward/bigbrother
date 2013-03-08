classdef BayesianForecaster < handle
    %BAYESIANFORECASTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        models = [];
        stds = [];
        means = [];
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
            fprintf(1, 'updateing pmodel\n');
            pmodel = 0;
        end
        
        function [f pmodel] = forecastSingle(obj, data, pmodel, ftype)
            %Forecast the next point from a timeseries
            %possible types are best and aggregate
            fprintf(1, 'forecast single\n');
            f = 0;
            pmodel = 0;
        end
        
        function [fdata probs window models] = ...
                forecast(obj, data, windowLen, ftype)
            %Perform a complete forecast for a dataset.  Initial model
            %probabilities are set to 1/numModels
            
            %Returns all forecasts for data and all probabilities of
            %forecasts
            fdata = 0;
            probs = 0;
            window = 0;
            models = 0;
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

