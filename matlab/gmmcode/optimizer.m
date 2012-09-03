function [likelihood, params] = optimizer(data, binaryList, params)
    options = optimset('Algorithm','interior-point');
    
    %likelihood = tobjective(params);
    [params, likelihood] = fmincon(@tobjective, params, [], [], [], [], [], [], @tconstraint, options);
    %[c ceq] = tconstraint(params);
    %disp(c)
    %disp(ceq)
    
    function out = tobjective(params)
        %Params have lambda and p(y)
        %First row is py
        %keyboard
        py = params(1, :);
        lambdas = params(2:size(params, 1), :);
        out = 0;
        for i = 1:length(data)
            px = 0;
            for b = 1:length(binaryList)
                temppxy = 0;
                temppy = 1;
                totalLambda = zeros(size(lambdas, 1), 1);
                for j = 1:length(binaryList(b, :))
                    if binaryList(b, j) == '1'
                        totalLambda = totalLambda + lambdas(:, j);
                        temppy = temppy * py(1, j);
                    end
                end
                %keyboard
                %temppxy2 = posspdf(data(:,i), totalLambda);
                temppxy = myposspdf(data(:,i), totalLambda);
                %fprintf('X = %f,%f prob = %f, %f\n', data(1, i), data(2,i), temppxy(1), temppxy(2));
                %temppxy = temppxy + 0.0001;
                px = px + prod(temppxy)*temppy;
            end
            out = out + log(px);
        end
        out = -out;
    end


    function [c, ceq] = tconstraint(params)
        %Grab all py
        py = params(1, :);
        c = -py;
        total = 0;
        %Generate list
        for b = 1:length(binaryList)
            temppy = 1;
            for j = 1:length(binaryList(b, :))
                if binaryList(b, j) == '1'
                    temppy = temppy * py(1, j);
                end
            end
            total = total + temppy;
        end
        ceq = total - 1;
    end
end

