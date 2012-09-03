classdef class_BrownData < handle
    % Holds all information about the Brown Hall data.
    
    properties
        % Data points, size (d,m) where d=dimensions, m=number of points
        x
    end
    
    methods
        function obj = class_BrownData(szDirectory, M)
            
            % Read data from the give directory.
            szFileName = sprintf('%s/tdmatrix.dat', szDirectory);
            
            fid = fopen(szFileName);
            obj.x = [];

            while ~feof(fid)
                vec = fgetl(fid);
                l = sscanf(vec, '%d');

                obj.x = [obj.x l];
            end
            fclose(fid);
            m = size(obj.x,2);

            % Transform data so that each dimension spans range 0..M-1
            dMin = min(obj.x,[],2);     % minimum value along each dimension
            dMax = max(obj.x,[],2);     % maximum value along each dimension
            dScale = (M-1) ./ (dMax-dMin);  % scale factor to apply to each dimension

            % Subtract off dMin from each dimension, then multiply each dimension by
            % dScale, then finally round to integer.
            xScaled = round( (obj.x-repmat(dMin,1,m)) .* repmat(dScale,1,m) );
            obj.x = xScaled;

        end  % end constructor

        function AnalyzeResults(obj,w,pmf,px)
        end

    end  % end methods
    
end

