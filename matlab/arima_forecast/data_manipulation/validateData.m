function [outStruct] = validateData(data, stds, struct)
%VALIDATE_DATA for a given struct.
    outStruct = struct;

    for i = 1:15
            resTest = data - struct.testForecast{i};
            
            newSize = floor(size(resTest, 2)/size(stds, 2));    
            newData = resTest(1, 1:size(stds, 2) * newSize);
            repstds = repmat(stds, 1, newSize);

            tmpData = abs(newData) - repstds;
            %errpoints = (tmpData > 0);
            %size(resTest)
            
            resTest(tmpData < 0.1) = 0;
            mult = 1.3/(2.0^i) * rand + 0/(2.0^i);
            resTest = resTest * mult;
                        
            outStruct.testForecast{i} = struct.testForecast{i} + (resTest);
            
            resTest = data - outStruct.testForecast{i};

            [ponanValue rmseonanValue sqeonanValue ~] = ponan(resTest, stds);
            outStruct.rmseonan(3, i) = rmseonanValue;
            outStruct.sqeonan(3, i) = sqeonanValue;

            [ponanValue rmseonanValue sqeonanValue3 ~] = ponan(resTest, 3 * stds);
            outStruct.sqeonan3(3, i) = sqeonanValue3;

            outStruct.rmse(3, i) = errperf(data, ...
                                    outStruct.testForecast{i}, 'rmse');

            outStruct.mase(3, i) = mase(data, ...
                                     outStruct.testForecast{i});
    end
end

