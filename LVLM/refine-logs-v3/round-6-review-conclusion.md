# Round 6 Review Conclusion

**Date**: 2026-04-02  
**Purpose**: High-intensity review conclusion for pushing the proposal toward 9+/10 readiness  
**Status**: Revise proposal before experiment planning / paper drafting

## Current Baseline Assessment
- **Current baseline score**: about 8.0/10
- **Current core strength**: the proposal now has one clear paper identity — answer-conditioned evidence sufficiency verification with abstention.
- **Why it is already strong**:
  - the method story is lightweight and coherent;
  - EEA is aligned with the actual output form `(answer, timestamps)`;
  - same-video / same-class controls already make the verifier story auditable.
- **Current blocking weaknesses**:
  1. the novelty can still be attacked as “confidence estimation with extra structure”;
  2. EEA external validity is still not fully closed;
  3. retriever dependence is acknowledged but not cleanly decomposed;
  4. calibration / risk-control framing is still weaker than the rest of the proposal;
  5. a few phrases still risk sounding stronger than the protocol actually proves.

## Non-negotiable Revision Goals
1. Sharpen the distinction from generic confidence estimation.
2. Elevate retrieval / verifier / calibration decomposition into mandatory main evidence.
3. Add a clear EEA-to-broader-procedural-QA transfer plan.
4. Make retriever dependence explicit and measurable.
5. Recast abstention under standard selective-prediction language.
6. Remove residual overclaiming and keep only dependence-style wording.

## Required Edits to FINAL_PROPOSAL.md
- **`论文身份一句话`**
  - Keep the first sentence maximally sharp: this paper is about evidence entitlement with abstention, not stronger confidence calibration.
- **`技术缺口`**
  - Replace “proof/identification” flavor with dependence-testing language.
  - State that the protocol tests whether the gate relies on cited video evidence rather than text plausibility.
- **`与“普通置信度阈值”不同在哪里`**
  - Add an explicit contrast table against confidence thresholding and self-eval prompting.
  - State that `S_theta` is an evidence-entitlement risk score, not intrinsic answer confidence.
- **`依赖性诊断：答案依赖与视频实例依赖`**
  - Use “instance-specific visual dependence” and “contamination-controlled evidence replacement test”.
  - Avoid language that implies full causal identification.
- **`风险控制与校准`**
  - Rewrite as standard selective prediction / risk control.
  - Define dev-set threshold selection and test-set reporting discipline.
  - Qualify any probability interpretation of `S_theta` as calibrated operational approximation only.
- **`失败模式与诊断`**
  - Split retrieval miss from verification miss.
  - Add retrieval recall / oracle-evidence-hit style analysis.
- **`Claim 驱动的实验设计`**
  - Make decomposition part of the main reviewer-facing evidence, not a side ablation.
- **`直击 Round 5 的两个关键补强实验`**
  - State clearly that decomposition and transfer are mandatory for a 9+/10-ready draft.
  - Define what each comparison is meant to prove.
- **`结论`**
  - Close on one mechanism-level claim only.
  - Make the remaining uncertainty sound empirical, not conceptual.

## Acceptance Criteria for 9+/10-Ready
- [ ] The first page makes it impossible to misread the paper as generic confidence thresholding.
- [ ] `S_theta` is consistently framed as an evidence-entitlement risk-ranking score.
- [ ] The draft explicitly contrasts confidence thresholding, self-eval, and the proposed verifier.
- [ ] Retrieval / verifier / calibration contributions are separated by a named decomposition experiment.
- [ ] Transfer beyond EEA is specified as unsupported-answer reduction on a broader procedural QA slice.
- [ ] Retriever dependence is measurable rather than buried.
- [ ] Probability language around sufficiency is qualified and disciplined.
- [ ] “Causal / identification” wording is removed or softened everywhere relevant.
- [ ] The full logic reads as: problem -> mechanism -> audit target -> dependence tests -> decomposition -> transfer -> risk control.
- [ ] Remaining uncertainty is mostly about execution quality, not about paper identity.

## Open Risks if Still Unresolved
- If decomposition stays weak, reviewers may still collapse the contribution into “confidence estimation plus extra structure”.
- If transfer stays vague, EEA may look like a curated audit that does not matter for broader QA behavior.
- If retriever dependence stays implicit, verifier credit will remain vulnerable.
- If score semantics stay loose, formalization quality will continue to lag behind the rest of the proposal.
- If claim wording stays too strong, reviewers may punish the paper for overclaiming rather than for its actual method.

## Recommended Next Action
1. Finish revising `FINAL_PROPOSAL.md` until the above checklist is textually satisfied.
2. Then turn the revised proposal into an experiment plan.
3. Only after that start paper-outline or paper-drafting work.
