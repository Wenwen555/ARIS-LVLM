# Round 4 Refinement

## Problem Anchor
- **Bottom-line problem**: Video-LLMs in procedural long-video understanding often answer with linguistically plausible but visually unsupported content, and they do not know when to abstain.
- **Must-solve bottleneck**: Existing work has task hierarchy, local scene evidence, and hallucination benchmarks, but still lacks an answer-conditioned support criterion that can decide whether a candidate answer is actually backed by video evidence.
- **Non-goals**: Not building a new base Video-LLM; not proposing a new scene-graph parser; not solving all open-domain video QA.
- **Constraints**: First paper should stay centered on procedural long videos, limited human verification budget, modest compute, and a single dominant mechanism-level claim.
- **Success condition**: The method must show that lower hallucination comes from explicit support sufficiency estimation and better abstention, not from generic confidence calibration or larger model scale.

## Anchor Check
- **Original bottleneck**: unsupported generation because the model answers before testing whether retrieved evidence really entitles the answer.
- **Why the revised method still addresses it**: the method remains a selective-prediction gate over answer-conditioned evidence; the new changes only make the visual-dependence controls contamination-free, make the EEA target instance-specific, and make the swapped-answer diagnostic reproducible.
- **Reviewer suggestions rejected as drift**: no expansion into benchmark-heavy dataset work, no parser-heavy macro alignment subsystem, no extra explanation head, no additional trainable causal module.

## Simplicity Check
- **Dominant contribution after revision**: answer-conditioned evidence sufficiency verification with calibrated abstention and auditable visual-dependence controls.
- **Components removed or merged**: macro cue remains optional; broad unsupported-answer metrics remain proxy-only; the tightened protocol lives entirely in annotation and evaluation, not in extra model components.
- **Reviewer suggestions rejected as unnecessary complexity**: no video synthesis, no explicit causal graph learner, no broad answer taxonomy.
- **Why the remaining mechanism is still the smallest adequate route**: the paper still uses one retriever, one verifier, one clean EEA benchmark, and a small number of carefully defined held-out controls.

## Changes Made

### 1. Make same-video controls contamination-free
- **Reviewer said**: same-video control clips may accidentally contain the true evidence.
- **Action**: require `E_K^{same}` to be sampled from timestamps that are disjoint from the original cited windows with an exclusion margin around every evidence interval.
- **Reasoning**: without strict exclusion, score drops under the control are uninterpretable.
- **Impact on core method**: turns the visual-dependence test into a clean falsification check.

### 2. Make EEA explicitly instance-specific
- **Reviewer said**: cross-video same-class evidence is only a principled negative if entitlement is defined for this specific video instance.
- **Action**: lock the annotation prompt to ask whether the cited evidence from **this video** entitles the answer.
- **Reasoning**: prevents reviewers from arguing that generic procedural clips from another video could still count as support.
- **Impact on core method**: makes `E_K^{class}` a valid control for pixel dependence rather than a semantic ambiguity.

### 3. Make swapped-answer construction auditable
- **Reviewer said**: the swap diagnostic can be dismissed if competing answers are hand-picked.
- **Action**: define `a'` deterministically using a fixed rule: choose the highest-scoring non-gold answer from the frozen base Video-LLM beam or retrieval candidate list that is plausible for the same question but labeled not entitled on EEA.
- **Reasoning**: this keeps the swap test hard, reproducible, and non-cherry-picked.
- **Impact on core method**: strengthens the anti-confirmation story without changing the model.

## Revised Proposal

# Research Proposal: Answer-Conditioned Evidence Sufficiency Verification for Procedural Long-Video QA

## Problem Anchor
- **Bottom-line problem**: Video-LLMs in procedural long-video understanding often answer with linguistically plausible but visually unsupported content, and they do not know when to abstain.
- **Must-solve bottleneck**: Existing work has task hierarchy, local scene evidence, and hallucination benchmarks, but still lacks an answer-conditioned support criterion that can decide whether a candidate answer is actually backed by video evidence.
- **Non-goals**: Not building a new base Video-LLM; not proposing a new scene-graph parser; not solving all open-domain video QA.
- **Constraints**: First paper should stay centered on procedural long videos, limited human verification budget, modest compute, and a single dominant mechanism-level claim.
- **Success condition**: The method must show that lower hallucination comes from explicit support sufficiency estimation and better abstention, not from generic confidence calibration or larger model scale.

