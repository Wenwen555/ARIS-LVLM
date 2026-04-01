# Round 2 Refinement

## Problem Anchor

（与上文相同，略）

---

## Anchor Check

- **Original bottleneck**: Video-LLM 生成无证据支持的答案，且无法拒绝回答
- **Why the revised method still addresses it**: 新方法仍然聚焦于判断答案是否有足够的视觉证据支持
- **Proxy-drift mitigation**: 证据来自视频编码器的时序段检索，而非 Video-LLM 自我生成的文本

---

## Simplicity Check

- **Dominant contribution**: Support Sufficiency Verifier + Minimal Support Corruption Training
- **Components further simplified**:
  - 删除 "answer flip" 验证要求
  - Attribution 改为 segment-level
  - 推理路径简化为 top-1 → verify/abstain

---

## Changes Made

### 1. Decouple Evidence from Answer Generation (CRITICAL)

**Reviewer said**: "Self-produced evidence is a weak integration point. The same model can hallucinate both the answer and the evidence trace."

**Action**: 
- 证据来源改为 **视频编码器的时序段检索**
- 使用预训练的 temporal grounding 模块（如 Moment-DETR）检索相关视频段
- VideoLLaMA-2 仅生成候选答案，不生成 evidence trace

**Implementation**:
```python
# 旧方案（有自我循环风险）
evidence_spans = VideoLLaMA.attention(video, Q, A)  # 同一模型生成

# 新方案（解耦）
evidence_segments = TemporalGroundingModule.retrieve(video, Q)  # 独立模块
support_trace = build_trace(evidence_segments)  # 基于视觉证据
```

### 2. Redefine Positive Labels (CRITICAL)

**Reviewer said**: "Real QA pair = support sufficient is not a safe assumption. Some answers are correct but only weakly grounded."

**Action**:
- **Clean positives**: 200-300 人工验证的支持充分样本
- **Weak positives**: 其余真实 QA 对，使用 lower weight
- **Negatives**: MECG 生成的 support-insufficient 样本

**Training strategy**:
```python
# 双层监督
L_clean = L_rank(clean_pos, negs) + L_abstain(clean_pos, negs)
L_weak = λ_weak * L_rank(weak_pos, negs)  # lower weight
L_total = L_clean + L_weak
```

### 3. Specify MECG Validation Exactly (CRITICAL)

**Reviewer said**: "Verify answer flip is too vague. You only need a trustworthy 'support destroyed / insufficient' label."

**Action**:
- 删除 "answer flip" 要求
- MECG 只需验证 **minimal evidence set 被破坏**
- 标签直接为 "support insufficient"

**New MECG Algorithm**:
```python
def offline_mecg(support_trace):
    hard_negatives = []
    for segment in support_trace:
        # 移除单个关键证据段
        edited_trace = remove_segment(support_trace, segment)
        
        # 验证 minimal evidence set 被破坏
        if not has_minimal_evidence(edited_trace):
            hard_negatives.append((edited_trace, label="insufficient"))
    
    return hard_negatives

def has_minimal_evidence(trace):
    # 检查是否包含问题所需的最小证据集
    # 例如："cut tomato" 需要至少一个 cut 动作段
    return check_evidence_coverage(trace)
```

### 4. Segment-Level Attribution (IMPORTANT)

**Reviewer said**: "Make attribution segment-level, not token-level."

**Action**:
```python
class SupportSufficiencyVerifier(nn.Module):
    def __init__(self):
        self.encoder = TransformerEncoder()
        self.sufficiency_head = nn.Linear(hidden_dim, 1)
        self.segment_scorer = nn.Linear(hidden_dim, 1)  # segment-level
        
    def forward(self, Q, A, segments):
        # segments: [(segment_emb, timestamp), ...]
        h = self.encoder(Q, A, segments)
        s = self.sufficiency_head(h[:, 0, :])
        segment_scores = self.segment_scorer(h[:, 1:, :])  # 每个段的贡献
        return s, segment_scores
```

### 5. Simplified Inference Path (IMPORTANT)

**Reviewer said**: "Consider simpler top-1 answer → verify or abstain path."

**Action**:
```python
def inference(video, Q):
    # 生成单个候选答案
    A = VideoLLaMA.generate(video, Q, top_k=1)
    
    # 检索证据段
    segments = TemporalGrounding.retrieve(video, Q)
    
    # 验证支持充分性
    s, segment_scores = SSV(Q, A, segments)
    
    if s < τ:
        return "<ABSTAIN>", segment_scores
    else:
        return A, segment_scores
```

### 6. Cross-Attention over Visual Features (MODERNIZATION)

**Reviewer said**: "Cross-attention over frozen visual segment features would be a more natural FM-era grounding interface."

**Action**:
```python
class SupportSufficiencyVerifier(nn.Module):
    def __init__(self):
        self.text_encoder = TransformerEncoder()  # Q, A
        self.cross_attention = CrossAttention()   # text ↔ visual segments
        self.sufficiency_head = nn.Linear(hidden_dim, 1)
        
    def forward(self, Q, A, visual_segments):
        h_text = self.text_encoder(Q, A)
        h_cross = self.cross_attention(h_text, visual_segments)
        s = self.sufficiency_head(h_cross[:, 0, :])
        return s
```

---

## Revised Proposal

# Research Proposal: Support Sufficiency Verifier with Visual Evidence Grounding

## Problem Anchor

（与上文相同）

## Method Thesis

