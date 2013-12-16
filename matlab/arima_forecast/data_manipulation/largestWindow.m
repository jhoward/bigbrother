function [windows, indexes] = largestWindow(data, windowSize, numWindows, removeWindow, smoothData)
    %Finds the windows with the largest total value for a given size
    %window.  Relies on peak finding algorithm to work.

    %ndata = smooth(data, 0.009, 'lowess');
    %ndata = ndata';
    ndata = data;
    if smoothData > 0
        ndata = smooth(abs(data), 5);
        ndata = ndata';
    end
        %ndata = data';
    %ndata = data;
    [pks, locs] = findpeaks(ndata);
    [~, ind] = sort(pks, 'descend');
    windows = [];
    indexes = zeros(1, numWindows);
    addOffset = mod(windowSize, 2) - 1;
    
    for i = 1:numWindows
        win = floor(windowSize / 2);
        windows(i, :) = data(:, locs(ind(i)) - win : locs(ind(i)) + win + addOffset); %#ok<AGROW>
        indexes(1, i) = locs(ind(i));
    end

    
    if removeWindow
        %Remove any seasonal windows
        rInd = [];
        for i = 1:numWindows
            t = find(indexes(i) >= (indexes - max(removeWindow)) & indexes(i) <= (indexes - min(removeWindow)));
            rInd = [rInd t];
        end
    
        indexes(rInd) = [];
        windows(rInd) = [];
    end
end

