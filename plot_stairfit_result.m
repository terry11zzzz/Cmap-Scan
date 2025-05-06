
%% 可视化：绘制原始 CMAP 数据与拟合阶梯曲线
% Inputs:
%   x, y: 原始刺激与CMAP响应
%   lambda_opt: 最优阶梯高度
%   tau_opt: 最优激活阈值
function plot_stairfit_result(x, y, lambda_opt, tau_opt)
    figure;
    hold on;
    grid on;

    % 原始数据散点图
    scatter(x, y, 40, 'filled', 'MarkerFaceAlpha', 0.4, 'DisplayName', 'Raw CMAP');

    % 构造阶梯函数曲线
    tau_aug = [min(x); tau_opt(:); max(x)];
    lambda_aug = lambda_opt(:);
    for i = 1:length(lambda_aug)
        x_left = tau_aug(i);
        x_right = tau_aug(i+1);
        plot([x_left, x_right], [lambda_aug(i), lambda_aug(i)], 'r-', 'LineWidth', 2, 'DisplayName', '');
        if i < length(lambda_aug)
            plot([x_right, x_right], [lambda_aug(i), lambda_aug(i+1)], 'r--', 'LineWidth', 1); % vertical jump
        end
    end

    xlabel('Stimulus Intensity (x)');
    ylabel('CMAP Amplitude (y)');
    title('CMAP Staircase Fitting');
    legend('show');
end
