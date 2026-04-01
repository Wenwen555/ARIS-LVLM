# 从高阶 RIP 到组合条件数：对 Cai-Zhang 2014 的改写分析与审核

## 任务说明

本文档针对论文：

- `Sparse Representation of a Polytope and Recovery of Sparse Signals and Low-Rank Matrices`
- T. Tony Cai, Anru Zhang
- IEEE Transactions on Information Theory, 2014
- PDF 路径：`lgl/Sparse_Representation_of_a_Polytope_and_Recovery_of_Sparse_Signals_and_Low-Rank_Matrices.pdf`

目标是回答下面这个问题：

> 原文给出了高阶 RIP 条件下的精确恢复结果。如果想改成“组合条件数”的结果，哪些部分可以直接保留，哪些部分必须重写，最终什么版本是严格成立的？

我对 PDF 做了结构化阅读，并对改写进行了自审。结论先说在前面：

## 核心结论

1. **原文的几何引理 Lemma 1.1 不需要改。**
2. **原文 Theorem 1.1 的证明主干也可以保留。**
3. **但不能把你给出的标准组合条件数**
   \[
   \kappa_s(A)=\max_{S\subset[n],\,|S|\le s}\kappa(A_S)
   =\max_{S\subset[n],\,|S|\le s}\frac{\sigma_{\max}(A_S)}{\sigma_{\min}(A_S)}
   \]
   **直接替换原文中的 \(\delta_{tk}\)。**
4. 如果要得到一个**严格成立**、并且真正能接上原证明的版本，应该引入的不是上面这个“逐子集最大条件数”，而是一个更强的量：
   \[
   \bar\kappa_s(A)
   :=\frac{\sigma_{+,s}(A)}{\sigma_{-,s}(A)},
   \]
   其中
   \[
   \sigma_{+,s}(A):=\max_{|S|\le s}\sigma_{\max}(A_S),\qquad
   \sigma_{-,s}(A):=\min_{|S|\le s}\sigma_{\min}(A_S).
   \]
5. 在这个更强定义下，可以把原文的高阶 RIP 结论改写成一个**严格正确的“全局组合条件数”版本**：
   \[
   \bar\kappa_{tk}(A)^2<q_t
   :=\frac{4t+1+\sqrt{16t^2+8t-15}}{2}
   \quad\Longrightarrow\quad
   \ell_1\text{ 精确恢复所有 }k\text{-稀疏信号}.
   \]
6. 如果坚持只用你图里的标准定义 \(\kappa_s(A)=\max_S\kappa(A_S)\)，那么**原证明不闭合**，必须额外加入“跨支撑集统一上、下谱界”的假设。

---

## 一、PDF 阅读摘要

### 1.1 基本信息

- 页数：`11`
- 主要结构：
  - `I. Introduction`
  - `II. Compressed Sensing`
  - `III. Affine Rank Minimization`
  - `IV. Discussion`
  - `V. Proofs`

### 1.2 原文最关键的逻辑链

原文的稀疏向量部分，其主链条是：

1. **Lemma 1.1**
   把一个满足 \(\|v\|_\infty\le \alpha,\ \|v\|_1\le s\alpha\) 的向量表示成若干 \(s\)-稀疏向量的凸组合。

2. **Null Space Property**
   为了证明 \(\ell_1\) 精确恢复，只需要说明对任意 \(h\in\mathcal N(A)\setminus\{0\}\)，都有
   \[
   \|h_{\max(k)}\|_1<\|h_{-\max(k)}\|_1.
   \]

3. **把 \(h_{-\max(k)}\) 分解成 \(h^{(1)}+h^{(2)}\)**，
   再把 \(h^{(2)}\) 用 Lemma 1.1 写成稀疏向量 \(u_i\) 的凸组合。

4. **构造一组 \(tk\)-稀疏向量 \(\beta_i\)**，
   对这些向量同时使用 RIP 上、下界，最后得到矛盾。

这条主链里，真正依赖高阶 RIP 的只有第 4 步。

---

## 二、原证明到底在哪里用了 RIP

原文在证明 Theorem 1.1 时，对若干 \(tk\)-稀疏向量应用了

