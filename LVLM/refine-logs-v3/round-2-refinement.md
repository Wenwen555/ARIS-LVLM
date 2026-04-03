# Round 2 Refinement

## Problem Anchor
- **Bottom-line problem**: Video-LLMs in procedural long-video understanding often answer with linguistically plausible but visually unsupported content, and they do not know when to abstain.
- **Must-solve bottleneck**: Existing work has task hierarchy, local scene evidence, and hallucination benchmarks, but still lacks an answer-conditioned support criterion that can decide whether a candidate answer is actually backed by video evidence.
- **Non-goals**: Not building a new base Video-LLM; not proposing a new scene-graph parser; not solving all open-domain video QA.
- **Constraints**: First paper should stay centered on procedural long videos, limited human verification budget, modest compute, and a single dominant mechanism-level claim.
- **Success condition**: The method must show that lower hallucination comes from explicit support sufficiency estimation and better abstention, not from generic confidence calibration or larger model scale.

## Anchor Check
- **Original bottleneck**: unsupported generation because the model answers before testing whether retrieved evidence really entitles the answer.
- **Why the revised method still addresses it**: the whole method remains a selective-prediction gate over answer-conditioned evidence; the new changes only tighten evaluation and anti-circularity diagnostics.
- **Reviewer suggestions rejected as drift**: no expansion into large-scale benchmark creation, no parser-heavy macro alignment method.

## Simplicity Check
- **Dominant contribution after revision**: answer-conditioned evidence sufficiency verification with calibrated abstention.
- **Components removed or merged**: macro cue remains optional; object/action tags are removed from the default method; all broad automatic unsupported metrics are demoted to secondary/proxy status.
- **Reviewer suggestions rejected as unnecessary complexity**: no new explanation head, no extra adversary module beyond simple evidence-dropout and swap-test diagnostics.
- **Why the remaining mechanism is still the smallest adequate route**: the paper now needs only candidate answer generation, answer-conditioned clip retrieval, a single verifier, and a human-auditable evaluation target.

## Changes Made

### 1. Lock the primary evaluation target to EEA
- **Reviewer said**: the paper lacks a defensible primary metric for unsupported answering.
- **Action**: define **Evidence-Entitlement Accuracy (EEA)** as the main evaluation target on a human-verified set where annotators see `(q, a, timestamps)` and judge whether the cited evidence entitles the answer.
- **Reasoning**: this makes the causal claim auditable and prevents weak automatic metrics from carrying the paper.
- **Impact on core method**: the method is now tightly linked to a clean evaluation target.

### 2. Add same-evidence swapped-answer diagnostic
- **Reviewer said**: answer-conditioned retrieval may still support post-hoc self-justification.
- **Action**: add a diagnostic constraint: for fixed evidence `E_K`, a plausible but wrong competing answer `a'` should produce a much lower score than the original answer.
- **Reasoning**: this directly tests whether the verifier is checking entitlement rather than generic answer-evidence compatibility.
- **Impact on core method**: stronger defense against confirmation-bias critique without adding new modules.

### 3. Reduce circularity in evidence-dropout negatives
- **Reviewer said**: verifier-generated negatives may be self-fulfilling.
- **Action**: generate dropout negatives using retriever attribution or frozen similarity scores, then evaluate them with a held-out verifier seed.
- **Reasoning**: avoids training negatives that only fool the same model that created them.
- **Impact on core method**: makes insufficiency supervision more credible.

## Revised Proposal

# Research Proposal: Answer-Conditioned Evidence Sufficiency Verification for Procedural Long-Video QA

## Problem Anchor
- **Bottom-line problem**: Video-LLMs in procedural long-video understanding often answer with linguistically plausible but visually unsupported content, and they do not know when to abstain.
- **Must-solve bottleneck**: Existing work has task hierarchy, local scene evidence, and hallucination benchmarks, but still lacks an answer-conditioned support criterion that can decide whether a candidate answer is actually backed by video evidence.
- **Non-goals**: Not building a new base Video-LLM; not proposing a new scene-graph parser; not solving all open-domain video QA.
- **Constraints**: First paper should stay centered on procedural long videos, limited human verification budget, modest compute, and a single dominant mechanism-level claim.
- **Success condition**: The method must show that lower hallucination comes from explicit support sufficiency estimation and better abstention, not from generic confidence calibration or larger model scale.

## Technical Gap
Current work still misses a trainable, answer-conditioned criterion for whether retrieved visual evidence actually entitles an answer. Hierarchy-only methods know likely procedural stage; local-evidence methods know what appears in short windows; hallucination benchmarks know when models fail. But none of these by themselves define when a candidate answer should be allowed to pass to final output.

