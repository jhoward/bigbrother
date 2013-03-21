function [output] = nnForecast(obj, data, ahead)
%Forecast some number of steps ahead for an entire data file.
    cobj = closeloop(obj);
    output = data;
    
    inc = floor(.1 * size(data, 2));
    count = 0;
    fprintf(1, 'Forecasting:');
 
    data = tonndata(data, true, false);
    off = obj.numInputDelays;
    
    for i = 1  + obj.numInputDelays:size(data, 2) - ahead
        
        if mod(i, inc) == 0
            count = count + 10;
            fprintf(1, '%i  ', count);
        end
        
        yini = data(:, i - off : i + ahead);
        [xs, xi, ai] = preparets(cobj, {}, {}, yini);
        predict = cobj(xs, xi, ai);
        
        predict = cell2mat(predict);
        output(:, i + ahead) = predict(:, end);
    end
    
    fprintf(1, '\n');
end