\[
(1-\delta_{tk})\|z\|_2^2\le \|Az\|_2^2\le (1+\delta_{tk})\|z\|_2^2.
\]

也就是说，证明真正需要的不是“RIP 这个名字”，而是如下两个量：

\[
\rho_+(s):=\max_{\|z\|_0\le s,\ z\neq 0}\frac{\|Az\|_2^2}{\|z\|_2^2},
\qquad
\rho_-(s):=\min_{\|z\|_0\le s,\ z\neq 0}\frac{\|Az\|_2^2}{\|z\|_2^2}.
\]

在 RIP 记号下，它们正好是

\[
\rho_+(s)=1+\delta_s,\qquad \rho_-(s)=1-\delta_s.
\]

所以，**原证明本质上只依赖 order-\(tk\) 的 sparse upper/lower spectral bounds**。

这一步非常关键，因为它告诉我们：

- 可以把 RIP 改写成别的谱量；
- 但这个替代量必须同时控制上界和下界；
- 单独一个“条件数”比值往往不够。

---

## 三、为什么不能直接替换成你图里的组合条件数

你给出的定义是：

\[
\kappa_s(A)=\max_{|S|\le s}\kappa(A_S)
=\max_{|S|\le s}\frac{\sigma_{\max}(A_S)}{\sigma_{\min}(A_S)}.
\]

这个定义控制的是：

- **每一个固定支撑集 \(S\)** 内部的最好和最坏奇异值之比。

但原文证明需要的是：

- 对所有可能出现的 \(tk\)-稀疏向量，统一控制
  \[
  \|Az\|_2^2 \le \rho_+(tk)\|z\|_2^2,\qquad
  \|Az\|_2^2 \ge \rho_-(tk)\|z\|_2^2.
  \]

问题在于：

\[
\kappa_s(A)=\max_S \frac{\sigma_{\max}(A_S)}{\sigma_{\min}(A_S)}
\]

并**不能**推出

\[
\frac{\max_S \sigma_{\max}(A_S)}{\min_S \sigma_{\min}(A_S)}
\]

的上界。

而原证明恰恰需要后一种“跨支撑集的全局比值”。

### 3.1 断点在哪里

原证明在同一行里会把某些 \(tk\)-稀疏向量用“上谱界”估计，另外一些 \(tk\)-稀疏向量用“下谱界”估计。  
这些向量的支撑集一般不是同一个。

所以如果只知道“每个支撑集内部的条件数都不大”，仍然可能出现：

- 某个支撑集 \(S_1\) 的 \(\sigma_{\max}(A_{S_1})\) 很大；
- 另一个支撑集 \(S_2\) 的 \(\sigma_{\min}(A_{S_2})\) 很小；
- 但两个集合各自的 condition number 都不大。

这时 \(\kappa_s(A)\) 仍然小，但原证明需要的“统一上、下谱界”已经崩掉了。

### 3.2 因而，直接替换是**不成立**的

所以，下面这个写法：

\[
\delta_{tk}<\frac{t-1}{t}
\quad\Longrightarrow\quad
\kappa_{tk}(A)<C_t
\]

然后在原证明里把所有 \(\delta_{tk}\) 替换成 \(\kappa_{tk}(A)\)，这是**不严格的**。

这也是我对这次改写的第一条审核结论：

> 如果“组合条件数”采用你图中的标准定义，那么原文证明不能直接移植，必须补充新的全局谱控制假设。

---

## 四、严格可成立的改写版本

### 4.1 正确的替代定义

为了完整接上原证明，建议引入下面两个量：

\[
\sigma_{+,s}(A):=\max_{|S|\le s}\sigma_{\max}(A_S),\qquad
\sigma_{-,s}(A):=\min_{|S|\le s}\sigma_{\min}(A_S).
\]

并定义一个**全局组合谱条件数**：

\[
\bar\kappa_s(A):=\frac{\sigma_{+,s}(A)}{\sigma_{-,s}(A)}.
\]

这比你图中的
\[
\kappa_s(A)=\max_{|S|\le s}\frac{\sigma_{\max}(A_S)}{\sigma_{\min}(A_S)}
\]
更强，因为一般有
\[
\bar\kappa_s(A)\ge \kappa_s(A).
\]

