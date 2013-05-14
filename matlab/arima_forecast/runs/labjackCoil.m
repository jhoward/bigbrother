%Work with labjack data
load('./data/labjack.mat');

plot(yg)
plot(yr)

yri = cumtrapz(yr);
ygi = cumtrapz(yg);

plot(ygi(1:200))
plot(yri(1:200))