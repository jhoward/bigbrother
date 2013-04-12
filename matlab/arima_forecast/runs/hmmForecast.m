function output = hmmForecast(prior, transmat, mu, sigma, mixmat, data, ahead)
    %prior should be a 1 by numStates
    %mu = sizeDimensions by States by numMixtures
    
    output = [];
    
    %Compute the expected value for each state
    tmpMix = reshape(mixmat, [1 size(mixmat)]);
    tmpMix = repmat(tmpMix, [size(mu, 1) 1 1]);
    tmpMu = mu .* tmpMix;
    eVals = sum(tmpMu, 3);
        
    %Set the prior and establish a min state prob
    currentState = prior;
    currentState(currentState < 0.0001) = 0.0001;
    currentState = currentState / sum(currentState);
    
    %First compute given a prior probability the new output for t + ahead
    out = currentState .* eVals;
    output = [sum(out, 2) output];
    
    %Step given output
    obslik = mixgauss_prob(output, mu, sigma, mixmat);
    [alpha, beta, gamma, ll] = fwdback(currentState, transmat, obslik, 'fwd_only', 1);
    %output = alpha
end

