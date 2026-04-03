# Research Proposal / Narrative Report: Evidence-Grounded Support Sufficiency over MT-MG for Procedural Long-Video QA

## Problem Anchor
- **Bottom-line problem**: Video-LLMs in procedural long-video understanding often answer with linguistically plausible but visually unsupported content, and they do not know when to abstain.
- **Must-solve bottleneck**: Existing work has task hierarchy, local scene evidence, and hallucination benchmarks, but still lacks an answer-conditioned support criterion that can decide whether a candidate answer is actually backed by video evidence.
- **Non-goals**: Not building a new base Video-LLM; not proposing a new scene-graph parser; not solving all open-domain video QA.
- **Constraints**: First paper should stay centered on procedural long videos, limited human verification budget, modest compute, and a single dominant mechanism-level claim.
- **Success condition**: The method must show that lower hallucination comes from explicit support sufficiency estimation and better abstention, not from generic confidence calibration or larger model scale.

## Why the current narrative was not closed
The original report correctly observed three threads of literature: macro task structure, micro scene evidence, and hallucination diagnosis. But the logical chain remained incomplete because it implicitly treated these threads as if putting them together were already a method. That is not enough for a paper.

The missing bridge is a decision problem:

> given a question `q`, a candidate answer `a`, and a long video `V`, does there exist a sufficiently complete and temporally coherent support path in the video that entitles the model to output `a` rather than abstain?

Once the problem is written this way, the paper becomes much sharper:
1. **MT-MG is not the final contribution by itself**. It is the smallest structured interface that can represent long-range task intent and local visual evidence together.
2. **The real mechanism-level contribution is support sufficiency estimation**. The model should not merely generate; it should first test whether the answer is supportable.
3. **Abstention is the behavioral consequence**. If support is insufficient, the correct action is to abstain rather than continue generation.
4. **Sparsification and counterfactual perturbation are enabling mechanisms**. They make support estimation scalable and trainable, rather than serving as independent contributions.

This closes the narrative from literature gap -> formal problem -> minimal mechanism -> validation.

## Technical Gap
Existing literature leaves four operational gaps.

### Gap 1: hierarchy and evidence are adjacent, not coupled
Goal-step-substep annotations tell the model where it is in a procedure, while scene graphs and state-change annotations tell it what is locally observed. But most work does not define a bidirectional support relation between them. As a result, the model may know the likely step without knowing the actual evidence, or see local interactions without knowing whether they are sufficient for the queried answer.

### Gap 2: hallucination work diagnoses error but rarely defines support sufficiency
VideoHallucer, EventHallusion, and VidHalluc greatly improve diagnosis, yet they mostly answer “when do models fail?” rather than “what evidence threshold entitles answering?” Many mitigation methods remain confidence-based, decoding-based, or post-hoc.

### Gap 3: negatives are often textually hard but not structurally faithful
Random answer replacement or weak perturbation can train superficial discrimination. What is missing is a negative construction that breaks the smallest evidence set needed for the answer while preserving most of the surrounding context.

### Gap 4: long-video joint modeling is expensive and noisy
If all clips, entities, and relations are jointly modeled densely, computation grows quickly and support estimation can be distracted by irrelevant background signals. Long-video support estimation therefore needs budgeted evidence selection, not all-to-all fusion.

## One-sentence thesis
**We treat procedural video hallucination as a support-insufficiency decision problem, use MT-MG as the minimal structured evidence interface, and learn a Support Sufficiency Verifier that decides answer vs abstain from answer-conditioned support paths.**

## Contribution Focus
- **Dominant contribution**: answer-conditioned support sufficiency verification for procedural long-video QA.
- **Supporting contribution 1**: MT-MG as the minimal structured interface for expressing macro intent and micro evidence as a support path.
- **Supporting contribution 2**: minimal support corruption and budgeted evidence selection as training/scalability mechanisms.
- **Explicit non-contributions**: no new foundation model, no universal graph parsing benchmark, no multilingual routing story in the first paper.

## Method Overview
The whole method should be narrated as a four-stage pipeline rather than a bag of modules.

```text
Video V, Question q
   -> Base Video-LLM proposes candidate answer a
   -> Answer-conditioned grounding retrieves a support path over MT-MG
   -> Support Sufficiency Verifier scores whether support is enough
   -> if score < tau: abstain
      else: output a
```

The key point is that answering is no longer unconditional generation. It becomes **generate candidate -> verify support -> answer or abstain**.

## Why MT-MG is still necessary
A frequent reviewer objection is: why not skip MT-MG and directly train a verifier on raw clips? The answer is that procedural long-video support is inherently two-scale.

- The **Macro-Tree** captures where the current evidence sits in the task trajectory and whether the answer is globally plausible for the current stage.
- The **Micro-Graph** captures what objects, actions, and state changes are locally visible.
- A support claim in procedural QA usually requires both: the local fact and its stage-consistent interpretation.

Therefore MT-MG is not decorative structure. It is the minimum representation that can express the support path needed for long procedural answers.

