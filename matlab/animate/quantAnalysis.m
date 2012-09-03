clear all
close all

%If set to zero, only global values will be shown.  One shows all values.
displayIndex = 0;

%Load the data
load mat/synthDataTrainedLZW.mat

%Construction confusion matrix
% Expect 0 get 0 (True  Neg)    Expect 0 get 1 (False Neg)
% Expect 1 get 0 (False Pos)    Expect 1 get 1 (True  Pos)
confusionMatrix = zeros(2, 2);
confusionMatrixPercent = zeros(2, 2);

%Percent of data by which a second accuracy count begins
%displayPercentAfter = 1 means this will be displayed
displayPercentAfter = 1;
percentAfter = 0.8;

threshold = 0.4;

indexConfMatrix = {};

for j = 1:size(predictedData, 2)
    indexConfMatrix{j} = zeros(2, 2);
end;

%Get the predicted data offset
offset = find(data(:, 1) == predictedData(1, 1));

%Get the counts
zerosCount = sum(data(offset:size(data, 1), 1:size(data, 2)) == 0);
onesCount = sum(data(offset:size(data, 1), 1:size(data, 2)) >= threshold);

totalZeros = sum(zerosCount(2:size(zerosCount, 2)));
totalOnes = sum(onesCount(2:size(onesCount, 2)));


%Get the counts Percent
percentIndex = ceil(size(predictedData, 2) * percentAfter);
zerosCountPercent = sum(data((offset + percentIndex):size(data, 1), ...
                             1:size(data, 2)) == 0);
onesCountPercent = sum(data((offset + percentIndex):size(data, 1), ...
                             1:size(data, 2)) >= threshold);
totalZerosPercent = sum(zerosCount(2:size(zerosCount, 2)));
totalOnesPercent = sum(onesCount(2:size(onesCount, 2)));


for i = 1:size(predictedData, 1)
    for j = 2:size(predictedData, 2)
        
        if (data(i + offset - 1, j) == 0) && (predictedData(i, j) == 0)
            indexConfMatrix{j}(1, 1) = indexConfMatrix{j}(1, 1) + 1;
            confusionMatrix(1, 1) = confusionMatrix(1, 1) + 1;
            
            if i >= percentIndex
                confusionMatrixPercent(1, 1) = ...
                    confusionMatrixPercent(1, 1) + 1;
            end
        end;

        if (data(i + offset - 1, j) == 0) && ...
                (predictedData(i, j) >= threshold)
            indexConfMatrix{j}(2, 1) = indexConfMatrix{j}(2, 1) + 1;
            confusionMatrix(2, 1) = confusionMatrix(2, 1) + 1;
            
            if i >= percentIndex
                confusionMatrixPercent(2, 1) = ...
                    confusionMatrixPercent(2, 1) + 1;
            end
        end;
        
        if (data(i + offset - 1, j) >= threshold) && ...
                (predictedData(i, j) == 0)
            indexConfMatrix{j}(1, 2) = indexConfMatrix{j}(1, 2) + 1;
            confusionMatrix(1, 2) = confusionMatrix(1, 2) + 1;
            
            if i >= percentIndex
                confusionMatrixPercent(1, 2) = ...
                    confusionMatrixPercent(1, 2) + 1;
            end
        end;
        
        if (data(i + offset - 1, j) >= threshold) && ...
                (predictedData(i, j) >= threshold)
            indexConfMatrix{j}(2, 2) = indexConfMatrix{j}(2, 2) + 1;
            confusionMatrix(2, 2) = confusionMatrix(2, 2) + 1;
            
            if i >= percentIndex
                confusionMatrixPercent(2, 2) = ...
                    confusionMatrixPercent(2, 2) + 1;
            end
        end;
    end;
end;

for j = 2:size(predictedData, 2)
    indexConfMatrix{j}(1, 1) = indexConfMatrix{j}(1, 1)/zerosCount(j);
    indexConfMatrix{j}(1, 2) = indexConfMatrix{j}(1, 2)/onesCount(j);
    indexConfMatrix{j}(2, 1) = indexConfMatrix{j}(2, 1)/zerosCount(j);
    indexConfMatrix{j}(2, 2) = indexConfMatrix{j}(2, 2)/onesCount(j);
end;


accuracy = (confusionMatrix(1, 1) + confusionMatrix(2, 2)) / ...
    (totalZeros + totalOnes);

accuracyPercent = (confusionMatrixPercent(1, 1) + ...
                   confusionMatrixPercent(2, 2)) / ...
    (totalZerosPercent + totalOnesPercent);

