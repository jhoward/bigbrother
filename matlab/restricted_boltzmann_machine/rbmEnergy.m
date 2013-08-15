function result = rbmEnergy(x)
    
    z = sum(exp(x));
    
    result = exp(x) ./ z;

end