但好处是：它正好控制了原证明所需的 sparse upper/lower spectral bounds。

### 4.2 等价改写为 sparse eigenvalue 形式

记

\[
\rho_+(s)=\sigma_{+,s}(A)^2,\qquad
\rho_-(s)=\sigma_{-,s}(A)^2.
\]

则原文中所有 RIP 不等式都可以逐字替换为

\[
\rho_-(tk)\|z\|_2^2\le \|Az\|_2^2\le \rho_+(tk)\|z\|_2^2
\qquad (\|z\|_0\le tk).
\]

这一步之后，Lemma 1.1、support split、Null Space Property 的结构全部不变。

---

## 五、改写后的主结果

### 5.1 可严格证明的精确恢复定理

**定理 A（基于全局组合谱条件数的精确恢复）**  
设 \(y=A\beta\)，其中 \(\beta\in\mathbb R^p\) 为 \(k\)-稀疏向量。设 \(t\ge 4/3\)，并定义

\[
\bar\kappa_{tk}(A)=\frac{\sigma_{+,tk}(A)}{\sigma_{-,tk}(A)}.
\]

若

\[
\bar\kappa_{tk}(A)^2 < q_t
\quad\text{其中}\quad
q_t:=\frac{4t+1+\sqrt{16t^2+8t-15}}{2},
\]

则 \(\ell_1\) 最小化
\[
\hat\beta=\arg\min_{z}\|z\|_1\quad\text{s.t. }Az=y
\]
可以精确恢复所有 \(k\)-稀疏信号。

### 5.2 证明思路

令

\[
q:=\frac{\rho_+(tk)}{\rho_-(tk)}=\bar\kappa_{tk}(A)^2.
\]

按照原文 Theorem 1.1 的证明，经过同样的分解和构造后，会得到

\[
0\le
\left[
\rho_+(tk)\Bigl(\frac12-\mu\Bigr)^2
-\frac{\rho_-(tk)}4
\;+\;
\Bigl(\frac{\rho_+(tk)}4-\rho_-(tk)\Bigr)\frac{\mu^2}{t-1}
\right]x^2,
\]

其中 \(x=\|h_{\max(k)}+h^{(1)}\|_2\)。

两边同时除以 \(\rho_-(tk)\)，得到只依赖于 \(q\) 的二次型：

\[
0\le
\left[
q\Bigl(\frac12-\mu\Bigr)^2
-\frac14
\;+\;
\Bigl(\frac q4-1\Bigr)\frac{\mu^2}{t-1}
\right]x^2.
\]

记

\[
g_t(\mu;q):=
q\Bigl(\frac12-\mu\Bigr)^2
-\frac14
\;+\;
\Bigl(\frac q4-1\Bigr)\frac{\mu^2}{t-1}.
\]

若能选到某个 \(\mu\ge 0\) 使得 \(g_t(\mu;q)<0\)，则得到矛盾，从而 Null Space Property 成立。

对 \(\mu\) 最优化后，\(g_t(\mu;q)<0\) 等价于

\[
q^2-(4t+1)q+4<0.
\]

由于 \(q\ge 1\)，可行区间是

\[
1\le q < \frac{4t+1+\sqrt{16t^2+8t-15}}{2}=q_t.
\]

这就证明了上面的定理。

### 5.3 一个可直接写进稿子的版本

如果你想把这个结果直接放进草稿里，我建议写成：

> Define the order-\(s\) sparse extremal singular values
> \[
> \sigma_{+,s}(A)=\max_{|S|\le s}\sigma_{\max}(A_S),\qquad
> \sigma_{-,s}(A)=\min_{|S|\le s}\sigma_{\min}(A_S),
> \]
> and the global combinatorial spectral condition number
> \[
> \bar\kappa_s(A)=\sigma_{+,s}(A)/\sigma_{-,s}(A).
> \]
> Then for \(t\ge 4/3\), the basis pursuit decoder exactly recovers every \(k\)-sparse signal whenever
> \[
> \bar\kappa_{tk}(A)^2<\frac{4t+1+\sqrt{16t^2+8t-15}}{2}.
> \]

---

## 六、和原始 RIP 结果的关系

在 RIP 归一化框架下，

