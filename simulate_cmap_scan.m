function cmap_dataset = simulate_cmap_scan()

% 参数设置
alpha1 = 200;     % μ 的指数分布 scale 参数 (μV)
beta1 = 25;       % μ 的指数分布 location 参数 (μV)
alpha2 = 12;      % τ 的正态分布均值 (mA)
beta2 = 1;        % τ 的标准差 (mA)
rho_range = [0, 0.02];
mu0 = 10;         % baseline noise 均值 (μV)
sigma_list = [1, 5, 10];  % baseline 噪声标准差 (μV)
M_list = [20, 50, 100, 150];  % motor unit 数量
n_trials = 5;     % 每种条件的重复次数
n_stim = 500;     % 刺激点数

cmap_dataset = struct();  % 输出结果存储

% 主循环
idx = 1;
for M = M_list
    for sigma = sigma_list
        for trial = 1:n_trials

            %% Step 1: 模拟 motor unit pool
            mu = exprnd(alpha1, [M, 1]) + beta1;               % 单位幅值 (μV)
            tau = normrnd(alpha2, beta2, [M, 1]);              % 激活阈值 (mA)
            rho = rand(M, 1) * diff(rho_range) + rho_range(1);% 扩散

            %% Step 2: 刺激序列
            stim_min = min(tau) - 0.5;
            stim_max = max(tau) + 0.5;
            stim_intensities = linspace(stim_min, stim_max, n_stim);

            %% Step 3：模拟 CMAP 曲线（带 activation fuzziness）
            cmap_curve = zeros(1, n_stim);
            for i = 1:n_stim
                I = stim_intensities(i);  % 当前刺激强度
            
                % --- 新增：计算每个 MU 的激活概率 ---
                P_active = 1 ./ (1 + exp(-(I - tau) ./ rho));  % sigmoid激活函数
                is_active = rand(M, 1) < P_active;             % Bernoulli采样（0或1）
            
                % --- 激活的 MU 总输出幅值 + 噪声 ---
                signal = sum(mu(is_active));
                noise = normrnd(mu0, sigma);
                cmap_curve(i) = signal + noise;
            end

            %% 保存结果
            cmap_dataset(idx).M = M;
            cmap_dataset(idx).sigma = sigma;
            cmap_dataset(idx).trial = trial;
            cmap_dataset(idx).stim = stim_intensities;
            cmap_dataset(idx).curve = cmap_curve;
            cmap_dataset(idx).mu = mu;
            cmap_dataset(idx).tau = tau;
            cmap_dataset(idx).rho = rho;
            idx = idx + 1;
        end
    end
end
end
