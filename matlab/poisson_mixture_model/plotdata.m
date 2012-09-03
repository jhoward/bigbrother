function plotdata(lBackground, l, x, w, z)
% Plot ground truth activity centers, and 1st 3 dimensions of observed pts.

d = size(x,1);      % Number of dimensions
m = size(x,2);      % Number of points
k = size(l,2);      % Number of activities

if k > 2    return;     end

plot(0,0,'.');      % Erase figure

mycolors = colormap(hsv(k));
hold on
for i=1:m
    [~,b] = max(w(:,i));        % Get combination for this point
    zb = z(:,b);                    % zb(j)=1 if activity j is present
    acolors = mycolors(zb==1,:);    % Get reduced array of colors
    if isempty(acolors)
        c = [0 0 0];                % Black for background activity only
    else
        c = mean(acolors,1);        % Average colors of activities present
    end
    if d==2
        plot(x(1,i), x(2,i), '.', 'Color', c);
        text(x(1,i), x(2,i), sprintf('%d',i), 'Color', c, 'FontSize', 9);
    else
        plot3(x(1,i), x(2,i), x(3,i), '.', 'Color', c);
        text(x(1,i), x(2,i), x(3,i), sprintf('%d',i), 'Color', c, 'FontSize', 9);
    end
end
for j=1:k
    % Plot activity centers
    if d==2
        plot(l(1,j), l(2,j), 's', 'Color', mycolors(j,:));
        plot(l(1,j)+lBackground(1), l(2,j)+lBackground(2), 'o');
    else
        plot3(l(1,j), l(2,j), l(3,j), 's', 'Color', mycolors(j,:));
        plot3(l(1,j)+lBackground(1), l(2,j)+lBackground(2), l(3,j)+lBackground(3), 'o');
    end
end
if d==2
    plot(lBackground(1), lBackground(2), 'sk');
    plot(lBackground(1), lBackground(2), 'o');
    xlim([0 max(x(1,:))]);
    ylim([0 max(x(2,:))]);
    axis equal
else
    plot3(lBackground(1), lBackground(2), lBackground(3), 'sk');
    plot3(lBackground(1), lBackground(2), lBackground(3), 'o');
    xlim([0 max(x(1,:))]);
    ylim([0 max(x(2,:))]);
    zlim([0 max(x(3,:))]);
    axis vis3d
end
hold off


return


