classdef HMM < bcf.models.Model
    %HMM Hidden Markov model class
    
    properties
        stateEVal           %weighted expected value (mean) for each state
        mu                  %means for each state
        sigma               %covariance matrix for each state
        prior               %prior
        mixmat              %mixing matrix
        transmat            %transition matrix
        Q                   %Number of states
        M                   %Number of gaussians per state
    end
    
    methods
        function obj = HMM(Q, M)
            obj.Q = Q;
            obj.M = M;
            
        end

        function train(obj, data) 
            %TODO Add in other options here to pre specify the matricies or
            %format them.
            prior0 = normalise(rand(obj.Q,1));
            transmat0 = mk_stochastic(rand(obj.Q,obj.Q));

            [mu0, Sigma0] = mixgauss_init(obj.Q*obj.M, ...
                reshape(data, [size(data, 1) size(data, 2) * size(data, 3)]), 'full');
            mu0 = reshape(mu0, [size(data, 1) obj.Q obj.M]);
            Sigma0 = reshape(Sigma0, [size(data, 1) size(data, 1) obj.Q obj.M]);
            mixmat0 = mk_stochastic(rand(obj.Q,obj.M));
            
            if obj.M == 1
                mixmat0 = ones(obj.Q, 1);
            end

            [~, prior1, transmat1, mu1, Sigma1, mixmat1] = ...  
                mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', 40);
            
            obj.mu = mu1;
            obj.sigma = Sigma1;
            obj.prior = prior1;
            obj.mixmat = mixmat1;
            obj.transmat = transmat1;
            
            obj.calculateExpectedValueStates();
        end
        
        function output = forecastAll(obj, data, ahead, varargin)
            %Forecast every spot in a dataset as though it came from ahead
            %spots before.
            parser = inputParser;
            parser.CaseSensitive = true;
            parser.addOptional('window', 4, @isnumeric);
            parser.parse(varargin{:});
            window = parser.Results.window;
            
            output = data;
            
            if window > 0
                for i = window:size(data, 2) - ahead
                    output(:, i + ahead) = bcf.forecast.hmmForecastSingle(obj, data(:, i - window + 1:i), ahead);
                end
            else
                output = bcf.forecast.hmmForecast(obj, data, ahead);
            end
        end
        
        function output = forecastSingle(obj, data, ahead, varargin)
            output = bcf.forecast.hmmForecastSingle(obj, data, ahead);
        end
            
        function prob = probabilityNoise(obj, data)
            %Computes the probability that some noise lies within this
            %models forecasted noise
            prob = mvnpdf(data, obj.noiseMu, obj.noiseSigma);
        end
        
        function calculateNoiseDistribution(obj, data)
            %Computes the models distribution for common noise forecasts
            res = [];
            for i = 1:size(data, 3)
                out = obj.forecastAll(data(:, :, i), 1, 'window', 0);
                res = [res (data(:, 2:end, i) - out(:, 2:end))]; %#ok<AGROW>
            end
            pd =  fitdist(res', 'Normal');
            obj.noiseMu = pd.mean;
            obj.noiseSigma = pd.std^2;
        end
        
        function calculateExpectedValueStates(obj)
            %Computes expected values for states.
            tmpMix = reshape(obj.mixmat, [1 size(obj.mixmat)]);
            tmpMix = repmat(tmpMix, [size(obj.mu, 1) 1 1]);
            tmpMu = obj.mu .* tmpMix;
            obj.stateEVal = sum(tmpMu, 3);
        end
    end
end


