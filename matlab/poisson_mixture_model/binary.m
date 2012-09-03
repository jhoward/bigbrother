function bNums = binary(n)
% Generate all binary numbers with n bits
% The numbers are returned in bNums, which is an array of 2^n x n

if n==1
    bNums = [0;1];
    return;
else
    b = binary(n-1);
    m = size(b,1);
    bNums = [
        zeros(m,1) b;
        ones(m,1) b
        ];
end

return
