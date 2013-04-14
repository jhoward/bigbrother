function output = hmmForecast(prior, transmat, mu, sigma, mixmat, data, ahead)
    %prior should be a 1 by numStates
    %mu = sizeDimensions by States by numMixtures
    
    output = data;
    
    %Compute the expected value for each state
    tmpMix = reshape(mixmat, [1 size(mixmat)]);
    tmpMix = repmat(tmpMix, [size(mu, 1) 1 1]);
    tmpMu = mu .* tmpMix;
    eVals = sum(tmpMu, 3);
        
    %Set the obeservation likelihoods for the whole dataset
    obslik = mixgauss_prob(data, mu, sigma, mixmat);
    [alpha, ~, gamma, ~] = fwdback(prior, transmat, obslik, 'fwd_only', 1);

    %fitdist(obslik(:, 5), 'normal')
    %fitdist(alpha(:, 5), 'normal')
    
    for t = 1:size(data, 2) - ahead
        %Get the current state
        currentState = alpha(:, t + ahead);
        currentState(currentState < 0.0001) = 0.0001;
        currentState = currentState / sum(currentState);
        
        futureState = currentState;
        
        for i = 1:ahead
            %Step ahead in states
            futureState = transmat * futureState;
            futureState(futureState < 0.0001) = 0.0001;
            futureState = futureState / sum(futureState);
        end
        
        %Compute the output from the future state.
        output(:, t + ahead) = sum(futureState' .* eVals, 2);
    end
    
    %plot(output)
end