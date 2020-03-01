function [theta] = trainAnts(X, y, alpha, m, rho, Q, max_iter)
%TRAINANTS Trains ACO given a dataset (X, y) and a regularization parameter lambda
%   [theta] = TRAINANTS (X, y, lambda, alpha, m, rho, max_iter) trains linear regression using
%   the dataset (X, y) and regularization parameter lambda with ACO. 
%   Returns the trained parameters theta.
%
global min_cost;
% Initialize the num of the ant
% Initialize the iteration times
min_cost = 214546;
for iter_num = 1:max_iter
    fprintf('Round %d\n', iter_num);
    for ant_num = 1:m

        % the ant explores
        if ant_num < m
            initial_theta = zeros(size(X, 2), 1);
            if (ant_num == 1 && iter_num == 1) || 1
                lambda = 0.0002;
                % Create "short hand" for the cost function to be minimized
                costFunction = @(t) linearRegCostFunction(X, y, t, lambda);

                % Now, costFunction is a function that takes in only one argument
                options = optimset('MaxIter', 200, 'GradObj', 'on');

                % Minimize using fmincg
                [final_theta, cost] = fmincg(costFunction, initial_theta, options);
                
                % Record the information
                if cost(end) < min_cost
                   min_cost = cost(end);
                   theta = final_theta;
                end
            end
            
        end
    end
    % all ants ran the map, then information update
    factor = Q/(min_cost*m);
    fprintf('factor: %f ', factor);
    if factor > 0.75
        beta = 0.75;
    elseif factor < 0.7
        beta = 0.7;
    else 
        beta = factor;
    end
    alpha = (1-rho+beta)*alpha;
    if alpha > 1
        alpha = 1;
    end
    fprintf('cost: %d\n', min_cost);
end


end
