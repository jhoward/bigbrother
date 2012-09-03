clear all
close all
tic
% Read data
load mat/synthDataRandom.mat

minHeight = 2;
minWidth = 2;

%If this is set to one, then all predicted values will be either one or zero.
%Otherwise all predicted values will be continous from 1 to 0.
discretize = 1;

printIncrement = 0.02;

%Create a dictionary 
%Format for each element in the dictionary is:
%   {Pattern ; zeros count vector ; ones count vector}
%zeros and ones count vectors are of the form 1 by size(pattern, 2)
%They represent the number of instances of zeros in that relative position and
%ones in that relative position
dict = {};

%Temporary dictionary to ensure the actual dictionary doesn't get
%updated sooner than it should.
tempDict = {};

%Temp dict is kept so that updates happen only at the end of a row
%scan instead of all the time.  When dictionary updates happen as
%soon as they can, the algorithm can cheat.
tempDict = {};

%Output data
%Lose minHeight number of rows due to lack of historic data
predictedData = zeros(size(data, 1) - minHeight, size(data, 2));
predictedData(:, 1) = data(minHeight + 1:size(data, 1), 1);

target = printIncrement;

%Iterate through the dataset
for i = minHeight:size(data, 1) - 1
    
    if (i - minHeight + 1)/(size(data, 1) - 1) >= target
        target = target + printIncrement;
        fprintf('%3.0f\n', target * 100);
    end
    
    tempDict = {};
    
    %Iterate through the sensors
    for j = 2:size(data, 2)
        
        %Reset the height and width to the minimums
        currentHeight = minHeight;
        currentWidth = minWidth;
    
        %Set the old pattern
        %Format for each element is: 
        %index, position
        oldZeros = 0;
        oldOnes = 0;
        
        predictedValue = 0;
        
        endLoop = 0;
    
        %The algorithm
        while endLoop == 0 
            levelZeros = 0;
            levelOnes = 0;
        
            %Acquire the correlation pattern
            %Sort correlation scores
            
            
            
            %Define index locations for pattern checking
            for k = max(2, j-currentWidth):...
                    min(size(data, 2) - currentWidth + 1, j + 1)
                patternZeros = 0;
                patternOnes = 0;
                
                %Acquire the current running pattern
                runningPattern = data(i - currentHeight + 1:i, ...
                                      k:k+currentWidth - 1);
                                
                %See if the pattern is in the dictionary
                for l = 1:size(dict, 2)
                    
                    %If pattern in dictionary update temp dictionary with 
                    %pattern information and get the counts
                    if size(dict{l}{1}) == size(runningPattern)
                        if dict{l}{1} == runningPattern
                        
                            %fprintf(1,'If dictionary = runPat\n');

                            %Update patternZeros and patternOnes here
                            relativeLocation = j - k + 2;

                            patternZeros = dict{l}{2}(relativeLocation);
                            patternOnes = dict{l}{3}(relativeLocation);

                            %Update the pattern in the dictionary.
                            
                            newIndex = size(tempDict, 2) + 1;
                            
                            tempDict{newIndex}{1} = runningPattern;
                            tempDict{newIndex}{2} = zeros(1, currentWidth + 2);
                            tempDict{newIndex}{3} = zeros(1, currentWidth + 2);
                            
                            if k < 3
                                vectPos = 2;
                            else
                                vectPos = 1;
                            end;

                            for m = max(k - 1, 2):k + size(runningPattern, 2)

                                if m > size(data, 2)
                                    break;
                                end;

                                if data(i+1, m) == 0
                                    tempDict{newIndex}{2}(vectPos) = ...
                                        tempDict{newIndex}{2}(vectPos) + 1;
                                else
                                    tempDict{newIndex}{3}(vectPos) = ...
                                        tempDict{newIndex}{3}(vectPos) + 1;
                                end;

                                vectPos = vectPos + 1;
                            end;

                            break;
                        end;
                    end;
                end; %end for l = 1:size(dict, 2)
                
                
                %If pattern not in dictionary, add it
                if patternZeros == 0 && patternOnes == 0
              
                    %fprintf(1, 'Pattern not in dictionary\n');
                    
                    %Update the dictionary
                    newIndex = size(tempDict, 2) + 1;
                    
                    tempDict{newIndex}{1} = runningPattern;
                    tempDict{newIndex}{2} = zeros(1, currentWidth + 2);
                    tempDict{newIndex}{3} = zeros(1, currentWidth + 2);
                    
                    %Update the pattern in the dictionary.
                    if k < 3
                        vectPos = 2;
                    else
                        vectPos = 1;
                    end;

                    for m = max(k - 1, 2):k + size(runningPattern, 2)

                        if m > size(data, 2)
                            break;
                        end;

                        if data(i+1, m) == 0
                            tempDict{newIndex}{2}(vectPos) = ...
                                tempDict{newIndex}{2}(vectPos) + 1;
                        else
                            tempDict{newIndex}{3}(vectPos) = ...
                                tempDict{newIndex}{3}(vectPos) + 1;
                        end;

                        vectPos = vectPos + 1;
                    end;
                end;
                
                levelZeros = levelZeros + patternZeros;
                levelOnes = levelOnes + patternOnes;
                
                
                %for n = 1:size(dict, 2)
                %    fprintf(1, 'Dict at %d\n', n);
                %    disp(dict{n}{1})
                %    disp(dict{n}{2})
                %    disp(dict{n}{3})
                %end;
                
            end; %End For k
            


            %Check if any patterns were found.  If they were, store them and 
            %increase the pattern size.  If none were found then take the
            %old patterns and determine the predictedValue.
            
            if levelZeros == 0 && levelOnes == 0
                %fprintf(1, 'No pattern found\n');
                
                if discretize == 0
                    if (oldZeros + oldOnes) > 0
                        predictedValue = oldOnes/(oldOnes + oldZeros);
                    else
                        predictedValue = 0;
                    end;
                else

                    if oldZeros > oldOnes
                        predictedValue = 0;
                    end;

                    if oldOnes > oldZeros
                        predictedValue = 1;
                    end;

                    if oldZeros == oldOnes
                        predictedValue = 0;
                    end;
                end;

                %End the while loop
                endLoop = 1;
                
            else
                %fprintf(1, 'Pattern found\n');
                %If there was a pattern found, store old information and
                %increase pattern size
                
                oldZeros = levelZeros;
                oldOnes = levelOnes;
                
                currentHeight = currentHeight + 1;
                currentWidth = currentWidth + 1;
                
                if i - currentHeight < 0
                    
                    %fprintf(1, 'Height too big\n');
                   
                    if discretize == 0
                        predictedValue = oldOnes/(oldOnes + oldZeros);
                    else   

                        if oldZeros > oldOnes
                            predictedValue = 0;
                        end;

                        if oldOnes > oldZeros
                            predictedValue = 1;
                        end;

                        if oldZeros == oldOnes
                            predictedValue = 0;
                        end;
                    end;

                    %End the while loop
                    endLoop = 1;
                end;
                if currentWidth > size(data, 2) - 1
                    
                    %fprintf(1, 'Width too big\n');
                    
                    if discretize == 0
                        predictedValue = oldOnes/(oldOnes + oldZeros);
                    else           
                        if oldZeros > oldOnes
                            predictedValue = 0;
                        end;

                        if oldOnes > oldZeros
                            predictedValue = 1;
                        end;

                        if oldZeros == oldOnes
                            predictedValue = 0;
                        end;
                    end;

                    %End the while loop
                    endLoop = 1;
                end;
            end;
        end; %End while
        
        
        %fprintf(1, 'PredictedValue:%d\n', predictedValue);
        predictedData(i - 1, j) = predictedValue;
    end;
    
    %After each row, update the dictionary with the contents of tempDict
    %This is where pruning decisions would go
    
    for k = 1:size(tempDict, 2)
        found = 0;

        for l = 1:size(dict, 2)
            
            if size(tempDict{k}{1}) == size(dict{l}{1})
                if tempDict{k}{1} == dict{l}{1}
                    dict{l}{2} = dict{l}{2} + tempDict{k}{2};
                    dict{l}{3} = dict{l}{3} + tempDict{k}{3};
                    found = 1;
                    break;
                end;
            end;
        end;
        
        if found == 0
            newIndex = size(dict, 2) + 1;
            
            dict{newIndex}{1} = tempDict{k}{1};
            dict{newIndex}{2} = tempDict{k}{2};
            dict{newIndex}{3} = tempDict{k}{3};
        end;
    end; %End for k = 1:size...
end; %End for i = 2:size(data...
    
save mat/synthDataRandomTrainedLZW.mat data predictedData
                                   
toc
