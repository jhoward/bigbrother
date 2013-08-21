classdef HMM < handle
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
                mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', 50);
            
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
        

        function output = forecastSingle(obj, data, ahead, varargin)
            output = bcf.forecast.hmmForecastSingle(obj, data, ahead);
        end
        
        
        function like = likelihood(obj, data, offset)
            %Data is of a shape of (dim X time)

            %Compute the observation likelihood for the given data
            obslik = mixgauss_prob(data(1, :), obj.mu, obj.Sigma, obj.mixmat);
            [alpha, ~, ~, ~]= fwdback(obj.prior, obj.transmat, obslik, 'fwd_only', 1, 'scaled', 1);
            
            %From alpha compute p(data(1, end)|alpha(:, end))
             like = exp(mhmm_logprob(data(1, end), alpha(:, end), obj.transmat, obj.mu, obj.sigma, obj.mixmat));
        end

        
        function calculateExpectedValueStates(obj)
            %Computes expected values for states.
            tmpMix = reshape(obj.mixmat, [1 size(obj.mixmat)]);
            tmpMix = repmat(tmpMix, [size(obj.mu, 1) 1 1]);
            tmpMu = obj.mu .* tmpMix;
            obj.stateEVal = sum(tmpMu, 3);
        end
        
        function samples = sampleData(obj, sampleLen, numSamples)
            %generate samples for the model
            [obs, ~] = mhmm_sample(sampleLen, numSamples, obj.prior, obj.transmat, obj.mu, obj.sigma, obj.mixmat);
            samples = obs;
        end
    end
end


