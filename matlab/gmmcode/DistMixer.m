classdef DistMixer
    %Datapoints existing in D dimensional space
    %Generated from a set of poissons or gaussians
    
    properties
        distribution = 'Gaussian';
        D = 2;
        K = 2;
        means = zeros(D, K);
        vars = zeros(D,D,K);
    end
    
    methods
    end
end

