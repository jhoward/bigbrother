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
        
        function train(obj, data)
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
            obj.noiseSigma = std(res, 1, 2);
            obj.noiseMu = mean(res, 2);
            %pd =  fitdist(res', 'Normal');
            %obj.noiseMu = pd.mean;
            %obj.noiseSigma = pd.std^2;
        end
        
        
        function prob = probabilityNoise(obj, data)
            %Computes the probability that some noise lies within this
            %models forecasted noise

            %First discretize the pdf
            %For now just always go from -2 to 2 by .1
            range = -2:0.01:2;
            dValues = normpdf(range, 0, obj.noiseSigma);
            dValues(dValues < 0.000000001) = 0.000000001;
            dValues = dValues ./ sum(dValues);
            prob = zeros(size(data));
            
            for i = 1:size(data, 2)
                %Change this to include values equal to zero
                foo = max(find(range <= data(1, i))) + 1;
                foo = min([length(dValues), foo]); 
                prob(1, i) = dValues(foo);
            end
            %prob = normpdf(data, obj.noiseMu, obj.noiseSigma);
        end
    end
end

