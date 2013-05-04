function [output] = tdnnForecast(obj, data, ahead)
%Forecast some number of steps ahead for an entire data file.
    output = data;
    data = tonndata(data, true, false);
    [xs, xi, ai] = preparets(obj, data(:, 1:end - ahead), data(:, 1 + ahead:end));
    predict = obj(xs, xi, ai);

    predict = cell2mat(predict);
    
    output(:, obj.numInputDelays + ahead + 1:end) = predict;
end

