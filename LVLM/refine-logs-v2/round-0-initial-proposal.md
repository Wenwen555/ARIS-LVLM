# Research Proposal: Video Hallucination Reduction via Support Insufficiency Modeling and Abstention

## Problem Anchor

- **Bottom-line problem**: Video-LLMs 在长视频程序性理解中生成缺乏视觉证据支持的内容（幻觉），且无法识别何时应该拒绝回答。

- **Must-solve bottleneck**:
  1. **证据脱节**: 生成的回答无法追溯到具体的视觉证据
  2. **先验绑架**: 语言模型先验覆盖了视觉观察
  3. **拒绝机制缺失**: 模型没有学会在证据不足时"闭嘴"（abstention）

- **Non-goals**:
  - 不是设计新的 Video-LLM 架构
  - 不是提出新的场景图解析算法
  - 不是构建大规模预训练数据集
  - 不是做通用的视频理解（收窄到程序性视频）

- **Constraints**:
  - 计算资源：4-8 GPU 天
  - 数据集：Ego4D、COIN（程序性视频）
  - 目标会议：NeurIPS/ICML/ICLR
  - 必须与 VideoLoom、HyperGLM 等最新工作明确区分

- **Success condition**:
  - 幻觉率绝对下降 >10%（有 evidence attribution 验证）
  - Evidence attribution F1 > 0.7
  - 模型学会 abstention（拒绝回答无证据问题，abstention calibration > 0.8）
  - 与 VideoLoom/HyperGLM 的差异化在论文中清晰可辩护

---

## Technical Gap

### 当前方法失败点

1. **HyperGLM (CVPR 2025)**: 已统一场景图+因果图，但：
   - 无显式 support relation 定义
   - 无 abstention 机制
   - 图推理目标是表示学习，而非幻觉控制

2. **State-Change Counterfactuals (ICCV 2025)**: 已有状态变化反事实，但：
   - 扰动在状态层面，非拓扑层面
   - 训练目标是表示学习，非 abstention

3. **VCR-Bench/HERBench**: 已有证据推理 benchmark，但：
   - 无最小支持集标注
  - 无 abstention 评估

### 为什么更大的系统不是答案

- 简单增加图规模 → O(N²) 复杂度，长视频不可行
- 更多训练数据 → 不解决"何时拒绝"的核心问题
- 更强的 LLM backbone → 语言先验更强，幻觉可能更严重

### 缺失的机制

**一个显式的 support insufficiency 检测器**：
- 判断候选答案是否有 consistent support topology
- 在证据不足时触发 abstention
- 通过最小拓扑反事实训练学习"拒绝"行为

---

## Method Thesis

- **One-sentence thesis**: 通过学习判断候选答案是否有 consistent support topology，并在证据不足时拒绝回答，从而减少 Video-LLM 的幻觉。

- **Why this is the smallest adequate intervention**:
  - 不改变 Video-LLM 架构
  - 只添加一个 support insufficiency 检测器
  - 训练数据通过自动化反事实生成获得

- **Why this route is timely in the foundation-model era**:
  - 利用预训练的场景图模型（EASG）生成微观证据
  - 利用 LLM 生成宏观任务结构
  - 符合"teach models when NOT to answer"的当前趋势

---

## Contribution Focus

- **Dominant contribution**: **Support Insufficiency Detection via Minimal-Edit Topological Counterfactuals**
  - 首个将 support topology violation 作为 abstention 信号的方法
  - 最小拓扑编辑反事实生成算法
  - Ranking + Abstention 训练目标

- **Optional supporting contribution**: **Evidence Attribution Benchmark with Minimal Support Sets**
  - 500-1000 QA 对 + 最小支持证据标注
  - 联合评估：answering + grounding + calibration + abstention

- **Explicit non-contributions**:
  - ❌ 层次化视频图表示（HyperGLM 已做）
  - ❌ 反事实训练用于表示学习（SCC 已做）
  - ❌ 查询感知帧选择（Frame-Voyager 已做）

---

## Proposed Method

### Complexity Budget

- **Frozen / reused backbone**:
  - Video-LLM: VideoLLaMA-2 或 InternVideo2（冻结）
  - 场景图生成: EASG 预训练模型（冻结）
  - 宏观任务解析: GPT-4 API（冻结）

- **New trainable components**:
  1. **Support Insufficiency Detector (SID)**: 判断 support graph 是否足够支撑答案
  2. **Minimal-Edit Counterfactual Generator (MECG)**: 生成拓扑层面的最小编辑反事实

- **Tempting additions intentionally not used**:
  - ❌ 端到端图神经网络（计算复杂度过高）
  - ❌ 自适应证据选择模块（降级为固定预算）
  - ❌ 多语言扩展（单独论文）

### System Overview

```
输入视频 V + 问题 Q
    ↓
[EASG] → 微观场景图 G_micro (实体-关系-状态)
    ↓
[GPT-4 + ASR] → 宏观任务树 T_macro (目标-步骤-子步骤)
    ↓
[Support Graph Builder] → G_support = BuildSupportGraph(G_micro, T_macro)
    ↓
[Support Insufficiency Detector] → s = SID(G_support, Q, candidate_answer)
    ↓
if s < threshold:
    → Output: "Insufficient evidence to answer"
else:
    → Output: candidate_answer
```

### Core Mechanism: Support Insufficiency Detector (SID)

- **Input**:
  - Support graph G_support (从微观图和宏观树构建)
  - Question Q
  - Candidate answer A（从 Video-LLM 生成）

- **Architecture**:
  ```
  G_support → GNN Encoder → h_graph
  Q, A → Text Encoder → h_qa
  h_combined = Attention(h_graph, h_qa)
  s = MLP(h_combined)  # support sufficiency score
  ```