## Mathematical Formalization
Let a video be segmented into temporal units:
\[
V = (x_1, x_2, \dots, x_T), \quad x_t \in \mathcal{X}.
\]
Given a question `q \in \mathcal{Q}` and a candidate answer `a \in \mathcal{A}`, we want to decide whether `a` is supported by `V`.

### 1. Macro-Tree
Define the macro structure as a rooted tree
\[
\mathcal{T} = (\mathcal{N}_M, \mathcal{E}_M),
\]
where each macro node
\[
m_i = (g_i, s_i, \ell_i, r_i)
\]
contains a semantic label `g_i` (goal / step / substep type), a stage descriptor `s_i`, and a temporal span `[\ell_i, r_i]`.

Intuitively, `\mathcal{T}` encodes the procedural trajectory: which subgoals the video is pursuing and in which temporal region they occur.

### 2. Micro-Graph
Define the local evidence graph as
\[
\mathcal{G} = (\mathcal{N}_\mu, \mathcal{E}_\mu),
\]
where each node `u \in \mathcal{N}_\mu` may be an object, action token, or state token, and each edge `e=(u,v,\rho,\Delta t)` represents a relation `\rho` with temporal offset `\Delta t`.

A micro subgraph `H \subseteq \mathcal{G}` is a candidate evidence set supporting the answer.

### 3. Answer-conditioned support path
For a given `(q,a)`, define an answer-conditioned retrieval operator
\[
R_\phi(q,a,V) = (\pi, H),
\]
where `\pi = (m_{i_1}, \dots, m_{i_L})` is a macro path in `\mathcal{T}` and `H` is a retrieved micro subgraph from `\mathcal{G}`.

This operator is answer-conditioned rather than question-conditioned because support must be tested for a concrete claim, not for the question alone.

### 4. Support sufficiency score
We decompose support into two factors:

1. **Coverage**: whether the retrieved evidence contains the necessary local facts for `(q,a)`.
2. **Consistency**: whether these local facts are temporally and semantically compatible with the retrieved macro path.

Formally,
\[
C(q,a,H) \in [0,1], \qquad U(q,a,\pi,H) \in [0,1].
\]
Then the overall support sufficiency score is
\[
S(q,a,V) = \sigma\big(f_\theta(q,a,\pi,H)\big)
\approx \alpha C(q,a,H) + (1-\alpha) U(q,a,\pi,H),
\]
where `f_\theta` is the Support Sufficiency Verifier and `\sigma` is a sigmoid.

A more operational decomposition is:
\[
C(q,a,H)=\frac{1}{|\Omega(q,a)|}\sum_{z\in \Omega(q,a)} \mathbf{1}[z \text{ is covered by } H],
\]
where `\Omega(q,a)` is the set of indispensable evidence atoms for the answer, and
\[
U(q,a,\pi,H)=\frac{1}{|H|}\sum_{h\in H} \mathbf{1}[h \text{ is stage-consistent with } \pi].
\]

In practice, on a clean subset `\Omega(q,a)` is human-verified; on weak data it is approximated by proxy coverage rules.

### 5. Decision rule
The final behavior is
\[
\hat{y}(q,V)=
\begin{cases}
\texttt{ABSTAIN}, & S(q,a,V) < \tau, \\
 a, & S(q,a,V) \ge \tau,
\end{cases}
\]
where `a` is the candidate answer produced by the base Video-LLM and `\tau` is calibrated on a clean validation split.

This gives a principled interpretation of hallucination:

> hallucination arises when the system outputs `a` despite `S(q,a,V) < \tau`.

### 6. Budgeted evidence selection
To keep support estimation scalable, we do not use the full graph. Instead we solve a budgeted selection problem:
\[
H^* = \arg\max_{H \subseteq \mathcal{G},\; |H| \le B}
\sum_{h\in H} r_\phi(h\mid q,a) + \lambda \sum_{h\in H} n_\psi(h),
\]
where `r_\phi` is answer-conditioned relevance and `n_\psi` is novelty / anomaly retention. The second term prevents intent-only pruning from discarding off-script but crucial evidence.

This turns sparsification into **budgeted evidence selection** rather than heuristic pruning.

### 7. Minimal support corruption
To train abstention, we need negatives that are structurally faithful. Let `\Omega(q,a)` be the minimal indispensable support set. A minimal support corruption seeks the smallest edit `\Delta` such that support becomes insufficient:
\[
\Delta^* = \arg\min_{\Delta} |\Delta| \, \text{s.t.} \, S(q,a,V \ominus \Delta) < \tau_m,
\]
where `V \ominus \Delta` denotes deleting or invalidating the evidence induced by `\Delta`, and `\tau_m` is a training margin threshold.

The resulting corrupted support path preserves most of the original context but destroys the entitlement to answer. This is stricter than random deletion and closer to real unsupported reasoning.

### 8. Learning objective
A compact training objective is
\[
\mathcal{L} = \mathcal{L}_{sup} + \lambda_{abs}\mathcal{L}_{abs} + \lambda_{attr}\mathcal{L}_{attr} + \lambda_{rank}\mathcal{L}_{rank}.
\]

