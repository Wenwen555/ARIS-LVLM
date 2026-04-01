# Final Proposal: Support Sufficiency Verifier for Video-LLM Abstention

**Version**: Refined through 4 rounds of GPT-5.4 review
**Date**: 2026-03-31
**Final Score**: 8.5/10

---

## Problem Anchor

- **Bottom-line problem**: Video-LLMs 在长视频程序性理解中生成缺乏视觉证据支持的内容（幻觉），且无法识别何时应该拒绝回答。

- **Must-solve bottleneck**:
  1. **证据脱节**: 生成的回答无法追溯到具体的视觉证据
  2. **先验绑架**: 语言模型先验覆盖了视觉观察
  3. **拒绝机制缺失**: 模型没有学会在证据不足时"闭嘴"（abstention）

- **Non-goals**:
  - 不是设计新的 Video-LLM 架构
  - 不是提出新的场景图解析算法
  - 不是做通用的视频理解（收窄到程序性视频）

- **Constraints**:
  - 计算资源：4-8 GPU 天
  - 数据集：Ego4D、COIN（程序性视频）
  - 目标会议：NeurIPS/ICML/ICLR

- **Success condition**:
  - 幻觉率绝对下降 >10%
  - Evidence attribution F1 > 0.7
  - Abstention calibration > 0.8

---

## Method Thesis

通过一个支持充分性判断器（Support Sufficiency Verifier），基于 **答案条件的视觉证据段** 判断候选答案是否有足够支持，并通过 **最小支持破坏训练** 学习在证据不足时拒绝回答。

---

## Contribution Focus

### Dominant Contribution

**Support Sufficiency Verifier with Minimal Support Corruption Training**

- 首个将 support insufficiency 作为 abstention 信号的方法
- 答案条件的证据检索（打破自我循环）
- 最小支持破坏负样本生成

### Key Differentiators

| 维度 | 本研究 | 现有工作 |
|------|--------|----------|
| Evidence 来源 | 答案条件的独立检索 | 模型自注意力 / 问题条件 |
| Abstention 依据 | Support insufficiency | 置信度阈值 |
| 负样本生成 | 最小支持破坏 | 随机采样 / 状态变化 |

---

## Proposed Method

### Architecture

```
输入视频 V + 问题 Q
    ↓
[VideoLLaMA-2] → 候选答案 A (top-1)
    ↓
[Answer-Conditioned Grounding] → 证据段 {S_1, ..., S_K}
    ↓
[Support Sufficiency Verifier] → s(Q, A, {S_i}) + segment_scores
    ↓
if s < τ: Output <ABSTAIN> + segment_scores
else: Output A + segment_scores
```

### Components

#### 1. Answer-Conditioned Grounding

```python
class AnswerConditionedGrounding(nn.Module):
    def forward(self, video, Q, A):
        query = f"{Q} [SEP] {A}"
        h_query = self.query_encoder(query)
        h_video = self.video_encoder(video)
        segment_scores = self.temporal_attention(h_query, h_video)
        return top_k_segments(segment_scores, k=5)
```

#### 2. Support Sufficiency Verifier

```python
class SupportSufficiencyVerifier(nn.Module):
    def __init__(self):
        self.text_encoder = TransformerEncoder()
        self.cross_attention = CrossAttention()
        self.sufficiency_head = nn.Linear(hidden_dim, 1)
        self.segment_scorer = nn.Linear(hidden_dim, 1)
        
    def forward(self, Q, A, segments):
        h_text = self.text_encoder(Q, A)
        h_cross = self.cross_attention(h_text, segments)
        s = torch.sigmoid(self.sufficiency_head(h_cross[:, 0, :]))
        segment_scores = self.segment_scorer(h_cross[:, 1:, :])
        return s, segment_scores
```

### Training

#### Data

| 类型 | 来源 | 权重 |
|------|------|------|
| Clean positives | 人工验证的支持充分样本 | 1.0 |
| Weak positives | 其余真实 QA | 0.3 |
| Clean negatives | MECG（人工标注段） | 1.0 |
| Proxy negatives | MECG（实体覆盖代理） | 0.5 |

#### Loss

```
L = L_rank + λ L_abstain + β L_attr

L_rank: max(0, margin - s(pos) + s(neg))
L_abstain: BCE(s, label)
L_attr: MSE(segment_scores, human_scores)
```

### MECG (Minimal Evidence Corruption Generator)

```python
def offline_mecg(segments, Q, data_type):
    for segment in segments:
        edited = remove(segments, segment)
        
        if data_type == "clean":
            # 人工标注的关键段被删除
            if segment in human_marked_indispensable[Q]:
                yield (edited, "insufficient")
        else:
            # 代理：实体覆盖被破坏
            if not has_entity_coverage(edited, Q):
                yield (edited, "proxy-insufficient")
```

---

## Experiments

### Main Claims

1. **SSV reduces hallucination via abstention**
   - Dataset: COIN + Ego4D subset
   - Comparison: VideoLLaMA-2 vs + SSV
   - Metrics: Hallucination rate, Abstention calibration

2. **Minimal support corruption training is effective**
   - Ablation: Random deletion vs Minimal corruption
   - Metric: Abstention accuracy

3. **Evidence attribution is accurate**
   - Dataset: 200-300 human-verified subset
   - Metric: Segment-level F1

### Key Ablation

| Training | Abstention Acc | Hallucination ↓ |
|----------|----------------|-----------------|
| Random negatives | X% | Y% |
| Minimal corruption | X+5% | Y-10% |

---

## Novelty Statement

**Not**: "A verifier for video QA with abstention"

**Is**: "Support-sufficiency verification trained with minimal support corruption for abstention in procedural video QA, where:
1. Evidence is answer-conditioned (breaking self-justification loops)
2. Insufficiency supervision comes from verified minimal support destruction
3. Abstention is triggered by genuine support insufficiency"

---

## Compute & Timeline

- **GPU-hours**: 24-32 (3-4 GPU days)
- **Timeline**: 4 weeks
  - Week 1: Implementation
  - Week 2-3: Experiments
  - Week 4: Analysis

---

## References

- HyperGLM (CVPR 2025): HyperGraph for Video Scene Graph
- State-Change Counterfactuals (ICCV 2025): SCC for procedural videos
- Ego4D Goal-Step (NeurIPS 2023): Macro task structure
- EASG (CVPR 2024): Action Scene Graphs
- Reliable VQA (ECCV 2022): Abstention in VQA