## Technical Gap
Current work still misses a trainable, answer-conditioned criterion for whether retrieved visual evidence actually entitles an answer. Hierarchy-only methods know likely procedural stage; local-evidence methods know what appears in short windows; hallucination benchmarks know when models fail. But none of these by themselves define when a candidate answer should be allowed to pass to final output. Just as importantly, even a strong verifier must be shown to depend on the cited video pixels rather than on answer priors or text-only compatibility, and the protocol for testing this dependence must be airtight.

## Method Thesis
- **One-sentence thesis**: We reduce unsupported answering in procedural long-video QA by requiring every candidate answer to pass an answer-conditioned evidence sufficiency verifier, and we validate this gate with contamination-free controls that test whether entitlement truly depends on cited evidence from the same video instance.
- **Why this is the smallest adequate intervention**: it leaves the base Video-LLM frozen, avoids any new parser, and adds only a retrieval-plus-verification gate plus evaluation-time evidence corruption controls.
- **Why this route is timely**: strong frozen video-language backbones already exist; what is missing is a selective-prediction layer grounded in evidence entitlement rather than model confidence.

## Contribution Focus
- **Dominant contribution**: answer-conditioned evidence sufficiency verification with calibrated abstention.
- **Optional supporting contribution**: weak procedural stage cue as an optional context feature for stage-confusable cases.
- **Explicit non-contributions**: no graph parser, no full MT-MG construction algorithm, no new base model.

## Proposed Method

### Complexity Budget
- **Frozen / reused backbone**: frozen base Video-LLM for candidate answer generation; frozen video/clip encoder for clip embeddings.
- **New trainable components**: answer-conditioned clip retriever and lightweight sufficiency verifier head.
- **Tempting additions intentionally not used**: explicit scene graph parser, dense long-context fusion, separate coverage/consistency heads, object/action tagging pipeline in the default system.

### System Overview
```text
Input: long video V, question q
1. Base Video-LLM proposes candidate answer a
2. Split V into clip bank B(V) = {c1, ..., cT}
3. Retrieve top-K evidence clips E_K = R_phi(q, a, B(V))
4. Optionally attach weak stage cue m
5. Compute sufficiency score S_theta(q, a, E_K, m)
6. If S_theta < tau -> ABSTAIN
   else -> output (a, timestamps)
7. On EEA examples, run contamination-free control evidence replacements to verify the score depends on cited pixels from this video
```

### Weak Evidence Interface
The implementation uses weak structure, not a parser-heavy MT-MG pipeline.
- **Micro evidence**: timestamped clip set `E_K`.
- **Macro cue**: optional stage hint `m` from existing step spans or script/ASR alignment.

This keeps the original macro–micro intuition but constrains the actual paper to an implementable verifier story.

### Mathematical Formalization
Let the long video be segmented into clips
\[
B(V)=\{c_1,\dots,c_T\}, \quad c_t \in \mathcal{C}.
\]
Given question `q` and candidate answer `a`, retrieve top-K evidence clips
\[
E_K = R_\phi(q,a,B(V)) = \{c_{i_1},\dots,c_{i_K}\}.
\]
Let `m` denote an optional macro-stage cue. The verifier predicts
\[
S_\theta(q,a,E_K,m) \in [0,1],
\]
which is interpreted as the probability that the cited evidence set is sufficient to entitle answer `a`.

A simple instantiation is
\[
h_t=f_v(c_{i_t}), \qquad h_{qa}=f_q([q;a]), \qquad h_m=f_m(m),
\]
\[
\alpha_t = \mathrm{softmax}(h_{qa}^{\top}Wh_t), \qquad h_E = \sum_{t=1}^{K}\alpha_t h_t,
\]
\[
S_\theta(q,a,E_K,m)=\sigma\left(w^{\top}[h_{qa};h_E;h_m]+b\right).
\]
If `m` is unavailable, the verifier reduces to `S_theta(q,a,E_K)`.

The final selective-prediction rule is
\[
\hat{y}(q,V)=
\begin{cases}
\texttt{ABSTAIN}, & S_\theta(q,a,E_K,m) < \tau, \\
 a, & S_\theta(q,a,E_K,m) \ge \tau.
\end{cases}
\]

