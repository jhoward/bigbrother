function [Y,YMSE,V] = forecastArima(OBJ, numPeriods, varargin)
%FORECAST Forecast ARIMA model responses and conditional variances
%
% Syntax:
%
%   [Y,YMSE,V] = arimaForecast(OBJ,numPeriods)
%   [Y,YMSE,V] = arimaForecast(OBJ,numPeriods,param1,val1,param2,val2,...)
%
% Description:
%
%   Forecast responses and conditional variances of a univariate time series
%   whose structure is characterized by an ARIMA(P,D,Q) process. 
%
% Input Arguments:
%
%   OBJ - ARIMA model specification object, as produced by the ARIMA 
%     constructor or ARIMA/ESTIMATE method.
%
%   numPeriods- Positive integer specifying the forecast horizon, in 
%     periods consistent with the underlying model OBJ and the sampling 
%     frequency of any presample data. 
%
% Optional Input Parameter Name/Value Pairs:
%
%   'Y0'         Presample response data, providing initial values for the 
%                model. Y0 is a column vector or a matrix. If Y0 is a column 
%                vector, then it is applied to each forecasted path. If Y0 
%                is a matrix, then it must have numPaths columns (see notes
%                below). Y0 may have any number of rows, provided at least 
%                OBJ.P observations exist to initialize the model. If the 
%                number of rows exceeds OBJ.P, then only the most recent OBJ.P
%                observations are used. If Y0 is unspecified, any necessary 
%                presample observations are set to the unconditional mean 
%                of the process if the process is stationary, or to zero if 
%                the process is non-stationary. The last row contains the 
%                most recent observation.
%
%   'E0'         Mean-zero presample innovations, providing initial values 
%                for the model. E0 is a column vector or a matrix. If E0 is 
%                a column vector, then it is applied to each forecasted path. 
%                If E0 is a matrix, then it must have numPaths columns (see 
%                notes below). E0 may have any number of rows, provided 
%                sufficient observations exist to initialize the ARIMA model 
%                as well as any conditional variance model (the number of 
%                observations required is at least OBJ.Q, but may be more if 
%                a conditional variance model is included). If the number of 
%                rows exceeds the number necessary, then only the most recent 
%                observations are used. If E0 is unspecified, any necessary 
%                presample observations are inferred from the corresponding 
%                response data in Y0, provided Y0 has at least OBJ.P + OBJ.Q 
%                observations; if Y0 is unspecified or of insufficient 
%                length, presample observations of E0 are set to zero. The 
%                last row contains the most recent observation.
%
%   'V0'         Positive presample conditional variances, providing initial
%                values for any conditional variance model; if the variance 
%                of the model is constant, then V0 is unnecessary. V0 is a 
%                column vector or a matrix. If V0 is a column vector, then 
%                it is applied to each forecasted path. If V0 is a matrix, 
%                then it must have numPaths columns (see notes below). V0 may
%                have any number of rows, provided sufficient observations 
%                exist to initialize the variance equation. If the number of 
%                rows exceeds the minimum, then only the most recent 
%                observations are used. If V0 is unspecified, any necessary 
%                presample observations are inferred from the corresponding 
%                residuals E0, provided E0 has sufficient observations 
%                required by the conditional variance model; if E0 is 
%                unspecified or of insufficient length, presample observations
%                of V0 are set to the unconditional variance of the variance 
%                process. The last row contains the most recent observation.
%
% Output Arguments:
%
%   Y - numPeriods-by-numPaths matrix of minimum mean square error (MMSE) 
%     forecasts of the conditional mean of the response data. The number of
%     columns of Y (numPaths) is taken as the largest number of columns of
%     the presample arrays Y0, E0, and V0. If Y0, E0, and V0 are unspecified, 
%     Y is a numPeriods column vector. In all cases, the first row of Y 
%     contains the conditional mean forecasts in period 1, the second row 
%     contains the conditional mean forecasts in period 2, and so on until 
%     the last row, which contains conditional mean forecasts at the 
%     specified forecast horizon. 
%
%   YMSE - numPeriods-by-numPaths matrix of mean square errors (MSE) of the
%     of the forecasts of the conditional mean Y. The number of columns of
%     YMSE (numPaths) is taken as the largest number of columns of the 
%     the presample arrays Y0, E0, and V0. If Y0, E0, and V0 are unspecified, 
%     Y is a numPeriods column vector. In all cases, the first row of YMSE 
%     contains the forecast error variances in period 1, the second row 
%     contains the forecast error variances in period 2, and so on until 
%     the last row, which contains the forecast error variances at the 
%     specified forecast horizon. The square roots of YMSE are the standard 
%     errors of the forecasts Y above.
%
%   V - numPeriods-by-numPaths matrix of minimum mean square error (MMSE) 
%     forecasts of the conditional variances of future model residuals. The 
%     number of columns of V (numPaths) is taken as the largest number of 
%     columns of the presample arrays Y0, E0, and V0. If Y0, E0, and V0 
%     are unspecified, V is a numPeriods column vector. In all cases, the 
%     first row of V contains the conditional variance forecasts in period 
%     1, the second row contains the conditional variance forecasts in 
%     period 2, and so on until the last row, which contains conditional 
%     variance forecasts at the specified forecast horizon. 
%
% Notes:
%
%   o The number of sample paths (numPaths) is the largest column dimension 
%     of the presample arrays Y0, E0, and V0, but not fewer than one.
%
%   o If Y0, E0, and V0 are matrices with multiple columns (paths), they 
%     must have the same number of columns, otherwise an error occurs.
%
%   o Missing values, indicated by NaNs, are removed from Y0, E0, and V0 by 
%     listwise deletion, thereby reducing the effective number of 
%     observations. That is, Y0, E0, and V0 are merged into a composite 
%     series, and any row of the combined series with at least one NaN is 
%     removed. The presample data is also synchronized such that the last 
%     (most recent) observation of each series is occurs at the same time.
%
% References:
%
%   [1] Baillie, R., and T. Bollerslev. "Prediction in Dynamic Models with 
%       Time-Dependent Conditional Variances." Journal of Econometrics.
%       Vol. 52, 1992, pp. 91-113.
%
%   [2] Bollerslev, T. "Generalized Autoregressive Conditional 
%       Heteroskedasticity." Journal of Econometrics. Vol. 31, 1986, pp.
%       307-327.
%
%   [3] Bollerslev, T. "A Conditionally Heteroskedastic Time Series Model
%       for Speculative Prices and Rates of Return." The Review Economics
%       and Statistics. Vol. 69, 1987, pp 542-547.
%
%   [4] Box, G. E. P., G. M. Jenkins, and G. C. Reinsel. Time Series
%       Analysis: Forecasting and Control. 3rd edition. Upper Saddle River,
%       NJ: Prentice-Hall, 1994.
%
%   [5] Enders, W. Applied Econometric Time Series. Hoboken, NJ: John Wiley
%       & Sons, 1995.
%
%   [6] Engle, R. F. "Autoregressive Conditional Heteroskedasticity with
%       Estimates of the Variance of United Kingdom Inflation." 
%       Econometrica. Vol. 50, 1982, pp. 987-1007.
%
%   [7] Hamilton, J. D. Time Series Analysis. Princeton, NJ: Princeton
%       University Press, 1994.
%
% See also ARIMA, ESTIMATE, INFER, SIMULATE.

