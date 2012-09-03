clear all
close all

% Read data:
%   beginTime                 1x19                38  char                
%   correlationMatrix         7x7x4             1568  double              
%   data                   1000x8              64000  double              
%   endTime                   1x19                38  char  
load mat/synthData.mat

% Extract data
times = data(:,1);
sensorhits = data(:,2:end);     % s(time,sensorj)

% sensorhits = ...
%     [ 0 0 0 0 0 0 0;
%       0 0 0 0 0 0 0;
%       0 1 0 0 0 0 0;
%       0 0 1 0 0 0 0;
%       0 0 0 1 0 0 0;
%       0 0 0 0 1 0 0;
%       0 0 0 0 0 1 0;
%       0 0 0 0 0 0 1;
%       0 0 0 0 0 0 0;
%       0 0 0 0 0 0 0];

sensorzeros = 1 - sensorhits;

M = size(sensorhits,2);         % number of sensors
N = size(sensorhits,1);         % number of times


% Compute overall probabilities for each sensor to be zero or 1.
% This is P(D=1|~M) and P(D=0|~M)
PD1 = mean(sensorhits(:));
PD0 = 1 - PD1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute a "walk left" feature.
% This will be centered in the group of M sensors (but it could be local to
% a subset of sensors).
% This feature depends on the following sensor locations.  Here wij=1 if sensor j at time i
% is relevant to the feature, and wij=0 otherwise.
w = [ 1 1 0 0 0 0 0;
      1 1 1 0 0 0 0;
      0 1 1 1 0 0 0;
      0 0 1 1 1 0 0;
      0 0 0 1 1 1 0;
      0 0 0 0 1 1 1;
      0 0 0 0 0 1 1];
% w = [ 1 1 0 0 0 0 0;
%       1 1 1 0 0 0 0;
%       0 1 1 1 0 0 0;
%       0 0 1 1 1 0 0;
%       0 0 0 1 1 1 0;
%       0 0 0 0 1 1 0;
%       0 0 0 0 0 0 0];

% Now for this model feature, define the probability of the data given the
% model. In other words, P(D=1|M) and P(D=0|M).
% Let's assume that the sensor hits are mutually independent, given M.
% Then we will store P(Di|M).  We only need to store P(Di=1|M), since
% P(Di=0|M) = 1 - P(Di=1|M).
% PDM1 = [ .9 .1  0  0  0  0  0;
%          .1 .9 .1  0  0  0  0;
%           0 .1 .9 .1  0  0  0;
%           0  0 .1 .9 .1  0  0;
%           0  0  0 .1 .9 .1  0;
%           0  0  0  0 .1 .9 .1;
%           0  0  0  0  0 .1 .9];
PDM1 = [ .6 .2  0  0  0  0  0;
         .2 .6 .2  0  0  0  0;
          0 .2 .6 .2  0  0  0;
          0  0 .2 .6 .2  0  0;
          0  0  0 .2 .6 .2  0;
          0  0  0  0 .2 .6 .2;
          0  0  0  0  0 .2 .6];
PDM0 = 1 - PDM1;

logPDM1 = log(PDM1);
logPDM0 = log(PDM0);

% Let's make "don't care" places so they won't affect anything.
for i=1:size(PDM1,1)
    for j=1:size(PDM1,2)
        if w(i,j)==0
            PDM1(i,j) = 0;
            PDM0(i,j) = 0;
            logPDM1(i,j) = 0;
            logPDM0(i,j) = 0;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Now figure out probability of the model given the data; i.e., P(M|D).
% From Bayes, we know  P(M|D) = P(D|M)*P(M)/P(D)
%   where
%     P(D|M) = prod_where_Di=1[ P(Di=1|M) ]*prod_where_Di=0[ P(Di=0|M) ]
%     and P(M) is from some a priori information

% What is P(D)?
%  P(D) = P(D|M)P(M) + P(D|~M)P(~M)
% We know P(D|M).  The other term is
%  P(D|~M) = prod_where_Di=1[ P(Di=1|~M) ]*prod_where_Di=0[ P(Di=0|~M) ]
%  where P(Di=1|~M) = PD1 and P(Di=0|~M) = PD0

PM = 0.1;       % some a priori probability of this event

% Compute P(D|M).  We will sum logs using convolution.
logsumPDM1 = conv2(sensorhits, logPDM1, 'same');
logsumPDM0 = conv2(sensorzeros, logPDM0, 'same');
logsumPDM = logsumPDM1 + logsumPDM0;
PDM = exp(logsumPDM);

% Compute P(D|~M).  
logsumPDNM1 = log(PD1) * conv2(sensorhits, w, 'same');
logsumPDNM0 = log(PD0) * conv2(sensorzeros, w, 'same');
logsumPDNM = logsumPDNM1 + logsumPDNM0;
PDNM = exp(logsumPDNM);

PD = PDM*PM + PDNM*(1-PM);
    
% Here is Bayes theorem
PMD = PDM * PM ./ PD;

% We only want the center column
PMD = PMD(:, floor((M+1)/2));


% Do non-maxima suppression; i.e., get rid of values that are not local
% peaks.  This is because we only want a single hypothesis of the feature,
% not multiple overlapping ones.
P(2:N-1) = (PMD(2:N-1) > PMD(3:N)) & ...    % bigger than lower neighbor
            (PMD(2:N-1) >= PMD(1:N-2));     % and bigger than upper neighbor
P(1) = 0;
P(N) = 0;
Pwalkleft = PMD .* double(P');

% Ok, let's use the walkleft feature to predict sensor readings.
%   Find P(D) = P(D|M)*P(M).
s = conv2(Pwalkleft, PDM1);
r0 = floor((M+1)/2);
sensorpredict = s(r0:r0+N-1, :);  % get rid of extra rows

% Take the difference betweeen the predicted sensor data and the actual
% sensor data.
sensordiff = sensorpredict - sensorhits;

% Threshold the sensordiff to 0 or 1
sensordiffthresh = round(abs(sensordiff));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To display data and features, put into a big image
I = zeros(N, 5);

% First, the original data
I = [I, sensorhits];
I = [I, zeros(N, 5)];     % separate by blanks

% Next, PMD
I = [I, PMD];
I = [I, zeros(N, 5)];     % separate by blanks

% Next, the walk left feature
I = [I, Pwalkleft];
I = [I, zeros(N, 5)];     % separate by blanks

% Predicted sensor data
I = [I, sensorpredict];
I = [I, zeros(N, 5)];     % separate by blanks

% Difference between predicted and actual sensor data
I = [I, sensordiff];
I = [I, zeros(N, 5)];     % separate by blanks

% Thresholded difference
I = [I, sensordiffthresh];
I = [I, zeros(N, 5)];     % separate by blanks

imtool(I, []);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaluate cost of representing original data vs. cost of representing it
% with the model of "walkleft".
%  entropy(bits) = -[ P(0)*log(P(0)) + P(1)*log(P(1)) ]
origCost = -( PD0*log(PD0) + PD1*log(PD1) )

PD1 = mean(sensordiffthresh(:));
PD0 =1 - PD1;
modelCost = -( PD0*log(PD0) + PD1*log(PD1) )


