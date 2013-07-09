classdef BCFContainer < handle
    %Container class to simplify usage of the Bayesian combined forecaster
    
    %Setup a bayesian forecaster and trains the component models 
    %as necessary

    
    properties
        models = {};
        data;
        minProb;
        maxProb;
        trainPercent; %Data taken from begining of data set
        testPercent;  %Data taken from middle of dataset
        validationPercent; %Data taken from end of dataset
    end    

    
    methods
        function obj = BayesianForecaster(models)
            obj.models = models;
            obj.minProb = 0.001;
            obj.maxProb = 0.999;
        end
        
        function setMinMaxProb(obj, minProb, maxProb)
            %Set the minimum and maximum values for pmodel
            obj.minProb = minProb;
            obj.maxProb = maxProb;
        end

        function trainModels(obj)
        
        end
    end
