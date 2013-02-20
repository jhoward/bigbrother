function [Y,YMSE,V] = aForecast(OBJ, fSteps, Y0, varargin)


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

%
% Get model parameters and extract lags associated with non-zero coefficients.
%

constant = OBJ.Constant;                        % Additive constant
variance = OBJ.Variance;                        % Conditional variance

if isa(variance, 'internal.econ.LagIndexableTimeSeries') % Allow for a conditional variance model
   P = max(OBJ.Variance.P, OBJ.P);
   Q = max(OBJ.Variance.Q, OBJ.Q);              % Total number of lagged e(t) needed
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

% if any(isnan(Y0(:))) || any(isnan(E0(:))) || any(isnan(V0(:)))
%    [Y0, E0, V0] = OBJ.listwiseDelete(Y0, E0, V0);  % Pre-sample data
% end

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

Y = [Y0'  zeros(numPaths,horizon)];

%
% Apply iterative expectations one forecast step at a time. Such forecasts
% require that the process e(t) is a serially uncorrelated, zero-mean process 
% with a symmetric conditional probability distribution (see [1], pp. 94-95).
%

startValue = max([LagsAR LagsMA]) + 1;
endValue = size(Y0, 1) - fSteps;

coefficients = [constant  AR  MA]';
errors = zeros(size(Y0));
errors = errors';

I = ones(numPaths,1);

% for t = startValue:endValue
% 
%     data   = [I  Y0(t - LagsAR,:)'  errors(:,t - LagsMA)];
%     Y(:,t) = data * coefficients;
%     errors = [Y(1, t) - Y0(t, 1) errors];
% end

mar = max(LagsAR);
mma = max(LagsMA);

for t = startValue:endValue
    
    ystar = Y0(t - mar:t + fSteps, :);
    estar = errors(:, t - mma: t + fSteps);

    for j = 1:fSteps
        data = [I  ystar(mar + j - LagsAR,:)'  estar(:,mma  + j - LagsMA)];
        ystar(mar + j, :) = data * coefficients;
        %Finish this - estar after t should be 0
        %estar = [Y(1, t) - Y0(t, 1) errors];
    end
    
    Y(:, t + fSteps - 1) = ystar(mar + fSteps, :);
    errors = [Y(1, t) - Y0(t, 1) errors];
end

Y = Y(1:end - fSteps);


% if nargout > 1     % Compute additional outputs only if necessary
% %
% %  Forecast the conditional variances.
% %
%    if isa(variance, 'internal.econ.LagIndexableTimeSeries')    % Conditional variance model
% 
%       isV0specified = any(strcmpi('V0', varargin(1:2:end)));
% 
%       if isE0specified && isV0specified
% 
%          V = forecast(variance, horizon, 'Y0', E0, 'V0', V0);
% 
%       elseif isE0specified
% 
%          V = forecast(variance, horizon, 'Y0', E0);
% 
%       elseif isV0specified
% 
%          if isE0Inferred
%             V = forecast(variance, horizon, 'V0', V0, 'Y0', residuals);
%          else
%             V = forecast(variance, horizon, 'V0', V0);
%          end
% 
%       else
% 
%          if isE0Inferred
%             V = forecast(variance, horizon, 'Y0', residuals);
%          else
%             V = forecast(variance, horizon);
%          end
% 
%      end
% 
%    else                              % Constant variance model
% 
%      V = variance(ones(horizon,numPaths));
% 
%    end
% 
% %
% %  Compute variances of forecasts errors of y(t).
% %
% 
%    wState  = warning;                           % Save warning state
%    cleanUp = onCleanup(@() warning(wState));    % Restore warning state
%    
%    warning('off', 'econ:LagOp:mldivide:WindowNotOpen')   
%    warning('off', 'econ:LagOp:mldivide:WindowIncomplete')
% 
% %
% %  Compute the coefficients of the truncated infinite-degree MA
% %  representation of the ARIMA model.
% %
% 
%    MA   = mldivide(getLagOp(OBJ, 'Compound AR'), ...
%                    getLagOp(OBJ, 'Compound MA'), ...
%                   'Degree', horizon - 1, 'RelTol', 0, 'AbsTol', 0);
% 
%    MA   = cell2mat(toCellArray(MA));
%    MA   = [MA  zeros(1, horizon - numel(MA))];
%    YMSE = toeplitz(MA.^2, [1 zeros(1, horizon - 1)]) * V;
% 
% end
% keyboard
% %
% % Remove the first max(P,Q) values used to initialize the variance forecast 
% % such that the t-th row of V(t) is the t-period-ahead forecast of the 
% % conditional variance, and transpose to a conventional time series format.
% %
% 
% Y = Y(:,(maxPQ + 1):end)';
% 
% end
