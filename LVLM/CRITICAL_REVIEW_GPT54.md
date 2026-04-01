# Codex MCP 深度批判性审查

**审查日期**: 2026-03-31
**审查模型**: GPT-5.4 (xhigh reasoning)
**ThreadId**: 019d41c0-c9a9-7a00-8a65-08e18b6908f5

## 整体判断

这个方向有真实问题价值，但当前叙事还不够"顶会化"。最大风险不是某个模块不合理，而是整篇论文像一组松散的改进项：`hierarchical representation + sparsification + counterfactuals + multilingual routing`。顶会 reviewer 最容易给出的致命评价会是：

> "This is a bag of reasonable tricks around an already active area, but the core scientific claim is still blurry."

如果想把它推到 `8/10+`，主问题必须收敛成一句话：

**Video-LLM 的 hallucination 来自 unsupported reasoning over long videos；你要学的是一个稀疏但可证据化的 support graph，并用 topology-consistent counterfactuals 训练模型学会"拒绝无证据生成"。**

这比"宏观-微观联合表示"更锋利，也更容易和 VideoLoom 拉开距离。

---

## 逐项 Devil's Advocate

### 1. MT-MG 联合表示（Macro-Tree + Micro-Graph）

- **最强 objection**: 这很像把已有的两类结构拼在一起。审稿人会问：`为什么这不是 engineering composition，而是新的学习问题？` 仅仅"宏观任务结构 + 微观场景图联合"本身不够新，尤其在 VideoLoom 已经做时空联合理解的前提下。

- **最可能 failure mode**: 宏观意图或步骤预测一旦错了，会把微观证据也拉偏。对长视频里"跳步、插入异常动作、非典型流程"的样本，模型会更容易 hallucinate 出"canonical task flow"，而不是忠于视频。

- **顶会潜力**: `6/10` 作为 standalone idea 偏弱；如果改写成 `evidence-grounded consistency learning`，可到 `8/10` 左右。

- **提升建议**:
  - 不要把重点放在"fusion"，而放在 `support consistency`
  - 让每个宏观节点都必须被一组微观状态/交互/状态变化支持
  - 训练时加入 `macro->micro entailment` 和 `micro->macro support` 的双向一致性损失
  - 再加一个 `unexpected-event` / `off-script` 通道，避免模型被任务先验绑死

### 2. 意图驱动稀疏化（O(N²) -> O(N log N)）

- **最强 objection**: 很容易被打成"启发式 pruning"。审稿人会追问：
  1. `复杂度下降是否真是端到端瓶颈？` 如果主要耗时仍在视觉编码或解码器，这个 big-O 贡献就不够硬
  2. 循环定义：意图本身也是模型估出来的，那稀疏化可能只是 confirmation bias

- **最可能 failure mode**: 它会优先保留"符合预期 intent"的证据，丢掉真正关键但反常的证据。问题在于 hallucination 往往就发生在视频偏离先验的时候，所以这个模块有可能**放大**而不是减轻 hallucination。

- **顶会潜力**: `5/10` 作为 standalone 不够；作为主方法里的一个组件可以到 `7-7.5/10`。

- **提升建议**:
  - 从 heuristic pruning 改成 `budgeted evidence selection`
  - **双通道设计**:
    - `exploit path`: 保留高 intent 相关证据
    - `explore path`: 专门保留高不确定性/高新颖度/反常证据
  - 报告的不只是速度，而是 `support-path recall`、`faithfulness`、`latency-memory-accuracy` 三维曲线
  - 给一个近似保证，哪怕是 submodular coverage 风格的弱保证

### 3. 拓扑反事实扰动生成硬负样本 ⭐ **最有机会做强**

- **最强 objection**: 图上的 counterfactual 很可能只是表示空间里的伪造噪声，而不是真实视频里的"难负样本"。审稿人会问：`这些负样本是不是太 synthetic 了？模型是不是只学会识别你的人造拓扑 artifact？`

- **最可能 failure mode**: 负样本看起来"硬"，实际上很假。模型对这些 perturbation 学得很好，但一到真实 hallucination case 就没用，因为真实错误往往不是明显违背拓扑，而是局部支持不足、状态变化遗漏、时间顺序偷换。

- **顶会潜力**: `7.2/10` 起步；如果能证明 counterfactual 的真实性和普适收益，可以到 `8.3-8.5/10`。

- **提升建议**:
  - 不要只做随机 rewiring，做 `minimal-edit counterfactuals`
  - 只改 1-2 个关键拓扑关系
  - 用 `state-change priors` 或近邻真实视频检索来约束可行性
  - 做一小部分人工验证，证明这些 counterfactual 在语义上 plausible 且 genuinely hard
  - 训练目标改成 `ranking + abstention`：让模型在无充分支持时倾向输出 `insufficient evidence`

### 4. Adaptive Cross-Lingual Routing

