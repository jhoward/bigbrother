function [ l, w, f, lBackground ] = EMPMM( x, l, w, f, z, lBackground, d, m, k)
    for iterMain=1:40
        if mod(iterMain, 20) == 0
            fprintf('\n');
        end
        fprintf('%d ', iterMain);

        %disp(l);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Do E-step: Estimate all w, assuming you know l and f.
        %%%{
        for i=1:m
    %         fprintf('\nPoint %d, has counts:\n', i);
    %         disp(x(:,i));
    %         disp('True combination for this point (aTrue):');
    %         disp([[1:2^k]' aTrue(:,i)]);

            %%%%%%%%%%%%%%
            % Compute p(xi,zb) = p(xi|zb) p(zb) for all values of b
            pxizb = zeros(2^k,1);
            for b=1:size(z,2)
                zb = z(:,b);    % zb contains 1's where activity is present
                %fprintf('combination b=%d\n', b);
                %disp('zb:'); disp(zb);

                pzb = f(b);
                %fprintf('pzb = %f\n', pzb);

                % Find p(xi|zb). First find the expected rate vector, given the
                % specified combination of activities in zb. This produces a
                % (d,k) matrix where column j is either 1 if activity j is
                % present, or 0 if it is not.
                mask = ones(size(l)) * diag(zb);
                lb = mask .* l;     % Set to zero any rates not present
                lb = sum(lb,2) + lBackground;  % Sum rates along each dimension
                %disp('Expected rate vector lb:'); disp(lb);

                % For each dimension n, find the probability that count xni
                % could have been produced by a Poisson with rate parameter
                % lb(n).  The total probability for this count vector is the
                % product of all of them (assuming dimensions are independent).
                p = 1.0;
                for n=1:d
                    p = p * evaluatePoisson(x(n,i), lb(n));
                end
                %fprintf('p(xi|zb) = %f\n', p);

                pxizb(b) = p*pzb;
            end
            %         disp('   b       j=1:k            p(xi,zb):');
            %         disp([ [1:2^k]'  z'   pxizb ]);


            %%%%%%%%%%%%%%
            % Compute wbi = p(zb|xi) for all values of b.
            % This is  p(zb|xi) = p(xi|zb)p(zb)/sum_b[p(xi|zb)p(zb)]
            %         if sum(pxizb)<1e-15
            %             fprintf('warning: pt %i has low p(xi) in Estep: %f\n', i, sum(pxizb));
            %         end
            w(:,i) = pxizb/sum(pxizb);

        end     % end for i=1:m
        %%%}


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Do M-step:  Estimate the rates l, assuming you know w. This is
        % done using an iterative algorithm.
        for iterMstep=1:50
            %fprintf('Iteration Mstep %d\n', iterMstep);

            % This flag is set to false if any activity rates are changing
            fNoChange = true;

            % For each activity, estimate its rate vector, given the
            % observations and assuming that all other rate activities are
            % known.
            for j=0:k
                % Estimate rates for activity j.
                %fprintf('Estimating rates for activity %d\n', j);

                % Recall that xi = a1i y1i + a2i y2i + ... + aki yki
                % where aji=1 if activity j is present in point i, and yji is
                % the data vector for activity j at time i.
                % Assume we know all wji = p(aji=1|xi).  We also know all
                % E[yjji] = ljj for all activities jj except for jj=j.
                % Now, let yjib be the portion of xi that is due to
                % activity j, given the rates l and the combination zb:
                %   yjib = xi - sum_jj ajji yjji
                %     where:
                %       (a) this is valid for combinations zb that include j
                %       (b) the sum is taken for all jj ~= j
                % Since the expected values of yjji are known, we can write as
                %   yjib = xi - sum_jj ljj
                %     where
                %       (a) ljj is the rate vector for the jjth activity
                %       (b) the sum is taken for all jj ~= j, and for only
                %       those jj that are present in combination zb

                % To find the expected value lj = E[yj] we need to sum over all
                % points i and all combinations b, such that j is present in b:
                %  lj = [sum_i sum_b yjib p(zib)]/[sum_i sum_b p(zib)]
                % where:
                %  p(zib) = p(zb|xi) = w(b,i)

                num = zeros(d,1);   % this is: sum_i sum_b yjib p(yjib)
                denom = 0;          % this is: sum_i sum_b p(yjib)
                for i=1:m
                    xi = x(:,i);    % Get point i
                    wi = w(:,i);    % Get p(zb|xi), for b=1..2^k
                    %                 fprintf('Point %d.\n', i);
                    %                 disp('xi:'); disp(xi);
                    %                 disp('   b       zb          wi=p(zb|xi):');
                    %                 disp([ [1:2^k]'  z'   wi ]);

                    for b=1:2^k
                        zb = z(:,b);    % zb = 1's where activity is present
                        if j==0 || zb(j)==1
                            % Only consider combinations where j is present

                            % Find yjib = = xi - sum_jj ljj
                            %  where
                            %   (a) ljj is the rate vector for the jjth activity
                            %   (b) the sum is taken for all jj ~= j, and for only
                            %     those jj that are present in combination zb
                            yjib = xi;    % the actual observation for point i
                            for jj=1:k
                                if jj~=j && zb(jj)
                                    % Subtract contribution from activity jj.
                                    yjib = yjib - l(:,jj);
                                end
                            end
                            if j~=0
                                yjib = yjib - lBackground;  % also subtract bkgnd
                            end

                            % Find p(zb|xi)
                            pzib = w(b,i);

                            num = num + yjib * pzib;
                            denom = denom + pzib;
                        end
                    end     % end for b=1:2^k
                end     % end for i=1:m

                if denom < 1e-10
                    keyboard
                end
                ljNew = num/denom;     % New rate for activity j

                % Let's clip to zero, since we can't have a negative count.
                % Actually, let's clip to some small positive number.
                tiny = 0.1;
                for n=1:d
                    if ljNew(n) < tiny  ljNew(n)=tiny;  end
                end

                %             fprintf('Estimated new rates for activity %d:\n', j);
                %             disp(ljNew);

                if j==0
                    ljOld = lBackground; lBackground = ljNew;
                else
                    ljOld = l(:,j); l(:,j) = ljNew;
                end

                if norm(ljNew-ljOld)/norm(ljOld) > 1e-5
                    fNoChange = false;  % this activity rate has changed
                end
            end     % for j=0:k

            if fNoChange  break;    end
        end     % for iterMstep
        %fprintf('Number of Mstep iterations: %d\n', iterMstep);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Second M-step:  Estimate a-priori probabilities f, assuming you know
        % w. I believe that this is just fb = (1/m) sum_i wbi (should show
        % this).
        f = (1/m)*sum(w,2);

        %     disp('Rates (lBackground):');
        %     disp(lBackground);
        %     disp('Rates (l):');
        %     disp(l);
        %     disp('A priori probabilities, each combination of activities (f):');
        %     disp(f);

        % Assume that if the Mstep took only one iteration, then nothing is
        % changing so we can stop.
        if iterMstep==1   break;    end
    end     % for iterMain
end

