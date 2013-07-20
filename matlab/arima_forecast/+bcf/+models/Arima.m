classdef Arima < bcf.models.Model
    %GAUSSIANMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        model
        blocksInDay
    end
    
    methods
        function obj = Arima(model, blocksInDay)
            obj.model = model;
            obj.blocksInDay = blocksInDay;
        end
        
        function val = forecastSingle(obj, data, ahead)
            val = obj.mu;
        end
        
        function train(obj, data, varargin)
            
            if nargin < 3
   error(message('econ:arima:forecast:NonEnoughInputs'))
end

parser = inputParser;
parser.CaseSensitive = true;
parser.addRequired  ('numPeriods',    @(x) validateattributes(x, {'double'}, {'scalar' 'integer' '>' 0}, '', 'forecast horizon'));
parser.addParamValue('E0'        , 0, @(x) validateattributes(x, {'double'}, {}, '', 'presample residuals'));
parser.addParamValue('V0'        , 0, @(x) validateattributes(x, {'double'}, {}, '', 'presample variances'));

try 
  parser.parse(fSteps, varargin{:});
catch exception
  exception.throwAsCaller();
end

horizon = parser.Results.numPeriods;
E0      = parser.Results.E0;
V0      = parser.Results.V0;
            
            ar = 0;
            diff = 1;
            ma = 1;
            sar = 0;
            sdiff = data.blocksInDay;
            sma = 4;

            arimaModel = arima('ARLags', 1:ar, 'D', diff, 'MALags', 1:ma, ...
                        'SARLags', 1:sar, 'Seasonality', sdiff, 'SMALags', 1:sma);

            model = estimate(arimaModel, data', 'print', true);
        end
        
        function output = forecastAll(obj, data, ahead, varargin)
            output = bcf.forecast.arimaForecast(obj.model, ahead, data');
        end
            
        function prob = probabilityNoise(obj, data)
            
            prob = mvnpdf(data, obj.noiseMu, obj.noiseSigma);
        end
        
        function calculateNoiseDistribution(obj, data, ahead)
            out = obj.forecastAll(data, ahead);
            res = data - out;
            tmpRes = reshape(res, size(res, 1), obj.blocksInDay, size(res, 2)/obj.blocksInDay);
            pd =  fitdist(res', 'Normal');
            obj.noiseMu = pd.mean;
            obj.noiseSigma = pd.std^2;
            obj.dayNoiseMu = mean(tmpRes, 3);
            obj.dayNoiseSigma = std(tmpRes, 0, 3);
        end
    end
end


