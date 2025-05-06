
%% CMAP Staircase Fitting with Automatic MUNE Estimation
% Inputs:
%   x: stimulus intensity (Nx1)
%   y: CMAP amplitude (Nx1)
%   M_range: candidate values for MU number (e.g., 2:20)
%   sigma: baseline noise standard deviation (e.g., 5 μV)
% Outputs:
%   M_opt: optimal MU number (MUNE)自动选出的最优 MU 数
%   lambda_opt: best step heights (M_opt+1)x1 最优阶梯高度（M+1 维）
%   tau_opt: best thresholds (M_opt)x1 最优激活阈值（M 维）

function [M_opt, lambda_opt, tau_opt] = fit_cmap_staircase(x, y, M_range, sigma)
    N = length(x);
    threshold = 2.4 * sigma;
    alpha = 0.1;  % weight for horizontal axis in distance

    best_M = NaN;
    best_lambda = [];
    best_tau = [];
    
    for M = M_range
        %% Step 1: Optimize lambda
        lambda_init = linspace(min(y), max(y), M+1)';
        obj_lambda = @(lambda) mean(arrayfun(@(yt) min(abs(yt - lambda)), y));
        lb = repmat(min(y), M+1, 1);
        ub = repmat(max(y), M+1, 1);
        options = optimoptions('patternsearch','Display','off');
        lambda_M = patternsearch(obj_lambda, lambda_init, [], [], [], [], lb, ub, [], options);
        lambda_M = sort(lambda_M);

        %% Check if error < 3σ for this M
        error_M = mean(arrayfun(@(yt) min(abs(yt - lambda_M)), y));
        if error_M < threshold
            best_M = M;
            best_lambda = lambda_M;
            break  % take first M that meets threshold (Occam's razor)
        end
    end

    if isnan(best_M)
        error('No M satisfies the threshold constraint. Consider increasing M_range.');
    end

    %% Step 2: Optimize tau for best_M
    tau_init = linspace(min(x), max(x), best_M)';
    obj_tau = @(tau) sum(arrayfun(@(t) ...
    min(arrayfun(@(i) alpha * abs(x(t) - tau(i)) + abs(y(t) - best_lambda(i)), ...
                 1:length(tau))), 1:length(x)));

    lb_tau = repmat(min(x), best_M, 1);
    ub_tau = repmat(max(x), best_M, 1);
    tau_opt = patternsearch(obj_tau, tau_init, [], [], [], [], lb_tau, ub_tau, [], options);
    tau_opt = sort(tau_opt);

    % Output
    M_opt = best_M;
    lambda_opt = best_lambda;
end

function val = nearest_lambda(lambda, tau, xt)
    M = length(tau);
    tau = [min(tau) - 1e-5; tau(:); max(tau) + 1e-5];
    idx = find(xt <= tau(2:end), 1, 'first');
    val = lambda(idx);
end
