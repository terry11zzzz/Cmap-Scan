
# 📘 CDIX计算算法说明

## 🔍 目的简介
CDIX（Complexity of Discrete Information indeX）是一种用于量化CMAP scan中肌电响应复杂性的指标。该指标通过对mid-scan段信号进行步长分析、概率建模和信息熵计算，从而衡量运动单位（MU）递招过程中的复杂程度。

## 📈 信号流程概述

1. 原始信号输入：CMAP扫描幅度序列
$A = [A_1, A_2, ..., A_N]$
3. 平滑处理：使用3阶Butterworth低通滤波器获得平滑信号
$E$
5. 分段提取：根据幅度阈值确定 mid-scan 区间
$A_{b_1:b_2}$
7. 步长计算：计算相邻幅度的跳变幅度
$S$
9. GMM分类：将步长划分为 small-step 与 large-step
10. 离散化：使用最小large-step幅度
$G$
12. 作为单位，将幅度序列转为整数序列
$\( D \)$
14. 熵计算：计算离散符号分布的信息熵
$H$
，并得出 CDIX

## 🧪 算法详细步骤

### 1. 平滑滤波
使用3阶 Butterworth 低通滤波器对原始 CMAP 扫描信号$A$ 进行平滑：

- 设计截止频率：
$F_c = \frac{50\pi}{N} \quad \text{(rad/sample)}$
- 处理方式：
$E = \text{filtfilt}(b, a, A)$
### 2. mid-scan 区间提取
根据下述阈值确定中段边界
$\( b_1 \)、\( b_2 \)$：

- 阈值计算：
$T_1 = E_{min} + (E_{max} - E_{min}) \cdot t_1 \\ T_2 = E_{min} + (E_{max} - E_{min}) \cdot t_2$
- 边界定义：
$b_1 = \max \{ n \mid E_n < T_1 \} \\ b_2 = \min \{ n \mid E_n > T_2 \}$
提取中段信号：
$A_{\text{mid}} = A_{b_1:b_2}$
### 3. 步长序列计算
对 mid-scan 信号计算跳变幅度（步长）：
$S = [|A_{b_1+1} - A_{b_1}|, \; |A_{b_1+2} - A_{b_1+1}|, \dots, |A_{b_2} - A_{b_2-1}|]$
### 4. GMM建模（两类混合高斯）

- 拟合
$\( S \)$
为两个分布（small-step 和 large-step）；
- 判定哪个分布为 small-step：选择均值更接近 0 的分布；
- 判定 large-step 属于哪个分布后，从中选取：
$G = \min(S_i \in \text{large-step})$
此 G 作为离散单位。

> 💡 注：文献中提到使用
$\( S \cup (-S) \)$
来估计 small-step 分布的均值和方差，以强调其对称性，但实际 GMM 拟合仍基于原始
$\( S \)$。

### 5. 离散化幅度序列

对 mid-scan 原始幅度按 G 进行离散化：
$D_i = \left\lfloor \frac{A_{b_1 + i}}{G} \right\rfloor, \quad \text{for } i = 0 \text{ to } b_2 - b_1$
得到离散符号序列
$\( D = [D_1, D_2, ..., D_L] \)$，其中
$\( L = b_2 - b_1 + 1 \)$。

### 6. 信息熵计算

对符号序列 D 中的每个唯一符号
$\( i \)$
，计算出现频数
$\( F_i \)$：

- 令
$\( p_i = \frac{F_i}{L} \)$
- 熵为：
$H = -\sum_i p_i \log_2 p_i$
### 7. CDIX 指数输出

最终 CDIX 为：
$\text{CDIX} = 2^H$
                                  |
## 📎 附加说明

- CDIX 越大，表示招募过程越复杂；
- CDIX 与 MU 招募数量、顺序变动等生理特征具有相关性；
- GMM 分类为核心环节，参数设定与数据质量会影响最终结果。
