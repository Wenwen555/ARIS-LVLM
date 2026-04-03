# 研究提案：面向程序性长视频问答的答案条件证据充分性验证

## 论文身份一句话
这不是一篇“更强置信度校准”论文，而是一篇**基于证据充分性的选择性作答**论文：系统只有在候选答案被该视频实例中的已引用视觉证据充分支持时才输出答案，否则拒答。

## 问题锚点
- **底层问题**：程序性长视频问答中的 Video-LLM 经常给出语言上流畅、但视觉上并未被视频证据支撑的答案，而且模型通常不知道什么时候应该拒答。
- **必须突破的瓶颈**：现有工作分别覆盖了任务层级、局部场景证据、幻觉评测等方向，但仍缺少一个**答案条件的、可训练的证据充分性判据**，去决定某个候选答案是否真的被当前视频中的证据所授权（entitle）。
- **非目标**：不训练新的基础 Video-LLM；不提出新的场景图解析器；不试图解决开放域视频问答中的所有幻觉问题。
- **现实约束**：首篇论文必须聚焦程序性长视频；人工核验预算有限；算力中等；论文只能围绕一个主导性的机制级 claim 展开。
- **成功标准**：必须证明“幻觉下降”主要来自**显式证据充分性估计 + 更优拒答**，而不是来自泛化的置信度阈值、文本先验或更大模型规模。

## 技术缺口
当前研究仍然缺少一个真正面向“答案是否被当前证据授权”的判据。仅靠层级建模，只能告诉我们问题大概率对应哪个过程阶段；仅靠局部证据检索，只能告诉我们短窗口里看到了什么；仅靠幻觉 benchmark，只能揭示模型何时犯错。它们都没有回答一个核心问题：**候选答案何时有资格被放行到最终输出？**

更关键的是，就算一个 verifier 在表面上有效，也必须进一步检验：它的判断是否真的依赖于**该视频实例中被引用的像素证据**，而不是答案先验、文本匹配性，或“只要这个答案看起来合理”就打高分。因此，这篇论文不仅要提出 verifier，还要设计一套**无污染、可审计的依赖性检验协议**，测试“证据授权”判断是否由被引用的视频证据驱动，而不是由文本合理性伪装出来。

## 方法主张
- **一句话主张**：我们通过一个**答案条件的证据充分性验证器**来控制最终作答；只有当候选答案被当前视频中的检索证据充分支持时才输出，否则拒答；并通过无污染的证据替换对照实验验证该 gate 的判定确实依赖于该视频实例中的已引用证据。
- **为什么这是最小充分干预**：基础 Video-LLM 保持冻结；不引入新的解析器；新增模块仅包括“答案条件检索器 + 轻量 verifier + 基于开发集的风险控制阈值”。
- **为什么现在做合适**：强大的冻结视频语言 backbone 已经存在，缺失的是一个基于**证据授权**而非“模型自信度”的选择性输出层。

## 核心贡献聚焦
- **主贡献**：提出答案条件的证据充分性验证（answer-conditioned evidence sufficiency verification），并将其用于**风险可控的拒答决策**。
- **支撑性贡献 1**：提出面向程序性长视频的 EEA（Evidence Entitlement Audit）评测协议，直接评估“给定引用证据，该答案是否被当前视频授权”。
- **支撑性贡献 2**：提出无污染的 same-video / same-class 证据替换控制，用于检验 verifier 是否真的依赖当前视频实例中的引用证据。
- **明确非贡献**：不是场景图论文；不是新 backbone 论文；不是大规模 benchmark 构建论文。

## 方法总览

### 复杂度预算
- **冻结/复用部分**：
  - 冻结基础 Video-LLM，用于生成候选答案；
  - 冻结视频/clip encoder，用于提取 clip 表征。
- **新增可训练部分**：
  - 答案条件 clip 检索器 `R_\phi`；
  - 轻量证据充分性验证头 `S_\theta`。
