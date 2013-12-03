function fig = plotPonan(res, stds, drawPoints) 
%Function to plot the ponan

    newSize = floor(size(res, 2)/size(stds, 2));    
    newData = res(1, 1:size(stds, 2) * newSize);
    repstds = repmat(stds, 1, newSize);


    
    fig = figure('Position', [100, 100, 100 + 2000, 100 + 750]);

    [value rmsevalue sseonan errpoints] = ponan(res, stds);

    errpoints = errpoints .* newData;
    
    errpoints(errpoints == 0) = -3;
    epnd = errpoints;
    
    plotRange = size(newData, 2);
    
    
    %Display std of residual
    xvals = 1:1:plotRange;
    xvals = [xvals, fliplr(xvals)];
    y1 = zeros(size(newData)) + repstds;
    y2 = zeros(size(newData)) - repstds;
    %y2 = weeklyMean(dayOfWeek, :) + weeklySigma(dayOfWeek, :);
    yvals = [y1, fliplr(y2)];
    tmp = fill(xvals, yvals, [0.5, 0, 0]);
    set(tmp,'EdgeColor',[0.5, 0, 0],'FaceAlpha',0.5,'EdgeAlpha',0.5);
    hold on;
    plot(newData, 'Color', [0, 0.5, 0.5], 'LineWidth', 2)
    hold on

    if drawPoints
        plot(epnd, '*', 'Color', [0.1, 0.1, 0.1], 'LineWidth', 3)
    end
    
    xlim([1, size(newData, 2)]);
    ylim([-0.4 0.4])
    %set(gca,'DefaultAxesFontName', 'Symbol')
    xlabel({'Time'}, 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
    ylabel({'Residual Values'}, 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)

    if drawPoints
        title({'Demonstration of PONAN'}, 'FontSize', 24, 'FontName', MyConstants.FONT_TYPE);
    else
        title({'Demonstration of SSEONAN'}, 'FontSize', 24, 'FontName', MyConstants.FONT_TYPE);
    end
    set(gca,'XTickLabel',[]);

end