% Copyright 1999-2011 The MathWorks, Inc.   
% $Revision: 1.1.6.4 $   $Date: 2011/11/09 16:44:30 $

%
% Check input parameters and set defaults.
%

if nargin < 2
   error(message('econ:arima:forecast:NonEnoughInputs'))
end

parser = inputParser;
parser.CaseSensitive = true;
parser.addRequired  ('numPeriods',    @(x) validateattributes(x, {'double'}, {'scalar' 'integer' '>' 0}, '', 'forecast horizon'));
parser.addParamValue('Y0'        , 0, @(x) validateattributes(x, {'double'}, {}, '', 'presample responses'));
parser.addParamValue('E0'        , 0, @(x) validateattributes(x, {'double'}, {}, '', 'presample residuals'));
parser.addParamValue('V0'        , 0, @(x) validateattributes(x, {'double'}, {}, '', 'presample variances'));

try 
  parser.parse(numPeriods, varargin{:});
catch exception
  exception.throwAsCaller();
end

horizon = parser.Results.numPeriods;
Y0      = parser.Results.Y0;
E0      = parser.Results.E0;
V0      = parser.Results.V0;

%
% Get model parameters and extract lags associated with non-zero coefficients.
%

constant = OBJ.Constant;                        % Additive constant
variance = OBJ.Variance;                        % Conditional variance

if isa(variance, 'internal.econ.LagIndexableTimeSeries') % Allow for a conditional variance model
   P = max(OBJ.Variance.P, OBJ.P);
   Q = max(OBJ.Variance.Q, OBJ.Q);              % Total number of lagged e(t) needed
   fprintf(1, 'In forecastArima\n');
