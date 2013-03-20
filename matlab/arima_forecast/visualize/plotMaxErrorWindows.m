function plotMaxErrorWindows( output, predoutput, windowSize, numErrorWindows)
%Plot the maximum error windows.

    %Find the largest error windows
    res = predoutput - output;
    [~, inds] = largestWindow(res, windowSize, numErrorWindows); 

    %plot the top 3 largest windows
    for i = 1:numErrorWindows
        win = floor(windowSize/2);
        x = linspace(1, windowSize * 3 + 1, windowSize * 3 + 1);
        plot(x, [output(:, inds(1, i) - 3 * win : inds(1, i) + 3 * win); ...
                    predoutput(:, inds(1, i) - 3 * win: inds(1, i) + 3 * win)]);
        xlim([1 windowSize * 3 + 1]);        

        mape = errperf(predoutput(:, inds(1, i) - 3 * win: inds(1, i) + 3 * win), ...
                    output(:, inds(1, i) - 3 * win : inds(1, i) + 3 * win), 'mape');
        mse = errperf(predoutput(:, inds(1, i) - 3 * win: inds(1, i) + 3 * win), ...
                    output(:, inds(1, i) - 3 * win : inds(1, i) + 3 * win), 'mse');
        rmse = errperf(predoutput(:, inds(1, i) - 3 * win: inds(1, i) + 3 * win), ...
                    output(:, inds(1, i) - 3 * win : inds(1, i) + 3 * win), 'rmse');

        fprintf(1, 'Window error rates -- mape: %f      mse: %f       rmse:%f\n\n', mape, mse, rmse);
        
        waitforbuttonpress;
    end
end