\[
\rho_+(tk)=1+\delta_{tk},\qquad \rho_-(tk)=1-\delta_{tk},
\]

因此

\[
\bar\kappa_{tk}(A)^2=\frac{1+\delta_{tk}}{1-\delta_{tk}}.
\]

原文条件

\[
\delta_{tk}<\frac{t-1}{t}
\]

会推出

\[
\bar\kappa_{tk}(A)^2 < 2t-1.
\]

所以，RIP 条件会自动推出一个组合谱比值条件。  
但要注意，这两个条件不是同一个量上的比较：

- RIP 控制的是“围绕 1 的双边偏差”；
- 组合谱条件数控制的是“全局上下谱比值”。

因此，二者**不是简单替换关系**，而是两套不同参数化方式。

---

## 七、如果坚持使用你图中的 \(\kappa_s(A)\)，应该怎么说

如果你希望保留图中的定义

\[
\kappa_s(A)=\max_{|S|\le s}\kappa(A_S),
\]

那么最稳妥的写法不是直接给出“主定理”，而是写成一个**条件化命题**：

> Assume in addition that the order-\(tk\) sparse submatrices admit a uniform cross-support spectral calibration, namely
> \[
> \frac{\sigma_{+,tk}(A)}{\sigma_{-,tk}(A)}\le C(\kappa_{tk}(A)).
> \]
> Then the proof of Theorem 1.1 goes through with \(\bar\kappa_{tk}(A)\) replaced by this upper bound.

换句话说：

- **只用 \(\kappa_s(A)\) 不够**；
- 你还得补上一个把不同支撑集的尺度统一起来的假设。

这是本次审核中最重要的“风险提示”。

### 7.1 能否回推出“原有定义下”的 \(L_1\) 恢复条件

可以，但要分两种意义来讲。

#### 情形 A：只想得到一个“由新条件推出的 corollary”

这是可以的，因为总有

\[
\kappa_s(A)\le \bar\kappa_s(A).
\]

因此，只要我们已经证明

\[
\bar\kappa_{tk}(A)^2<q_t
\quad\Longrightarrow\quad
\ell_1\text{ 精确恢复},
\]

那么立刻得到一个**伴随结论**：

\[
\bar\kappa_{tk}(A)^2<q_t
\quad\Longrightarrow\quad
\kappa_{tk}(A)^2<q_t
\quad\Longrightarrow\quad
\ell_1\text{ 精确恢复}.
\]

但要注意，这句话的逻辑重点仍然是：

- 真正起作用的是 \(\bar\kappa_{tk}(A)\) 的约束；
- \(\kappa_{tk}(A)\) 只是被顺带控制住了。

所以这**不是**一个“仅用原定义 \(\kappa_{tk}(A)\) 就足够”的恢复定理。

#### 情形 B：想得到一个“只写 \(\kappa_{tk}(A)\) 的 sufficient condition”

这也可以，但必须额外引入一个“跨支撑集谱尺度波动因子”。

定义

\[
M_+(s):=\max_{|S|\le s}\sigma_{\max}(A_S),\qquad
M_-(s):=\min_{|S|\le s}\sigma_{\max}(A_S),
\]
\[
m_+(s):=\max_{|S|\le s}\sigma_{\min}(A_S),\qquad
m_-(s):=\min_{|S|\le s}\sigma_{\min}(A_S).
\]

则

\[
\bar\kappa_s(A)=\frac{M_+(s)}{m_-(s)}.
\]

另一方面，由

\[
\sigma_{\max}(A_S)\le \kappa_s(A)\,\sigma_{\min}(A_S)
\quad\text{对所有 }|S|\le s
\]

可得

\[
M_+(s)\le \kappa_s(A)\,m_+(s),
\]

所以

\[
\bar\kappa_s(A)\le \frac{m_+(s)}{m_-(s)}\,\kappa_s(A).
\]

同理，由

\[
\sigma_{\min}(A_S)\ge \sigma_{\max}(A_S)/\kappa_s(A)
\]

可得

\[
\bar\kappa_s(A)\le \frac{M_+(s)}{M_-(s)}\,\kappa_s(A).
\]

因此，若定义谱尺度波动因子

