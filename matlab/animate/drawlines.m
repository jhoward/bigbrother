function success = drawlines(mapcoordinates,lwidth)

    for i=1:size(mapcoordinates,1)
        line(mapcoordinates(i,1:2), mapcoordinates(i,3:4), 'LineWidth', lwidth);
    end
    
    success = 1;
end