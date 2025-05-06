
# 🧩 阶梯函数拟合 CMAP 曲线的逻辑步骤（文字版）

---

## Step 1：问题识别
- 实际记录的 CMAP 曲线不是严格递增的；
- 原因包括：
  - Motor unit alternation（MU 激活不稳定）
  - 噪声干扰（baseline fluctuation）
- 因此，不能直接使用普通的最小二乘拟合方法（如多项式拟合）。

---

## Step 2：提出拟合策略
- 使用 **单调递增的阶梯函数（staircase function）** 来拟合 CMAP 曲线；
- 每一个“台阶”代表一个 MU 的激活；
- 每一级阶梯的高度对应 MU 的幅值（μ），位置对应其激活阈值（τ）；
- 这样不仅能拟合曲线，还能估计出参与反应的 MU 数量。

---

## Step 3：定义变量
- $x_t$：第 t 个刺激强度；
- $y_t$：对应的 CMAP 响应幅值；
- $\mu_k$：第 k 个 MU 的输出幅值；
- $\tau_k$：第 k 个 MU 的激活阈值；
- $\lambda_i = \sum_{k=1}^{i} \mu_k$：阶梯函数的第 i 段高度；
- 假设 $\tau_0 = x_1$, $\tau_{M+1} = x_N$。

---

## Step 4：构建阶梯函数模型
使用如下形式表示理想 CMAP 函数：

$$
f_{\lambda,\tau}(x) = \sum_{i=1}^{M+1} \lambda_i \cdot \mathbb{I}_{(\tau_{i-1}, \tau_i]}(x)
$$

其中，$\mathbb{I}_{(\tau_{i-1}, \tau_i]}(x)$ 是指示函数（如果 x 落在该区间则为 1，否则为 0）；
这表示刺激强度落在每个激活区间时，CMAP 值跳跃到新的阶梯高度。


---

## Step 5：关于噪声的处理假设
- 假设 baseline 噪声仅表现为一个偏移值 $\mu_0$，而忽略其波动（即不考虑 $\sigma^2$）；
- 这样模型可以专注拟合跳跃趋势而非处理随机扰动。

---

## Step 6：优化目标

### 优化 λ（阶梯高度）
固定 M，优化 $\lambda$，使每个观测值 $y_t$ 离最近的 $\lambda_i$ 越近越好：

$$
\varphi_M(\lambda) = \frac{1}{N} \sum_{t=1}^{N} \min_i |y_t - \lambda_i|
$$

- 使用 patternsearch 等非导数优化方法求解；
- 若 $\varphi_M(\lambda_{opt}) < 3\sigma$（$\sigma$ 为基线噪声标准差），则认为拟合足够好；
- 选择满足该条件的最小 M，作为最终估计的 MUNE。

### 优化 τ（激活阈值）

在 $\lambda_{opt}$ 给定下，优化 $\tau_i$，使观测点 $(x_t, y_t)$ 到阶梯曲线上最近一段的加权曼哈顿距离最小：

$$
\varphi_M(\tau) = \sum_{t=1}^{N} \min_i \left[ \alpha |x_t - \tau_i| + |y_t - \lambda_i| \right]
$$

- $\alpha$ 是调节横纵误差比重的权重；
- 该步骤提升拟合精度，但不影响 MUNE 的估计。

---

## Step 7：最终输出
- 构建出的阶梯函数 $f_{\lambda,\tau}(x)$ 将尽可能贴近实际记录的 CMAP 曲线 $y$；
- 同时给出最小 M 作为 MUNE 估计结果。