\[
\Gamma_s
:=\min\left\{
\frac{m_+(s)}{m_-(s)},
\frac{M_+(s)}{M_-(s)}
\right\}\ge 1,
\]

则有

\[
\bar\kappa_s(A)\le \Gamma_s\,\kappa_s(A).
\]

于是原来的全局组合谱条件数结果立刻推出：

\[
\Gamma_{tk}^2\,\kappa_{tk}(A)^2<q_t
\quad\Longrightarrow\quad
\ell_1\text{ 精确恢复所有 }k\text{-稀疏信号}.
\]

也就是

\[
\kappa_{tk}(A)^2<\frac{q_t}{\Gamma_{tk}^2}
\quad\Longrightarrow\quad
\ell_1\text{ 精确恢复}.
\]

这里

\[
q_t=\frac{4t+1+\sqrt{16t^2+8t-15}}{2}.
\]

这条结论就是你想要的“原有定义下的 \(L_1\) 恢复条件”，但它不是裸的 \(\kappa_{tk}(A)\) 条件，而是：

- `原有条件数` \(\kappa_{tk}(A)\)
- 再加一个 `跨支撑集谱尺度一致性因子` \(\Gamma_{tk}\)

共同构成的 sufficient condition。

#### 情形 C：什么时候能退化成只含 \(\kappa_{tk}(A)\) 的漂亮形式

如果你能在论文里额外假设：

\[
\Gamma_{tk}\le C_{tk}
\]

其中 \(C_{tk}\) 是一个已知常数，那么上面的条件会简化成

\[
\kappa_{tk}(A)^2<\frac{q_t}{C_{tk}^2}
\quad\Longrightarrow\quad
\ell_1\text{ 精确恢复}.
\]

特别地，如果支撑间谱尺度几乎不波动，即 \(\Gamma_{tk}\approx 1\)，那么就近似得到

\[
\kappa_{tk}(A)^2<q_t
\quad\Longrightarrow\quad
\ell_1\text{ 精确恢复}.
\]

但这一点一定要明确写成**额外假设**，不能默认成立。

---

## 八、关于 noisy case 和 low-rank case

### 8.1 noisy case

原文 Theorem 2.1 不仅依赖于比值，还依赖于绝对常数：

- 噪声项里会出现类似 \(\sqrt{1+\delta}\) 的量；
- 最终不等式的分母来自“负二次型的强度”，本质上依赖 \(\rho_+\) 和 \(\rho_-\) 的组合。

因此：

> noisy case 不能只用一个“组合条件数比值”来整洁表达。  
> 正确做法是改写成 \(\rho_+(tk),\rho_-(tk)\) 的二参数形式。

也就是说：

- **精确恢复定理**可以做成 ratio-only；
- **稳定恢复定理**建议保留为 sparse upper/lower eigenvalue 形式。

### 8.2 low-rank case

原文第三部分是 affine rank minimization。  
这里如果要做“条件数化”，也不能直接套列子矩阵的组合条件数定义，而应该定义：

\[
\rho_{+,r}(\mathcal M)
=\max_{\operatorname{rank}(X)\le r}\frac{\|\mathcal M(X)\|_2^2}{\|X\|_F^2},
\qquad
\rho_{-,r}(\mathcal M)
=\min_{\operatorname{rank}(X)\le r}\frac{\|\mathcal M(X)\|_2^2}{\|X\|_F^2},
\]

以及

\[
\bar\kappa_r(\mathcal M)=\sqrt{\rho_{+,r}(\mathcal M)/\rho_{-,r}(\mathcal M)}.
\]

这样才能得到真正平行于向量情形的 rank-restricted condition result。

---

## 九、自审结论

### 9.1 本次改写中“严格成立”的部分

- 保留 Lemma 1.1，不需要改。
- 保留 Null Space Property 证明主干，不需要改。
- 用 sparse upper/lower eigenvalues 替换 RIP，是严格成立的。
- 用
  \[
  \bar\kappa_{tk}(A)=\sigma_{+,tk}(A)/\sigma_{-,tk}(A)
  \]
  替换原文的高阶 RIP 参数，并得到
  \[
  \bar\kappa_{tk}(A)^2<\frac{4t+1+\sqrt{16t^2+8t-15}}{2}
  \]
  这一 sufficient condition，是严格成立的。

