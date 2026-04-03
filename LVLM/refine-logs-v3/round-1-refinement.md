# Round 1 Refinement

## Problem Anchor
- **Bottom-line problem**: Video-LLMs in procedural long-video understanding often answer with linguistically plausible but visually unsupported content, and they do not know when to abstain.
- **Must-solve bottleneck**: Existing work has task hierarchy, local scene evidence, and hallucination benchmarks, but still lacks an answer-conditioned support criterion that can decide whether a candidate answer is actually backed by video evidence.
- **Non-goals**: Not building a new base Video-LLM; not proposing a new scene-graph parser; not solving all open-domain video QA.
- **Constraints**: First paper should stay centered on procedural long videos, limited human verification budget, modest compute, and a single dominant mechanism-level claim.
- **Success condition**: The method must show that lower hallucination comes from explicit support sufficiency estimation and better abstention, not from generic confidence calibration or larger model scale.

## Anchor Check
- **Original bottleneck**: unsupported generation in procedural long-video QA because the model lacks an explicit answer-conditioned support test.
- **Why the revised method still addresses it**: the revised method keeps the answer/abstain decision centered on support sufficiency, but replaces idealized structure with a weak, implementable evidence interface.
- **Reviewer suggestions rejected as drift**: turning the paper into a new procedural parser or a new graph construction method would drift from the non-goals.

## Simplicity Check
- **Dominant contribution after revision**: answer-conditioned evidence sufficiency verification enabling abstention.
- **Components removed or merged**:
  1. remove full explicit Micro-Graph as a required data product;
  2. merge coverage and consistency into one learned sufficiency score, keeping decomposition only for analysis;
  3. replace idealized minimal-support oracle with implementable evidence-dropout and near-miss negatives.
- **Reviewer suggestions rejected as unnecessary complexity**: no bespoke anomaly term, no new state-tracking parser, no multi-branch graph learning stack.
- **Why the remaining mechanism is still the smallest adequate route**: it keeps only three things the claim truly needs — answer-conditioned retrieval, support verification, calibrated abstention.

## Changes Made

### 1. Replace strong MT-MG with weak structured evidence interface
- **Reviewer said**: MT-MG construction is too idealized and risks becoming a parser paper.
- **Action**: redefine MT-MG as a weak support interface: `Macro-Tree = existing step/substep spans or script-derived stage labels`; `Micro evidence = retrieved timestamped clips with optional object/action tags`.
- **Reasoning**: preserves the two-scale intuition without requiring bespoke graph parsing.
- **Impact on core method**: keeps the argument that procedural support is two-scale, but moves implementation to a realistic clip-bank formulation.

### 2. Collapse support score into a single implementable verifier
- **Reviewer said**: support objects were defined at the interface level, not the method level.
- **Action**: define `S_theta(q,a,E_K,m)` directly over top-K evidence clips `E_K` and an optional macro-stage embedding `m`.
- **Reasoning**: makes the method implementable as a frozen encoder + lightweight verifier head.
- **Impact on core method**: sharper paper shape; easier to train and evaluate.

### 3. Replace minimal-support oracle with implementable negatives
- **Reviewer said**: true `Omega(q,a)` is not realistically available at scale.
- **Action**: replace oracle minimal corruption with two practical negatives:
  - **evidence-dropout adversary**: iteratively remove top-ranked evidence clips until support flips;
  - **near-miss retrieval**: retrieve clips from same video but neighboring/different step segment.
- **Reasoning**: keeps structural faithfulness without overclaiming true minimality.
- **Impact on core method**: supervision becomes scalable and honest.

### 4. Narrow the evaluation to selective prediction and evidence entitlement
- **Reviewer said**: the validation menu is too wide.
- **Action**: keep only four core outputs: unsupported-answer rate, risk-coverage curve, false-abstain rate, and evidence entitlement accuracy on a clean subset.
- **Reasoning**: these metrics directly test the paper’s causal claim.
- **Impact on core method**: stronger and more reviewable experimental story.

## Revised Proposal

# Research Proposal: Answer-Conditioned Evidence Sufficiency Verification for Procedural Long-Video QA

## Problem Anchor
- **Bottom-line problem**: Video-LLMs in procedural long-video understanding often answer with linguistically plausible but visually unsupported content, and they do not know when to abstain.
- **Must-solve bottleneck**: Existing work has task hierarchy, local scene evidence, and hallucination benchmarks, but still lacks an answer-conditioned support criterion that can decide whether a candidate answer is actually backed by video evidence.
- **Non-goals**: Not building a new base Video-LLM; not proposing a new scene-graph parser; not solving all open-domain video QA.
- **Constraints**: First paper should stay centered on procedural long videos, limited human verification budget, modest compute, and a single dominant mechanism-level claim.
- **Success condition**: The method must show that lower hallucination comes from explicit support sufficiency estimation and better abstention, not from generic confidence calibration or larger model scale.

