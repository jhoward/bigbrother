classdef NARNET < bcf.models.Model
    %TDNNMODEL time delayed neural network model
    properties
        net
        
    end
    
    methods        
        function obj = NARNET(net)
            obj.net = net;
        end
        
        function output = forecastAll(obj, data, ahead)
            output = bcf.forecast.narForecast(obj, data, ahead);
        end
    end
    
end

