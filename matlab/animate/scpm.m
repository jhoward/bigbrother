%Function to find the pattern in the data and return the value of the array
%next line at location element.  If the pattern isn't found, return
%default.

function val = scpm(data, pattern, maxHistory, element, startIndex,...
                    endIndex, default)


numRowChecks = min(maxHistory, abs(endIndex - startIndex) - size(pattern, 1));

%Quickly made two variables for the two class classifier.  Would love to use a
%hash table to handle a classifier with more possible states (classes).

numOnes = 0;
numZeros = 0;

runningStop = endIndex + 1;
runningStart = runningStop - size(pattern, 1) + 1;

for i = 1:numRowChecks
    
    runningStart = runningStart - 1;
    runningStop = runningStop - 1;
    runningPattern = data(runningStart:runningStop, 2:size(data, 2));
   
    %If the pattern compares, value at location element in the next row and
    %record its value
    patternStr = simpleCount(runningPattern, pattern(:, 2:size(pattern, 2)), .98);
    nextRowVal = data(runningStop + 1, element);

    if nextRowVal == 0
        numZeros = numZeros + patternStr;
    end;
    if nextRowVal == 1
        numOnes = numOnes + patternStr;
    end;
end;

if numOnes > numZeros
    val = 1;
end;
if numOnes < numZeros
    val = 0;
end;
if numOnes == numZeros
    val = default;
end;
        