%Sensitivity or Recall Rate -- Measure of how well a binary
%classification test identifies a "condition"
%In diseases: Percent that if a person has a disease, the test will
%be positive.
sensitivity = confusionMatrix(2, 2) / ...
    (confusionMatrix(2, 2) + confusionMatrix(1, 2));

sensitivityPercent = confusionMatrixPercent(2, 2) / ...
    (confusionMatrixPercent(2, 2) + confusionMatrixPercent(1, 2));


%Specificity -- Mease of how well a binary classification test
%identifies the negative cases
%In diseases: Percent that if a person has a disease, the test will
%be negative.
specificity = confusionMatrix(1, 1) / ...
    (confusionMatrix(1, 1) + confusionMatrix(2, 1));

specificityPercent = confusionMatrixPercent(1, 1) / ...
    (confusionMatrixPercent(1, 1) + confusionMatrixPercent(2, 1));


%Positive predictive value or Precision rate -- Proportion of
%positive results that are accurate
precision = confusionMatrix(2, 2) / ...
    (confusionMatrix(2, 2) + confusionMatrix(2, 1));

precisionPercent = confusionMatrixPercent(2, 2) / ...
    (confusionMatrixPercent(2, 2) + confusionMatrixPercent(2, 1));


%F-measure -- weight score of precision and recall
fmeasure = 2 * precision * sensitivity / ...
    (precision + sensitivity);

fmeasurePercent = 2 * precisionPercent * sensitivityPercent / ...
    (precisionPercent + sensitivityPercent);

confusionMatrix(1, 1) = confusionMatrix(1, 1)/totalZeros;
confusionMatrix(2, 2) = confusionMatrix(2, 2)/totalOnes;
confusionMatrix(2, 1) = confusionMatrix(2, 1)/totalZeros;
confusionMatrix(1, 2) = confusionMatrix(1, 2)/totalOnes;

confusionMatrixPercent(1, 1) = confusionMatrixPercent(1, 1)/totalZerosPercent;
confusionMatrixPercent(2, 2) = confusionMatrixPercent(2, 2)/totalOnesPercent;
confusionMatrixPercent(2, 1) = confusionMatrixPercent(2, 1)/totalZerosPercent;
confusionMatrixPercent(1, 2) = confusionMatrixPercent(1, 2)/totalOnesPercent;

fprintf(1, 'True Negative:%f\n', confusionMatrix(1, 1));
fprintf(1, 'True Positive:%f\n', confusionMatrix(2, 2));
fprintf(1, 'False Positive:%f\n', confusionMatrix(2, 1));
fprintf(1, 'False Negative:%f\n', confusionMatrix(1, 2));
fprintf(1, 'Accuracy:%f\n', accuracy);
fprintf(1, 'Specificity:%f\n', specificity);
fprintf(1, 'Sensitivity:%f\n', sensitivity);
fprintf(1, 'Precision:%f\n', precision);
fprintf(1, 'F-Measure:%f\n', fmeasure);

%Display percentage information here if necessary
if displayPercentAfter == 1
    fprintf(1, '\n');
    
    fprintf(1, 'True Negative from %f percent:%f\n', ...
            percentAfter * 100, confusionMatrixPercent(1, 1));
    fprintf(1, 'True Positive from %f percent:%f\n', ...
            percentAfter * 100, confusionMatrixPercent(2, 2));
    fprintf(1, 'False Positive from %f percent:%f\n', ...
            percentAfter * 100, confusionMatrixPercent(2, 1));
    fprintf(1, 'False Negative from %f percent:%f\n', ...
            percentAfter * 100, confusionMatrixPercent(1, 2));
    fprintf(1, 'Accuracy from %f percent:%f\n', ...
            percentAfter * 100, accuracyPercent);
    fprintf(1, 'Specificity from %f percent:%f\n', ...
            percentAfter * 100, specificityPercent);
    fprintf(1, 'Sensitivity from %f percent:%f\n', ...
            percentAfter * 100, sensitivityPercent);
    fprintf(1, 'Precision from %f percent:%f\n', ...
            percentAfter * 100, precisionPercent);
    fprintf(1, 'F-Measure from %f percent:%f\n', ...
            percentAfter * 100, fmeasurePercent);
end

%Display indexConfMatrix here if necessary
if displayIndex == 1
    
    fprintf(1, '\n\n');
    
    for i = 2:size(indexConfMatrix, 2)
        fprintf(1, 'Index %i\n', i-1);
        fprintf(1, 'True Negative:%f\n', indexConfMatrix{i}(1, 1));
        fprintf(1, 'True Positive:%f\n', indexConfMatrix{i}(2, 2));
        fprintf(1, 'False Positive:%f\n', indexConfMatrix{i}(2, 1));
        fprintf(1, 'False Negative:%f\n\n', indexConfMatrix{i}(1, 2));
    end;
end;
