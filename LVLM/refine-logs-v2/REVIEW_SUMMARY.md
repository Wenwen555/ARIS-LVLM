# Review Summary

**Problem**: Video-LLM 幻觉问题 - 生成无视觉证据支持的内容且无法拒绝回答
**Initial Approach**: MT-MG 联合表示 + 意图驱动稀疏化
**Date**: 2026-03-31
**Rounds**: 4 / 5 (MAX_ROUNDS)
**Final Score**: 8.5 / 10
**Final Verdict**: REVISE (Close to READY)

---

## Problem Anchor

- **Bottom-line problem**: Video-LLMs 在长视频程序性理解中生成缺乏视觉证据支持的内容（幻觉），且无法识别何时应该拒绝回答。
- **Must-solve bottleneck**: 证据脱节、先验绑架、拒绝机制缺失
- **Success condition**: 幻觉率下降 >10%，Evidence F1 > 0.7，Abstention calibration > 0.8

---

## Round-by-Round Resolution Log

| Round | Main Concerns | What Changed | Solved? |
|-------|---------------|--------------|---------|
| 1 | Method specificity (5/10), Symbolic pipeline, Feasibility | Replaced GNN with Transformer verifier, Deleted GPT-4/EASG, Made MECG offline | Partial |
| 2 | Self-justification loop, Training signal, MECG validation | Decoupled evidence from answer gen, Redefined positive labels, Removed answer flip | Partial |
| 3 | Grounding interface, Minimal evidence definition | Answer-conditioned grounding, Two-tier minimal evidence definition | Partial |
| 4 | Weak proxy mismatch, Claim framing | Anchor claim on clean subset, Rename weak negatives | Partial |

---

## Method Evolution

### Round 1 → Round 2
- **Deleted**: GPT-4 API, EASG, GNN encoder, Multi-encoder fusion
- **Simplified**: Single Transformer verifier
- **Result**: Score 6.3 → 7.4

### Round 2 → Round 3
- **Decoupled**: Evidence from answer generation
- **Redefined**: Positive labels (clean + weak)
- **Specified**: MECG validation (minimal evidence set destroyed)
- **Result**: Score 7.4 → 8.2

### Round 3 → Round 4
- **Answer-conditioned**: Grounding on (Q, A)
- **Operationalized**: Minimal evidence set definition
- **Aligned**: Attribution and evaluation units
- **Result**: Score 8.2 → 8.5

---

## Final Method Architecture

```
VideoLLaMA-2 → A (candidate answer)
    ↓
AnswerConditionedGrounding(Q, A, V) → {S_i}
    ↓
SupportSufficiencyVerifier → s(Q, A, {S_i}) + segment_scores
    ↓
if s < τ: <ABSTAIN>
else: Output A
```

---

## Final Status

- **Anchor status**: Preserved
- **Focus status**: Tight (one mechanism)
- **Modernity status**: Appropriate foundation-model-era design

**Strongest parts**:
1. Self-justification loop genuinely broken
2. Training signal cleanly operationalized
3. Single defensible mechanism-level claim

**Remaining weaknesses**:
1. Weak proxy (entity coverage) may not capture true support
2. Novelty needs careful framing as training mechanism contribution

---

## Key Differentiator from Prior Work

| Prior Work | Our Method |
|------------|------------|
| HyperGLM: Graph representation learning | **Support insufficiency detection** |
| SCC: State-level counterfactuals | **Minimal support corruption** |
| Reliable VQA: Confidence-based abstention | **Evidence-conditioned abstention** |

---

## Suggested Next Steps

1. Implement SSV and MECG
2. Create clean human-verified subset (200-300 QA)
3. Run ablation: generic verifier vs minimal corruption
4. Validate on COIN + Ego4D subset