For the swapped-answer diagnostic, let `\mathcal{A}(q,V)` be the frozen generator’s beam or candidate list. Define the competing answer deterministically as
\[
a' = \arg\max_{\tilde a \in \mathcal{A}(q,V) \setminus \{a\}} p(\tilde a \mid q,V)
\]
subject to `\tilde a` being judged not entitled on EEA for the cited evidence. The swap margin is
\[
\Delta_{swap}(E)= S_\theta(q,a,E,m) - S_\theta(q,a',E,m).
\]
A well-grounded verifier should satisfy `\Delta_swap(E_K) > 0` by a clear margin on clean evidence-entitled cases.

To identify video dependence, define two control evidence sets for the same `(q,a)` pair:
\[
E_K^{same} \sim \mathrm{SampleDisjointSameVideo}(V; E_K, \epsilon), \qquad
E_K^{class} \sim \mathrm{SampleSameClass}(\mathcal{D}\setminus V).
\]
Here `E_K^{same}` is formed by sampling clips from the same video whose timestamps are disjoint from every interval in `E_K` with exclusion margin `\epsilon`, and `E_K^{class}` is formed by clips from a different video in the same procedural class. We then measure
\[
\Delta_{vid}^{same}=S_\theta(q,a,E_K,m)-S_\theta(q,a,E_K^{same},m),
\]
\[
\Delta_{vid}^{class}=S_\theta(q,a,E_K,m)-S_\theta(q,a,E_K^{class},m).
\]
On truly entitled cases, a visual verifier should satisfy both `\Delta_{vid}^{same} > 0` and `\Delta_{vid}^{class} > 0` by a clear margin, while the swapped-answer margin should collapse under corrupted evidence:
\[
\Delta_{swap}(E_K^{same}) \approx 0, \qquad \Delta_{swap}(E_K^{class}) \approx 0.
\]
This is the paper’s core identification check for “entitlement requires the cited pixels from this video instance.”

### EEA Protocol and Risk-Controlled Calibration
EEA is the primary evaluation target, so its protocol is defined explicitly.
- Annotators see `(q, a, timestamps, clips)`.
- They answer exactly: **“Does the cited evidence from this video entitle this answer?”**
- Labels are binary: `entitled` or `not entitled`.
- A subset is double-annotated; agreement and adjudication are reported.
- EEA is split into `EEA_dev` and `EEA_test`.

The abstention threshold is chosen only on `EEA_dev` using a target risk level `\alpha`:
\[
\tau^* = \inf\{\tau : \widehat{R}_{dev}(\tau) \le \alpha\},
\]
where `\widehat{R}_{dev}(\tau)` is the empirical error on non-abstained `EEA_dev` examples. Final risk-coverage and false-abstain numbers are reported only on `EEA_test`.

### Training Recipe
We use three supervision sources.

1. **Clean EEA subset**: annotators judge whether `(q, a, timestamps, clips)` is evidence-entitled.
2. **Near-miss negatives**: clips from the same video but neighboring or different step segments.
3. **Evidence-dropout negatives**: remove high-attribution clips using retriever attribution or frozen similarity, not verifier score alone, then validate transfer using a held-out verifier seed.

The objective is compact:
\[
\mathcal{L} = \mathcal{L}_{sup} + \lambda_{rank}\mathcal{L}_{rank} + \lambda_{swap}\mathcal{L}_{swap} + \lambda_{cal}\mathcal{L}_{cal}.
\]
where
\[
\mathcal{L}_{sup}=\mathrm{BCE}(S_\theta, y_{eea}),
\]
\[
\mathcal{L}_{rank}=\max(0, \gamma - S_\theta(q,a,E^+) + S_\theta(q,a,E^-)),
\]
\[
\mathcal{L}_{swap}=\max(0, \delta - S_\theta(q,a,E_K) + S_\theta(q,a',E_K)).
\]
`\mathcal{L}_{swap}` is a minimal mechanism-level safeguard against post-hoc justification. The video-dependence controls are not extra training modules; they are held-out identification tests on `EEA_test`.

### Inference Path
At test time the system outputs either `(answer, timestamps)` or `ABSTAIN`. The timestamps are part of the prediction object, not just post-hoc explanation. This is what makes EEA human-auditable.

### Why the mechanism stays small
The paper adds only one lightweight gate between generation and emission. Everything else is in service of making that gate auditable, calibratable, and visibly dependent on the cited evidence.

### Failure Modes and Diagnostics
- **Retriever misses true support**: inspect EEA recall with larger K.
- **Verifier learns textual compatibility only**: inspect `Delta_swap(E_K)` together with `Delta_vid^{same}` and `Delta_vid^{class}`.
- **Same-video control is contaminated**: enforce disjoint sampling with exclusion margin `\epsilon` and report any sampling failures.
- **Stage cue hurts**: drop `m` and keep stage-free verifier as main model.
- **Dropout negatives are circular**: evaluate them with held-out verifier seeds and report transfer rate.
- **EEA labels are unstable**: report agreement, adjudication, and dev/test consistency before relying on risk-coverage claims.

### Novelty and Elegance Argument
The paper’s novelty is not another confidence threshold. It is a minimal answer-conditioned entitlement test over cited visual evidence, with abstention tied to evidence sufficiency, with explicit anti-confirmation diagnostics, and with held-out controls that test whether the verifier actually needs the cited pixels from the target video instance. The method stays practical precisely because it refuses to make parser-level claims while still making the core causal story auditable.

## Claim-Driven Validation Sketch

### Claim 1: The verifier improves selective prediction on evidence entitlement
- **Minimal experiment**: base model vs base + verifier on `EEA_test`, with `tau` selected on `EEA_dev`.
- **Baselines / ablations**: confidence thresholding, self-eval prompting, generic verifier without answer-conditioned retrieval.
- **Metric**: EEA, risk-coverage on EEA, false-abstain rate on EEA.
- **Expected evidence**: better risk-control at matched coverage.

### Claim 2: Entitlement depends on cited pixels from this video instance, not just text compatibility
- **Minimal experiment**: on EEA-entitled examples, replace `E_K` with contamination-free `E_K^{same}` and `E_K^{class}`.
- **Baselines / ablations**: original evidence, disjoint same-video evidence, same-class cross-video evidence.
- **Metric**: score drop `Delta_vid`, swap-gap collapse, and resulting risk-coverage degradation.
- **Expected evidence**: `S_theta(q,a,E)` and `Delta_swap(E)` are high only for the real cited evidence from the target video, and collapse under both control replacements.

### Claim 3: Answer-conditioned retrieval and practical counterfactual negatives improve verifier training
- **Minimal experiment**: question-conditioned vs answer-conditioned retrieval, and near-miss only vs near-miss + evidence-dropout negatives.
- **Baselines / ablations**: no swap loss, no dropout negatives, question-conditioned retrieval.
- **Metric**: EEA under insufficient-support cases, abstention accuracy, held-out transfer of generated negatives.
- **Expected evidence**: stronger sufficient/insufficient separation without obvious circularity.

### Secondary Metrics
- Unsupported-answer rate outside EEA is reported only as a **proxy** metric.
- Efficiency curves are secondary and included only if the retrieval budget becomes an active concern.

## Experiment Handoff Inputs
- **Must-prove claims**: verifier improves EEA-based selective prediction; entitlement depends on cited pixels from the target video; answer-conditioned retrieval and practical counterfactual negatives help.
- **Must-run ablations**: no verifier, confidence threshold, question-conditioned retrieval, no macro cue, no swap loss, no dropout negatives, disjoint same-video evidence, same-class cross-video evidence.
- **Critical datasets / metrics**: COIN/Ego4D subsets, `EEA_dev`, `EEA_test`, EEA, risk-coverage, false-abstain, `Delta_swap`, `Delta_vid`.
- **Highest-risk assumptions**: retriever quality, EEA labeling consistency, true score collapse under contamination-free evidence corruption, transfer from clean EEA to broader data.

## Compute & Timeline Estimate
- **Estimated GPU-hours**: low-to-moderate due to frozen encoders and lightweight heads.
- **Data / annotation cost**: a few hundred EEA annotations plus timestamp validation and partial double annotation.
- **Timeline**: short enough for a first paper because no parser or heavy graph construction is required.
