%Simple program to create the results set for each dataset.

svm.trainForecast = {};
svm.testForecast = {};
svm.validForecast = {};
svm.rmse = [];
svm.mase = [];
svm.rmseonan = [];
svm.sqeonan = [];


arima.trainForecast = {};
arima.testForecast = {};
arima.validForecast = {};
arima.rmse = [];
arima.mase = [];
arima.rmseonan = [];
arima.sqeonan = [];


tdnn.trainForecast = {};
tdnn.testForecast = {};
tdnn.validForecast = {};
tdnn.rmse = [];
tdnn.mase = [];
tdnn.rmseonan = [];
tdnn.sqeonan = [];


average.trainForecast = {};
average.testForecast = {};
average.validForecast = {};
average.rmse = [];
average.mase = [];
average.rmseonan = [];
average.sqeonan = [];


BCF.trainForecast = {};
BCF.testForecast = {};
BCF.validForecast = {};
BCF.rmse = [];
BCF.mase = [];
BCF.rmseonan = [];
BCF.sqeonan = [];
BCF.trainProbs = {};
BCF.validProbs = {};
BCF.testProbs = {};
BCF.trainProbsRaw = {};
BCF.validProbsRaw = {};
BCF.testProbsRaw = {};


IBCF.trainForecast = {};
IBCF.testForecast = {};
IBCF.validForecast = {};
IBCF.rmse = [];
IBCF.mase = [];
IBCF.rmseonan = [];
IBCF.sqeonan = [];
IBCF.trainProbs = {};
IBCF.validProbs = {};
IBCF.testProbs = {};
IBCF.trainProbsRaw = {};
IBCF.validProbsRaw = {};
IBCF.testProbsRaw = {};


ICBCF.trainForecast = {};
ICBCF.testForecast = {};
ICBCF.validForecast = {};
ICBCF.rmse = [];
ICBCF.mase = [];
ICBCF.rmseonan = [];
ICBCF.sqeonan = [];
ICBCF.trainProbs = {};
ICBCF.validProbs = {};
ICBCF.testProbs = {};
ICBCF.trainProbsRaw = {};
ICBCF.validProbsRaw = {};
ICBCF.testProbsRaw = {};


ABCF.svm.testForecast = {};
ABCF.svm.rmse = [];
ABCF.svm.mase = [];
ABCF.svm.rmseonan = [];
ABCF.svm.sqeonan = [];
ABCF.svm.clusters = {};
ABCF.svm.testProbs = {};
ABCF.svm.centers = {};
ABCF.svm.idx = {};


ABCF.arima.testForecast = {};
ABCF.arima.rmse = [];
ABCF.arima.mase = [];
ABCF.arima.rmseonan = [];
ABCF.arima.sqeonan = [];
ABCF.arima.clusters = {};
ABCF.arima.testProbs = {};
ABCF.arima.centers = {};
ABCF.arima.idx = {};


ABCF.tdnn.testForecast = {};
ABCF.tdnn.rmse = [];
ABCF.tdnn.mase = [];
ABCF.tdnn.rmseonan = [];
ABCF.tdnn.sqeonan = [];
ABCF.tdnn.clusters = {};
ABCF.tdnn.testProbs = {};
ABCF.tdnn.centers = {};
ABCF.tdnn.idx = {};


ABCF.average.testForecast = {};
ABCF.average.rmse = [];
ABCF.average.mase = [];
ABCF.average.rmseonan = [];
ABCF.average.sqeonan = [];
ABCF.average.clusters = {};
ABCF.average.testProbs = {};
ABCF.average.centers = {};
ABCF.average.idx = {};


ABCF.BCF.testForecast = {};
ABCF.BCF.rmse = [];
ABCF.BCF.mase = [];
ABCF.BCF.rmseonan = [];
ABCF.BCF.sqeonan = [];
ABCF.BCF.clusters = {};
ABCF.BCF.testProbs = {};
ABCF.BCF.centers = {};
ABCF.BCF.idx = {};


ABCF.IBCF.testForecast = {};
ABCF.IBCF.rmse = [];
ABCF.IBCF.mase = [];
ABCF.IBCF.rmseonan = [];
ABCF.IBCF.sqeonan = [];
ABCF.IBCF.clusters = {};
ABCF.IBCF.testProbs = {};
ABCF.IBCF.centers = {};
ABCF.IBCF.idx = {};


ABCF.ICBCF.testForecast = {};
ABCF.ICBCF.rmse = [];
ABCF.ICBCF.mase = [];
ABCF.ICBCF.rmseonan = [];
ABCF.ICBCF.sqeonan = [];
ABCF.ICBCF.clusters = {};
ABCF.ICBCF.testProbs = {};
ABCF.ICBCF.centers = {};
ABCF.ICBCF.idx = {};


results.svm = svm
results.arima = arima
results.average = average
results.tdnn = tdnn
results.BCF = BCF
results.IBCF = IBCF
results.ABCF = ABCF


save(MyConstants.RESULTS_DATA_LOCATIONS{1}, 'results');
save(MyConstants.RESULTS_DATA_LOCATIONS{2}, 'results');
save(MyConstants.RESULTS_DATA_LOCATIONS{3}, 'results');