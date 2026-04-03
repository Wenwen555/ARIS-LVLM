# Round 5 Review

**Date**: 2026-04-02
**Reviewer**: Independent external-style review via Claude subagent (Codex-MCP unavailable in this session)

## Raw Review

<details>
<summary>Full raw response</summary>

Scores
- Problem Fidelity: 9/10
- Method Specificity: 8/10
- Contribution Quality: 8/10
- Formalization Quality: 7/10
- Feasibility: 8/10
- Validation Focus: 9/10
- Venue Readiness: 7/10

Overall: 8.0/10  
Verdict: REVISE

Review

This proposal is substantially improved and now reads like a coherent top-tier ML paper pitch rather than a bundle of ideas. The narrative is mostly closed: the problem is unsupported answering in procedural long-video QA; the gap is the lack of an answer-conditioned support criterion; the mechanism is a retrieval-plus-sufficiency gate with abstention; the validation is centered on EEA plus contamination-controlled evidence replacement. That chain is logically consistent and reviewer-visible.

The dominant contribution is now fairly sharp: answer-conditioned evidence sufficiency verification with calibrated abstention. The proposal wisely demotes macro cues, parser ideas, and broader benchmark ambitions. This helps. The main risk is that the paper still carries a secondary “identification/causal audit” contribution alongside the verifier itself. It is good science, but it slightly blurs whether the paper is primarily a method paper or an evaluation/protocol paper. Tightening that framing would help.

The mathematical formalization is paper-appropriate but not yet fully convincing. It is adequate for a systems/ML paper sketch: variables are defined, the selective prediction rule is explicit, and swap/video-dependence margins are clearly operationalized. However, it still looks like a proposal formalization rather than a final paper formalization. In particular, the calibration rule is empirical only, the entitlement label model is underspecified, and the status of the verifier score as “probability of sufficiency” is asserted more than justified. The control-based collapse claims are testable, but not theoretically motivated enough to feel inevitable.

Remaining weaknesses:
1. The core scientific novelty may be attacked as “confidence estimation with extra structure” unless the distinction from generic calibration is demonstrated very crisply.
2. EEA is central, but external validity remains uncertain: does performance on EEA transfer to real QA quality, or only to a curated entitlement benchmark?
3. The retriever is a quiet dependency. If retrieval quality dominates outcomes, the verifier’s claimed contribution may weaken.
4. The “causal” language around cited pixels and identification is slightly stronger than what the protocol strictly proves.

Concrete fixes
1. Reframe the paper around one sentence: “selective answer emission based on evidence entitlement, not confidence,” and subordinate all controls to supporting that claim.
2. Add one explicit decomposition showing what gains come from retrieval vs verifier vs calibration thresholding.
3. Replace strong causal wording with more defensible language like “instance-specific visual dependence.”
4. Strengthen formalization of calibration/risk control, ideally with a standard selective prediction or conformal-style guarantee discussion.
5. Add one transfer experiment linking EEA gains to downstream reduction in unsupported final answers on a broader QA set.

Relevant file: `D:/科研/LVLM/Auto-claude-code-research-in-sleep/LVLM/refine-logs-v3/round-5-refinement.md`

</details>
