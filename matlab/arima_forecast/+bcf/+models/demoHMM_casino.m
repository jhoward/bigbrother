%Testing HMM on weighted dice

setSeed(1);

fair = 1; 
loaded = 2;

obsModel = [1/6 , 1/6 , 1/6 , 1/6 , 1/6 , 1/6  ;   % fair die
           1/10, 1/10, 1/10, 1/10, 1/10, 5/10 ];   % loaded die
       
transmat = [0.95 , 0.05;
           0.10  , 0.90];
       
pi = [0.5, 0.5];

len = 3; 
nsamples = 20;
markov.pi = pi;
markov.A = transmat;
hidden = markovSample(markov, len, nsamples);
observed = zeros(1, len);
for t=1:len
   observed(1, t) = sampleDiscrete(obsModel(hidden(t), :));
end

nstates = size(obsModel, 1);
modelEM = hmmFit(observed, nstates, 'discrete', ...
    'maxIter', 1000, 'verbose', true, 'convTol', 1e-7, 'nRandomRestarts', 3);


model.nObsStates = size(obsModel, 2);
model.emission = tabularCpdCreate(obsModel);
model.nstates = nstates;
model.pi = pi;
model.A = transmat;
model.type = 'discrete';
viterbiPath = hmmMap(model, observed);

[gamma, loglik, alpha, beta, localEvidence]  = hmmInferNodes(model, observed);
maxmargF = maxidx(alpha); % filtered (forwards pass only)
maxmarg = maxidx(gamma);  % smoothed (forwards backwards)

postSamp = mode(hmmSamplePost(model, observed, 100), 2)';
die = hidden;
rolls = observed;
dielabel = repmat('F',size(die));
dielabel(die == 2) = 'L';
vitlabel = repmat('F',size(viterbiPath));
vitlabel(viterbiPath == 2) = 'L';
maxmarglabel = repmat('F',size(maxmarg));
maxmarglabel(maxmarg == 2) = 'L';
postsamplabel = repmat('F',size(postSamp));
postsamplabel(postSamp == 2) = 'L';
rollLabel = num2str(rolls);
rollLabel(rollLabel == ' ') = [];
for i=1:60:300
    fprintf('Rolls:\t  %s\n',rollLabel(i:i+59));
    fprintf('Die:\t  %s\n',dielabel(i:i+59));
    fprintf('Viterbi:  %s\n',vitlabel(i:i+59));
    fprintf('MaxMarg:  %s\n',maxmarglabel(i:i+59));
    fprintf('PostSamp: %s\n\n',postsamplabel(i:i+59));
end
