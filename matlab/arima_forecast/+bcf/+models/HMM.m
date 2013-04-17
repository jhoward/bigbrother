classdef HMM < bcf.models.Model
    %HMM Hidden Markov model class
    
    properties
        stateEVal
        mu
        sigma
        prior
        mixmat
        transmat
    end
    
    methods
        function obj = HMM(mu, sigma, prior, mixmat, transmat)
            obj.mu = mu;
            obj.sigma = sigma;
            obj.prior = prior;
            obj.mixmat = mixmat;
            obj.transmat = transmat;
        end
        
        function val = forecast(obj, data, ahead)
            %Perform this later
            val = 1;
        end
        
        function output = forecastAll(obj, data, ahead)
            output = bcf.forecast.hmmForecast(obj.model, ahead, data);
        end
            
        function prob = probabilityNoise(obj, data)
            %Computes the probability that some noise lies within this
            %models forecasted noise
            prob = mvnpdf(data, obj.noiseMu, obj.noiseSigma);
        end
        
        function calculateNoiseDistribution(obj, data)
            %Computes the models distribution for common noise forecasts
            out = obj.forecastAll(data, 1);
            res = data - out;
            pd =  fitdist(res', 'Normal');
            obj.noiseMu = pd.mean;
            obj.noiseSigma = pd.std^2;
        end
        
        function calcualateExpectedValuesStates(obj)
            %Computes expected values for states.
            tmpMix = reshape(obj.mixmat, [1 size(obj.mixmat)]);
            tmpMix = repmat(tmpMix, [size(obj.mu, 1) 1 1]);
            tmpMu = obj.mu .* tmpMix;
            obj.stateEVal = sum(tmpMu, 3);
        end
    end
end


