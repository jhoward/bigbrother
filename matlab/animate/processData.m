%Function searches for loitering, walkLeft, and walkRight within
%Data


function [Y] = processData(X, dLoiter, dWalkLeft, dWalkRight)

[N, D] = size(X);

Y = zeros(N, 3);

%Calculate loiter, walkLeft, walkRight values
for i=1:N

	loiterMax = 0;
	walkLeftMax = 0;
	walkRightMax = 0;

    for j=1:D

		loiter = X(i, j);
		%Find loitering
		%Make function
		for k=1:dLoiter
			if i+k <= N
				loiter = loiter + X(i + k, j);
			end;
			
			if i-k >= 1
				loiter = loiter + X(i - k, j);
			end;
		end;

		if loiter > loiterMax
			loiterMax = loiter;
		end;

		
		%Find walkLeft
		%Make function
		walkLeft = X(i, j);

		for k=1:dWalkLeft
			
			if (j-k >= 1) && (i+k <= N)
				walkLeft = walkLeft + X(i + k, j - k);
			end;

			if (j+k <= D) && (i-k >= 1)
				walkLeft = walkLeft + X(i - k, j + k);
			end;
		end;

		if walkLeft > walkLeftMax
			walkLeftMax = walkLeft;
		end;

		%Find walkRight
		%Make function
		walkRight = X(i, j);

		for k=1:dWalkRight

			if (j+k <= D) && (i+k <= N)
				walkRight = walkRight + X(i + k, j + k);
			end;

			if (j-k >= 1) && (i-k >= 1)
				walkRight = walkRight + X(i - k, j - k);
			end;
		end;

        if walkRight > walkRightMax
			walkRightMax = walkRight;
        end;
    end; %End for j = 1:D

	Y(i, 1) = loiterMax;
	Y(i, 2) = walkLeftMax;
	Y(i, 3) = walkRightMax;

end; %End for i = 1:N

