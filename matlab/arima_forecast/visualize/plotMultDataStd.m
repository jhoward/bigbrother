function fig = plotMultDataStd(data, stds)
%Plot of multiple equal-length datasets.  Standard deviation of a single
%period is optional.  The STD part of this assumes zero mean.

    fig = figure('Position', [100, 100, 1100, 850]);

    yMax = max(data{1}, 2);
    yMin = min(data{1}, 2);
    
    dataWidth = size(stds, 2);
    
    xvals = 1:1:dataWidth;
    xvals = [xvals, fliplr(xvals)];
    
    colors = {[0 0 0], [0 0.7 0.7], [1, 0.3, 1]}

    y1 = -1 * stds;
    y2 = stds;
    yvals = [y1, fliplr(y2)];
    tmp = fill(xvals, yvals, [0.5, 0, 0]);
    set(tmp,'EdgeColor',[0.5, 0, 0],'FaceAlpha',0.5,'EdgeAlpha',0.5);
    hold on

    for d = 1:size(data, 2)
        plot(data{d}(1, 1:dataWidth), 'Color', colors{d})
    end

    hold off
    xlim([1, dataWidth]);
    ylim([-0.8, 0.8]);
end

