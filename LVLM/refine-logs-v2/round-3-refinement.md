# Round 3 Refinement (Final)

## Changes Made

### 1. Answer-Conditioned Grounding (CRITICAL)

**Issue**: Grounding must be conditioned on `(Q, A)` to properly test support sufficiency.

**Fix**:
```python
# 旧方案
segments = TemporalGrounding.retrieve(video, Q)  # 仅问题条件

# 新方案
segments = TemporalGrounding.retrieve(video, Q, A)  # 问题+答案条件
```

**Implementation**:
```python
class AnswerConditionedGrounding(nn.Module):
    """答案条件的时序定位模块"""
    
    def __init__(self):
        self.query_encoder = TransformerEncoder()
        self.video_encoder = FrozenVideoEncoder()
        self.temporal_attention = TemporalAttention()
        
    def forward(self, video, Q, A):
        # 编码查询 = 问题 + 候选答案
        query = f"{Q} [SEP] {A}"
        h_query = self.query_encoder(query)
        
        # 视频特征
        h_video = self.video_encoder(video)
        
        # 时序注意力 → 相关段
        segment_scores = self.temporal_attention(h_query, h_video)
        segments = top_k_segments(segment_scores, k=5)
        
        return segments, segment_scores
```

### 2. Operational Definition of Minimal Evidence Set (CRITICAL)

**Issue**: `has_minimal_evidence()` needs concrete definition.

**Fix**: Two-tier definition:

```python
def has_minimal_evidence(segments, Q, data_type):
    """检查是否包含最小证据集"""
    
    if data_type == "clean":
        # 在人工验证子集上：使用人工标注的关键段
        return all(
            segment in segments 
            for segment in human_marked_indispensable[Q]
        )
    else:
        # 在弱监督数据上：使用代理定义
        # 代理：至少覆盖问题中的所有关键动作/对象
        required_entities = extract_required_entities(Q)
        covered_entities = set()
        for seg in segments:
            covered_entities.update(seg.entities)
        return required_entities <= covered_entities
```

**Clean Subset Protocol**:
- 200-300 QA 对
- 人工标注每个问题的"不可或缺段"（indispensable segments）
- MECG 在这些段上进行最小删除

**Weak Data Protocol**:
- 使用实体覆盖作为代理
- 标记为 weak negatives（非 clean negatives）

### 3. Threshold Calibration (IMPORTANT)

```python
def calibrate_threshold(SSV, val_clean_split, target_abstention_rate=0.3):
    """在干净验证集上校准阈值"""
    scores = []
    labels = []
    
    for Q, A, segments, label in val_clean_split:
        s, _ = SSV(Q, A, segments)
        scores.append(s)
        labels.append(label)
    
    # 找到满足目标 abstention 率的阈值
    τ = find_threshold(scores, labels, target_abstention_rate)
    return τ
```

### 4. Attribution Alignment (IMPORTANT)

```python
# 训练：segment-level scores
segment_scores = SSV.segment_scorer(h_cross[:, 1:, :])

# 评估：segment-level F1
def evaluate_attribution(segment_scores, human_segments):
    pred_segments = top_k(segment_scores, k=5)
    true_segments = human_segments
    
    precision = len(pred ∩ true) / len(pred)
    recall = len(pred ∩ true) / len(true)
    f1 = 2 * precision * recall / (precision + recall)
    return f1
```

### 5. Key Ablation (IMPORTANT)

| Ablation | Description | Purpose |
|----------|-------------|---------|
| **Random vs Minimal** | 随机删除段 vs 最小支持破坏 | 证明 minimal corruption 的必要性 |

---

## Final Proposal Summary

### Core Method

```
Input: Video V, Question Q
    ↓
[VideoLLaMA-2] → Candidate Answer A
    ↓
[Answer-Conditioned Grounding] → Evidence Segments {S_i}
    ↓
[Support Sufficiency Verifier] → s(Q, A, {S_i}) + segment_scores
    ↓
if s < τ: Output <ABSTAIN>
else: Output A
```

### Training

- **Clean positives**: Human-verified support-sufficient (weight=1.0)
- **Weak positives**: Remaining real QA (weight=0.3)
- **Clean negatives**: MECG on human-marked indispensable segments
- **Weak negatives**: MECG on entity-coverage proxy

### Key Contributions

1. **Answer-Conditioned Evidence Grounding**: 首个将候选答案纳入证据检索条件的 Video QA 方法
2. **Minimal Support Corruption Training**: 通过最小支持破坏生成 insufficiency 监督信号
3. **Abstention via Support Insufficiency**: 基于视觉证据充分性的拒绝回答机制

### Novelty Statement

> Support-sufficiency verification trained with minimal support corruption for abstention in procedural video QA, where:
> 1. Evidence is answer-conditioned, breaking self-justification loops
> 2. Insufficiency supervision comes from minimal support corruption
> 3. Abstention is triggered by verified support insufficiency

---

## Score History

| Round | Overall | Verdict | Key Issues |
|-------|---------|---------|------------|
| 1 | 6.3 | REVISE | Method specificity, Symbolic pipeline |
| 2 | 7.4 | REVISE | Self-justification loop, Training signal |
| 3 | 8.2 | REVISE | Grounding interface, Minimal evidence definition |
| Target | ≥9.0 | READY | — |