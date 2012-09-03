clear all
close all
%profile on
tic
% Read data
<<<<<<< .mine
load mat/synthData.mat
=======
%load mat/sensor_data_03_04_to_03_04.mat
load mat/synthDataRandom.mat
>>>>>>> .r85

minHeight = 2;
minWidth = 2;

%If this is set to one, then all predicted values will be either one or zero.
%Otherwise all predicted values will be continous from 1 to 0.
discretize = 1;

printIncrement = 0.02;

%Create a dictionary 
%Format for each element in the dictionary is:
%   {sensor ; Pattern # ; number 1, 2, or 3}
%zeros and ones count vectors are of the form 1 by size(pattern, 2)
%They represent the number of instances of zeros in that relative position and
%ones in that relative position
%dict = cell(1, size(data, 2));
%dict = {}

%Initialize the stupid dictionary.   Needs to be done both because
%I don't know enough about matlab, but also because there are no
%actual datatypes in the language.
%for i = 1:size(data, 2)
%    dict{i} = cell(1, 1000);
%end
%
%for i = 1:size(data, 2)
%    for j = 1:1000
%        dict{i}{j} = cell(1, 3);
%    end
%end


dict = {};

for i = 1:size(data, 2)
    dict{i} = {};
end



%Output data
%Lose minHeight number of rows due to lack of historic data
predictedData = zeros(size(data, 1) - minHeight, size(data, 2));
predictedData(:, 1) = data(minHeight + 1:size(data, 1), 1);

%Make a list of the closest neighbors by correlation
%Format for each element in the dictionary is:
%    {sensor ; vector of neighbors }
fprintf(1, 'Calculating neighbors.\n');
neighbors = {};

T = size(correlationMatrix, 3);
rhoMax = max(correlationMatrix(:,:,2:T), [], 3);
[temp, relCorrelation] = sort(rhoMax, 1, 'descend');


target = printIncrement;

fprintf(1, 'Predicting Data\n');
%Iterate through the dataset
for i = minHeight + 1:size(data, 1)
    
    if (i - minHeight - 1)/(size(data, 1) - minHeight - 1) >= target
        target = target + printIncrement;
        fprintf('%3.3f\n', target * 100);
    end
    
    if target > 0.5
        break
    end

    
    
    tempDict = {};
    
    %Iterate through the sensors
    for j = 2:size(data, 2)

        %Reset the height and width to the minimums
         currentHeight = minHeight;
         currentWidth = minWidth;
     
         %Set the best pattern guess
         patternZeros = 0;
         patternOnes = 0;
         
         predictedValue = 0;
         
         endLoop = 0;
         predict = 0;
     
         %The algorithm
         while endLoop == 0 
             pattern = zeros(currentWidth, currentHeight);
             
             %Make the correlation pattern
             for k = 1:currentWidth
                 pattern(k, :) = data(i - currentHeight:i - 1, ...
                                      relCorrelation(k, j - 1) + 1);
             end
             
             found = 0;

             %See if pattern is in dictionary
             for l = 1:size(dict{j}, 2)
                 %If pattern in dictionary, update temp dict with
                 %pattern information
                 if size(dict{j}{l}{1}) == size(pattern)
                     if dict{j}{l}{1} == pattern
                         found = 1;

                         %Take the current prediction
                         patternZeros = dict{j}{l}{2};
                         patternOnes = dict{j}{l}{3};
                         
                         %Update the pattern in the dictionary
                         if data(i, j) == 0
                             dict{j}{l}{2} = dict{j}{l}{2} + 1;
                         else
                             dict{j}{l}{3} = dict{j}{l}{3} + 1;
                         end
                         
                         %Increase search pattern size
                         if currentWidth < (size(data, 2) - 1)
                             currentWidth = currentWidth + 1;
                             
                             %TODO Make this a more intelligent
                             %pattern squashing
                             currentHeight = currentHeight + 1;
                         else
                             endLoop = 1;
                             predict = 1;
                         end
                     end
                 end
             end
             
             %If pattern not in dictionary, add pattern and
             %end the loop and predict the value
             if found == 0
                 
                 %Add pattern to dictionary
                 newIndex = size(dict{j}, 2) + 1;
                 dict{j}{newIndex}{1} = pattern;
                 dict{j}{newIndex}{2} = 0;
                 dict{j}{newIndex}{3} = 0;
                 
                 %Update the pattern in the dictionary
                 if data(i, j) == 0
                     dict{j}{newIndex}{2} = dict{j}{newIndex}{2} + 1;
                 else
                     dict{j}{newIndex}{3} = dict{j}{newIndex}{3} + 1;
                 end
                 
                 endLoop = 1;
                 predict = 1;
             end
             
             
             %predict the value
             if predict == 1
                 if discretize == 1
                     if patternZeros >= patternOnes
                         predictedData(i - minHeight, j) = 0;
                     else
                         predictedData(i - minHeight, j) = 1;
                     end
                 else
                     predictedData(i - minHeight, j) = ...
                         patternOnes / (patternOnes + patternZeros);
                 end
             end
         end %End while endLoop
    end %End for j
end %End for i
                 
                 
save mat/realCorrelation.mat beginTime endTime ...
    data predictedData dict relCorrelation
toc
