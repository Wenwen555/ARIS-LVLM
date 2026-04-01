# Round 1 Review

**Date**: 2026-03-31
**Model**: GPT-5.4 (xhigh reasoning)
**ThreadId**: 019d4203-d2aa-7693-9657-e823fa7665ab

## Overall Score: 6.3/10

## Dimension Scores

| Dimension | Score | Status |
|-----------|-------|--------|
| Problem Fidelity | 7/10 | PASS |
| Method Specificity | 5/10 | ❌ CRITICAL |
| Contribution Quality | 7/10 | PASS |
| Frontier Leverage | 6/10 | ❌ IMPORTANT |
| Feasibility | 6/10 | ❌ CRITICAL |
| Validation Focus | 8/10 | PASS |
| Venue Readiness | 7/10 | PASS |

## Verdict: REVISE

---

## Key Issues

### 1. Method Specificity (5/10) - CRITICAL

**Weakness**: The method lacks implementable interfaces. `G_support` is undefined; candidate answer generation is undefined; "verify answer flip" is undefined; "state-change prior verification" is undefined; abstention is described as a score threshold but not as a trained behavior.

**Concrete fix**: Specify one exact end-to-end recipe:
1. Build a question-conditioned support graph over top-`M` temporal segments, not the whole video.
2. Define node types explicitly: `action`, `object-state`, `tool/object`, `segment`; define edge types: `before`, `enables`, `acts_on`, `changes_state`.
3. Generate `K` candidate answers from the frozen Video-LLM.
4. Let SID output two heads: a sufficiency score `s(Q,A,G)` and an evidence-node mask.
5. Make MECG an offline perturbation procedure: remove or swap one critical edge/node.
6. Train with `L = L_rank + λ L_abstain + β L_attr`.
7. At inference, choose the candidate answer with highest sufficiency score; if `max s < τ`, output `<ABSTAIN>`.

### 2. Frontier Leverage (6/10) - IMPORTANT

**Weakness**: The proposal uses foundation models, but mostly as frozen utilities wrapped by a symbolic pipeline. `GPT-4 API + EASG + GNN + fusion MLP` is not yet a clearly justified 2026 design.

**Concrete fix**: Either simplify to a more FM-native verifier or justify the symbolic choice much more tightly:
- Frozen Video-LLM proposes candidate answers and evidence spans.
- Serialize the support trace as structured tuples or short natural-language facts.
- Use a single transformer/LM verifier over `(Q, A, support trace)` to score sufficiency and abstention.
- Keep MECG only as hard-negative generation.

### 3. Feasibility (6/10) - CRITICAL

**Weakness**: The current plan likely underestimates preprocessing and evaluation cost. Long-video scene graph quality is shaky; counterfactual answer-flip checking is nontrivial; a new benchmark is expensive; GPT-4 in the loop hurts reproducibility.

**Concrete fix**: Cut scope hard:
- Use one backbone, not multiple.
- Start with `COIN` plus a curated `Ego4D` subset.
- Use existing step/action annotations as initial support nodes.
- Make MECG fully offline and local to support subgraphs.
- Replace benchmark with a small human-verified evaluation subset.

---

## Simplification Opportunities

1. Recast `MECG` as an **offline hard-negative miner**, not a trainable component.
2. **Delete `GPT-4 API`** macro parsing from the core method.
3. Do not make the benchmark a headline contribution.

## Modernization Opportunities

1. Replace `GNN + text encoder + attention fusion + MLP` with a **single transformer-style verifier** over serialized support tuples.
2. Use **question-conditioned evidence spans** from frozen Video-LLM as primary support units.
3. Add **explicit `<ABSTAIN>` supervision** on insufficient-support examples.

## Drift Warning

**NONE** - The proposal still targets the anchored problem.

---

## Topline Assessment

> This is a promising direction, mainly because it stays close to the actual bottleneck: unsupported answers in procedural video QA, and the missing ability to abstain when evidence is insufficient. The strongest part is the idea of using minimal counterfactual support edits to create hard insufficiency examples.
>
> The current proposal is not yet at top-venue method sharpness. The main issue is not lack of ambition; it is that the method is still specified at the slogan level, and the pipeline is more symbolically stacked than it needs to be. The best version of this paper is a single support-sufficiency verifier plus abstention mechanism on top of a frozen Video-LLM, with MECG used only as hard-negative synthesis.

---

## Target Paper

The paper the reviewer wants to see:

> One frozen Video-LLM, one question-conditioned support representation, one sufficiency/abstention verifier, MECG only as hard-negative synthesis, and a small verified attribution set. That is focused, defensible, and much more likely to clear a top-venue bar.