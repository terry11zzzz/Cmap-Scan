
function [D50_integral, D50_diffcount] = compute_D50(x, y)
% compute_D50_methods - 同时计算 CMAP 曲线的两种 D50 指标
%
% 输入：
%   x - 刺激强度（升序排列）
%   y - 对应的 CMAP 响应幅值
%
% 输出：
%   D50_integral  - 方法1：积分法D50（前50%面积所占刺激范围）
%   D50_diffcount - 方法2：跳变计数法D50（占50%幅值需几个跳变）
%   D50_diffcount 小 → 响应被几个大幅单位主导 → MU 激活集中、同步；

%   D50_diffcount 大 → 跳变小且多 → MU 激活分散、不同步,CMAP 曲线越平滑，说明MU的招募比较均匀、连续；
    %% 方法 1：积分法 D50
    y1 = y - min(y);           % 去除基线
    y1 = y1 / max(y1);         % 归一化
    y_cumsum = cumsum(y1);     % 累积能量
    y_total = y_cumsum(end);

    idx_start = find(y_cumsum >= 0.0 * y_total, 1, 'first');
    idx_end   = find(y_cumsum >= 0.5 * y_total, 1, 'first');

    D50_integral = x(idx_end) - x(idx_start);

    %% 方法 2：跳变计数法 D50
    y_sorted = sort(y);                        % 升序排序
    dA = diff(y_sorted);                       % 相邻差值 ΔA
    [dA_sorted, sort_idx] = sort(dA, 'descend');  % 降序排序
    dA_cumsum = cumsum(dA_sorted);             % 累加跳变

    A_range = max(y) - min(y);                 % 最大CMAP幅度
    n = find(dA_cumsum >= 0.5 * A_range, 1);   % 找到最小n满足条件
    D50_diffcount = n;
end