## Technical Gap
The literature already provides three ingredients separately: procedural hierarchy, local evidence annotations, and hallucination benchmarks. What is still missing is a concrete, trainable decision variable that answers a narrower question: **does the retrieved evidence entitle this answer?** Existing work usually stops at one of three places: likely step inference, local fact extraction, or post-hoc hallucination diagnosis. None of these is the same as an answer-conditioned entitlement test.

## Method Thesis
- **One-sentence thesis**: We reduce unsupported answering in procedural long-video QA by forcing every candidate answer to pass an answer-conditioned evidence sufficiency verifier before it can be emitted.
- **Why this is the smallest adequate intervention**: it adds no new base Video-LLM and no new parser; it only inserts a verification-and-abstention layer between candidate answer generation and final output.
- **Why this route is timely**: modern frozen video encoders and VLM backbones already provide strong candidate answers and clip features; the missing piece is selective prediction based on evidence entitlement.

## Contribution Focus
- **Dominant contribution**: Answer-conditioned evidence sufficiency verification with calibrated abstention.
- **Optional supporting contribution**: Weakly structured procedural evidence interface combining stage cues and timestamped clips.
- **Explicit non-contributions**: no graph parser, no foundation-model pretraining, no benchmark construction at full scale.

## Proposed Method

### Complexity Budget
- **Frozen / reused backbone**: frozen base Video-LLM for candidate answer generation; frozen clip encoder / video encoder for clip features.
- **New trainable components**: (1) answer-conditioned retriever, (2) lightweight support verifier head.
- **Tempting additions intentionally not used**: explicit graph neural network, dense all-to-all long-context fusion, new scene-graph parser, multi-task generation stack.

### System Overview
```text
Input: long video V, question q
1. Base Video-LLM generates candidate answer a
2. Split V into clip bank B(V) = {c_1, ..., c_T}
3. Retrieve top-K evidence clips E_K = R_phi(q, a, B(V))
4. Optionally retrieve macro-stage cue m from existing step/substep annotations or script-derived stage labels
5. Support verifier outputs S_theta(q, a, E_K, m)
6. If S_theta < tau -> ABSTAIN
   else -> output a with cited timestamps
```

### Weak Structured Evidence Interface
The paper keeps the macro/micro intuition but downgrades it to an implementable interface.

- **Macro side**: weak procedural stage cue `m`, obtained from existing step spans, ASR-script alignment, or coarse substep labels already available in instructional datasets.
- **Micro side**: top-K timestamped clips `E_K`, optionally enriched with off-the-shelf object/action tags.

This is still “MT-MG” in spirit, but no longer a claim about building a full explicit graph. The stage cue tells us where the answer should belong in the procedure; the clip set tells us what local evidence is actually visible.

### Mathematical Formalization
Let the long video be segmented into a clip bank
\[
B(V)=\{c_1,\dots,c_T\}, \quad c_t \in \mathcal{C}.
\]
For question `q` and candidate answer `a`, retrieve top-K evidence clips:
\[
E_K = R_\phi(q,a,B(V)) = \{c_{i_1},\dots,c_{i_K}\}.
\]
Let `m` denote an optional macro-stage cue. The verifier estimates
\[
S_\theta(q,a,E_K,m) \in [0,1],
\]
interpreted as the probability that the evidence set sufficiently supports answer `a` for question `q`.

The final decision is selective prediction:
\[
\hat{y}(q,V)=
\begin{cases}
\texttt{ABSTAIN}, & S_\theta(q,a,E_K,m) < \tau, \\
 a, & S_\theta(q,a,E_K,m) \ge \tau.
\end{cases}
\]

To keep the interpretation explicit, we analyze `S_theta` as approximately reflecting two latent factors:
\[
S_\theta(q,a,E_K,m) \approx g\big(\text{coverage}(q,a,E_K),\; \text{stage-consistency}(q,a,E_K,m)\big),
\]
but we do **not** instantiate two separate supervision-heavy modules. The decomposition is explanatory; the trained model remains a single verifier.

A simple instantiation is:
\[
h_t = f_v(c_{i_t}), \quad h_{qa}=f_q([q;a]), \quad h_m=f_m(m),
\]
\[
\alpha_t = \mathrm{softmax}(h_{qa}^\top W h_t), \quad h_E = \sum_{t=1}^{K} \alpha_t h_t,
\]
\[
S_\theta = \sigma\big(w^\top [h_{qa};h_E;h_m] + b\big).
\]
If macro-stage cue `m` is unavailable, the model falls back to `S_theta(q,a,E_K)`.

