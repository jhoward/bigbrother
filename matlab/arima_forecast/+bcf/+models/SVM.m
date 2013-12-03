classdef SVM < bcf.models.Model
    %Support vector regression
    %   Add multiple dimensions later   
    
    %For SVM models there is a "model parameters" function which dictates
    %the accuracy of a given model
    
    properties
        model
        modelParameters
        window
    end
    
    methods
        function obj = SVM(modelParameters, window)
            obj.modelParameters = modelParameters;
            obj.window = window;
        end

        function train(obj, data)
            %Train the model from a single dimensional dataset
            xWin = zeros(obj.window, size(data, 2) - 1 - obj.window);
            for i = 1 : size(data, 2) - obj.window
                xWin(:, i) = data(1, i:i + obj.window - 1);
            end
            
            yWin = data(obj.window + 1:end);
            
            obj.model = svmtrain(yWin',xWin',obj.modelParameters);
        end
        
        function val = forecastSingle(obj, data, ahead)
            val = obj.mu;
        end
        
        function output = forecastAll(obj, data, ahead, varargin)
            output = bcf.forecast.svmForecast(obj.model, data, ahead);
        end
            
        function prob = probabilityNoise(obj, data)
            data = data .* obj.noiseMult;
            prob = mvnpdf(data', obj.noiseMu^2, obj.noiseSigma);
        end
        
        function calculateNoiseDistribution(obj, data, ahead)
            out = obj.forecastAll(data, ahead);
            res = data - out;
            res = res .* obj.noiseMult;
            pd =  fitdist(res', 'Normal');
            obj.noiseMu = pd.mean;
            obj.noiseSigma = pd.std;
        end
    end
end


