# Round 1 Refinement

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

## Anchor Check

- **Original bottleneck**: Video-LLM 生成无证据支持的答案，且无法拒绝回答
- **Why the revised method still addresses it**: 新方法仍然聚焦于判断答案是否有足够视觉证据支持，并学习在证据不足时拒绝
- **Reviewer suggestions rejected as drift**: 无 - 所有建议都服务于核心问题

---

## Simplicity Check

- **Dominant contribution after revision**: Support Sufficiency Verifier (SSV) - 一个单一的支持充分性判断器
- **Components removed or merged**:
  - ❌ GPT-4 API（删除运行时依赖）
  - ❌ MECG 作为可训练组件（改为离线 hard-negative mining）
  - ❌ 独立的 Benchmark 贡献（改为小规模验证集）
  - ❌ GNN + 多编码器融合（改为单一 Transformer verifier）

- **Reviewer suggestions rejected as unnecessary complexity**: 无 - 审稿人的简化建议全部采纳

- **Why the remaining mechanism is still the smallest adequate route**: 只有一个可训练组件（SSV），所有其他组件复用预训练模型或离线处理

---

## Changes Made

### 1. Method Architecture - Replaced symbolic pipeline with FM-native verifier

**Reviewer said**: "The proposal uses foundation models, but mostly as frozen utilities wrapped by a symbolic pipeline. `GPT-4 API + EASG + GNN + fusion MLP` is not yet a clearly justified 2026 design."

**Action**: 
- 删除 GPT-4 API 依赖
- 删除 GNN 编码器
- 采用单一 Transformer-style verifier
- 使用 Frozen Video-LLM 生成的 evidence spans 作为 support units

**Reasoning**: 简化架构，减少符号管道，更符合 foundation-model-era 设计

**Impact on core method**: 核心机制从 "GNN + 融合" 简化为 "单一 Verifier"

### 2. Interface Specification - Added concrete definitions

**Reviewer said**: "The method lacks implementable interfaces. `G_support` is undefined; candidate answer generation is undefined; 'verify answer flip' is undefined."

**Action**: 添加完整接口定义：
- **Support Graph G_support**: 节点类型 `action`, `object-state`, `tool`, `segment`；边类型 `before`, `enables`, `acts_on`, `changes_state`
- **Candidate Answers**: 从 Frozen Video-LLM 生成 K 个候选
- **Verifier Output**: 两个头 - `s(Q,A,G)` 充分性分数 + `mask` 证据节点掩码
- **Training Loss**: `L = L_rank + λ L_abstain + β L_attr`

**Reasoning**: 使方法可直接实现

**Impact on core method**: 增加可操作性，减少歧义

### 3. Scope Reduction - Cut to feasible size

**Reviewer said**: "The current plan likely underestimates preprocessing and evaluation cost. GPT-4 in the loop hurts reproducibility. A new benchmark is expensive."

**Action**:
- 使用单一 backbone (VideoLLaMA-2)
- 聚焦 COIN + 精选 Ego4D 子集
- MECG 改为完全离线
- Benchmark 改为小规模人工验证评估子集 (200-300 QA)

**Reasoning**: 在 4-8 GPU 天预算内可行

**Impact on core method**: 减少工程复杂度，提高可行性

### 4. MECG as Offline Hard-Negative Miner

**Reviewer said**: "Recast MECG as an offline hard-negative miner, not a trainable component."

**Action**: MECG 不再是可训练组件，改为预处理阶段离线生成 hard negatives

**Reasoning**: 减少训练复杂度，聚焦核心贡献

**Impact on core method**: 简化训练流程

---

## Revised Proposal

# Research Proposal: Support Sufficiency Verifier for Video-LLM Abstention

## Problem Anchor

（与上述相同，略）

## Method Thesis

- **One-sentence thesis**: 通过一个单一的支持充分性判断器（Support Sufficiency Verifier），判断 Video-LLM 生成的候选答案是否有足够的视觉证据支持，并在证据不足时学会拒绝回答。

- **Why this is the smallest adequate intervention**:
  - 只添加一个可训练组件（SSV）
  - Video-LLM 冻结，不改架构
  - 训练数据通过离线 hard-negative mining 获得

