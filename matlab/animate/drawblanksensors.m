function drawblanksensors(sensorxy)

offsetx = 115;
offsety = 4;
scalex = 1.0;
scaley = 1.0;

% fixed radius
r1 = 5;

mycolor = [0 0 1];

% draw each sensor
for sensorid=1:size(sensorxy,1)
    x0 = scalex*sensorxy(sensorid,1) + offsetx;
    y0 = scaley*sensorxy(sensorid,2) + offsety;

    rectangle('Curvature', [1 1], ...
        'Position', [x0-r1 y0-r1 2*r1 2*r1], ...
        'FaceColor', mycolor);
end




