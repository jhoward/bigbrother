function m = createModel(modelName, varargin)

    if strcmp(modelName, 'svm')
        m = svmModel(varargin);
    end
    
    if strcmp(modelName, 'tdnn')
        m = tdnnModel(varargin);
    end
    
    if strcmp(modelName, 'avg')
        m = avgModel(varargin);
    end
    
    if strcmp(modelName, 'arima')
        m = arimaModel(varargin);
    end
end


function tmpModel = svmModel(varargin)
    tmpModel = 'svmModel';
end

function tmpModel = tdnnModel(varargin)
    tmpModel = 'tdnnModel';
end

function tmpModel = avgModel(varargin)
    tmpModel = 'avgModel';
    
    
end

function tmpModel = arimaModel(varargin)
    tmpModel = 'arimaModel';
end
