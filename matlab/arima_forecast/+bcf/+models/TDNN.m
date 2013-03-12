classdef TDNN
    %TDNNMODEL time delayed neural network model
    properties
        net
        
    end
    
    methods        
        function obj = TDNN(net)
            obj.net = net;
        end
        
        function val = forecast(obj, data, ahead)
            td = num2cell(data);
            [yts,yti,ati,tts] = preparets(obj.net,td,td);
            val = net(yts,yti,ati);
            
        end
    end
    
end