- **刻意不引入的复杂项**：
  - 显式场景图解析器；
  - 重型长时序融合器；
  - 多头 coverage/consistency 子模块；
  - 默认系统中的对象/动作标签流水线。

### 系统流程
```text
输入：长视频 V，问题 q
1. 冻结的基础 Video-LLM 生成候选答案 a
2. 将 V 切分为 clip 库 B(V) = {c1, ..., cT}
3. 用答案条件检索器取回 top-K 证据 clips：E_K = R_phi(q, a, B(V))
4. 可选地拼接弱阶段线索 m
5. 计算证据充分性分数 S_theta(q, a, E_K, m)
6. 若 S_theta < tau，则输出 ABSTAIN
   否则输出 (a, timestamps)
7. 在 EEA 样本上进行无污染证据替换，验证该分数是否依赖当前视频实例中的引用证据
```

这里需要明确一个 **module contract**：retriever 负责提出候选证据集、提高 support recall；本文的核心 scientific claim 不在于“检索本身更强”，而在于**在给定固定 retrieved evidence set 的条件下，如何对答案是否被这些证据充分授权作出 sufficiency decision**。换言之，abstention 的 primary decision object 不是答案自信度，而是 `E_K` 对 `a` 的支持是否达到可放行阈值。

### 弱证据接口
本文使用的是**弱结构接口**，而不是 parser-heavy 的 MT-MG 路线。
- **微观证据**：带时间戳的 clip 集合 `E_K`；
- **宏观线索**：可选的阶段提示 `m`，可来自步骤分段、脚本或 ASR 对齐。

这样既保留了“宏观过程 + 微观证据”的直觉，又把论文主体约束为一个真正可实现、可审稿、可复现的 verifier 故事。

## 数学形式化
设长视频被切分为 clips：
\[
B(V)=\{c_1,\dots,c_T\}, \quad c_t \in \mathcal{C}.
\]
给定问题 `q` 和候选答案 `a`，检索得到 top-K 证据 clips：
\[
E_K = R_\phi(q,a,B(V)) = \{c_{i_1},\dots,c_{i_K}\}.
\]
令 `m` 表示可选的宏观阶段线索，验证器输出：
\[
S_\theta(q,a,E_K,m) \in [0,1],
\]
它表示“给定当前引用证据集，答案 `a` 被该视频实例授权”的分数。这里我们将其视为**风险排序分数**；若经过校准，也可以解释为充分性概率近似。

一个最小实现为：
\[
h_t=f_v(c_{i_t}), \qquad h_{qa}=f_q([q;a]), \qquad h_m=f_m(m),
\]
\[
\alpha_t = \mathrm{softmax}(h_{qa}^{\top}Wh_t), \qquad h_E = \sum_{t=1}^{K}\alpha_t h_t,
\]
\[
S_\theta(q,a,E_K,m)=\sigma\left(w^{\top}[h_{qa};h_E;h_m]+b\right).
\]
当 `m` 不可用时，退化为 `S_\theta(q,a,E_K)`。

最终的选择性作答规则为：
\[
\hat{y}(q,V)=
\begin{cases}
\texttt{ABSTAIN}, & S_\theta(q,a,E_K,m) < \tau, \\
 a, & S_\theta(q,a,E_K,m) \ge \tau.
\end{cases}
\]

### 与“普通置信度阈值”不同在哪里
如果只做常规置信度阈值，判定对象是 `p(a\mid q,V)` 或模型自评得分；而本文判定对象是
\[
S_\theta(q,a,E_K,m),
\]
即“**在给定已引用证据后，这个答案是否被授权**”。更直接地说，本文关心的不是 answer confidence，而是 **evidence-entitlement risk**。这一区别不只是输入形式不同，而是 **scientific object** 与 **decision object** 都不同：常规 confidence gating 试图判断“模型是否足够相信自己的答案”；本文则直接判断“候选答案对应的检索证据集是否已经构成可作答所需的最小充分支持”，abstention 只是这个 sufficiency decision 的 downstream consequence。

