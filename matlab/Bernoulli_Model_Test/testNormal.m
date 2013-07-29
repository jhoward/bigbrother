%Test normal discretization
mean = 0;
std = 3.0;

range = (mean - 2 * std):(std/50):(mean + 2 * std);
dValues = normpdf(range, mean, std);
dValues(dValues < 0.000000001) = 0.000000001;
dValues = dValues ./ sum(dValues);
prob = zeros(size(data));

foo = max(find(range <= data(1, i))) + 1;

dValues(foo)

plot(dValues)