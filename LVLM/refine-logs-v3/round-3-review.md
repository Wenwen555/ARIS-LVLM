# Round 3 Review

**Date**: 2026-04-02
**Reviewer**: Codex MCP
**ThreadId**: 019d4c78-936b-7a32-b850-6a7ca40d22d5

## Raw Review

<details>
<summary>Full raw response</summary>

## Scores (1–10)

1. **Problem Fidelity**: **9**  
2. **Method Specificity**: **8**  
3. **Contribution Quality**: **8**  
4. **Frontier Leverage**: **8**  
5. **Feasibility**: **8**  
6. **Validation Focus**: **7**  
7. **Venue Readiness**: **7**

**OVERALL SCORE (weighted toward 1/2/3/4): 8.2 / 10**

---

## Anchor / shape checks

- **Problem Anchor**: **preserved** (still “procedural long-video QA → evidence entitlement → abstain”, no parser drift).
- **Dominant contribution**: **sharper** (now cleanly: answer-conditioned evidence sufficiency verification + calibrated abstention, with auditable timestamps).
- **Method complexity**: **simpler, not overbuilt**. Retriever + single verifier head + selective prediction is the smallest adequate mechanism.
- **Frontier leverage**: **appropriate** (frozen backbones + selective prediction + citation-conditioned verification is modern and natural; no forced trend modules).

---

## Any blocking issue remaining?
**Yes (1 main blocker, 1 secondary):**

1) **Primary blocker: ensuring EEA + swap genuinely test *visual entitlement*, not text-only compatibility.**  
Right now, a strong failure mode is: the verifier uses `q`/`a` priors + stage cue and only weakly uses video embeddings, yet still looks good on some EEA slices.

- Minimal, core fix (not “extra experiments”; it’s causal identification for your claim):
  - **Video-dependence controls on EEA**:
    - Replace `E_K` with **random clips from same video** (or shuffled timestamps) and show `Sθ` drops + swap-gap collapses.
    - Replace `E_K` with clips from a **different video in same class** and show similar collapse.
  - Report these as “**entitlement requires the cited pixels**” controls; without them, the paper is easy to dismiss as calibrated textual verification.

2) **Secondary risk: EEA protocol reliability / scope.**  
EEA is now your *primary target*, so annotation design is part of the method. If the set is “a few hundred” with weak agreement, reviewers won’t buy risk–coverage curves as stable.

- Minimal fix:
  - Pre-register the EEA prompt: annotators see `(q, a, timestamps, clips)` and answer exactly “**Does this evidence entitle this answer?**”
  - **Double-annotate** at least a subset and report agreement + adjudication rule.
  - Split EEA into **dev (for τ/calibration)** vs **test (for final curves)** to avoid threshold tuning leakage.

---

## For any score < 7 (none)
None below 7 after this revision. (But venue readiness remains contingent on the blocker controls above.)

---

## Simplification Opportunities
- **NONE** (you already removed the main sprawl). Keep `m` optional and don’t add tags by default.

---

## Modernization Opportunities
- **Add a risk-control framing** (still minimalist): choose `τ` to satisfy a target risk on EEA dev (selective prediction / risk-limiting), then report achieved coverage on EEA test. This strengthens the “not generic confidence” claim without adding modules.

---

## Drift Warning
**NONE**, assuming stage cue `m` stays optional and you do not expand into stage extraction as a contribution.

---

## Verdict
**REVISE** (overall < 9, and the “visual entitlement vs text compatibility” identification is still a real blocker until you include the minimal video-dependence controls on the EEA benchmark).

</details>
