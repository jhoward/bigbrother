%run TDNN

clear all

%fileName = 'simulated';
%fileName = 'brown';
fileName = 'denver';

load(strcat('./data/', fileName, 'Run.mat'));

%Train
d = 8;
s = 1;

y = data.trainData;
p = y(d+1:end-s); % inputs
t = y(d+1+s:end); % targets
p = num2cell(p);
t = num2cell(t);
testP = data.testData(d + 1:end-s);
testT = data.testData(d + 1 + s:end);
testP = num2cell(testP);
testT = num2cell(testT);

net = timedelaynet(1:d, 10);
[ys,yi,ai,ts] = preparets(net,p,t);
net = train(net,ys,ts);

[yts,yti,ati,tts] = preparets(net,testP,testT);
yout = net(yts,yti,ati);

yout = cell2mat(yout);
tout = cell2mat(tts);

errperf(yout, tout, 'mape')
%errperf(icast2, data.testData(1, :), 'mape')
start = randi(size(yout, 2));
width = data.blocksInDay*2;

x = linspace(1, width, width + 1);
plot(x, [tout(1, start:start + width); yout(start:start + width);]);
legend('raw', 'one ahead');