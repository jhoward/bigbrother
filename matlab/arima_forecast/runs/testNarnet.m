time = 1:10:7200;
timeh = time(1:end/2);
timenh = time(end/2 +1 : end);
input = sind(time(1:end/2));

timeh = repmat(timeh, [2 1]);
timenh = repmat(timenh, [2 1]);

toPredict = sind(time(end/2 +1 : end));
% plot(time(1:end/2),input,'o-g',time(end/2+1:end), toPredict,'+-r')
% legend('input to neural network','expected output');

inputSeries = tonndata(timeh,true,false);
targetSeries = tonndata(input,true,false);
% Create a Nonlinear Autoregressive Network with External Input

inputDelays = 1:10;
feedbackDelays = 1:10;
hiddenLayerSize = 50;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize);

% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer states.
% Using PREPARETS allows you to keep your original time series data unchanged, while
% easily customizing it for networks with differing numbers of delays, with
% open loop or closed loop feedback modes.
[inputs,inputStates,layerStates,targets] = preparets(net,inputSeries,{},targetSeries);

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Train the Network
[net,tr] = train(net,inputs,targets,inputStates,layerStates);

% Test the Network
outputs = net(inputs,inputStates,layerStates);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs)

% View the Network
% view(net)
% % Plots
% % Uncomment these lines to enable various plots.
% figure, plotperform(tr)
% figure, plottrainstate(tr)
% figure, plotregression(targets,outputs)
% figure, plotresponse(targets,outputs)
% figure, ploterrcorr(errors)
% figure, plotinerrcorr(inputs,errors)


% Closed Loop Network
% Use this network to do multi-step prediction.
% The function CLOSELOOP replaces the feedback input with a direct
% connection from the outout layer.
netc = closeloop(net);
netc.name = [net.name ' - Closed Loop'];


% Only a certain number of predictions can be made
%accurately modulate this parameter to check it.
NumberOfPredictions = 30

% Creating a new input series which has the time
% inputs for the second half of the time but also
% includes last 10 time steps from the previous
% timeSeries
newInputSeries = timenh(:, 1:NumberOfPredictions);
newInputSeries = [cell2mat(inputSeries(end-10:end)  ) (newInputSeries)]
%newInputSeries = num2cell(newInputSeries);
newInputSeries = tonndata(newInputSeries, true, false);

%Creating a new target with first 10 values which
%are the expected outputs network and the
%remaining targets are set to NAN, These values
%which are set to NAN will be predicted.
newTargetSet = nan(1, size(newInputSeries, 2))
newTargetSet = num2cell(newTargetSet )
newTargetSet (1:10) = targetSeries(end-9:end)


[xc,xic,aic,tc] = preparets(netc,newInputSeries,{},newTargetSet);
yPredicted = sim(netc,xc,xic,aic)
% timenh = [ timenh timenh(end)+10];
figure,plot(timeh,cell2mat(targetSeries),'.-',timenh(1:NumberOfPredictions +1),cell2mat(yPredicted),'+-')
title(['PREDICTION PLOT - NumberOfPredictions =' num2str(NumberOfPredictions)])
legend('INPUT DATA','PREDICTED DATA')