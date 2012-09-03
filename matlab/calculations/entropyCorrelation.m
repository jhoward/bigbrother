%Calculate the correlation matrix of a dataset using 
%entropy calculations from information theory

function correlation = entropyCorrelation(data, offset)
%Establish the correlation matrix
correlation = zeros(size(data, 2),size(data, 2),offset + 1);

%Determine the probability array for all points
prob = sum(data, 1)/size(data, 1)
condProb = zeros(offset + 1, size(data, 2), size(data, 2), 2);

%Determine conditional probabilities
for t = 0:offset
    for x = 1:size(data, 2)
        for y = 1:size(data, 2)
            
            %Determine the conditional probability for the given pairing
            %Four pairings are possible 0|0, 1|0, 0|1, 1|1
            %Save in condProb at t, x, y, pair where pair is
            %ordered 1 - 1|0, 2 - 1|1
            Yj = 0;
            
            tempSet = data((find(data(1:(size(data, 1) - t), y) == Yj) + t), x);
            
            %Calculate the conditional probability 
            p10 = sum(tempSet)/size(tempSet, 1);
            
            Yj = 1;
            
            tempSet = data((find(data(1:(size(data, 1) - t), y) == Yj) + t), x);
            p11 = sum(tempSet)/size(tempSet, 1);
            
            condProb(t + 1, x, y, 1) = p10;
            condProb(t + 1, x, y, 2) = p11;
        end;
    end;
end;
                
                
%Calculate the H(X) array
entX = zeros(1, size(data, 2));
for i = 1:size(data, 2)
    
    if prob(1, i) == 1
        entX(1, i) = 0;
    else
        
        entZero = (1-prob(1,i))*log2((1-prob(1,i)));
        entOne = prob(1,i)*log2(prob(1,i));
        
        entX(1,i) = -1 * (entZero + entOne);
    end;
end;


%Calculate the conditional entropies
entXY = zeros(size(data, 2), size(data, 2), offset + 1);

for t = 0:offset
    for y = 1:size(data, 2)
        for x = 1:size(data, 2)
            
            %pY = 0
            pY = 1 - prob(1, y);
            
            %0|0
            pXY = 1 - condProb(t + 1, x, y, 1);
            sum00 = pXY * log2(pXY);
            if pXY == 0
                sum00 = 0;
            end;
            
            
            %1|0
            pXY = condProb(t + 1, x, y, 1);
            sum10 = pXY * log2(pXY);
            if pXY == 0
                sum10 = 0;
            end;
            
            %Finish y = 0
            sumY0 = pY*(sum00 + sum10);
            
            %pY = 1
            pY = prob(1, y);
            
            %0|1
            pXY = 1 - condProb(t + 1, x, y, 2);
            sum01 = pXY * log2(pXY);
            if pXY == 0
                sum01 = 0;
            end;
            
            %1|1
            pXY = condProb(t + 1, x, y, 2);
            sum11 = pXY * log2(pXY);
            if pXY == 0
                sum11 = 0;
            end;
            
            sumY1 = pY*(sum01 + sum11);
            
            entXY(x, y, t + 1) = -1 * (sumY0 + sumY1);
            
        end;
    end;
end;


%Calculate the Symmetrical Uncertainty
%SU(X|Y) = 2*(H(X) - H(X|Y))/(H(X) + H(Y))
for t = 0:offset
    for y = 1:size(data, 2)
        for x = 1:size(data, 2)
            
            hX = entX(1, x);
            hY = entX(1, y);
            
            hXY = entXY(x, y, t + 1);
            
            correlation(x, y, t + 1) = 2 * (hX - hXY) / (hX + hY);
        end;
    end;
end;

correlation