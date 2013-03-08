clear all;

m1 = 1;
m2 = 5;
std1 = 1;
std2 = 2;

%Make a dataset that is derived from 2 sources
data = m1 + std1*randn(1, 100);
data = [data (m2 + std2*randn(1, 100))];

%make 2 gaussians
model1 = bcf.models.Gaussian(m1, std1);
model2 = bcf.models.Gaussian(m2, std2);

models = [model1 model2];

forecaster = bcf.BayesianForecaster(models);

