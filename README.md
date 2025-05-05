# Cmap-Scan

# CMAP Scan Simulation Algorithm (with Activation Fuzziness ρ)
# CMAP 扫描模拟算法（包含激活模糊度 ρ）

This document outlines the full simulation algorithm for generating Compound Muscle Action Potential (CMAP) curves, including both deterministic and probabilistic (fuzziness-based) motor unit activation.
本文件介绍完整的复合肌肉动作电位（CMAP）曲线模拟算法，包含确定性激活与基于模糊度ρ的概率激活方法。

---

## 📌 Step 1: Construct the Motor Unit Pool  
## 第一步：构建运动单位池

Each motor unit (MU) is defined by three parameters:
每个运动单位（MU）由以下三个参数定义：

| Parameter | Description (EN)                    | Description (CN)              | Distribution | Typical Values |
|-----------|--------------------------------------|-------------------------------|--------------|----------------|
| μ         | MUAP amplitude (unit output)         | MUAP 幅值（单位输出）         | Exponential (offset) | μ ~ Exp(200) + 25 μV |
| τ         | Activation threshold (in mA)         | 激活阈值（单位 mA）           | Normal       | τ ~ N(12, 1²) mA |
| ρ         | Threshold diffusion (fuzziness)      | 阈值扩散度（激活模糊性）      | Uniform      | ρ ~ U(0, 0.02) |

Also includes baseline noise:  
同时添加基线噪声：

- Gaussian noise with mean μ₀ = 10 μV  
  高斯噪声，均值 μ₀ = 10 μV
- σ ∈ {1, 5, 10} μV (used to simulate different SNRs)  
  σ ∈ {1, 5, 10} μV（用于模拟不同的信噪比）

---

## 📌 Step 2: Generate Stimulus Sequence  
## 第二步：生成刺激强度序列

- Define stimulus current range:  
  定义刺激电流范围：  
  \[ min(τ) - 0.5, max(τ) + 0.5 \]
- Discretize this range into 500 evenly spaced points  
  将该范围均匀分为 500 个刺激点

This simulates gradually increasing stimulation during CMAP scan  
此过程模拟了 CMAP 扫描时逐步增加的刺激强度

---

## 📌 Step 3A: CMAP Curve (Original: Hard Threshold)  
## 第三步A：CMAP 曲线（原始版本：硬性激活阈值）

For each stimulus intensity **I**:  
对每个刺激电流 **I**：

1. Mark all MUs where \( I > τj \)  
   标记所有被刺激电流激活的 MU（即 I 大于其阈值）  
2. Sum all their μ values:  
   叠加所有激活 MU 的 μ：  
   \[ 	signal = \sum_{{active}} μj \]
3. Add Gaussian noise (μ₀, σ):  
   添加高斯噪声（均值 μ₀，标准差 σ）：  
   \[ 	CMAP(I) = 	signal + 	noise \]

---

## 📌 Step 3B: CMAP Curve (Improved: Fuzziness with ρ)  
## 第三步B：CMAP 曲线（改进版本：引入ρ的激活模糊性）

Replace hard threshold with sigmoid activation probability:  
将硬性激活换为 sigmoid 函数表示的激活概率：

