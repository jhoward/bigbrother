function correlation = linearCorrelation(data, offset)

% Build a correlation matrix that counts how many times a hit from sensor i
% co-occurs with a hit from sensor j, at a time offset of t seconds.  The 
% matrix is
%   C(1:50, 1:50, 0:T)
% where T is the maximum offset in seconds.  Actually, since Matlab wants
% to start indices at 1, we will have to do
%   C(1:50, 1:50, 1:T+1
T = offset;
hits = data
C = zeros(size(data, 2),size(hits, 2),T+1);

%oneSec = (datenum('00:00:01') - datenum('00:00:00'));
%N = round((endTime - beginTime)/oneSec);
N = size(data, 1);

for t=0:T
    for iSec=1:N-t
        for i=1:size(hits, 2)
            if hits(iSec,i) == 1
                for j=1:size(hits, 2)
                    if hits(iSec+t,j)
                        C(i,j,t+1) = C(i,j,t+1) + 1;
                    end
                end
            end
        end
    end
end

C

% Compute correlation coefficient.  This is given by
%  rho = cov(X,Y)/sqrt( var(X)var(Y) )
% where cov(X,Y) = E[ (X-uX)(Y-uY) ] = E[XY] - E[X}E[Y]
% and var(X) = E[X^2] - E^2[X}, etc

for t=0:T
    for i=1:size(C, 2)
        for j=1:size(C, 2)
            EXY = C(i,j,t+1)/(N - t);
            EX = C(i,i,1)/(N - t);
            EX2 = EX;   % E[X^2} same as E[X} since X is 0 or 1
            EY = C(j,j,1)/(N - t);
            EY2 = EY;
            rho(i,j,t+1) = (EXY - EX*EY)/sqrt( (EX2-EX^2)*(EY2-EY^2) );
        end
    end
end

correlation = rho;
