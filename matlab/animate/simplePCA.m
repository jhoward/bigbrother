clear all

close all

 

 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a database of n examples, each example has m dimensions

% They will go in a matrix X, which is m x n

n = 5;    % Number of vectors in the database

m = 2;    % No. of dimensions

X = [

    0.5, 0.1;

    0.4, 0.15;

    0.6, 0.2;

    0.7, 0.3;

    0.8, 0.275]';

disp('Here are the original vectors in the database: ');  disp(X);

 

 

% Plot the vectors on a 2D feature space

figure, plot(X(1,:), X(2,:), 'ko');

daspect([1,1,1]), xlim([0,1]), ylim([0,1]);

xlabel('r1'), ylabel('r2');

pause

 

 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Subtract off the mean from each dimension of the data

u = mean(X,2);

disp('The mean vector is: '); disp(u);

X = X - repmat(u,1,n);

hold on

plot(u(1), u(2), '+');

hold off

 

disp('Here are the database vectors, zero mean: ');  disp(X);

 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Take PCA

%Y = X';
Y = X' / sqrt(n-1);

[U,S,V] = svd(Y);      % Y = U*S*V'

% variances = diag(S) .^ 2;     % Should be in decreasing order

% The Principal components are the columns of V

disp('The PCs are the columns: ');  disp(V);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 

% We will only use the first PC.  Plot the range of vectors that can be

% generated with only the first PC.  It will be the mean plus the PC.

%   u + a*PC1

p0 = u + 2*V(:,2);

p1 = u - 2*V(:,2);

line( [p0(1) p1(1)], [p0(2) p1(2)], 'Color', 'b' );

p0 = u + 2*V(:,1);

p1 = u - 2*V(:,1);

line( [p0(1) p1(1)], [p0(2) p1(2)], 'Color', 'b' );

pause

 

% Here is a new vector

xnew = [0.5; 0.25];

hold on

plot(xnew(1), xnew(2), '+');

hold off

 
 

% Reconstruct the vector with only the top p PCs

p = 2;

Vapprox = V(:,1:p);

xnewp = Vapprox' * (xnew-u);

Xreconstructed = Vapprox*xnewp + u;

 

 

hold on

plot(Xreconstructed(1), Xreconstructed(2), '*r');

hold off