通过一个支持充分性判断器（SSV），基于 **视频编码器检索的视觉证据段** 判断候选答案是否有足够支持，并学习在证据不足时拒绝回答。

## Key Differentiators from Previous Version

| 维度 | Round 1 | Round 2 (Current) |
|------|---------|-------------------|
| Evidence 来源 | VideoLLaMA self-attention | **独立 Temporal Grounding 模块** |
| Positive labels | 所有真实 QA | **人工验证子集 + 弱监督** |
| MECG validation | Answer flip | **Minimal evidence set destroyed** |
| Attribution | Token-level | **Segment-level** |
| Inference | K candidates | **Top-1 verify/abstain** |

## Proposed Method

### Architecture

```
输入视频 V + 问题 Q
    ↓
[VideoLLaMA-2] → 候选答案 A (top-1)
    ↓
[Temporal Grounding Module] → 证据段 {S_1, ..., S_M}
    ↓
[Support Sufficiency Verifier]
    → s(Q, A, {S_i}) 充分性分数
    → {α_i} 每段的贡献权重
    ↓
if s < τ: Output <ABSTAIN> + {α_i}
else: Output A + {α_i}
```

### Components

**Frozen**:
- VideoLLaMA-2: 候选答案生成
- Temporal Grounding Module: 证据段检索

**Trainable**:
- Support Sufficiency Verifier (SSV): 单一跨模态验证器

### SSV Architecture

```python
class SupportSufficiencyVerifier(nn.Module):
    """基于视觉证据段的支持充分性验证器"""
    
    def __init__(self, hidden_dim=768):
        self.text_encoder = TransformerEncoder(hidden_dim)
        self.cross_attention = CrossAttention(hidden_dim)
        self.sufficiency_head = nn.Linear(hidden_dim, 1)
        self.segment_scorer = nn.Linear(hidden_dim, 1)
        
    def forward(self, Q, A, visual_segments):
        """
        Args:
            Q: 问题文本
            A: 候选答案文本
            visual_segments: [(segment_embedding, timestamp), ...]
        
        Returns:
            s: 支持充分性分数
            segment_scores: 每个证据段的贡献权重
        """
        h_text = self.text_encoder(Q, A)  # [batch, seq_len, hidden]
        h_cross = self.cross_attention(h_text, visual_segments)
        
        s = torch.sigmoid(self.sufficiency_head(h_cross[:, 0, :]))
        segment_scores = self.segment_scorer(h_cross[:, 1:, :])
        
        return s, segment_scores
```

### Training Objective

```
L = L_rank + λ L_abstain + β L_attr

L_rank: max(0, margin - s(pos) + s(neg))  # Ranking loss
L_abstain: BCE(s, label)  # Abstention prediction
L_attr: MSE(segment_scores, human_scores)  # Evidence attribution

Positive samples:
  - Clean: 人工验证的支持充分样本 (weight=1.0)
  - Weak: 其余真实 QA (weight=0.3)

Negative samples:
  - MECG 生成的 support-insufficient 样本
```

### MECG (Offline Hard-Negative Mining)

```python
def offline_mecg(evidence_segments, Q):
    """生成 support-insufficient 负样本"""
    hard_negatives = []
    
    for segment in evidence_segments:
        # 最小编辑：移除单个证据段
        edited_segments = remove(evidence_segments, segment)
        
        # 验证：minimal evidence set 被破坏
        if not has_minimal_evidence(edited_segments, Q):
            hard_negatives.append({
                'segments': edited_segments,
                'label': 'insufficient'
            })
    
    return hard_negatives

def has_minimal_evidence(segments, Q):
    """检查是否包含问题所需的最小证据集"""
    required = get_required_evidence(Q)  # 基于 Q 分析所需证据类型
    return all(r in segments for r in required)
```

### Inference

```python
def inference(video, Q, SSV, τ=0.5):
    # 生成候选答案
    A = VideoLLaMA.generate(video, Q, top_k=1)
    
    # 检索证据段
    segments = TemporalGrounding.retrieve(video, Q, top_k=5)
    
    # 验证支持充分性
    s, segment_scores = SSV(Q, A, segments)
    
    if s < τ:
        return {
            'answer': '<ABSTAIN>',
            'reason': 'Insufficient visual evidence',
            'evidence': segment_scores
        }
    else:
        return {
            'answer': A,
            'confidence': s,
            'evidence': segment_scores
        }
```

---

## Claim-Driven Validation

### Claim 1: SSV reduces hallucination via abstention

- **Experiment**: COIN + Ego4D subset
- **Comparison**: VideoLLaMA-2 baseline vs + SSV
- **Metrics**: Hallucination rate ↓, Abstention calibration

### Claim 2: Minimal support corruption training is effective

- **Ablation**: Random negatives vs Minimal-edit negatives
- **Metric**: Abstention accuracy

### Claim 3: Visual evidence grounding enables accurate attribution

- **Experiment**: 200-300 human-verified subset
- **Metric**: Segment-level attribution F1

---

## Novelty Statement

**Not**: "A verifier for video QA"

**Is**: "Support-sufficiency verification trained with minimal support corruption for abstention under procedural-video evidence insufficiency"

**Key differentiators**:
1. Evidence 来自独立视觉检索，非模型自我生成
2. Minimal support corruption 负样本生成
3. Segment-level attribution + Abstention 联合训练

---

## Compute & Timeline

- **GPU-hours**: 24-32 (3-4 GPU days)
- **Timeline**: 4 weeks (implementation + experiments + analysis)