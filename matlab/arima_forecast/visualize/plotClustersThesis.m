function fig = plotClustersThesis(windows, idx, varargin)
%Plot all cluster centers

    parser = inputParser;
    parser.CaseSensitive = false;
    parser.addOptional('times', []);
    parser.addOptional('centers', []);
    parser.addOptional('plotWindows', true);
    parser.addOptional('dataset', 1);
    parser.addOptional('model', 'svm');

    try 
      parser.parse(varargin{:});
    catch exception
      exception.throwAsCaller();
    end

    dataTimes = parser.Results.times;
    centers = parser.Results.centers;
    plotWindows = parser.Results.plotWindows;
    dataset = parser.Results.dataset;
    model = parser.Results.model;

    numClusters = size(unique(idx), 1);
    if min(idx) == -1
        numClusters = numClusters - 1;
    end
    
    fig = figure('Position', [100, 100, 100 + 1200, 100 + 550]);
    
    suby = 2;
    subx = ceil(numClusters / suby);
    
    width = size(windows, 2);
    
    for i = 1:numClusters
        index = find(idx == i);
        subplot(suby, subx, i);
        
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
            ylim([-0.4, 0.4]);
            hold off
        end

        if ~isempty(dataTimes)
            clusterDays = data.times(ind(index));
            ind(index)
            datestr(clusterDays)
        end
        
        %set(gcf, 'NextPlot', 'add');
        %axes;
        %plotTitle = ['Sample clusters for ', MyConstants.DATA_SETS{dataset}, ' dataset from ', model, ' model'];
        %suptitle(plotTitle);
    end
    
    