clear all;

N = 50;
D = 3;
window = 5;
horizon = 1;

x = linspace(0, pi, N);
x = repmat(x, [1 D]);
xp = x + 0.01 * randn(size(x));
x = x + 0.01 * randn(size(x));

y = sin(x) + 0.01 * randn(size(x));
yp = sin(xp) + 0.01 * randn(size(x));

modelSVM = bcf.models.SVM('-s 4 -t 2 -q');
modelSVM.train(y, window);

modelSVM.calculateNoiseDistribution(y, 1);
yy = modelSVM.forecastAll(y, 1);
yyp = modelSVM.forecastAll(yp, 15);

plot(1:1:75, [y(1, 25:99); yy(1, 25:99)]);
plot(1:1:75, [yp(1, 25:99); yyp(1, 25:99)]);

% xWin = zeros(window, N * D - 1 - window);
% xpWin = zeros(window, N * D - 1 - window);
% for i = 1:(N * D) - window
%     xWin(:, i) = y(1, i:i + window - 1);
%     xpWin(:, i) = yp(1, i:i + window - 1);
% end

%yWin = y(window + 1:end);
%ypWin = yp(window + 1:end);

%model = svmtrain(yWin',xWin',['-s 4 -t 2']);
% w = model.SVs' * model.sv_coef;
% b = -model.rho;
% 
%zz = svmpredict(ypWin',xpWin',model);
% %zz2 = svmpredict(ypWin(100)', xpWin(:, 10)', model);
%zz2 = bcf.forecast.svmForecast(model, yp, 5);

% output = yp;
% 
% Forecast ahead
% for t = window + 1:size(data, 2) - ahead
%     set the data
%     tmpData = data(1, t - window:t - 1);
%     tmpOut = 0;
%     for i = 1:ahead
%         tmpOut = svmpredict(1, tmpData, obj, '-q');
% 
%         update tmpData
%         tmpData = [tmpData(2:end) tmpOut];
%     end
%     output(1, t + ahead) = tmpOut;
%  end


%plot(1:1:75, [ypWin(1:75); zz(1:75)']);
%plot(1:1:100, [yp(50:149); zz2(50:149)]);