### Training Recipe
We use three forms of supervision.

1. **Clean evidence entitlement labels** on a small human-verified subset. Annotators judge whether the proposed clip set truly entitles the answer.
2. **Evidence-dropout adversary**. Starting from retrieved `E_K`, remove top-ranked clips until the verifier flips or confidence drops sharply. The removed set is treated as putative critical evidence; the resulting clip set becomes an insufficient-support negative.
3. **Near-miss negatives**. Retrieve clips from the same video but a neighboring or different step segment. These preserve domain and context while breaking answer entitlement.

The loss is intentionally compact:
\[
\mathcal{L} = \mathcal{L}_{sup} + \lambda_{rank}\mathcal{L}_{rank} + \lambda_{cal}\mathcal{L}_{cal}.
\]
- **Support supervision**:
\[
\mathcal{L}_{sup}=\mathrm{BCE}(S_\theta, y_{sup}).
\]
- **Ranking** between sufficient and insufficient evidence sets:
\[
\mathcal{L}_{rank}=\max(0, \gamma - S_\theta(q,a,E^+) + S_\theta(q,a,E^-)).
\]
- **Calibration loss** on a clean validation split for selective prediction.

### Inference Path
At inference, the system must output `(answer, timestamps)` or abstain. This is important: the timestamps are not just explanation; they are the evidence object that the verifier consumes. This tightens the causal story from generation to verification.

### Why the mechanism stays small
The paper only needs one new decision head because the base model already knows how to propose plausible answers. Our claim is not that base Video-LLMs cannot reason, but that they lack a principled evidence sufficiency gate.

### Failure Modes and Diagnostics
- **Retriever misses the right clips**: diagnose via evidence entitlement accuracy and top-K recall on the clean subset.
- **Macro stage cue is noisy**: run verifier with and without `m`; keep macro cue only if it reduces false support on stage-confusable questions.
- **Verifier over-abstains**: inspect risk-coverage and false-abstain rate; recalibrate `tau`.
- **Near-miss negatives are too easy**: combine with evidence-dropout negatives and report margin separation.

### Novelty and Elegance Argument
The novelty is not “we add another verifier.” The novelty is that abstention is triggered by **answer-conditioned evidence entitlement** rather than generic confidence, and that support supervision is generated from weakly structured procedural evidence plus counterfactual evidence removal, not from self-confidence alone. The representation remains intentionally weak and practical so the paper stays centered on the decision problem instead of drifting into parser engineering.

## Claim-Driven Validation Sketch

### Claim 1: Evidence sufficiency verification reduces unsupported answers
- **Minimal experiment**: base Video-LLM vs base + verifier.
- **Baselines / ablations**: confidence thresholding, self-eval prompting, generic verifier without answer-conditioned retrieval.
- **Metric**: unsupported-answer rate, risk-coverage, false-abstain rate.
- **Expected evidence**: lower unsupported-answer rate at matched coverage and better calibration.

### Claim 2: Answer-conditioned retrieval is necessary
- **Minimal experiment**: question-conditioned retrieval vs answer-conditioned retrieval.
- **Baselines / ablations**: keyframe selection, random top-K clips.
- **Metric**: evidence entitlement accuracy on clean subset.
- **Expected evidence**: answer-conditioned retrieval yields more entitlement-consistent evidence sets.

### Claim 3: Counterfactual evidence removal yields better insufficiency supervision than generic negatives
- **Minimal experiment**: near-miss negatives only vs evidence-dropout + near-miss negatives.
- **Baselines / ablations**: random deletion.
- **Metric**: abstention accuracy, margin between sufficient / insufficient evidence sets.
- **Expected evidence**: stronger separation and better unsupported-answer suppression.

## Experiment Handoff Inputs
- **Must-prove claims**: support verification lowers unsupported answers; answer-conditioned evidence is necessary; practical counterfactual negatives help.
- **Must-run ablations**: no verifier, confidence threshold, question-conditioned retrieval, random deletion, no macro cue.
- **Critical datasets / metrics**: COIN / Ego4D subsets, clean entitlement subset, unsupported-answer rate, risk-coverage, false-abstain rate.
- **Highest-risk assumptions**: weak stage cue quality, retrieval quality, transfer from clean subset to larger weakly labeled set.

## Compute & Timeline Estimate
- **Estimated GPU-hours**: low-to-moderate; compatible with frozen encoder + lightweight head training.
- **Data / annotation cost**: concentrated into a few hundred human-verified entitlement examples.
- **Timeline**: short enough for a first paper because the method avoids new parser training and full graph construction.
