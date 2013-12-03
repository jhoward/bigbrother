function [ windows, indexes ] = windowExtraction(data, windowSize, numWindows)
    %Finds the windows with the largest total value for a given size
    %window.  Relies on peak finding algorithm to work.

    %ndata = smooth(data, 0.009, 'lowess');
    %ndata = ndata';
    %ndata = smooth(abs(data), 4);
    %ndata = ndata';
    %ndata = data';
    ndata = data;
    [pks, locs] = findpeaks(ndata);
    
    %size(pks)
    
    [~, ind] = sort(pks, 'descend');
    windows = zeros(numWindows, windowSize);
    indexes = zeros(numWindows, 1);
    
    for i = 1:numWindows
        win = floor(windowSize / 2);
        %size(ndata(:, locs(ind(i)) - win + 1 - mod(windowSize, 2): locs(ind(i)) + win))
        windows(i, :) = data(:, locs(ind(i)) - win + 1 - mod(windowSize, 2) : locs(ind(i)) + win);
        indexes(i, 1) = locs(ind(i));
    end
    
    %Shift this index by 1
    
    %     %Remove any seasonal windows
    %     rInd = [];
    %     for i = 1:numWindows
    %         t = find(indexes(i) >= (indexes - max(removeWindow)) & indexes(i) <= (indexes - min(removeWindow)));
    %         rInd = [rInd t];
    %     end
    %     
    %     indexes(rInd) = [];
    %     windows(rInd) = [];
end

