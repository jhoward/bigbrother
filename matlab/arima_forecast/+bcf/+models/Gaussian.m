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
        
        function output = forecastSingle(obj, data, ahead, varargin)
            output = obj.mu;
        end
        
        function output = forecastAll(obj, data, ahead, varargin)
            output = ones(size(data)) .* obj.mu;
        end
            
        function val = probability(obj, data)
            %Forecast for a model the probability of each observation
            %TODO Change this later
            prob = mvnpdf(data, obj.noiseMu, obj.noiseSigma);
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
        end
    end
end