else
   P = OBJ.P;                                   % Total number of lagged y(t) needed
   Q = OBJ.Q;                                   % Total number of lagged e(t) needed
end

AR         = getLagOp(OBJ, 'Compound AR'); 
isARstable = isStable(AR);                      % Determine if the process is AR stable

AR     = reflect(AR);                           % This negates the AR coefficients
MA     = getLagOp(OBJ, 'Compound MA'); 
LagsAR = AR.Lags;                               % Lags of non-zero AR coefficients
LagsMA = MA.Lags;                               % Lags of non-zero MA coefficients
LagsAR = LagsAR(LagsAR > 0);                    % Exclude lag zero
LagsMA = LagsMA(LagsMA > 0);                    % Exclude lag zero

if isempty(LagsAR)
   AR = [];
else
   AR = AR.Coefficients;                        % Lag Indexed Array
   AR = [AR{LagsAR}];                           % Non-zero AR coefficients (vector)
end

if isempty(LagsMA)
   MA = [];
else
   MA  = MA.Coefficients;                       % Lag Indexed Array
   MA  = [MA{LagsMA}];                          % Non-zero MA coefficients (vector)
end

%
% Ensure coefficients are specified.
%

if any(isnan(constant))
   error(message('econ:arima:forecast:UnspecifiedConstant'))
end

if any(isnan(AR))
   error(message('econ:arima:forecast:UnspecifiedAR'))
end

if any(isnan(MA))
   error(message('econ:arima:forecast:UnspecifiedMA'))
end

if ~isa(variance, 'internal.econ.LagIndexableTimeSeries') && any(isnan(variance))
   error(message('econ:arima:forecast:UnspecifiedVariance'))
end

%
% Compute the total number of observations generated for each path as the
% sum of the number of observations forested and the number of presample 
% observations needed to initialize the recursions.
%

maxPQ = max([P Q]);              % Maximum presample lags needed
T     = horizon + maxPQ;         % Total number of periods required for forecasting

%
% Compute the number of sample paths as the largest column dimension of the 
% presample arrays, but not fewer than one. If any of Y0, E0, and V0 are 
% column vectors, then the function "checkPresampleData" called later on will
% automatically expand the number of columns to the correct number of paths.
%

numPaths = max([size(Y0,2) size(E0,2) size(V0,2) 1]);

[nRows, nColumns] = size(Y0);

if nColumns ~= numPaths
   if (nColumns ~= 1) && ( ((nRows == 0) && (nColumns > 0)) || ~isempty(Y0) )
      error(message('econ:arima:forecast:InvalidY0', numPaths))
   end
end

[nRows, nColumns] = size(E0);

if nColumns ~= numPaths
   if (nColumns ~= 1) && ( ((nRows == 0) && (nColumns > 0)) || ~isempty(E0) )
      error(message('econ:arima:forecast:InvalidE0', numPaths))
   end
end

[nRows, nColumns] = size(V0);

if nColumns ~= numPaths
   if (nColumns ~= 1) && ( ((nRows == 0) && (nColumns > 0)) || ~isempty(V0) )
      error(message('econ:arima:forecast:InvalidV0', numPaths))
   end
end