- **Support classification**:
\[
\mathcal{L}_{sup} = \mathrm{BCE}(S(q,a,V), y_{sup}),
\]
where `y_{sup}=1` for support-sufficient pairs and `0` otherwise.

- **Abstention calibration**:
\[
\mathcal{L}_{abs} = \mathrm{BCE}(p_{ans}, y_{ans}), \quad p_{ans}=\mathbf{1}[S(q,a,V)\ge \tau],
\]
with `y_{ans}` denoting whether the system should answer.

- **Attribution alignment**:
\[
\mathcal{L}_{attr} = 1 - \mathrm{F1}(\hat{H}, H^*),
\]
where `\hat{H}` is the predicted evidence subset and `H^*` is human-marked evidence on the clean subset.

- **Pairwise ranking for corruption**:
\[
\mathcal{L}_{rank} = \max\big(0, \gamma - S(q,a,V^+) + S(q,a,V^-)\big).
\]

Here `V^+` is a support-sufficient sample and `V^-` is its minimal support corruption.

## Why this is a tighter first-paper story
This reframing sharply reduces contribution sprawl.

- We no longer sell “macro + micro + sparsification + counterfactuals” as four independent ideas.
- We sell **one dominant claim**: support sufficiency over structured evidence reduces unsupported answering and enables principled abstention.
- MT-MG explains what evidence is represented.
- Budgeted selection explains how support remains scalable.
- Minimal support corruption explains how insufficiency supervision is learned.

The story becomes problem-first, not module-first.

## Relation to prior work
This framing creates a clearer boundary relative to existing literature.

1. **Versus hierarchy-only work**: we do not stop at step inference; we require evidence-backed entitlement for a concrete answer.
2. **Versus graph-only work**: we do not stop at local fact extraction; we ask whether the local facts are sufficient and stage-consistent for the queried answer.
3. **Versus hallucination benchmarks**: we do not only diagnose error; we operationalize support sufficiency as a trainable decision variable.
4. **Versus dense joint modeling**: we do not aim for ever-larger fusion; we aim for minimal, sufficient support paths.

## Validation Logic
The experiment story should mirror the causal chain of the method.

### Claim 1: support sufficiency estimation reduces unsupported answering
- Compare base Video-LLM vs base + verifier.
- Metrics: hallucination rate, risk-coverage, abstention calibration.
- Required evidence: lower hallucination at matched or better calibrated coverage.

### Claim 2: MT-MG support paths are more faithful than flat retrieval
- Compare answer-conditioned MT-MG grounding vs question-conditioned retrieval and keyframe selection.
- Metrics: evidence attribution F1, support-path recall.
- Required evidence: better retrieval of indispensable evidence units.

### Claim 3: minimal support corruption is more effective than generic hard negatives
- Compare random deletion, answer flip, and minimal support corruption.
- Metrics: abstention accuracy, hallucination reduction under perturbation.
- Required evidence: stronger separation between sufficient and insufficient cases.

### Claim 4: budgeted evidence selection preserves faithfulness while improving scalability
- Compare dense support estimation vs budgeted selection.
- Metrics: compute-accuracy trade-off, memory, latency, support-path recall.
- Required evidence: similar support quality under lower budget.

## Risk and boundary conditions
A tighter narrative must also state what can fail.

1. **Macro-path error propagation**: if the retrieved macro path is wrong, consistency can be misleading.
   - Mitigation: allow anomaly-retention term and off-script evidence channel.
2. **Weak proxy mismatch**: proxy coverage on weak data may not equal real support.
   - Mitigation: anchor main claim on a clean human-verified subset and treat weak labels as auxiliary scalability support.
3. **Over-abstention**: an aggressive threshold may reject answerable cases.
   - Mitigation: report risk-coverage and false-abstain rate, not only raw abstention rate.
4. **Synthetic corruption gap**: even minimal edits may not perfectly match real-world failure.
   - Mitigation: human verification on a small corruption subset and comparison against naturally hard cases from hallucination benchmarks.

## What the final paper should claim
The paper should not claim “we solve video hallucination in general.” That would be too broad. The precise claim should be:

> In procedural long-video QA, unsupported generation can be reduced by explicitly estimating answer-conditioned support sufficiency over a structured macro-micro evidence interface, and by abstaining when support is insufficient.

That claim is focused, defensible, and experimentally testable.

## Suggested report-level conclusion
Current literature has already delivered the three ingredients separately: task hierarchy, local evidence structure, and hallucination diagnosis. What it still lacks is a closed decision loop telling the model whether a specific answer is actually entitled by the video. Our refined thesis is therefore not merely to combine Macro-Tree and Micro-Graph, but to use MT-MG as the minimal support interface for an answer-conditioned support sufficiency decision. On top of this interface, a verifier decides whether the model should answer or abstain; budgeted evidence selection keeps the process scalable; minimal support corruption provides faithful insufficiency supervision. This makes the overall story logically closed: literature gap -> formal problem -> minimal mechanism -> trainable supervision -> answer/abstain behavior -> claim-driven validation.
