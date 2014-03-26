function [] = plotClusters(windows, idx, varargin)
%Plot all cluster centers
%TODO Add noise visualization

    parser = inputParser;
    parser.CaseSensitive = false;
    parser.addOptional('times', []);
    parser.addOptional('centers', []);
    parser.addOptional('noise', []);
    parser.addOptional('plotWindows', true);

    try 
      parser.parse(varargin{:});
    catch exception
      exception.throwAsCaller();
    end

    fig = figure('Position', [100, 100, 100 + 250, 100 + 250]);
    title('Denver sample cluster   ', 'FontSize', 15, 'FontName', MyConstants.FONT_TYPE);

    
    dataTimes = parser.Results.times;
    centers = parser.Results.centers;
    plotWindows = parser.Results.plotWindows;
    noise = parser.Results.noise;

    numClusters = size(unique(idx), 1);
    if min(idx) == -1
        numClusters = numClusters - 1;
    end
    
    width = size(windows, 2);
    
    %for i = 1:numClusters
    for i = 2:2
        index = find(idx == i);
        
        if plotWindows
            pData = windows(index, :);
            x = linspace(1, width, width);
            xflip = [x(1 : end - 1) fliplr(x)];
            for j = 1:size(pData, 1)
                y = pData(j, :);
                yflip = [y(1 : end - 1) fliplr(y)];
                patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
                hold on
            end
        end
        
        if size(centers, 2) > 0
            plot(centers(i, :), 'Color', [1 0 0]);
            xlim([1, size(centers, 2)]);
            hold off
        end

        if ~isempty(dataTimes)
            clusterDays = data.times(ind(index));
            ind(index)
            datestr(clusterDays)
        end

        %waitforbuttonpress;
        %clf
    end
end

