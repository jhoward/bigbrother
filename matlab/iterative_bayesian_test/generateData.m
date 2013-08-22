%Generate data
function data = generateData(unitSize, numUnits, type, noiseStd)

    data = zeros(1, unitSize * numUnits);
    
    %Full sin curves
    if type == 1;
        stepSize = numUnits * 2 * pi / (unitSize * numUnits);
        endData = numUnits * 2 * pi - stepSize;
        x = 0:stepSize:endData;
        data = 1.0 .* (sin(x) + noiseStd .* randn(size(x)));
        %data = 2.5 .* (sin(x) + noiseStd .* randn(size(x)));
    end
    
    %y = x^2
    if type == 2;
        yB = 0:1:unitSize - 1;
        yB = yB .* yB;
        yB = yB ./ max(yB);
        yB = repmat(yB, [1 numUnits]);
        %data = 1.5 .* (yB + noiseStd .* randn(size(yB)));
        data = 1.0 .* (yB + noiseStd .* randn(size(yB)));
    end
    
    %y = 0 + noise
    if type == 3;
        yN = zeros(1, unitSize * numUnits);
        yN = noiseStd .* randn(1, unitSize * numUnits);
        data = yN;
    end
    
    
end