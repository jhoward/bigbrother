function [ windows, indexes ] = largestWindow(data, windowSize, numWindows, removeWindow)
    %Finds the windows with the largest total value for a given size
    %window.  Relies on peak finding algorithm to work.

    %ndata = smooth(data, 0.009, 'lowess');
    %ndata = ndata';
    ndata = smooth(abs(data), 10);
    ndata = ndata';
    %ndata = data';
    %ndata = data;
    [pks, locs] = findpeaks(ndata);
    [~, ind] = sort(pks, 'descend');
    windows = cell(1, numWindows);
    indexes = zeros(1, numWindows);
    
    for i = 1:numWindows
        win = floor(windowSize / 2);
        windows{1, i} = ndata(:, locs(ind(i)) - win : locs(ind(i)) + win);
        indexes(1, i) = locs(ind(i));
    end

    %Remove any seasonal windows
    rInd = [];
    for i = 1:numWindows
        t = find(indexes(i) >= (indexes - max(removeWindow)) & indexes(i) <= (indexes - min(removeWindow)));
        rInd = [rInd t];
    end
    
    indexes(rInd) = [];
    windows(rInd) = [];
end

