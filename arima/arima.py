import rpy2.robjects.numpy2ri
import rpy2.robjects as R
from rpy2.robjects.packages import importr
forecast = importr("forecast")

R.r("data(datasets/color)")

#R.r.assign("sd", data_1d)
#mod = R.r('mod = arima(sd, order=c(1,1,1))')#, seasonal=list(order=c(0,1,1), period=168))')
#fd = R.r('fd = forecast.Arima(mod)')
