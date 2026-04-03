# Round 4 Review

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
6. **Validation Focus**: **8**  
7. **Venue Readiness**: **7**

**OVERALL SCORE (weighted toward 1/2/3/4): 8.4 / 10**

---

## Dimension-specific weaknesses (only for scores < 7)
NONE

(Closest-to-border note: Venue Readiness stays at 7 mainly because the paper’s credibility will hinge on tight operational details of the new controls + EEA protocol, not because the core method is unclear.)

---

## Does this close the “visual entitlement vs text-only compatibility” blocker?
**Mostly yes.** The added identification controls (`E_K` → same-video shuffled/random; cross-video same-class) + swap-gap collapse test are exactly the right *minimal* way to test “entitlement requires cited pixels” without adding new modules.

Remaining fragility is **definition discipline**, not missing mechanisms:
- **Control contamination risk**: `E_K^{same}` can accidentally include real evidence unless you *explicitly exclude* the original evidence windows (and nearby timestamps) when sampling/shuffling.  
- **Cross-video semantics**: `E_K^{class}` is only a valid negative if your EEA definition is unambiguously **instance-specific** (“this answer is entitled by evidence from *this video*”). This must be explicit in the annotation prompt, otherwise a reviewer can argue cross-video clips *can* “entitle” generic procedural answers.

These are easy to fix in the writeup and protocol, and they keep the approach minimal.

---

## Simplification Opportunities
- **NONE** (the added pieces are evaluation-time controls, not module sprawl).  
If you need to cut one thing, cut `m` from the main model and keep it as a single ablation.

---

## Modernization Opportunities
1. **Upgrade the risk-control phrasing** (still minimal): present τ selection as a simple risk-limiting / selective prediction guarantee on `EEA_dev` and report achieved coverage on `EEA_test` (you are already doing this; just make it the headline framing).  
2. **Make swapped-answer construction deterministic and auditable**: define how `a'` is generated (e.g., second-best decode / templated distractor / same-step plausible alternative), otherwise reviewers may suspect “hand-picked easy swaps.”

---

## Drift Warning
**NONE.** The new additions strengthen causal identification and evaluation reliability without drifting into benchmark-building or parser engineering.

---

## Verdict
**REVISE** (overall < 9, so not “READY” by your rule).

What prevents a ≥9 is not bloat; it’s that the *new controls must be airtight* to be convincing:
- specify contamination-free sampling for `E_K^{same}` (disjoint-from-`E_K` + margin);
- lock the EEA prompt to “evidence from this video instance” so `E_K^{class}` is a principled negative;
- specify `a'` generation so swap-loss/diagnostics cannot be dismissed as cherry-picked.

If you nail those protocol details, this becomes a clean, method-first verifier paper with a credible entitlement claim.

</details>