- **Why this route is timely in the foundation-model era**:
  - 使用 Frozen Video-LLM 生成候选答案和 evidence spans
  - 采用 Transformer-style verifier（非传统 GNN）
  - 符合 "teach models when NOT to answer" 趋势

---

## Contribution Focus

- **Dominant contribution**: **Support Sufficiency Verifier (SSV)**
  - 首个将 support insufficiency 作为 abstention 信号的方法
  - 问题条件化的支持表示
  - Ranking + Abstention + Attribution 多任务训练

- **Explicit non-contributions**:
  - ❌ 层次化视频图表示（HyperGLM 已做）
  - ❌ 反事实训练用于表示学习（SCC 已做）
  - ❌ 新的 Benchmark（仅小规模验证集）
  - ❌ 可训练的图生成器（改为离线处理）

---

## Proposed Method

### Complexity Budget

- **Frozen / reused backbone**:
  - Video-LLM: VideoLLaMA-2（冻结）
  - Evidence Span Extraction: 复用 Video-LLM 的 attention weights 或使用预训练 temporal grounding 模块

- **New trainable components**:
  1. **Support Sufficiency Verifier (SSV)**: 单一 Transformer-style verifier

- **Deleted from original proposal**:
  - ❌ GPT-4 API
  - ❌ EASG 场景图模型
  - ❌ GNN 编码器
  - ❌ 多编码器融合模块
  - ❌ 可训练的 MECG

### System Overview

```
输入视频 V + 问题 Q
    ↓
[Frozen VideoLLaMA-2] 
    → Candidate Answers {A_1, ..., A_K}
    → Evidence Spans {E_1, ..., E_M} (attention-based extraction)
    ↓
[Support Serialization]
    → Support Trace T = [(action_i, object_i, state_i, time_i), ...]
    ↓
[Support Sufficiency Verifier (SSV)]
    → s(Q, A_k, T) for each candidate
    → evidence_mask for attribution
    ↓
if max_k s(Q, A_k, T) < τ:
    → Output: <ABSTAIN> + evidence_mask
else:
    → Output: A* = argmax_k s(Q, A_k, T) + evidence_mask
```

### Core Mechanism: Support Sufficiency Verifier (SSV)

#### Input Interface

- **Question Q**: 自然语言问题
- **Candidate Answer A**: 从 VideoLLaMA-2 生成的候选答案
- **Support Trace T**: 序列化的支持证据
  ```python
  T = [
    ("cut", "tomato", "sliced", "0:15-0:20"),
    ("place", "tomato", "on_plate", "0:21-0:25"),
    ...
  ]
  ```

#### Architecture

```python
class SupportSufficiencyVerifier(nn.Module):
    def __init__(self, hidden_dim=768):
        self.encoder = TransformerEncoder(hidden_dim)  # 共享编码器
        self.sufficiency_head = nn.Linear(hidden_dim, 1)  # 充分性分数
        self.attribution_head = nn.Linear(hidden_dim, 1)  # 证据掩码
        
    def forward(self, Q, A, T):
        # 序列化输入
        input_text = f"Question: {Q} Answer: {A} Evidence: {format_trace(T)}"
        h = self.encoder(input_text)  # [batch, seq_len, hidden_dim]
        
        # 充分性分数
        s = self.sufficiency_head(h[:, 0, :])  # [batch, 1] - 使用 [CLS] token
        
        # 证据归因（可选）
        mask = self.attribution_head(h)  # [batch, seq_len, 1]
        
        return s, mask
```

#### Output

- **s(Q, A, T)**: 支持充分性分数 ∈ [0, 1]
- **evidence_mask**: 每个证据片段的贡献权重（用于 attribution）

#### Training Objective

```
L = L_rank + λ L_abstain + β L_attr

L_rank: max(0, margin - s(pos) + s(neg))  # Ranking loss
L_abstain: BCE(s, label)  # Abstention prediction
L_attr: BCE(mask, human_annotated_mask)  # Evidence attribution (小规模监督)
```

#### Training Data Construction

