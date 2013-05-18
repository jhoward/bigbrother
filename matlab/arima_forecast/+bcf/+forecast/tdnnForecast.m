function [output] = tdnnForecast(obj, data, ahead)
%Forecast some number of steps ahead for an entire data file.
     output = data;
     data = tonndata(data, true, false);
%     [xs, xi, ai] = preparets(obj, data(:, 1:end - ahead), data(:, 1 + ahead:end));
%     predict = obj(xs, xi, ai);
% 
%     predict = cell2mat(predict);
%     
%     output(:, obj.numInputDelays + ahead + 1:end) = predict;
    netc = closeloop(obj);
    delay = obj.numInputDelays;
    
    dlen = floor(size(data, 2) / 10);
    count = 0;
    
    for i = 1  + delay + ahead:size(data, 2) - ahead
        
        if mod(i, dlen) == 0
            count = count + 10;
            fprintf(1, '%i  ', count);
        end
        
        isv = data(:, i - ahead + 1:i);
        tsv = data(:, i:i + ahead);
        isp = [data(:, i - delay + 1:i), isv];
        %size(isp)
        
        tsp = [data(:, i - delay + 1:end), con2seq(nan(1, ahead))];
        %size(tsp)
        [xs, xi, ai] = preparets(netc, isp, {}, {});
        predict = netc(xs, xi, ai);
        
        predict = cell2mat(predict);
        output(:, i + ahead) = predict(:, end);
    end
end