\[
P{active_j}(I) = 1/(1 + exp( -({I - τ_j)/ρ_j))
\]

Then for each MU:  
然后对每个 MU：

- Sample activation with probability P{active_j}(I) using Bernoulli  
  使用伯努利分布按该概率决定是否激活  
- Sum the μ of activated MUs  
  对激活的 MU 的 μ 求和  
- Add noise as before  
  添加噪声

This allows simulation of **motor unit alternation** and smoothed CMAP curves.  
该方法可模拟 **运动单位交替激活** 现象，使得 CMAP 曲线更平滑更真实。

---

## 📌 Step 4: Repeat Across Conditions  
## 第四步：在多种条件下重复模拟

Loop over all combinations of:  
遍历以下组合条件：

- M ∈ {20, 50, 100, 150} (number of MUs) → MU数量  
- σ ∈ {1, 5, 10} (noise levels) → 噪声水平  
- 5 repetitions per condition → 每种组合重复 5 次

Total: 4 × 3 × 5 = 60 CMAP curves  
共生成 60 条 CMAP 曲线

---

## ✅ Output  
## 输出内容

For each trial, store:  
每次模拟结果包括：

- Stimulus sequence → 刺激电流序列  
- CMAP curve → CMAP 曲线  
- μ, τ, ρ vectors → 每个 MU 的参数向量  
- Condition: M, σ, trial index → 实验条件索引

These can be used for model evaluation, MUNE algorithm testing, etc.  
这些结果可用于模型验证、MUNE 算法测试等

---

2025  


# Understanding the Role of ρ in CMAP Simulation  
# 理解 ρ 在 CMAP 模拟中的作用

---

## 🔍 What is ρ?
## 🔍 什么是 ρ？

In CMAP scan simulation, **ρ (rho)** represents the *activation fuzziness* or *threshold diffusion* for each motor unit (MU). It controls how sharply or gradually a MU transitions from inactive to active as the stimulation intensity increases.

在 CMAP 扫描模拟中，**ρ（rho）** 表示每个运动单位（MU）的“激活模糊度”或“阈值扩散度”。它控制当刺激强度逐渐增强时，MU 从“未激活”变为“激活”的过程是突变还是平滑过渡。

---

## ⚙️ Without ρ: Hard Threshold Activation  
## ⚙️ 没有 ρ：硬性阈值激活

In the original simulation, a MU is activated if the stimulus \( I \) exceeds its threshold \( τ \):

原始模拟中，每个 MU 只有在刺激电流 \( I \) 超过其阈值 \( τ \) 时才会被激活：

```
if I > τ → MU is activated  
if I <= τ → MU is not activated
```

This produces a **step-like CMAP curve**, where MUs are added in discrete jumps.  
这种方式会产生“阶梯状”的 CMAP 曲线，激活过程非常突兀、不连续。

---

## 🌡️ With ρ: Probabilistic Activation via Sigmoid  
## 🌡️ 加入 ρ：通过 Sigmoid 函数实现概率激活

With ρ, each MU has a **probability of activation** depending on how close the stimulus is to its threshold:

引入 ρ 后，每个 MU 的激活不再是“开关式”，而是根据当前电流与其阈值的接近程度，具有一个激活概率：

\[
P{active_j}(I) = 1/(1 + exp( -({I - τ_j)/ρ_j))
\]

This means:  
- If I is much lower than τ → low probability  
- If I ≈ τ → 50% probability  
- If I is much higher than τ → high probability  

也就是说：  
- 刺激远小于阈值 → 激活概率接近 0  
- 刺激接近阈值 → 激活概率约为 50%  
- 刺激远大于阈值 → 激活概率接近 1

---

## 🎲 How to Use ρ in Simulation  
## 🎲 模拟中如何使用 ρ

We simulate this by **Bernoulli sampling** using the activation probability:

我们通过对激活概率进行一次伯努利抽样（0/1）来决定该 MU 是否激活：

```matlab
P_active = 1 ./ (1 + exp(-(I - tau) ./ rho));
is_active = rand(M, 1) < P_active;
```

Then sum up the μ values of activated MUs to get the CMAP signal.  
然后将所有被激活 MU 的 μ 相加，得到当前刺激下的 CMAP 电位。

---

## ✅ Why ρ Matters  
## ✅ 为什么 ρ 很重要

| Without ρ               | With ρ (probabilistic)                  |
|------------------------|-----------------------------------------|
| Sharp activation       | Smooth, realistic activation            |
| Step-wise CMAP         | Sigmoid-like CMAP                       |
| No alternation         | Can simulate motor unit alternation     |
| Not biologically realistic | Closer to actual physiological behavior |

引入 ρ 能够让模拟过程更加接近真实神经反应，也能模拟“交替激活”这种常见现象。

---

2025
