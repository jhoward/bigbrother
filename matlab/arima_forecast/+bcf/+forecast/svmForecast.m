function output = svmForecast(obj, data, ahead)
%Dataformat is same as always - #Dimensions by DataLength
%For now this only works with one dimension
    window = size(obj.Parameters, 1);
    output = data;
    
    %Forecast ahead
    for t = window + 1:size(data, 2) - ahead
        %set the data
        tmpData = data(1, t - window + 1:t);
        tmpOut = 0;
        for i = 1:ahead
            tmpOut = svmpredict(1, tmpData, obj, '-q');
            
            %update tmpData
            tmpData = [tmpData(2:end) tmpOut];
        end
        output(1, t + ahead) = tmpOut;
     end
end
