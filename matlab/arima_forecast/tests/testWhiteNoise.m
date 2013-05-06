%Test the durbin watson statistic

clear all

x = rand(1, 10000);
[h, p, s, c] = lbqtest(x)
