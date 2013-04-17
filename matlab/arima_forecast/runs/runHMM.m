O = 1; %Number of dimensions
T = 10; %Time series length
nex = 20; %Number of examples
x = linspace(0, pi, T);
data = sin(x);
data = repmat(data, [1 1 nex]);
noise = randn(O, T, nex) * 0.05;

data = data + noise;

M = 2; %Number of Gaussians
Q = 50; %Number of states
left_right = 0;

prior0 = normalise(rand(Q,1));
transmat0 = mk_stochastic(rand(Q,Q));

[mu0, Sigma0] = mixgauss_init(Q*M, reshape(data, [O T*nex]), 'full');
mu0 = reshape(mu0, [O Q M]);
Sigma0 = reshape(Sigma0, [O O Q M]);
mixmat0 = mk_stochastic(rand(Q,M));

if M == 1
    mixmat0 = ones(Q, 1);
end

[LL, prior1, transmat1, mu1, Sigma1, mixmat1] = ...  
    mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', 10);

[B, B2] = mixgauss_prob(data(:,:,10), mu1, Sigma1, mixmat1);
[path] = viterbi_path(prior1, transmat1, B);

x2 = linspace(3, 1, 10);
x3 = linspace(0, 1, 5);


mhmm_logprob(x2, prior1, transmat1, mu1, Sigma1, mixmat1)
mhmm_logprob(x3, prior1, transmat1, mu1, Sigma1, mixmat1)

samples = mhmm_sample(3 * T, nex, prior1, transmat1, mu1, Sigma1, mixmat1);

%Plot data
for i = 1:size(data, 3)
    %plot(x, [data(1, :, i); samples(1, :, i)]);
    plot(data(1, :, i));
    hold on
end


d2 = num2cell(data, [1 2]); % each elt of the 3rd dim gets its own cell
obslik = mixgauss_prob(data(:, :, 1), mu1, Sigma1, mixmat1);

[alpha, beta, gamma, ll] = fwdback(prior1, transmat1, obslik, 'fwd_only', 1, 'scaled', 1);


output = data;
for i = 1:size(data, 3)
    output(:, :, i) = hmmForecast(prior1, transmat1, mu1, Sigma1, mixmat1, data(:, :, i), 3);
    obslik2 = mixgauss_prob(data(:, :, i), mu1, Sigma1, mixmat1);
end

obslik2 = mixgauss_prob(x3, mu1, Sigma1, mixmat1);
[alpha2, beta, gamma, ll] = fwdback(prior1, transmat1, obslik2, 'fwd_only', 1, 'scaled', 1);
o = hmmForecast(prior1, transmat1, mu1, Sigma1, mixmat1, x3, 3);


tmpMix = reshape(mixmat1, [1 size(mixmat1)]);
tmpMix = repmat(tmpMix, [size(mu1, 1) 1 1]);
tmpMu = mu1 .* tmpMix;
eVals = sum(tmpMu, 3);
o2 = data(:, :, 1);
obslik = mixgauss_prob(data(:, :, 1), mu1, Sigma1, mixmat1);
[alpha, beta, gamma, ll] = fwdback(prior1, transmat1, obslik, 'fwd_only', 1, 'scaled', 1);
currentState = alpha(:, 1);
futureState = transmat1' * currentState;
o2(:, 2) = sum(futureState' .* eVals, 2);
currentState = alpha(:, 2);
futureState = transmat1' * currentState;
o2(:, 3) = sum(futureState' .* eVals, 2);
currentState = alpha(:, 3);
futureState = transmat1' * currentState;
o2(:, 4) = sum(futureState' .* eVals, 2);

for i = 1:size(data, 3)
    %plot(x, [data(1, :, i); samples(1, :, i)]);
    plot(x, [data(:, :, i); output(:, :, i)]);
    hold on
end