%
% Remove missing observations (NaN's) via listwise deletion.
%
% 
% if any(isnan(Y0(:))) || any(isnan(E0(:))) || any(isnan(V0(:)))
%    [Y0, E0, V0] = OBJ.listwiseDelete(Y0, E0, V0);  % Pre-sample data
% end
% 
%
% Check any user-specified presample observations used for conditioning, or 
% generate any required observations automatically.
%

isE0specified = any(strcmpi('E0', varargin(1:2:end)));

if isE0specified      % Did the user specify presample e(t) observations?

%
%  Check user-specified presample data for the residuals e(t). 
%
%  Notice that the following line of code saves the original E0 input to 
%  forecast the conditional variance model later (rather than overwriting
%  it with a stripped version of itself).
%

   e0 = internal.econ.LagIndexableTimeSeries.checkPresampleData(zeros(maxPQ,numPaths), 'E0', E0, Q);

%
%  Prepend the residuals with any user-specified presample observations and
%  transpose for efficiency.
%

   E            = zeros(numPaths,T);
   E(:,1:maxPQ) = e0';
    
else

%
%  The user did not specify presample e(t) observations. 
%

  if any(strcmpi('Y0', varargin(1:2:end))) && ( (size(Y0,1) >= (P + Q)) && ~isempty(Y0) )
 
%
%     Sufficient observations of the input series y(t) have been specified,
%     and so initial values of the residuals e(t) may be inferred.
%
      residuals    = infer(OBJ, Y0);
      E            = zeros(numPaths,T);
      E(:,1:maxPQ) = residuals((end - maxPQ + 1):end,:)';
      isE0Inferred = true;
   else
%
%     Insufficient observations of the input series y(t) have been specified,
%     so initialize any required presample observations with the unconditional 
%     mean of zero.
      E            = zeros(numPaths,T);   % Unconditional mean of e(t)
      isE0Inferred = false;

   end

end


if any(strcmpi('Y0', varargin(1:2:end)))  % Did the user specify presample y(t)?
    fprintf(1, 'Here');
%
%  Check user-specified presample data for the residuals e(t).
%

   Y0 = internal.econ.LagIndexableTimeSeries.checkPresampleData(zeros(maxPQ,numPaths), 'Y0', Y0, OBJ.P);

%
%  Size the responses y(t) and initialize with specified data.
%

   Y = [Y0'  zeros(numPaths,horizon)];

else

%
%  The user did not specify presample y(t) observations. 
%

   if isARstable && (sum(AR) ~= 1)
%
%     The model is AR-stable, so compute the unconditional (i.e., long-run) 
%     mean of the y(t) process directly from the parameters of the model and 
%     use it to initialize any required presample observations.
%
      average = constant / (1 - sum(AR));
      Y       = repmat([average(ones(1,maxPQ)) zeros(1,horizon)], numPaths, 1);

   else
%
%     The model is not AR-stable, and so a long-run mean of the y(t) process 
%     cannot be calculated from the model. The following simply assumes zeros 
%     for any required presample observations for y(t).
%
      Y  = zeros(numPaths,T);

   end

end

%
% Apply iterative expectations one forecast step at a time. Such forecasts
% require that the process e(t) is a serially uncorrelated, zero-mean process 
% with a symmetric conditional probability distribution (see [1], pp. 94-95).
%

coefficients = [constant  AR  MA]';
keyboard
I = ones(numPaths,1);

for t = (maxPQ + 1):T
    data   = [I  Y(:,t - LagsAR)  E(:,t - LagsMA)];
    Y(:,t) = data * coefficients;
end

if nargout > 1     % Compute additional outputs only if necessary
%
%  Forecast the conditional variances.
%
   if isa(variance, 'internal.econ.LagIndexableTimeSeries')    % Conditional variance model
        fprintf(1, 'I dont think this is run.\n');
      isV0specified = any(strcmpi('V0', varargin(1:2:end)));

      if isE0specified && isV0specified

         V = forecast(variance, horizon, 'Y0', E0, 'V0', V0);

      elseif isE0specified

         V = forecast(variance, horizon, 'Y0', E0);

      elseif isV0specified

         if isE0Inferred
            V = forecast(variance, horizon, 'V0', V0, 'Y0', residuals);
         else
            V = forecast(variance, horizon, 'V0', V0);
         end

      else

         if isE0Inferred
            V = forecast(variance, horizon, 'Y0', residuals);
         else
            V = forecast(variance, horizon);
         end

     end

   else                              % Constant variance model

     V = variance(ones(horizon,numPaths));

   end

%
%  Compute variances of forecasts errors of y(t).
%

   wState  = warning;                           % Save warning state
   cleanUp = onCleanup(@() warning(wState));    % Restore warning state
   
   warning('off', 'econ:LagOp:mldivide:WindowNotOpen')   
   warning('off', 'econ:LagOp:mldivide:WindowIncomplete')

%
%  Compute the coefficients of the truncated infinite-degree MA
%  representation of the ARIMA model.
%

   MA   = mldivide(getLagOp(OBJ, 'Compound AR'), ...
                   getLagOp(OBJ, 'Compound MA'), ...
                  'Degree', horizon - 1, 'RelTol', 0, 'AbsTol', 0);

   MA   = cell2mat(toCellArray(MA));
   MA   = [MA  zeros(1, horizon - numel(MA))];
   YMSE = toeplitz(MA.^2, [1 zeros(1, horizon - 1)]) * V;

end

%
% Remove the first max(P,Q) values used to initialize the variance forecast 
% such that the t-th row of V(t) is the t-period-ahead forecast of the 
% conditional variance, and transpose to a conventional time series format.
%

Y = Y(:,(maxPQ + 1):end)';

end
