function [] = contPlot(data, width)

    dw = size(data, 2);
    numMoves = floor(dw / width);
    yMax = max(data);
    yMin = min(data);
    
    for i = 1:numMoves + 1
        fprintf(1, 'Current Index: %i\n', (i - 1) * width + 1);
        plot(data((i - 1) * width + 1:(i * width)))
        xlim([1, width]);
        ylim([yMin, yMax]);
        waitforbuttonpress;
    end
end

