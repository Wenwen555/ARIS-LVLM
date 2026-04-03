# Refinement Report

**Problem**: Procedural long-video Video-LLMs hallucinate by emitting answers that are linguistically plausible but not visually entitled by evidence.
**Initial Approach**: Start from an Evidence-Grounded MT-MG story, then close the logic so the paper has one dominant mechanism-level claim instead of a bundle of loosely related components.
**Date**: 2026-04-02
**Rounds**: 5 / 5
**Final Score**: 8.0 / 10
**Final Verdict**: REVISE

## Problem Anchor
- **Bottom-line problem**: Video-LLMs in procedural long-video understanding often answer with linguistically plausible but visually unsupported content, and they do not know when to abstain.
- **Must-solve bottleneck**: Existing work has task hierarchy, local scene evidence, and hallucination benchmarks, but still lacks an answer-conditioned support criterion that can decide whether a candidate answer is actually backed by video evidence.
- **Non-goals**: Not building a new base Video-LLM; not proposing a new scene-graph parser; not solving all open-domain video QA.
- **Constraints**: First paper should stay centered on procedural long videos, limited human verification budget, modest compute, and a single dominant mechanism-level claim.
- **Success condition**: The method must show that lower hallucination comes from explicit support sufficiency estimation and better abstention, not from generic confidence calibration or larger model scale.

## Output Files
- Review summary: `LVLM/refine-logs-v3/REVIEW_SUMMARY.md`
- Final proposal: `LVLM/refine-logs-v3/FINAL_PROPOSAL.md`

## Score Evolution

| Round | Problem Fidelity | Method Specificity | Contribution Quality | Frontier Leverage | Feasibility | Validation Focus | Venue Readiness | Overall | Verdict |
|-------|------------------|--------------------|----------------------|-------------------|-------------|------------------|-----------------|---------|---------|
| 1 | 8 | 5 | 6 | 6 | 5 | 6 | 5 | 6.2 | REVISE |
| 2 | 9 | 7 | 8 | 7 | 7 | 6 | 6 | 7.6 | REVISE |
| 3 | 9 | 8 | 8 | 8 | 8 | 7 | 7 | 8.2 | REVISE |
| 4 | 9 | 8 | 8 | 8 | 8 | 8 | 7 | 8.4 | REVISE |
| 5 | 9 | 8 | 8 | 7 | 8 | 9 | 7 | 8.0 | REVISE |

## Round-by-Round Review Record

| Round | Main Reviewer Concerns | What Was Changed | Result |
|-------|-------------------------|------------------|--------|
| 1 | Method was too abstract; contribution sprawl; MT-MG and minimal corruption were not feasible as stated | Converted the story into a verifier paper with clip evidence, lightweight sufficiency scoring, and optional macro cue | Resolved |
| 2 | Needed a primary auditable metric and anti-confirmation mechanism | Centered evaluation on EEA, added selective-prediction framing, and introduced swap-style answer controls | Partially resolved |
| 3 | Needed evidence that the verifier depends on visual evidence rather than textual compatibility | Added same-video and same-class control evidence replacements and dev/test threshold split | Partially resolved |
| 4 | Needed airtight protocol details for controls and swapped-answer construction | Tightened contamination-free sampling and deterministic competitor-answer protocol | Resolved |
| 5 | Needed sharper framing, softer claims, and stronger formal framing | Re-centered on evidence entitlement rather than confidence, noted overclaim risk, and identified next formal upgrades | Partially resolved |

## Final Proposal Snapshot
- Canonical clean version lives in `LVLM/refine-logs-v3/FINAL_PROPOSAL.md`
- Final thesis in brief:
  - Treat hallucination as a failure of **answer-conditioned evidence entitlement**, not just answer correctness.
  - Add a lightweight verifier gate between generation and emission, with abstention when evidence is insufficient.
  - Evaluate the gate on a human-auditable EEA benchmark with timestamped evidence.
  - Use contamination-free same-video and same-class controls to test instance-specific visual dependence.
  - Keep MT-MG only as weak structural intuition, not as a heavy parser contribution.

## Method Evolution Highlights
1. The biggest simplification was collapsing the framework into one paper identity: **verifier + abstention**, not parser + graph + scaling + benchmark.
2. The main mechanism upgrade was introducing EEA as the central entitlement target with swap and evidence-replacement controls.
3. The most important modernization was adopting a selective-prediction framing under frozen backbones instead of proposing a new heavy Video-LLM.

## Pushback / Drift Log
| Round | Reviewer Said | Author Response | Outcome |
|-------|---------------|-----------------|---------|
| 1 | Full MT-MG and minimal corruption looked infeasible under stated constraints | Downgraded MT-MG to weak structure and replaced hard parser claims with clip evidence + lightweight controls | Accepted |
| 2 | Needed auditable proof rather than broad weak metrics | Elevated EEA to the main target and made broader unsupported-answer metrics proxy only | Accepted |
| 3 | Needed visual-dependence controls to avoid text-only compatibility criticism | Added disjoint same-video and same-class evidence controls without adding modules | Accepted |
| 5 | Reviewer warned that “causal” wording overclaims what the protocol proves | Shift recommendation toward “instance-specific visual dependence” framing | Accepted |

## Remaining Weaknesses
- The mathematical formalization is solid for a proposal but still not fully theory-backed.
- The distinction from generic confidence calibration needs one especially crisp empirical decomposition.
- The proposal still needs one transfer experiment showing EEA improvement correlates with fewer unsupported answers on a broader QA set.
- Retriever dependence should be explicitly quantified so the verifier gets unambiguous credit.

## Raw Reviewer Responses

<details>
<summary>Round 1 Review</summary>

See `LVLM/refine-logs-v3/round-1-review.md`.

</details>

<details>
<summary>Round 2 Review</summary>

See `LVLM/refine-logs-v3/round-2-review.md`.

</details>

<details>
<summary>Round 3 Review</summary>

See `LVLM/refine-logs-v3/round-3-review.md`.

</details>

<details>
<summary>Round 4 Review</summary>

See `LVLM/refine-logs-v3/round-4-review.md`.

</details>

<details>
<summary>Round 5 Review</summary>

See `LVLM/refine-logs-v3/round-5-review.md`.

</details>

## Next Steps
- Strengthen the calibration section with a more standard selective-prediction or conformal-risk interpretation.
- Add one explicit decomposition experiment: retrieval only vs retrieval + verifier vs retrieval + verifier + calibrated abstention.
- Add one transfer experiment from EEA to a broader QA slice.
- Then proceed to `/experiment-plan`.
