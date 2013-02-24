function [windows, values]=maxDevWindows(y, p, d)
    %First smooth the data then find the top peaks and use those as window
    %centers.
    %y = target data
    %p = raw data
    %d = window width
    %For not just use the l2 norm

    error = y-p;
    serror = abs(error);
    serror = smooth(error, 'lowess');
    serror = serror';
    [peaks, loc] = findpeaks(serror, 'MINPEAKDISTANCE', 5, 'MINPEAKHEIGHT', max(serror)*0.1);
    values = zeros(1, size(peaks, 2));
    
    offset = floor(d/2);
    
    for i = 1:size(peaks, 2)
        values(1, i) = norm(serror(1, loc(i)-offset:loc(i)+offset), 2);
    end

    [values, ind] = sort(values, 2, 'descend');
    windows = loc(ind);
    windows = windows - offset;
end