| 方案 | 判定对象 | 决策对象 | 是否显式条件于答案与证据 | 输出是否自带可审计 timestamps | 核心失败模式 |
|---|---|---|---|---|---|
| confidence thresholding | `p(a\mid q,V)` 或 self-score | answer confidence / self-belief | 否 | 否 | 模型更谨慎，但不保证拒掉的是“证据不足”样本 |
| self-eval prompting | 语言模型自评文本 | linguistic self-judgment | 通常否 | 否 | 容易复述文本先验，难证明依赖当前视频证据 |
| 本文的 evidence-entitlement verifier | `S_\theta(q,a,E_K,m)` | answer-conditioned evidence sufficiency | 是 | 是 | 若失败，主要暴露为 retrieval miss 或 verification miss |

这意味着：
1. 判定输入显式包含 `a` 和 `E_K`，不是仅看问题或全局视频；
2. 最终输出必须附带 timestamps，因此证据对象是可审计的；
3. 后续对照实验不是测“模型有没有变谨慎”，而是测“去掉真实证据后，这个 entitlement 判断是否坍塌”；
4. `S_\theta` 应被理解为**证据授权风险排序分数**，而不是基础模型对答案本身的内在自信度；
5. 因而本文的主贡献不是“更好地校准 answer score”，而是把 hallucination control 的核心 decision variable 从 answer confidence 改写为 evidence entitlement。

## 依赖性诊断：答案依赖与视频实例依赖
### 1. 交换答案诊断（swap diagnostic）
令 `\mathcal{A}(q,V)` 表示冻结生成器在 `(q,V)` 上得到的 beam 或候选列表。竞争答案 `a'` 被**确定性**地定义为最高分的非输出候选：
\[
a' = \arg\max_{\tilde a \in \mathcal{A}(q,V) \setminus \{a\}} p(\tilde a \mid q,V).
\]
在干净的 EEA 子集上，只标注两对：(1) `(q,a,E_K)`；(2) `(q,a',E_K)`。因此每个问题只需两次“答案-证据授权”判断，标注负担固定且可审计。

