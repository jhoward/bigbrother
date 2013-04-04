classdef Gaussian < bcf.models.Model
    %GAUSSIANMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mu
        sigma
        history
    end
    
    methods
        function obj = Gaussian(mu, sigma)
            obj.mu = mu;
            obj.sigma = sigma;
            obj.history = 0;
        end
        
        function val = forecast(obj, data, ahead)
            val = obj.mu;
        end
        
        function output = forecastAll(obj, data, ahead)
            output = ones(size(data)) .* obj.mu;
        end
            
        function val = probability(obj, data)
            %Forecast for a model the probability of each observation
            %TODO Change this later
            val = 1;
        end
        
        
        function calculateNoiseDistribution(obj, data)
            out = obj.forecastAll(data, 1);
            res = data - out;
            pd =  fitdist(res', 'Normal');
            obj.noiseMu = pd.mean;
            obj.noiseSigma = pd.std;
        end
        
        
        function prob = probabilityNoise(obj, data)
            prob = mvnpdf(data, obj.noiseMu, obj.noiseSigma);
<<<<<<< HEAD
        end
        
        function calculateNoiseDistribution(obj, data)
            out = obj.forecastAll(data, 1);
            res = data - out;
            pd =  fitdist(res', 'Normal');
            obj.noiseMu = pd.mean;
            obj.noiseSigma = pd.std^2;
=======
>>>>>>> End of Day
        end
    end
end

