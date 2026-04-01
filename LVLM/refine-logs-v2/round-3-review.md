# Round 3 Review

**Date**: 2026-03-31
**Model**: GPT-5.4 (xhigh reasoning)
**ThreadId**: 019d4203-d2aa-7693-9657-e823fa7665ab

## Overall Score: 8.2/10 (↑ from 7.4)

## Dimension Scores

| Dimension | Score | Change |
|-----------|-------|--------|
| Problem Fidelity | 9/10 | ↑1 |
| Method Specificity | 8/10 | ↑1 |
| Contribution Quality | 8/10 | ↑1 |
| Frontier Leverage | 8/10 | ↑1 |
| Feasibility | 8/10 | — |
| Validation Focus | 9/10 | ↑1 |
| Venue Readiness | 8/10 | ↑1 |

## Verdict: REVISE

---

## Why This Works Better

> The proposal now attacks the right failure mode with the right granularity:
> - unsupported answer generation,
> - evidence-conditioned verification,
> - explicit abstention,
> - minimal support corruption for insufficiency supervision.
>
> That is a coherent modern paper shape.

---

## Remaining Concerns

### CRITICAL

1. **Grounding interface underspecified**: Need to state whether temporal grounding is conditioned on `Q` only or `(Q, A)`. Should be `(Q, A)` for support sufficiency checking.

2. **Minimal evidence set needs operational definition**: `has_minimal_evidence(edited, Q)` needs concrete definition. On clean subset: human-marked indispensable segments. On weak data: separate weak label.

### IMPORTANT

3. **Threshold τ calibration**: Should be calibrated on held-out clean split with fixed risk-coverage target.

4. **Attribution alignment**: Score and evaluate at same unit (retrieved segments).

5. **Decisive ablation needed**: Random deletion vs minimal support corruption.

---

## Action Items

| Priority | Item | Action |
|----------|------|--------|
| CRITICAL | Answer-conditioned grounding | `TemporalGrounding(Q, A, V) → {S_i}` |
| CRITICAL | Minimal evidence set definition | Human-marked on clean subset, surrogate on weak data |
| IMPORTANT | τ calibration | Fixed on held-out clean split |
| IMPORTANT | Attribution alignment | Segment-level for both training and eval |
| IMPORTANT | Key ablation | Random vs minimal corruption |

---

## Self-Justification Loop Status

> **Mostly broken now.** Evidence no longer comes from the answer generator's own rationale path, and the verifier consumes independently grounded visual segments.

**Residual caveat**: This only fully holds if grounding is conditioned on `(Q, A)`.

---

## Novelty Status

> Sharper. The paper now has a single defensible mechanism-level claim:
> `support-sufficiency verification trained with minimal support corruption for abstention in procedural video QA`

**Pseudo-novelty risk reduced but not gone**: Writing must center on training mechanism, not just presence of verifier.