- **Training signal / loss**:
  - 正样本：真实 QA 对（support sufficient）
  - 负样本：最小拓扑编辑反事实（support insufficient）
  - Loss: Binary cross-entropy + Ranking loss
    ```
    L = BCE(s, label) + λ * max(0, margin - s_pos + s_neg)
    ```

- **Why this is the main novelty**:
  - 首个将 support topology 作为 faithfulness certificate 的方法
  - 首个通过拓扑反事实学习 abstention 的方法

### Supporting Component: Minimal-Edit Counterfactual Generator (MECG)

- **Input**: Support graph G_support, original answer A

- **Output**: Counterfactual support graph G_cf, flipped answer A_cf

- **Algorithm**:
  ```
  1. Identify top-K critical support edges (by attention weight)
  2. For each edge e_i:
     - Generate minimal edit: remove/replace e_i
     - Verify: does this flip the answer?
     - If yes, add to counterfactual set
  3. Return minimal-edit counterfactuals
  ```

- **Constraints**:
  - 只修改 1-2 个拓扑关系（minimal）
  - 必须通过 state-change prior 验证（plausible）
  - 必须翻转答案（genuinely hard）

- **Training signal**: 作为 SID 的负样本

### Modern Primitive Usage

- **LLM (GPT-4)**: 用于宏观任务树生成
  - 角色：结构化解析器
  - 比手工规则更灵活，比训练模型更便宜

- **Pretrained VidSGG (EASG)**: 用于微观场景图生成
  - 角色：视觉证据提取器
  - 复用预训练权重，不微调

- **Video-LLM (VideoLLaMA-2)**: 用于答案生成
  - 角色：候选答案生成器
  - 冻结，只训练 SID

### Integration into Base Generator

- **Attachment point**: Video-LLM 输出层之后
- **Frozen**: Video-LLM backbone, EASG, GPT-4
- **Trainable**: SID, MECG
- **Inference order**:
  1. Video-LLM 生成候选答案
  2. 构建 support graph
  3. SID 判断 support sufficiency
  4. 输出答案或 abstention

### Training Plan

- **Stage 1**: 生成 support graphs（使用 EASG + GPT-4）
- **Stage 2**: 生成 counterfactuals（使用 MECG）
- **Stage 3**: 训练 SID（使用正样本 + counterfactual 负样本）
- **Data**: Ego4D, COIN（程序性视频）
- **Pseudo-labels**: 最小支持集由 MECG 自动生成

### Failure Modes and Diagnostics

- **Failure mode 1**: SID 过度拒绝（high precision, low recall）
  - Detection: Abstention rate 异常高
  - Mitigation: 降低 threshold，增加正样本

- **Failure mode 2**: SID 欠拒绝（high recall, low precision）
  - Detection: 幻觉率未下降
  - Mitigation: 增加 hard negative counterfactuals

- **Failure mode 3**: Counterfactuals 不 plausible
  - Detection: 人工验证失败率 > 20%
  - Mitigation: 增强 state-change prior 约束

### Novelty and Elegance Argument

- **Closest work**:
  - HyperGLM: 图表示学习，无 support insufficiency 概念
  - SCC: 状态变化反事实，非拓扑层面
  - Reliable VQA: Abstention，但非基于 support topology

- **Exact difference**:
  - 我们的方法是首个将 **support topology violation** 作为 **abstention signal** 的方法
  - 反事实在 **拓扑层面** 生成，而非状态层面
  - 训练目标是 **学习拒绝**，而非更好的表示

- **Why this is focused**:
  - 只有一个核心机制：Support Insufficiency Detection
  - 只有一个训练目标：Abstention when support insufficient
  - 所有其他组件（图构建、反事实生成）都服务于这个核心

---

## Claim-Driven Validation Sketch

### Claim 1: Support Insufficiency Detection reduces hallucination

- **Minimal experiment**:
  - 数据集：Ego4D（测试集）
  - 比较：Video-LLM baseline vs Video-LLM + SID
  - 指标：Hallucination rate, Evidence F1

- **Expected evidence**:
  - 幻觉率绝对下降 >10%
  - Evidence F1 > 0.7

### Claim 2: Minimal-Edit Topological Counterfactuals enable effective abstention

- **Minimal experiment**:
  - 比较：Random counterfactuals vs Minimal-edit counterfactuals vs No counterfactuals
  - 指标：Abstention calibration, Hallucination reduction

- **Expected evidence**:
  - Minimal-edit counterfactuals 效果最好
  - Abstention calibration > 0.8

### Claim 3: [Optional] Benchmark enables multi-dimensional evaluation

- **Minimal experiment**:
  - 在我们的 benchmark 上评估现有方法
  - 指标：Answering, Grounding, Calibration, Abstention

- **Expected evidence**:
  - 现有方法在 abstention 维度表现差
  - 我们的方法在各维度更平衡

---

## Experiment Handoff Inputs

- **Must-prove claims**:
  1. SID reduces hallucination
  2. Minimal-edit counterfactuals enable abstention

- **Must-run ablations**:
  1. SID vs No SID
  2. Minimal-edit vs Random counterfactuals
  3. Topological vs State-level counterfactuals

- **Critical datasets / metrics**:
  - Datasets: Ego4D, COIN
  - Metrics: Hallucination rate, Evidence F1, Abstention calibration

- **Highest-risk assumptions**:
  1. Counterfactuals 的 quality（需要人工验证）
  2. SID 的泛化性（需要跨数据集测试）

---

## Compute & Timeline Estimate

- **Estimated GPU-hours**: 32-48 GPU hours（4-6 GPU 天）
- **Data / annotation cost**: 中（需要人工验证 counterfactuals）
- **Timeline**:
  - 实现：2 周
  - 实验：2-3 周
  - 分析：1 周