定义 swap margin：
\[
\Delta_{swap}(E)= S_\theta(q,a,E,m) - S_\theta(q,a',E,m).
\]
若 verifier 真在判断“当前证据是否支持当前答案”，则在真实 entailed 样本上应满足：
\[
\Delta_{swap}(E_K) > 0.
\]

### 2. 视频实例依赖诊断（video-instance dependence）
为了检验该判断是否依赖于**当前视频实例中的已引用证据**，我们构造两种对照证据：
\[
E_K^{same} \sim \mathrm{SampleDisjointSameVideo}(V; E_K, \epsilon), \qquad
E_K^{class} \sim \mathrm{SampleSameClass}(\mathcal{D}\setminus V).
\]
其中：
- `E_K^{same}`：从**同一视频**中采样，但要求与 `E_K` 的所有时间区间严格不相交，并设排除边界 `\epsilon`；
- `E_K^{class}`：从**同类但不同视频 ID** 的样本中采样，并通过 ASR / 脚本重叠过滤排除近重复片段。

定义两种分数下降：
\[
\Delta_{vid}^{same}=S_\theta(q,a,E_K,m)-S_\theta(q,a,E_K^{same},m),
\]
\[
\Delta_{vid}^{class}=S_\theta(q,a,E_K,m)-S_\theta(q,a,E_K^{class},m).
\]
在真正被授权的样本上，一个视觉 grounding 的 verifier 应满足：
\[
\Delta_{vid}^{same} > 0, \qquad \Delta_{vid}^{class} > 0.
\]
同时，交换答案的 margin 应在被破坏证据上显著坍塌：
\[
\Delta_{swap}(E_K^{same}) \approx 0, \qquad \Delta_{swap}(E_K^{class}) \approx 0.
\]

这里我们使用的表述是**视频实例级视觉依赖（instance-specific visual dependence）**，而非强因果措辞。论文要支持的结论是：该 gate 的判断在经验上依赖于当前视频实例中的已引用证据，而不是仅靠文本合理性支撑。same-video / same-class 控制的角色，是提供 contamination-controlled evidence replacement test，而不是声称完成严格因果识别。

## EEA 协议：把“证据授权”做成主评测
EEA（Evidence Entitlement Audit）是本论文的首要评测对象，而不是一个附属分析。

### 标注对象
标注者看到的是：
- 问题 `q`
- 候选答案 `a`
- 被系统引用的 timestamps
- 对应 clips

标注问题被严格固定为：
> **这些来自当前视频实例的已引用证据，是否足以授权这个答案？**

### 标注规则
- 标签为二元：`entitled` / `not entitled`；
- 在 clean swap 子集上，额外标注唯一的确定性竞争答案 `a'`；
- 部分样本双标，并报告一致率与 adjudication；
- 数据划分为 `EEA_dev` 和 `EEA_test`。

### 为什么 EEA 是主指标
因为这篇论文要解决的不是“答案正确率本身”，而是“**系统是否在证据不足时仍然放行答案**”。只有 EEA 能直接回答这个问题，并且它与本文的输出形式 `(answer, timestamps)` 完全对齐。

### 外部有效性桥接（transfer criterion）
本文对 transfer 的主张是收敛且受限的：我们并不声称 EEA 上的改进会自动迁移到所有视频 QA 质量，而只主张**对 unsupported-answer 的控制能力**应能迁移到更广的 procedural QA slice。这里保持三个约束：
1. **transfer object** 不是 overall QA accuracy，而是 unsupported final answers 的减少；
2. **eligibility condition** 是 target slice 仍能被 answer-conditioned retriever 找到与 clean EEA 相同类型的 support primitives（动作发生、对象状态、局部时序、参与对象 grounding）；
3. **validation condition** 是在 target 的 held-out clean subset 上，calibration 与 attribution 不应明显崩塌；若崩塌，则弱数据收益只能算 scalability evidence，而不能算主 claim evidence。

## 风险控制与校准
Round 5 的关键短板之一，是校准部分还停留在“经验阈值”层面。这里将其明确提升为**选择性预测（selective prediction）/ 风险控制**表述。本文把 abstention policy 视为一个标准 selective prediction 决策：`S_\theta` 负责对“证据是否足以授权答案”的风险进行排序，阈值 `\tau` 决定系统在给定目标风险下放行多少样本。

令 `\widehat{R}_{dev}(\tau)` 表示在 `EEA_dev` 上、不拒答样本的经验风险（例如 entitlement error）。我们选择阈值：
\[
\tau^* = \inf\{\tau : \widehat{R}_{dev}(\tau) \le \alpha\},
\]
其中 `\alpha` 是预设目标风险水平。

测试时仅在 `EEA_test` 上报告：
- achieved risk
- coverage
- false-abstain rate
- risk-coverage curve

### 理论立场
本文不声称提出新的校准理论，但会把系统明确置于标准的 selective prediction 框架下：
- verifier 分数负责对“证据授权风险”排序；
- `EEA_dev` 用于选择满足目标风险的阈值；
- `EEA_test` 用于无偏报告 achieved risk 与 coverage；
- 若将 `S_\theta` 解释为概率，只能理解为**经校准后的 operational approximation**，而不是未经论证的本体概率。

如果篇幅允许，可增加一段 conformal-style discussion：即把 `S_\theta` 看作 nonconformity 反向分数，并说明本文如何在开发集上实现有限样本下的风险控制近似。但这属于**支撑性理论 framing**，不是主方法贡献。

## 训练方案
我们使用三类监督源：
1. **干净 EEA 子集**：人工标注 `(q, a, timestamps, clips)` 是否被证据授权；
2. **near-miss negatives**：来自同一视频、但位于相邻或错误步骤段的 clips；
3. **evidence-dropout negatives**：移除高归因 clips，归因来源是 retriever attribution 或冻结相似度，而不是 verifier 自己的分数；并通过 held-out verifier seed 验证其可迁移性，避免循环论证。

总目标函数为：
\[
\mathcal{L} = \mathcal{L}_{sup} + \lambda_{rank}\mathcal{L}_{rank} + \lambda_{swap}\mathcal{L}_{swap} + \lambda_{cal}\mathcal{L}_{cal}.
\]
其中
\[
\mathcal{L}_{sup}=\mathrm{BCE}(S_\theta, y_{eea}),
\]
\[
\mathcal{L}_{rank}=\max(0, \gamma - S_\theta(q,a,E^+) + S_\theta(q,a,E^-)),
\]
\[
\mathcal{L}_{swap}=\max(0, \delta - S_\theta(q,a,E_K) + S_\theta(q,a',E_K)).
\]

这里：
- `\mathcal{L}_{sup}` 学习最直接的 entitlement 判别；
- `\mathcal{L}_{rank}` 强化真实支持证据与近邻干扰证据之间的分离；
- `\mathcal{L}_{swap}` 防止模型对任意“看起来合理”的答案做事后合理化。

注意：same-video / same-class 控制不是训练模块，而是**保留到测试期的依赖性检验**。

## 推理输出
测试时系统只输出两类结果之一：
- `(answer, timestamps)`
- `ABSTAIN`

这里的 timestamps 是预测对象的一部分，而不是事后解释。这使得系统天然可审计，也使 EEA 成为与模型行为完全一致的评测方式。

## 为什么机制保持小而硬
整篇论文新增的核心只有一个 gate：
> 候选答案是否被当前引用证据充分授权？

其余设计——包括 swap、same-video、same-class、风险阈值——都只是为了让这个 gate：
- 可训练；
- 可校准；
- 可审计；
- 可证明不是在偷用文本先验。

## 失败模式与诊断
- **retrieval miss：检索器没找到真证据**：报告不同 `K` 下的 EEA recall / oracle-evidence-hit rate，并分析 verifier 是否被错误证据上限锁死。
- **verification miss：真证据已取回但 verifier 仍误判**：在 oracle hit 的样本上单独报告 entitlement error，避免把检索失败和验证失败混在一起。
- **verifier 学成文本兼容性打分器**：联合检查 `\Delta_{swap}(E_K)`、`\Delta_{vid}^{same}`、`\Delta_{vid}^{class}`。
- **same-video 对照被污染**：强制与 `E_K` 及其邻域时间窗不相交，并报告采样失败率。
- **same-class 对照泄漏近重复**：强制不同 video ID，并使用 ASR / script overlap 过滤。
- **阶段线索 `m` 带来噪声**：把 `m` 仅作为 ablation，主模型默认不依赖它。
- **dropout negative 存在循环性**：用 held-out verifier seed 检查其跨 seed 转移效果。
- **EEA 标注不稳定**：先报告一致率、仲裁比例与 dev/test 一致性，再使用风险-coverage 结论。

## 新颖性与优雅性论证
这篇论文的新颖性不在于“再加一个 confidence threshold”，而在于它把 hallucination control 的**科学对象**与**决策对象**同时改写了：
1. 不再把问题表述为“模型对答案是否足够自信”，而是表述为**候选答案是否被当前检索证据充分授权**；
2. 不再把 abstention 视为 answer confidence 的阈值化，而是视为 answer-conditioned evidence sufficiency decision 的 downstream consequence；
3. 不再只输出答案文本，而是输出**可审计的 `(answer, timestamps)` 或 `ABSTAIN`**；
4. 不再只测“模型更不更谨慎”，而是通过最小控制实验检测该 gate 是否真的依赖当前视频实例中的引用证据。

这也是它的优雅之处：retriever 只负责 evidence proposal，verifier 只负责 conditional sufficiency decision；论文只加一个必要的 gate，不加多余的系统工程包袱。

## Claim 驱动的实验设计

### Claim 1：verifier 能提升基于证据授权的选择性预测
- **最小实验**：在固定 retriever 的前提下，比较 base model vs base + verifier，并只在 `EEA_dev` 上选阈值、在 `EEA_test` 上报告结果。
- **基线/消融**：
  - 仅用原模型置信度阈值；
  - self-eval prompting；
  - 不使用答案条件检索的 generic verifier；
  - retrieval only / retrieval + verifier / retrieval + verifier + calibration。
- **指标**：EEA、risk-coverage、false-abstain、conditional entitlement error。
- **预期证据**：在匹配 coverage 下，本文方法的 achieved risk 更低；并且在 fixed retriever setting 下，这个增益应主要归因于 verifier 对 sufficiency decision 的改进，而不是 retrieval proposal quality 的变化。

### Claim 2：该判断依赖当前视频实例中的引用证据，而非文本兼容性
- **最小实验**：在 EEA-entitled 样本上，把 `E_K` 分别替换成 `E_K^{same}` 和 `E_K^{class}`。
- **指标**：`\Delta_{vid}`、`\Delta_{swap}` 坍塌、以及 risk-coverage 恶化。
- **预期证据**：只有真实引用证据能同时维持高 `S_\theta` 和正的 `\Delta_{swap}`。

### Claim 3：答案条件检索优于仅问题条件检索
- **最小实验**：question-conditioned retrieval vs answer-conditioned retrieval，并在同一个 verifier 与同一阈值选择协议下比较。
- **指标**：EEA、insufficient-support 样本上的拒答准确率、retrieval recall、oracle-evidence-hit rate。
- **预期证据**：显式把答案作为条件能更好地区分“看起来相关”与“足以授权”；这里的收益应主要表现为 evidence proposal / support recall 的提升，从而为后续 verifier 提供更干净的证据上限，而不是替代 verifier 的 sufficiency decision。

### Claim 4：practical counterfactual negatives 能改进 verifier 训练，而非制造伪提升
- **最小实验**：near-miss only vs near-miss + evidence-dropout negatives。
- **指标**：EEA、abstention accuracy、held-out seed transfer。
- **预期证据**：引入 dropout negatives 后，充分/不充分分离更明显，且收益可跨 seed 迁移。

## 直击 Round 5 的两个关键补强实验
### A. 分解实验：把 retrieval / verifier / calibration 的贡献拆开
这是冲击 9 分所必需的实验之一，而且必须被写成**主证据**而不是附属消融。

比较四种系统：
1. **Base only**：直接输出答案；
2. **Base + Retrieval evidence only**：输出附带检索证据，但不加 verifier gate；
3. **Base + Retrieval + Verifier**：有 verifier 分数，但不做风险校准阈值；
4. **Base + Retrieval + Verifier + Risk-controlled abstention**：完整方法。

核心问题：
- 检索本身带来多少收益？
- verifier 相比“只是把证据贴出来”到底多大增益？
- 校准阈值相对裸 verifier 又贡献了多少风险控制收益？

主报告方式：
- 在 matched coverage 下比较 achieved risk；
- 同时汇报 unsupported-answer rate、false-abstain rate、risk-coverage AUC；
- 明确把 B vs A 解释为 retrieval 暴露收益、C vs B 解释为 verifier 的 entitlement 判断收益、D vs C 解释为 calibrated abstention 的风险控制收益。

这组实验将直接回应“你这是不是只是 confidence estimation with extra structure”的质疑。

### B. 迁移实验：EEA 提升是否真能减少更广 procedural QA 中的 unsupported final answers
这是冲击 9 分所必需的第二个实验，而且它的角色是**外部有效性桥接**，不是宣称泛化到所有视频 QA。

做法：
- 在更广的程序性 QA 切片上，人工抽样检查最终输出是否 unsupported；
- 比较 base、confidence threshold、本文方法三者；
- 在 matched coverage 或 fixed abstention budget 下，比较 unsupported-answer rate；
- 分析 EEA 改善是否与 broader QA 上 unsupported-answer rate 的下降一致。

这个实验不要求大规模新 benchmark，只需要一个**中等规模、人工可核验的 transfer slice**。它将直接补上“EEA 会不会只是在一个精心设计的小评测上有效”的漏洞。这里的成功标准不是 overall QA accuracy 必须同步上升，而是：在 coverage 可比或 abstention 预算固定时，本文方法能更稳定地降低 unsupported final answers；若 target slice 上 calibration 或 attribution 明显崩塌，则该结果最多只能作为 scalability evidence，而不能支撑主 claim。

## 次级指标
- 更广义数据上的 unsupported-answer rate 只作为**迁移代理指标**；
- 效率曲线只在 retrieval 预算成为实际约束时汇报；
- 常规 QA accuracy 不是主指标，只作补充背景。

## 实验交接输入
- **必须证明的 claims**：
  1. verifier 提升 EEA 上的选择性预测；
  2. entitlement 判断依赖当前视频实例中的引用证据；
  3. 答案条件检索优于问题条件检索；
  4. practical counterfactual negatives 有效且不过度循环；
  5. EEA 收益能迁移到更广的 unsupported-answer 控制。
- **必须跑的消融**：
  - no verifier
  - confidence threshold
  - self-eval prompting
  - question-conditioned retrieval
  - no macro cue
  - no swap loss
  - no dropout negatives
  - disjoint same-video evidence
  - same-class cross-video evidence
  - retrieval only / retrieval + verifier / retrieval + verifier + calibration
- **关键数据与指标**：
  - COIN / Ego4D 子集
  - `EEA_dev`, `EEA_test`
  - EEA
  - risk-coverage
  - false-abstain
  - `\Delta_{swap}`
  - `\Delta_{vid}`
  - broader unsupported-answer transfer rate
- **最高风险假设**：
  - retriever 质量是否成为瓶颈；
  - EEA 标注一致性是否足够高；
  - 对照替换后分数是否真的显著坍塌；
  - EEA 改善是否能迁移到更广义 QA 输出质量。

## 计算与标注预算
- **GPU 成本**：中低到中等，因为 backbone 冻结，新增模块轻量；
- **标注成本**：几百条 EEA 标注 + timestamps 核验 + clean swap 子集上的竞争答案标注 + 部分双标；
- **额外成本**：一个中等规模 broader QA transfer slice 的人工 unsupported 检查；
- **整体可行性**：仍适合作为首篇论文，因为没有 parser 构建和重模型训练负担。

## 结论
本文的核心不是继续增强 answer confidence estimation，而是把 hallucination control 的主决策变量改写为**evidence entitlement**：系统只在当前视频实例中的已引用证据足以授权候选答案时才放行，否则拒答。

围绕这一点，本文给出了一套彼此对齐的证据包：answer-conditioned retriever 提供可审计的 evidence proposal，verifier 对固定证据集执行 sufficiency decision，EEA 直接评测这种授权关系，same-video / same-class 替换检验该判断是否依赖实例级视觉证据，而 selective-prediction 风险控制则把最终输出约束为可报告的 risk-coverage tradeoff。

如果这些实验成立，论文支持的将是一个收敛而清晰的 method claim：在程序性长视频问答中，把最终作答从 answer confidence gating 改写为 evidence-entitlement gating，能够更可靠地减少 unsupported final answers。剩余不确定性主要在于执行质量——例如 retrieval 上限、标注一致性与 transfer 强度——而不再在于论文身份本身。
