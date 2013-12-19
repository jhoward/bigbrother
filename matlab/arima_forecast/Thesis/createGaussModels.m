function [models] = createGaussModels(windows, idx, data)
    models = {};
    
    for i = 1:max(idx)
        index = find(idx == i);
        clustData = windows(index, :); %#ok<FNDSB>
        clustData = reshape(clustData', 1, size(clustData, 1) * size(clustData, 2));
        
        models{i} = bcf.models.AvgGaussian(size(windows, 2)); %#ok<AGROW>
        models{i}.train(clustData);
    end
    
    models{max(idx) + 1} = bcf.models.AvgGaussian(1);
    models{max(idx) + 1}.noiseValues = std(data);
    models{max(idx) + 1}.avgValues = mean(data);
end