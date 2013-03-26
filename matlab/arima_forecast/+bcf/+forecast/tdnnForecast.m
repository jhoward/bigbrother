function [output] = tdnnForecast(obj, data, ahead)
%Forecast some number of steps ahead for an entire data file.
    output = data;
    data = tonndata(data, true, false);
    [xs, xi, ai] = preparets(obj, data(:, 1:end - ahead), data(:, 1 + ahead:end));
    predict = obj(xs, xi, ai);

    predict = cell2mat(predict);
    
    output(:, obj.numInputDelays + ahead + 1:end) = predict;
%     cobj = closeloop(obj);
%     output = data;
%     
%     inc = floor(.1 * size(data, 2));
%     count = 0;
%     fprintf(1, 'Forecasting:');
%  
%     data = tonndata(data, true, false);
%     off = obj.numInputDelays;
%     
%     for i = 1  + obj.numInputDelays:size(data, 2) - ahead
%         
%         if mod(i, inc) == 0
%             count = count + 10;
%             fprintf(1, '%i  ', count);
%         end
%         
%         yini = data(:, i - off : i + ahead);
%         
% %         datacut = data(:, i - off : i + ahead);
% %         
% %         yini = zeros(size(datacut));
% %         yini = tonndata(yini, true, false);
% %         yini(:, 1:size(datacut, 2) - ahead) = data(:, i - off : i);
%         
%         [xs, xi, ai] = preparets(cobj, yini, yini);
%         predict = cobj(xs, xi, ai);
%         
%         predict = cell2mat(predict);
%         output(:, i + ahead) = predict(:, end);
%     end
%     
%     fprintf(1, '\n');
end

