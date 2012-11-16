function forecastData = forecast_101011(data, ar, ma, sma, seasonality, fStart, fEnd)
%Forecast the next output for now.

fData = zeros(fEnd, 1);


%Get "caught" up to fStart
for i = seasonality + 1:fEnd
    arComp = ar * (data(i) - data(i - seasonality));
    maComp = ma * (data(i) - fData(i));
    smaComp = sma * (data(i - seasonality + 1) - fData(i - seasonality + 1));
    maSmaComp = ma * sma * (data(i - seasonality) - fData(i - seasonality));
    
    fData(i + 1) = data(i - seasonality + 1) + arComp - maComp - smaComp + maSmaComp;
end

forecastData = fData(fStart:fEnd, :);
end

