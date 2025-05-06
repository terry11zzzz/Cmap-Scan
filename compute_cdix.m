function CDIX = compute_cdix(cmap_signal, t1_ratio, t2_ratio)
% 计算 CMAP 扫描信号的 CDIX（复杂度指数）
% 输入:
%   cmap_signal - 一维向量，CMAP 扫描结果
%   t1_ratio    - 前段比例（默认 0.02）
%   t2_ratio    - 后段比例（默认 0.95）
% 输出:
%   CDIX        - 复杂度指数

    if nargin < 2
        t1_ratio = 0.02;
    end
    if nargin < 3
        t2_ratio = 0.95;
    end

    % Step 1: Segmentation - 取中段
    A = cmap_signal(:);  % 保证为列向量
    N = length(A);
    Fc = 50 * pi / N;  % rad/sample
    Fs = 1;  % 这里单位不影响滤波，只需归一化频率
    
    % 3rd-order Butterworth low-pass filter
    [b, a] = butter(3, Fc / (pi));  % Fc 已按 Nyquist 归一化为 [0, 1]
    E = filtfilt(b, a, A);  % 双向滤波避免相位延迟
   
    
    Emin = min(E);
    Emax = max(E);
    threshold1 = Emin + (Emax - Emin) * t1_ratio;
    threshold2 = Emin + (Emax - Emin) * t2_ratio;
    
    % 找边界 b1 和 b2
    b1 = find(E < threshold1, 1, 'last');
    b2 = find(E > threshold2, 1, 'first');
    
    % 边界容错处理
    if isempty(b1), b1 = 1; end
    if isempty(b2), b2 = N; end
    
    % 中段 mid-scan 信号
    mid_scan = A(b1:b2);

    % Step 2.1: 步长序列 S（每步跳变）
    S = abs(diff(mid_scan));  % 取绝对值差分

    % Step 2.2: GMM 聚类，分成两类
    % 构造 small-step 的数据集：S 与 -S 合并
    S_augmented = [S; -S];  % 用于估计 small-step 的均值和方差
    
    % Step 1: 拟合 GMM（注意，这里我们依然用 S 来建模两个分布）
    gm = fitgmdist(S, 2, 'RegularizationValue',1e-6);
    
    % Step 2: 用 GMM 分类每个 S 属于哪个类别（small or large）
    idx = cluster(gm, S);  % 每个 S 的类别（1或2）
    mu1 = gm.mu(1);
    mu2 = gm.mu(2);
    
    % Step 3: 判定哪个是 small-step（接近0的那个）
    [~, small_idx] = min(abs([mu1, mu2]));  % small-step 的索引
    large_idx = 3 - small_idx;              % large-step 的索引
    
    % Step 4: 获取属于 large-step 的所有 S 值
    S_large = S(idx == large_idx);
    
    % Step 5: 找到最小的 large-step 幅度，作为 G
    G = min(S_large);


    % Step 2.3: 离散化
    D = floor(mid_scan / G);  % 除以 G 并取整

    % Step 3: 计算熵 H
    L=length(mid_scan);
    [F, ~, ic] = unique(D);  % 找到唯一值和对应的 index
    counts = accumarray(ic(:), 1);
    probs = counts / L;
    H = -sum(probs .* log2(probs));  % 熵

    % CDIX 指数
    CDIX = 2 ^ H;
end
