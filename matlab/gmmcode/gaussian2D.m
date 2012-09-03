function pts = gaussian2D(mu, C, z)
% Generate points along a contour for a 2D Gaussian with center 
%    mu = [x;y] and covariance matrix C.
% z specifies the value of the contour to plot; ie plot points 
%    where x'*Cinv*x = z^2 
% Output:  the points of the ellipse are in pts(2,N)

% First check if the covariance is so small that we can't invert it
if cond(C) > 1000
    % In that case, just return a tiny circle around mu
    pts = [ 0.001   0    -0.001   0     0.001;
            0     0.001    0   -0.001    0  ];
    pts(1,:) = pts(1,:) + mu(1);
    pts(2,:) = pts(2,:) + mu(2);
    return;
end

% Let y = Rx, where R is the rotation matrix that aligns the axes.
% Then y'*D*y = z^2, where D is a diagonal matrix.
% Or, x'R'*D*Rx = z^2.  x'(R'DR)x = z^2.
% So Cinv = R'DR.  This is just taking the SVD of Cinv.
[U,S,V] = svd(inv(C));
R = V;

% The length of the ellipse axes are len=1/sqrt(Si/z^2)
% where Si is the ith singular value.
xrad = sqrt( z^2/S(1,1) );
yrad = sqrt( z^2/S(2,2) );

% Ok, generate points along a circle of unit radius centered at the origin
% But before plotting an x,y point, scale by (xrad,yrad), rotate by R,
% and translate by mu.
angs = 0:10:360;
pts = zeros(2,length(angs));      % vertices of the ellipse
for i=1:length(angs)
    a = angs(i);
    p = [cosd(a); sind(a)];
    p = [xrad; yrad] .* p;
    p = R*p + mu;
    pts(:,i) = p;
end

return


