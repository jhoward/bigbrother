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
            
            %mu0
            %Sigma0
            %mixmat0
            
            if obj.M == 1
                mixmat0 = ones(obj.Q, 1);
            end

            [~, prior1, transmat1, mu1, Sigma1, mixmat1] = ...  
                mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', 40);
            
            %Renormalize the transition matrix
            minTransValue = 1 / (obj.Q * 4);
            transmat1(transmat1 < minTransValue) = minTransValue;
            tmp = repmat(sum(transmat1, 2), 1, obj.Q);
            transmat1 = transmat1 ./ tmp;
            
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
                    %data(:, i - window + 1:i)
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
            
            %First discretize the pdf
            %For now just always go from -2 to 2 by .1
            range = (obj.noiseMu - 2 * obj.noiseSigma):(obj.noiseSigma / 50):(obj.noiseMu + 2 * obj.noiseSigma);
            dValues = normpdf(range, obj.noiseMu, obj.noiseSigma);
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
        
        function calculateNoiseDistribution(obj, data)
            %Computes the models distribution for common noise forecasts
            %res = [];
            out = [];
            for i = 1:size(data, 3)
                out = [out; obj.forecastAll(data(:, :, i), 1, 'window', 0)];
            end
            data2d = reshape(data, size(data, 2), size(data, 3));
            data2d = data2d';
            
            foo = out - data2d;
            obj.noiseSigma = mean(std(foo, 1, 1));
            obj.noiseMu = mean(mean(foo, 1));
            %pd =  fitdist(res', 'Normal');
            %obj.noiseMu = pd.mean;
            %obj.noiseSigma = pd.std^2;
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


