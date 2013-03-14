classdef BayesianForecaster < handle
    %BAYESIANFORECASTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        models = [];
        minProb;
        maxProb;
    end
    
    methods
        function obj = BayesianForecaster(models)
            obj.models = models;
            obj.minProb = 0.01;
            obj.maxProb = 0.99;
            %obj.stds = ones(1, size(models, 2));
            %obj.means = zeros(1, size(models, 2));
        end
        
        function setMinMaxProb(obj, minProb, maxProb)
            %Set the minimum and maximum values for pmodel
            obj.minProb = minProb;
            obj.maxProb = maxProb;
        end
        
        function [pmodel] = ...
                    updatepmodel(obj, data, pmodel) 
            %Update the probabilities for all models

            probs = zeros(size(pmodel));
            
            for k = 1:size(pmodel, 2)
                probs(1, k) = mvnpdf(data(:, end) - obj.models(k).forecast(data(:, 1:(end - 1)), 1), ...
                                    obj.models(k).fnMu, obj.models(k).fnSigma);
            end

            nc = pmodel * probs';
            pmodel = (probs.*pmodel)./nc;
            
            pmodel(pmodel <= obj.minProb) = obj.minProb;
            pmodel(pmodel >= obj.maxProb) = obj.maxProb;
            
            %TODO
            %Redistribute the probabilities according to the probability
            %limits
        end
        
        function [f] = forecastSingle(obj, data, pmodel, ahead, ftype)
            %Forecast a single point in a time series.  The point may be
            %steps ahead
            tmp = obj.models(1).forecast(data(:, end - 1));
            f = zeros(size(tmp));
            
            if strcmp(ftype, 'aggregate')
                for k = 1:size(pmodel, 2)
                    f = f + pmodel(k).*obj.models(k).forecast(data(:, 1:end), ahead);
                end
            end
            
            if strcmp(ftype, 'best')
                [~, ind] = max(pmodel);
                f = obj.models(ind).forecast(data(:, 1:end), ahead);
            end            
        end
        
        function [fdata probs models] = ...
                forecast(obj, data, windowLen, ahead, ftype)
            %Perform a complete forecast for a dataset.  Initial model
            %probabilities are set to 1/numModels
            
            %Returns all forecasts for data and all probabilities of
            %forecasts
            
            probs = ones(size(obj.models, 2), size(data, 2));
            probs = probs ./ size(obj.models, 2);            
            models = zeros(1, size(data, 2));
            fdata = data;
            
            for i = windowLen + 1:size(data, 2) - ahead
                pmodels = probs(:, i - 1)';
                probs(:, i) = obj.updatepmodel(data(i - windowLen:i), pmodels);

                [f] = obj.forecastSingle(data(i - windowLen:i), ...
                                           probs(:, i)', ahead, ftype);
                [~, ind] = max(pmodels);
                models(1, i) = ind;
                fdata(:, i + ahead) = f;
            end
        end
        
        function [fdata probs models] = forecastStatic(obj, data, ftype)
            %Perform a complete forecast for a dataset.  Initial model
            %probabilities are set to 1/numModels
            
            %This method works with static window and ahead forecasters.
            %Such as neural networks
            
            %First make a forecast for each model.
            %TODO change this to handle 1 step and multi step forecasts.
            %Only handles one step now
            fcasts = repmat(data, [1 1 size(obj.models, 2)]);
            dexpand = repmat(data, [1 1 size(obj.models, 2)]);
            for k = 1:size(obj.models, 2)
                fcasts(:, :, k) = obj.models(k).forecast(data, 1);
            end
         
            diffs = fcasts - dexpand;
            initial = ones(size(obj.models));
            initial = initial ./ size(obj.models, 2);

            %batch update pmodels
            aPmodels = obj.updatePModelsBatch(diffs, initial);
            
            probs = [];
            models = [];
            fdata = aPmodels;
        end
        
        function aPmodels = updatePModelsBatch(obj, diffs, pmodels)
            %Diffs is presumed to be a N by M by numModels matrix where
            %data is of length M with dimensionality N
            
            %pmodels is of size 1 by numModels
            %aPmodels will be of size numModels by M
            %pks (probability of model k given forecasting noise) is
            %numModels by M
            
            aPmodels = ones(size(obj.models, 2), size(diffs, 2));
            aPmodels(:, 1) = pmodels';
            pks = ones(size(pmodels, 2), size(diffs, 2));
            
            for k = 1:size(obj.models, 2)
                pks(k, :) = obj.models(k).probabilityNoise(diffs(:, :, k)');
            end

            
            
                %Reset values
            pks(pks <= obj.minProb) = obj.minProb;
            pks(pks >= obj.maxProb) = obj.maxProb;
            
            
            for i = 2:size(diffs, 2)
                
                %Compute the normalizing constant
                nc = aPmodels .* pks;

                %Finish this tomorrow.
            
            
                aPmodels(:, i) = (aPmodels(:, i - 1) .* pks) ./ nc;
            end
        end
        
      
        function [fdata probs models windows forecasts] = ...
                windowForecast(obj, data, minWindow, maxWindow, ahead, ftype)
        
            %TODO implement modles array
            numWindows = maxWindow - minWindow + 1;
            windows = ones(1, size(data, 2));
            probs = ones(numWindows, size(obj.models, 2), size(data, 2));
            probs = probs ./ size(obj.models, 2);
            models = [];
            
            fdata = data;
            forecasts = repmat(data, [1 1 numWindows]);
            
            %Array sizes
            %probs          numWindows X numModels X lenghtData
            %forecasts      dimData X lenghtData X numWindows
            %i = time location in data
            %j = window size
            
            for i = maxWindow + 1:size(data, 2) - ahead                
                for j = minWindow:maxWindow
                    winIndex = j - minWindow + 1;
                    p = probs(winIndex, :, i); %size: 1 X numModels                    
                    [f] = obj.forecastSingle(data(:, i - j:i + ahead), p, ahead, ftype);                    
                    
                    forecasts(:, i + ahead, winIndex) = f;
                    probs(winIndex, :, i + ahead) = obj.updatepmodel(data(:, i - j:i + ahead), p, ahead);                    
                end
                
                %Get the best probability
                [~, i1] = max(max(probs(:, :, i), [], 2));
                [~, i2] = max(max(probs(:, :, i), [], 1));
                fdata(:, i + ahead) = forecasts(:, i + ahead, i1);
                windows(1, i + ahead) = i1;
            end
        end
    end
end