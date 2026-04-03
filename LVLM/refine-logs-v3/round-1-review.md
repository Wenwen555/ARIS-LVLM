# Round 1 Review

**Date**: 2026-04-02
**Reviewer**: Codex MCP
**ThreadId**: 019d4c78-936b-7a32-b850-6a7ca40d22d5

## Raw Review

<details>
<summary>Full raw response</summary>

## Scores (1–10)

1. **Problem Fidelity**: **8**  
2. **Method Specificity**: **5**  
3. **Contribution Quality**: **6**  
4. **Frontier Leverage**: **6**  
5. **Feasibility**: **5**  
6. **Validation Focus**: **6**  
7. **Venue Readiness**: **5**

**OVERALL SCORE (weighted to 1/2/3/4): 6.2 / 10**

---

## Dimension-by-dimension issues (only for scores < 7)

### 2) Method Specificity (5)
- **Weakness**: The proposal formalizes many objects (`Macro-Tree`, `Micro-Graph`, `Ω(q,a)`, “minimal corruption”) without a concrete, implementable instantiation. Right now the core mechanism (“support sufficiency”) is described at the *interface* level, but not at the *construction + supervision* level.
- **Concrete method-level fix** (highest leverage): Collapse to an implementable definition of “support” with explicit data products:
  - Represent support as **K timestamped clips** + **optional short textual rationales**, not a full micro-graph.  
  - Define `S(q,a,V)` as **video→text entailment** over retrieved clips: `S = max_{clips} Eθ(clip, q, a)` or `S = aggregate(Eθ over K clips)` with a calibrated selective prediction head.
  - If you keep MT-MG: specify *exactly* how you build it (heuristics vs model-generated vs existing annotations), and what errors it introduces.
- **Priority**: **P0** (without this, it’s not a method yet).

### 3) Contribution Quality (6)
- **Weakness**: The “dominant contribution” is good, but the current mechanism stack (MT-MG + budgeted selection + minimal corruption + 4-term loss) still reads like contribution sprawl. Reviewers will ask: is the paper “a verifier” or “a graph framework + training recipe”?
- **Concrete fix**: Make the dominant contribution *one sentence narrower*:
  - “Answer-conditioned **evidence sufficiency verification** enabling abstention.”  
  Then demote everything else to *implementation details* with a clear minimal version:
  - v0: retrieve K clips → verifier → abstain.  
  - v1 (optional): add macro stage features **only if** it measurably improves false-positive support.
- **Priority**: **P1**.

### 5) Feasibility (5)
- **Weakness**: Two feasibility blockers:
  1) **MT-MG construction** implicitly requires strong temporal parsing / state tracking (which you claim as non-goal).  
  2) **Minimal support corruption** assumes access to `Ω(q,a)` or an oracle-like “indispensable atoms” set; that’s not available without heavy annotation or circular self-labeling.
- **Concrete fix**:
  - Replace “micro-graph” with a **clip bank** + lightweight object/action tags from an off-the-shelf detector (optional). Avoid new graph parsing claims.
  - Replace “minimal corruption” with an implementable counterfactual:
    - **evidence-dropout adversary**: iteratively remove the top-ranked evidence clip(s) until verifier flips; treat removed clips as “putative minimal support” *without claiming true minimality*.
    - Or **hard negative via near-miss retrieval**: retrieve clips from the same video but different step segment; this is structurally faithful and cheap.
- **Priority**: **P0**.

### 6) Validation Focus (6)
- **Weakness**: The validation menu is close to being too wide for an early-stage paper, and some metrics (e.g., “support-path recall” over MT-MG) presuppose labeled paths you likely won’t have.
- **Concrete fix** (keep only what proves the core claim):
  - Must-have: **selective prediction** evaluation (risk–coverage / accuracy–abstention curve) + hallucination/unsupported-answer rate.
  - Must-have: **small human-verified evidence sufficiency set** (even a few hundred examples) where annotators mark whether the proposed evidence *entitles* the answer. Without this, “support sufficiency” is ungrounded.
  - Optional: efficiency curves only if budgeted selection is still present after simplification.
- **Priority**: **P1**.

### 7) Venue Readiness (5)
- **Weakness**: The narrative is strong, but the implementable core is not yet locked. The current draft reads like it could expand into (a) a new structured representation paper or (b) a verification/abstention paper; reviewers will penalize ambiguity.
- **Concrete fix**: Commit to one of two crisp “paper shapes”:
  - **Verifier paper** (recommended): minimal evidence representation + calibrated sufficiency verifier + abstention.  
  - **Structure paper**: MT-MG is the contribution (but that would drift from your stated non-goals unless you own the parsing/annotation story).
- **Priority**: **P0–P1**.

---

## Simplification Opportunities (concrete deletions/merges)
1. **Delete the full Micro-Graph** in v1; use **timestamped clip evidence sets** (optionally with tags).  
2. **Merge coverage+consistency** into a single learned sufficiency score `Sθ(clip-set, q, a)`; keep the decomposition only as *analysis*, not as two separate submodels requiring extra supervision.  
3. **Delete novelty/anomaly term** `nψ(h)` unless it is essential for the main claim; it will look like an unrelated retrieval trick.

---

## Modernization Opportunities (only where natural)
1. Use a **frozen modern VLM/video encoder + lightweight verifier head** (or cross-encoder on clip features) to make the method credible under “modest compute” and clearly foundation-model-era without “new base model” claims.  
2. Treat abstention as **selective prediction** with proper calibration (temperature/Platt scaling on a clean split) and report risk–coverage; this aligns perfectly with the decision framing.  
3. Add an **evidence citation interface**: require the system to output `(answer, timestamps)` and run the verifier on those timestamps. This tightens the causal story: “less hallucination because evidence must pass verification.”

---

## Drift Warning
**Moderate drift risk**: If MT-MG requires bespoke temporal segmentation, state tracking, or graph extraction beyond off-the-shelf tooling, the paper quietly becomes “we built a procedural video parser,” contradicting the non-goals. Either (a) constrain MT-MG to weak, cheap structure (retrieved step segments + clip sets), or (b) explicitly embrace that drift.

---

## Verdict
**REVISE**

The anchored problem and the decision framing are strong and venue-aligned. The main issue is that the proposal currently names objects (MT-MG, minimal corruption, Ω-atoms) that are not realistically obtainable under your stated constraints. Lock a minimal, implementable definition of “support sufficiency” (clip evidence + entailment-style verifier + calibrated abstention) and only then add macro structure if it demonstrably fixes a specific failure mode (stage-confusable evidence).

</details>