## Method Thesis
- **One-sentence thesis**: We reduce unsupported answering in procedural long-video QA by requiring every candidate answer to pass an answer-conditioned evidence sufficiency verifier before the system is allowed to answer.
- **Why this is the smallest adequate intervention**: it leaves the base Video-LLM frozen, avoids any new parser, and adds only a retrieval-plus-verification gate.
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
3. Retrieve top-K evidence clips EK = R_phi(q, a, B(V))
4. Optionally attach weak stage cue m
5. Compute sufficiency score S_theta(q, a, EK, m)
6. If S_theta < tau -> ABSTAIN
   else -> output (a, timestamps)
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

To explicitly test anti-confirmation behavior, define a swapped-answer control with a plausible but wrong answer `a'`:
\[
\Delta_{swap} = S_\theta(q,a,E_K,m) - S_\theta(q,a',E_K,m).
\]
A well-grounded verifier should satisfy `\Delta_swap > 0` by a clear margin on clean evidence-entitled cases.

### Training Recipe
We use three supervision sources.

1. **Clean EEA subset**: annotators judge whether `(q, a, timestamps)` is evidence-entitled.
2. **Near-miss negatives**: clips from the same video but neighboring/different step segments.
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
`\mathcal{L}_{swap}` is a minimal mechanism-level safeguard against post-hoc justification.

### Inference Path
At test time the system outputs either `(answer, timestamps)` or `ABSTAIN`. The timestamps are part of the prediction object, not just post-hoc explanation. This is what makes EEA human-auditable.

### Why the mechanism stays small
The paper adds only one lightweight gate between generation and emission. Everything else is in service of making that gate auditable and trainable.

### Failure Modes and Diagnostics
- **Retriever misses true support**: inspect EEA recall with larger K.
- **Verifier learns textual compatibility only**: inspect swapped-answer gap `Delta_swap`.
- **Stage cue hurts**: drop `m` and keep stage-free verifier as main model.
- **Dropout negatives are circular**: evaluate them with held-out verifier seeds and report transfer rate.

### Novelty and Elegance Argument
The paper’s novelty is not another confidence threshold. It is a minimal answer-conditioned entitlement test over cited visual evidence, with abstention tied to evidence sufficiency and with explicit anti-confirmation diagnostics. The method stays practical precisely because it refuses to make parser-level claims.

## Claim-Driven Validation Sketch

### Claim 1: The verifier improves selective prediction on evidence entitlement
- **Minimal experiment**: base model vs base + verifier on the clean EEA set.
- **Baselines / ablations**: confidence thresholding, self-eval prompting, generic verifier without answer-conditioned retrieval.
- **Metric**: EEA, risk-coverage on EEA, false-abstain rate on EEA.
- **Expected evidence**: better risk-control at matched coverage.

### Claim 2: Answer-conditioned evidence is necessary
- **Minimal experiment**: question-conditioned vs answer-conditioned retrieval.
- **Metric**: EEA and swapped-answer gap.
- **Expected evidence**: answer-conditioned retrieval yields more discriminative evidence-entitlement decisions.

### Claim 3: Practical counterfactual negatives improve insufficiency supervision
- **Minimal experiment**: near-miss only vs near-miss + evidence-dropout.
- **Metric**: EEA under insufficient-support cases, abstention accuracy, held-out transfer of generated negatives.
- **Expected evidence**: stronger sufficient/insufficient separation without obvious circularity.

### Secondary Metrics
- Unsupported-answer rate outside EEA is reported only as a **proxy** metric.
- Efficiency curves are secondary and included only if the retrieval budget becomes an active concern.

## Experiment Handoff Inputs
- **Must-prove claims**: verifier improves EEA-based selective prediction; answer-conditioned retrieval is necessary; practical counterfactual negatives help.
- **Must-run ablations**: no verifier, confidence threshold, question-conditioned retrieval, no macro cue, no swap loss, no dropout negatives.
- **Critical datasets / metrics**: COIN/Ego4D subsets, clean EEA subset, EEA, risk-coverage, false-abstain, swap-gap.
- **Highest-risk assumptions**: retriever quality, EEA labeling consistency, transfer from clean EEA to broader data.

## Compute & Timeline Estimate
- **Estimated GPU-hours**: low-to-moderate due to frozen encoders and lightweight heads.
- **Data / annotation cost**: a few hundred EEA annotations plus timestamp validation.
- **Timeline**: short enough for a first paper because no parser or heavy graph construction is required.
