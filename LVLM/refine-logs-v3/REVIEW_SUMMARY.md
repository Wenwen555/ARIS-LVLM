# Review Summary

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

## Round-by-Round Resolution Log

| Round | Main Reviewer Concerns | What This Round Simplified / Modernized | Solved? | Remaining Risk |
|-------|-------------------------|------------------------------------------|---------|----------------|
| 1 | Method too abstract; MT-MG and minimal corruption were not implementable enough; contribution sprawl | Reframed into a verifier paper: retrieve K clips -> sufficiency score -> abstain; demoted full MT-MG to weak structure interface | Yes | Evaluation protocol still weak |
| 2 | Need a primary auditable metric and anti-confirmation controls | Made EEA the primary target, emphasized selective prediction framing, added swap-based answer control | Partial | Still needed visual-dependence controls |
| 3 | Needed proof that the verifier depends on cited pixels, not only text compatibility | Added same-video and same-class evidence replacement controls; split EEA into dev/test with threshold calibration | Partial | Protocol details still needed to avoid contamination |
| 4 | Control contamination, same-class ambiguity, and deterministic swapped-answer construction | Tightened same-video exclusion margin, locked same-video-instance entitlement wording, made competitor answer deterministic and auditable | Yes | Formalization still slightly proposal-level |
| 5 | Final pass: sharpen paper identity, strengthen formal framing, and reduce overclaiming | Re-centered around “evidence entitlement, not confidence”, clarified that controls support the verifier claim, recommended softer “instance-specific visual dependence” wording | Partial | Need stronger calibration theory and transfer evidence |

## Overall Evolution
- The method moved from a broad MT-MG framework story to one sharp claim: **answer-conditioned evidence sufficiency verification with calibrated abstention**.
- MT-MG was retained only as weak structural intuition instead of a heavy parser claim.
- Sparsification and counterfactuals were demoted from parallel contributions to support mechanisms and protocol controls.
- The evaluation was tightened around **EEA + risk-coverage**, rather than a broad benchmark shopping list.
- Drift into parser engineering and graph-construction claims was avoided throughout.

## Final Status
- **Anchor status**: preserved
- **Focus status**: tight
- **Modernity status**: appropriately frontier-aware
- **Strongest parts of final method**:
  - selective answer emission based on evidence entitlement rather than confidence
  - lightweight retrieval-plus-verifier design under frozen backbones
  - auditable timestamped evidence and contamination-controlled visual-dependence tests
- **Remaining weaknesses**:
  - formal calibration story is still empirical rather than theory-backed
  - the retriever remains a quiet dependency that needs explicit decomposition
  - EEA-to-broader-QA transfer still needs one concrete supporting experiment
