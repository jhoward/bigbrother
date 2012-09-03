function val = simpleCount(pattern, cmpPattern, threshold)

    count = 0;
    
    for i = 1:size(pattern, 1)
        for j = 1:size(pattern, 2)
            if pattern(i, j) == cmpPattern(i, j)
              count = count + 1;
            end;
        end;
    end;
    
    
    totalSize = size(pattern, 1) * size(pattern, 2);
    
    if count/totalSize > threshold
        val = count/totalSize;
    else
        val = 0;
    end;