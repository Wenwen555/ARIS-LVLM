# Round 2 Review

**Date**: 2026-04-02
**Reviewer**: Codex MCP
**ThreadId**: 019d4c78-936b-7a32-b850-6a7ca40d22d5

## Raw Review

<details>
<summary>Full raw response</summary>

## Re-scores (1–10)

1. **Problem Fidelity**: **9**  
2. **Method Specificity**: **7**  
3. **Contribution Quality**: **8**  
4. **Frontier Leverage**: **7**  
5. **Feasibility**: **7**  
6. **Validation Focus**: **6**  
7. **Venue Readiness**: **6**

**OVERALL SCORE (weighted toward 1/2/3/4): 7.6 / 10**

---

## Anchor / scope checks you asked for

- **Problem Anchor preserved or drifted?** Preserved. This is still “procedural long-video QA hallucination → evidence entitlement → abstain,” without sliding into parser/graph construction.
- **Dominant contribution sharper or still too broad?** Sharper. It now reads like a verifier paper (answer-conditioned evidence sufficiency + calibrated abstention) rather than “structure + training + scaling” sprawl.
- **Method simpler or still overbuilt?** Simpler and close to minimal: retrieve `E_K` → score `Sθ(q,a,E_K,m)` → abstain. The only remaining “extra” is the macro cue `m`; it’s fine if kept strictly optional/ablative.
- **Frontier leverage appropriate or forced/old-school?** Appropriate. Frozen backbone + selective prediction + evidence citation is modern and natural; no trendy add-ons are being forced.
- **Remaining critiques focus (mechanism / weak supervision / integration / pseudo-novelty / complexity):** Main remaining gap is **evaluation + supervision validity**: how you operationalize “unsupported” at scale, and how you avoid **confirmation bias / circularity** in evidence-dropout and answer-conditioned retrieval.

---

## Issues (only dimensions < 7)

### 6) Validation Focus (6)
- **Weakness**: The core claim is “reduces unsupported answers because of evidence entitlement,” but the proposal still under-specifies *the measurement protocol* for “unsupported-answer rate” beyond the small clean subset. If the only high-precision measurement is a few hundred examples, reviewers may read the rest as indirect.
- **Concrete method-level fix**:
  - Define one primary, auditable target: **Evidence-Entitlement Accuracy (EEA)** on a human-verified set where annotators see `(q, a, timestamps)` and judge “entitled / not entitled.” Make this the *main* claim metric.
  - Use risk–coverage and false-abstain **on that same EEA set** as the central selective-prediction figure, then optionally report broader weak/automatic metrics separately as “scaling signal,” not proof.
  - For “unsupported-answer rate” outside the EEA set: explicitly label it as **proxy** (e.g., model-graded is not acceptable as primary evidence unless validated against EEA).
- **Priority**: **P0** (this is the main remaining blocker to a clean causal story).

### 7) Venue Readiness (6)
- **Weakness**: Two plausibility attacks a top-venue reviewer will make:
  1) **Post-hoc evidence / confirmation bias**: answer-conditioned retrieval can “find something that sounds supportive,” and the verifier may just learn answer–evidence textual compatibility rather than true video grounding.  
  2) **Self-fulfilling counterfactuals**: evidence-dropout adversary uses the model’s own scoring to generate negatives, risking circular supervision that doesn’t transfer.
- **Concrete method-level fix**:
  - Add one tight diagnostic that directly targets confirmation bias: **swap test**—keep `E_K` fixed, swap in a competing answer `a'` (wrong but plausible), require `Sθ(q,a',E_K)` to drop. This is mechanism-level and doesn’t expand scope.
  - Make evidence-dropout less circular by basing removal on **retriever attribution** (or a frozen similarity scorer) rather than verifier score alone, and report how often dropout negatives fool a *held-out* verifier.
- **Priority**: **P0–P1** (not fatal, but reviewers will hammer this unless pre-empted).

---

## Simplification Opportunities
1. **Make `m` strictly optional**: present the main method as `Sθ(q,a,E_K)`; treat `+m` as a single ablation line item (“stage-confusable questions only”).  
2. **Drop object/action tags unless necessary**: they risk becoming a stealth parser subsystem; keep only timestamps + frozen clip embeddings.

---

## Modernization Opportunities (natural, not trendy)
1. Calibrate abstention with a **selective prediction / risk-control** framing (e.g., threshold chosen to satisfy a target risk on EEA). This strengthens the “not generic confidence” claim while staying minimal.  
2. Train the verifier with a **contrastive objective over (q,a,E)** triples (your ranking loss is already close)—explicitly emphasize “same evidence, different answer” negatives as the modern grounding pressure.

---

## Drift Warning
**NONE**, as currently written—provided you do not let “macro stage cue” expand into a new alignment/parser contribution.

---

## Verdict
**REVISE**

You did the right simplifications and now have a coherent dominant contribution. To get this over the line, lock down (i) a defensible primary evaluation target (EEA + risk–coverage on human-verified evidence entitlement), and (ii) one mechanism-level control that neutralizes the “post-hoc evidence / circular negatives” critique without adding modules.

</details>
