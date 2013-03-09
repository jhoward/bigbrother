clear all;

m1 = 1;
m2 = 5;
std1 = 1;
std2 = 2;

data = zeros(1, 200);

%Make a dataset that is derived from 2 sources
for i = 1:20
    index = (i - 1) * 10 + 1;
    switch mod(i, 2)
        case 0
           data(index:index + 9) = m1 + std1*randn(1, 10);
        case 1
            data(index:index + 9) = m2 + std2*randn(1, 10);
    end
end

%make 2 gaussians
model1 = bcf.models.Gaussian(m1, std1);
model2 = bcf.models.Gaussian(m2, std2);

models = [model1 model2];

forecaster = bcf.BayesianForecaster(models);