- **最强 objection**: 如果放进同一篇 paper，它会显得非常"偏题"。主线是 video hallucination reduction，这个模块更像是另一篇 multilingual VLM paper。另一个风险是 novelty claim：`script detection + routing` 很容易被 reviewer 说成是 MoE / adapter routing 的变体，不够新。

- **最可能 failure mode**: router 只是学会了 language ID shortcut。对 code-switch、transliteration、方言、借词混写时性能不稳，而且很多 gain 可能被简单的 `translate-test` baseline 吃掉。

- **顶会潜力**: 如果单做成"multilingual hallucination robustness"论文，给 `7.5-8/10`；如果硬塞进这篇主 paper，降到 `5.5/10`，因为故事会散。

- **提升建议**:
  - 除非愿意把整篇论文改成"multilingual video hallucination"，否则不要并进来
  - 若单独做，重点不是"语言性能提升"，而是"不同语言下 hallucination rate 的不均衡"和"routing 如何降低 unsupported generation"
  - 一定要对比 `translate-test`、多语 tokenizer、adapter/MoE baselines
  - 慎用"first to ..."这种 claim

---

## 优先级排名

### 按 standalone idea 排名

| 排名 | 想法 | 顶会潜力 | 理由 |
|------|------|----------|------|
| 1 | 拓扑反事实硬负样本 | 8.3-8.5/10 | 最能拉开差异、最 data-centric |
| 2 | Adaptive Cross-Lingual Routing | 7.5-8/10 | 但应是单独论文 |
| 3 | MT-MG 联合表示 | 8/10 (重构后) | 需改写为 support-graph consistency |
| 4 | 意图驱动稀疏化 | 7-7.5/10 | 不适合单独成文 |

### 按 cohesive顶会论文 package 排名

| 排名 | Package | 顶会潜力 | 理由 |
|------|---------|----------|------|
| 1 | MT-MG support graph + 拓扑反事实 + 稀疏化 | 8/10+ | 最 cohesive 的主线 |
| 2 | Cross-Lingual Routing 单独论文 | 7.5-8/10 | 单独成另一篇 |
| 3 | MT-MG 单独投稿 | 6/10 | 需重构 |
| 4 | 稀疏化单独投稿 | 5/10 | 不够 standalone |

**结论**: 最值得做的是 **A+C**（MT-MG + 拓扑反事实），再把 B（稀疏化）作为 enabling mechanism；**D（Cross-Lingual Routing）不要混进第一篇**。

---

## 实际会做的 2-3 个方向

1. **MT-MG**，但必须重构为 **support-graph consistency**，不是泛泛的层次联合表示
2. **拓扑反事实硬负样本**，这是最能拉开差异、也最 data-centric 的部分
3. **意图驱动稀疏化**，但只作为主方法里的效率/鲁棒性组件，不作为主贡献单独卖

如果资源足够，可以让另一个学生或并行项目单独做 `Adaptive Cross-Lingual Routing`。
如果资源有限，**明确砍掉 D**，先把主线做锋利。

---

## 推到 8/10+ 的具体建议

### 论文叙事重构

| 维度 | 当前问题 | 改进建议 |
|------|----------|----------|
| **题眼** | "hierarchical representation" | 改成 **"supported generation / evidence-grounded hallucination reduction"** |
| **核心主张** | 四个点都沾一点 | 收敛到 **support graph + plausible counterfactuals** |
| **稀疏化** | heuristic pruning | 必须 `uncertainty-aware`，显式保留 `off-intent` 证据 |
| **反事实** | 随机 rewiring | 必须 `minimal, plausible, validated` |
| **指标** | accuracy only | 增加 `abstention / insufficient-evidence` 训练和指标 |

### 必须增加的组件

1. **小而硬的 benchmark 子集**: 标注 `answer-supporting evidence`。没有这层证据监督，很难证明 hallucination 真的降了。

2. **强 baseline**: 必须设一组会杀死你的 baseline：
   - `question-conditioned retrieval`
   - `keyframe/segment selection`
   - `hard negative preference tuning`
   - `long-context transformer without graphs`
   - 如果这些简单法接近你，你的方法故事就站不住

3. **多维指标报告**:
   - `hallucination rate`
   - `evidence attribution F1`
   - `calibration`
   - `compute-accuracy tradeoff`

### Scope 控制

顶会更喜欢一个清晰主张被打穿，而不是四个点都沾一点。

---

## 一句话结论

> **现在最危险的不是"idea 不够好"，而是"idea 太多、主张不够尖"。把核心收敛到 support graph + plausible counterfactuals，你就有机会从 6.5/10 推到 8/10 以上。**

---

## 下一步行动

1. [ ] 将论文题眼重构为 "supported generation"
2. [ ] 设计 evidence-supporting benchmark 子集
3. [ ] 实现双通道稀疏化（exploit + explore）
4. [ ] 实现 minimal-edit counterfactuals 并人工验证
5. [ ] 设计 ranking + abstention 训练目标
6. [ ] 设置强 baseline 对比组