classdef NARNET < bcf.models.Model
    %TDNNMODEL time delayed neural network model
    properties
        net
        
    end
    
    methods        
        function obj = NARNET(net)
            obj.net = net;
        end
        
        function val = forecast(obj, data, ahead)
            %TODO Change this to handle vector values
            td = num2cell(data);
            [xs,xi,~,~] = preparets(obj.net,{},{}, td);
            if isempty(xs)
                val = obj.net({0},xi);
            else 
                val = obj.net(xs, xi);
            end
            val = cell2num(val);
        end
    end
    
end

