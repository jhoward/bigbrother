function [] = contPlotMult(data, dataWidth, stds)
%Plot of multiple equal-length datasets.  Standard deviation of a single
%period is optional.  The STD part of this assumes zero mean.

    dw = size(data{1}, 2);
    numMoves = floor(dw / dataWidth);
    yMax = max(data{1}, 2);
    yMin = min(data{1}, 2);

    xvals = 1:1:dataWidth;
    xvals = [xvals, fliplr(xvals)];
    
    colors = {[0 0 0], [0 0.7 0.7], [1, 0.3, 1]}

    for i = 1:numMoves + 1
%         y1 = -1 * stds;
%         y2 = stds;
%         yvals = [y1, fliplr(y2)];
%         tmp = fill(xvals, yvals, [0.5, 0, 0]);
%         set(tmp,'EdgeColor',[0.5, 0, 0],'FaceAlpha',0.5,'EdgeAlpha',0.5);
%         hold on
        
        for d = 1:size(data, 2)
            plot(data{d}((i - 1) * dataWidth + 1:(i * dataWidth)), 'Color', colors{d})
            if d == 1
                hold on
            end
        end
       
        hold off
        xlim([1, dataWidth]);
        ylim([0, 1.0]);
        waitforbuttonpress;
        fprintf(1, 'Current Index: %i\n', (i - 1) * dataWidth + 1);
    end
end