### 9.2 本次改写中“不能直接成立”的部分

- 不能把你图中的
  \[
  \kappa_s(A)=\max_{|S|\le s}\kappa(A_S)
  \]
  直接代入原证明。
- 不能只用 \(\kappa_s(A)\) 给出 noisy case 的完整稳定恢复界。
- 不能把向量情形的组合条件数定义直接拿去写 matrix recovery，除非先改成 rank-restricted spectral quantities。

### 9.3 我建议你论文里采用的最终版本

如果你的目标是“把原文的高阶 RIP 结果改成组合条件数结果，同时保证稿子严谨”，我建议你：

1. **不要**直接使用图片中的 \(\kappa_s(A)\) 作为主定理参数。
2. 改用我在这里定义的
   \[
   \bar\kappa_s(A)=\sigma_{+,s}(A)/\sigma_{-,s}(A)
   \]
   作为主文中的“组合谱条件数”。
3. 在正文里备注：
   \[
   \kappa_s(A)=\max_{|S|\le s}\kappa(A_S)
   \]
   是一个更常见但更弱的定义；为了接通原证明，我们使用全局版本。

这样写，最稳，也最容易过审稿人的逻辑检查。

---

## 十、可直接使用的中文结论段

下面这段可以直接作为你草稿里的中文说明：

> 原文中的高阶 RIP 条件本质上只是在 order-\(tk\) 的稀疏向量集合上提供统一的双边谱界，因此可以用 sparse upper/lower spectral bounds 来替代。需要注意的是，若仅采用通常的组合条件数定义 \(\kappa_s(A)=\max_{|S|\le s}\kappa(A_S)\)，则它只控制单个支撑集内部的谱比值，无法控制原证明中所需的跨支撑集统一上、下界，因此不能直接替换高阶 RIP。为此，我们引入全局组合谱条件数 \(\bar\kappa_s(A)=\sigma_{+,s}(A)/\sigma_{-,s}(A)\)。在该定义下，可以沿用原文 Theorem 1.1 的证明，并得到：当 \(t\ge 4/3\) 且 \(\bar\kappa_{tk}(A)^2 < \frac{4t+1+\sqrt{16t^2+8t-15}}{2}\) 时，\(\ell_1\) 最小化能够精确恢复所有 \(k\)-稀疏信号。

---

## 十一、可直接使用的英文结论段

> The high-order RIP condition used in Cai and Zhang (2014) can be replaced by sparse upper/lower spectral bounds, since the proof only relies on a uniform two-sided estimate over the set of \(tk\)-sparse vectors. However, the standard combinatorial spectral condition number \(\kappa_s(A)=\max_{|S|\le s}\kappa(A_S)\) is not sufficient by itself, because it only controls the conditioning within each fixed support and does not provide the cross-support uniform lower/upper spectral bounds required by the proof. To make the argument rigorous, we introduce the global combinatorial spectral condition number \(\bar\kappa_s(A)=\sigma_{+,s}(A)/\sigma_{-,s}(A)\), where \(\sigma_{+,s}(A)=\max_{|S|\le s}\sigma_{\max}(A_S)\) and \(\sigma_{-,s}(A)=\min_{|S|\le s}\sigma_{\min}(A_S)\). Then, by following the proof of Theorem 1.1, one obtains that basis pursuit exactly recovers every \(k\)-sparse signal whenever \(t\ge 4/3\) and
> \[
> \bar\kappa_{tk}(A)^2<\frac{4t+1+\sqrt{16t^2+8t-15}}{2}.
> \]

---

## 十二、后续建议

如果你下一步要继续推进，我建议按下面顺序做：

1. 先决定你论文里“组合条件数”到底采用哪个定义。
2. 如果追求严谨并且想最大化复用 Cai-Zhang 的证明，就用本文档的 \(\bar\kappa_s(A)\)。
3. 如果必须沿用图片里的标准定义 \(\kappa_s(A)\)，那就需要额外加入一个“全局谱校准”假设，否则主定理不要写成完全等价替换。
4. noisy case 和 low-rank case 建议分开处理，不要试图用一个单一 \(\kappa_s\) 统一写完。
