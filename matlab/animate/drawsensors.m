function drawsensors(sensorxy,activationcount,maxcount)

offsetx = 115;
offsety = 4;
scalex = 1.0;
scaley = 1.0;

r1 = 10;

% fill each sensors with count
for sensorid=1:size(sensorxy,1)
    if activationcount(sensorid) > 0
        x0 = scalex*sensorxy(sensorid,1) + offsetx;
        y0 = scaley*sensorxy(sensorid,2) + offsety;

%         c = activationcount(sensorid);
%         if c > maxcount     c = maxcount;   end
%         mycolor = [1 (c/maxcount) 0];

        mycolor = [1 0 0 ];     % red
        rectangle('Curvature', [1 1], ...
            'Position', [x0-r1 y0-r1 2*r1 2*r1], ...
            'FaceColor', mycolor);
    end
end