- **Positive samples**: 
  - 真实 QA 对，标注为 support sufficient
  - 来源：Ego4D/COIN 原始标注

- **Negative samples (Hard negatives)**:
  - 离线 MECG 生成：移除/替换关键证据片段
  - 标注为 support insufficient
  - 必须满足：答案翻转（通过自动验证）

### Offline MECG (Hard-Negative Mining)

MECG 不再是可训练组件，改为预处理阶段：

```python
def offline_mecg(support_trace, original_answer, flip_verification):
    hard_negatives = []
    for edge in critical_edges(support_trace):
        # 最小编辑：移除或替换单个证据
        edited_trace = remove_edge(support_trace, edge)
        
        # 验证答案翻转
        if flip_verification(edited_trace) != original_answer:
            hard_negatives.append(edited_trace)
    
    return hard_negatives
```

### Inference Path

1. VideoLLaMA-2 生成 K 个候选答案
2. 提取 evidence spans（基于 attention weights）
3. 序列化为 support trace
4. SSV 为每个候选打分
5. 输出最高分答案或 <ABSTAIN>

### Why the Mechanism Stays Small

- **一个可训练组件**: SSV
- **一个训练目标**: Support sufficiency + Abstention
- **一个推理路径**: Candidate → Score → Output/Abstain
- **所有其他组件冻结或离线**: VideoLLaMA-2, MECG

---

## Claim-Driven Validation Sketch

### Claim 1: SSV reduces hallucination via abstention

- **Minimal experiment**:
  - 数据集：COIN + Ego4D 子集
  - 比较：VideoLLaMA-2 baseline vs VideoLLaMA-2 + SSV
  - 指标：Hallucination rate, Evidence F1, Abstention calibration

- **Expected evidence**:
  - 幻觉率绝对下降 >10%
  - Abstention calibration > 0.8

### Claim 2: Minimal-edit hard negatives enable effective abstention learning

- **Minimal experiment**:
  - 比较：Random negatives vs Minimal-edit negatives vs No negatives
  - 指标：Abstention accuracy, Hallucination reduction

- **Expected evidence**:
  - Minimal-edit negatives 效果最好
  - 证明 hard-negative quality 的重要性

### Claim 3: Evidence attribution improves interpretability

- **Minimal experiment**:
  - 在小规模验证集（200-300 QA）上评估
  - 指标：Attribution F1, Human evaluation

- **Expected evidence**:
  - Attribution F1 > 0.7
  - 人工评估证明可解释性

---

## Experiment Handoff Inputs

- **Must-prove claims**:
  1. SSV reduces hallucination via abstention
  2. Minimal-edit hard negatives enable effective learning

- **Must-run ablations**:
  1. SSV vs No SSV (baseline)
  2. Minimal-edit vs Random negatives
  3. With vs Without L_attr (attribution head)

- **Critical datasets / metrics**:
  - Datasets: COIN, Ego4D (curated subset)
  - Metrics: Hallucination rate, Evidence F1, Abstention calibration

- **Highest-risk assumptions**:
  1. Evidence span extraction quality（需要验证）
  2. Hard negative quality（需要人工验证子集）

---

## Compute & Timeline Estimate

- **Estimated GPU-hours**: 24-32 GPU hours（3-4 GPU 天）
- **Data / annotation cost**: 低-中（小规模验证集标注）
- **Timeline**:
  - 实现：1 周
  - 实验：1-2 周
  - 分析：1 周

---

## Novelty and Elegance Argument

- **Closest work**:
  - HyperGLM: 图表示学习，无 support insufficiency 判断
  - SCC: 状态变化反事实，非 evidence-level abstention
  - Reliable VQA: Abstention，但非基于 support trace

- **Exact difference**:
  - 首个将 **support trace serialization + sufficiency verification** 作为 **abstention signal** 的方法
  - 单一 Transformer verifier（非 GNN 管道）
  - Ranking + Abstention + Attribution 联合训练

- **Why this is focused**:
  - 一个核心机制：Support Sufficiency Verifier
  - 一个训练目标：Abstention when support insufficient
  - 简化的架构：无符号管道，无多模块融合