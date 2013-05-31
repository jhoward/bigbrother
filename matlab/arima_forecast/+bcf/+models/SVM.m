classdef SVM < bcf.models.Model
    %Support vector regression
    %   Add multiple dimensions later    
    properties
        model
        modelParameters
    end
    
    methods
        function obj = SVM(modelParameters)
            obj.modelParameters = modelParameters;
        end
        
        function train(obj, data, window)
            %Train the model from a single dimensional dataset
            xWin = zeros(window, size(data, 2) - 1 - window);
            for i = 1 : size(data, 2) - window
                xWin(:, i) = data(1, i:i + window - 1);
            end
            
            yWin = data(window + 1:end);
            
            obj.model = svmtrain(yWin',xWin',obj.modelParameters);
        end
        
        function val = forecastSingle(obj, data, ahead)
            val = obj.mu;
        end
        
        function output = forecastAll(obj, data, ahead, varargin)
            output = bcf.forecast.svmForecast(obj.model, data, ahead);
        end
            
        function prob = probabilityNoise(obj, data)
            prob = mvnpdf(data, obj.noiseMu, obj.noiseSigma);
        end
        
        function calculateNoiseDistribution(obj, data, ahead)
            out = obj.forecastAll(data, ahead);
            res = data - out;
            pd =  fitdist(res', 'Normal');
            obj.noiseMu = pd.mean;
            obj.noiseSigma = pd.std^2;
        end
    end
end


