function fig = plotGaussianModel(model, varargin)
%Plot the gaussian model    
    if nargin < 1
       error(message('plotMean - Not enough inputs'))
    end

    parser = inputParser;
    parser.CaseSensitive = false;
    parser.addOptional('figsizeX', 1000);
    parser.addOptional('figsizeY', 750);
    parser.addOptional('xlabel', 'time');
    parser.addOptional('ylabel', 'activity activation');
    parser.addOptional('plotTitle', 'Activity activation vs time');
    parser.addOptional('meanColor', [0, 0.5, 0.5]);
    parser.addOptional('stdColor', [0.5, 0, 0]);
    parser.addOptional('rawData', []);


    try 
      parser.parse(varargin{:});
    catch exception
      exception.throwAsCaller();
    end


    figsizeX = parser.Results.figsizeX;
    figsizeY = parser.Results.figsizeY;
    graph_xlabel = parser.Results.xlabel;
    graph_ylabel = parser.Results.ylabel;
    plotTitle = parser.Results.plotTitle;
    meanColor = parser.Results.meanColor;
    stdColor = parser.Results.stdColor;
    rawData = parser.Results.rawData;
    dataLen = model.modelLength;
    width = 2;
    means = model.avgValues;
    stds = model.noiseValues;
    xvals = 1:1:dataLen;
    xvals = [xvals, fliplr(xvals)];
    lineGraph = true;
    
    fig = figure('Position', [100, 100, 100 + figsizeX, 100 + figsizeY]);

    y1 = means - stds;
    y2 = means + stds;
    yvals = [y1, fliplr(y2)];

    tmp = fill(xvals, yvals, stdColor);
    set(tmp,'EdgeColor',stdColor,'FaceAlpha',0.5,'EdgeAlpha',0.5);
    hold on;

    if size(rawData, 1) > 0
        for i = 1:size(rawData, 1)
            plot(1:dataLen, rawData(i, :), 'Color', [0.5, 0.5, 0.5])
        end
    end
    
    
    if ~lineGraph
        means1 = means - (width/2);
        means2 = means + (width/2);
        meanVals = [means1, fliplr(means2)];
        tmp2 = fill(xvals, meanVals, meanColor);
        set(tmp2, 'EdgeColor', meanColor, 'FaceAlpha', 1.0, 'EdgeAlpha', 1.0);
        hold on;
    else
        plot(1:1:dataLen, means, 'LineWidth', width, 'Color', meanColor); 
        hold on
    end

    xlim([1, dataLen]);
    ylim([-1.5, 1.5]);
    %set(gca,'DefaultAxesFontName', 'Symbol')
    xlabel(graph_xlabel, 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
    ylabel(graph_ylabel, 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
    title(plotTitle, 'FontSize', 24, 'FontName', MyConstants.FONT_TYPE);
end

