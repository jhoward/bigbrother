% Mixture of Poissons

clear all
close all
tic;

% This is used to reset the random number generator to the same sequence
%s = RandStream('swb2712','Seed',0);
%RandStream.setDefaultStream(s);

D = 3;
K = 2;
N = 200;

[data, means, vars, bink] = CreateData(K, D, N);
disp(means)
disp(vars)


% %Plot ground truth
% for k = 1:size(bink, 1)
%     u = bink(k, :);
%     numOnes = length(strfind(u, '1'));
%     col = 'r';
%     if numOnes > 1
%         col = 'g';
%     end
% 
%     totalMean = zeros(D, 1);
%     %totalVariance = zeros(D, D);
%     
%     for j = 1:K
%         if u(j) == '1'
%             totalMean = totalMean + means(:, j);
%             %totalVariance = totalVariance + vars(:, :, j);
%         end
%     end
%     
%     %pts = gaussian2D(totalMean, totalVariance, 2);
%     %plot(pts(1,:), pts(2, :), col);
%     hold on
% end
% 
% plot(data(1, :), data(2, :), '.');
% %for n=1:N
% %    text(X(1,n), X(2,n), sprintf('%d', n));
% %end
% 
% axis equal
% %xlim([8 35]); ylim([8 35]);
% hold off


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Estimate classes
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
Z = char(dec2bin(1, K));

for k = 2:2^K - 1
    Z = char(Z, dec2bin(k, K));
end

A = [.4142 .4142];
%A = [.26, .26, .26];
%A = [.18, .18, .18, .18];


Y = rand(D, K) * 8 + 10; %Poisson means
[likelihood params] = optimizer(data, Z, [A; Y]);

fprintf('Log likelihood: %f\n', likelihood);
disp(params)
%params = [0.0021 0.8264; 20.2740   11.8304; 3.4132   10.1085];
%[likelihood params] = optimizer(X, Z, params);

toc



