# Related Work 排序清单（含 arXiv 与引用量维度）

**研究主题**：面向 Video-LLM 幻觉抑制的程序性长视频结构化数据研究  
**核心方法定位**：Evidence-Grounded MT-MG  
**排序依据**：综合考虑“与我们研究的相关程度”“在整条研究叙事中的重要性程度”，并新增“引用量”作为辅助维度  
**参考来源**：
- [`LVLM/COMPREHENSIVE_REPORT.md`](./COMPREHENSIVE_REPORT.md)
- [`LVLM/LITERATURE_SURVEY.md`](./LITERATURE_SURVEY.md)

**数据说明**：
- arXiv 链接按标题通过 arXiv API 逐篇核验；若未检到公开 arXiv，则明确标注“无公开 arXiv”。
- 引用量统计口径：优先使用 OpenCitations COCI；若对应 DOI 尚未被 COCI 收录，则回退到 OpenAlex `cited_by_count`。
- 检索日期：`2026-04-01`。
- 这里的引用量不是 Google Scholar 口径，而且对新近 preprint、dataset track、以及尚未充分合并版本的论文会偏低，因此只用于判断“路线成熟度 / 社区主干性”，不机械决定排序。

---

## 一、排序原则

为了让这份排序既能服务论文写作，也能服务开题答辩和实验设计，我采用三条主轴：

### 1. 相关程度

相关程度主要看一篇工作和我们的核心问题有多接近。我们的核心问题不是一般性的视频理解，而是：

- 长程程序性视频理解
- 宏观任务结构与微观视觉证据的联合表示
- Video-LLM 在证据不足时的 hallucination 抑制
- 结构化中间表示驱动的数据构建、监督和拒答机制

### 2. 重要性程度

重要性程度主要看一篇工作在整条叙事链里的地位，包括：

- 是否定义了一个关键问题
- 是否开创了一条后续必须回应的技术路线
- 是否构成我们方法的直接对照基线
- 是否是论文写作中必须引用的 foundational work

### 3. 新增辅助维度：引用量

引用量不是新的主排序轴，但它非常有用，因为它能帮助我们区分三种不同角色：

- **高引用基础工作**：说明这是 reviewer 和社区都熟悉的“背景地基”。
- **中引用结构路线**：说明这条线已经成形，但还未成为领域唯一主干。
- **低引用前沿工作**：往往是最接近我们的问题，但因为太新，尚未形成大规模引用积累。

因此，这个维度主要帮助回答：

- 我们的工作是在接哪条已经成立的主干？
- 我们的工作又是在推进哪条尚处于前沿的新线？
- 论文写作时，哪些工作是“必须交代的地基”，哪些工作是“必须正面对比的近邻”？

### 4. 排序规则

综合排序时采用以下优先级：

1. 先看是否直接贴近我们的核心方法缺口  
2. 再看它在领域中的基础性、代表性和不可替代性  
3. 最后再用引用量判断“它更像 community main trunk，还是更像 frontier branch”

评分说明：

- `相关度`：1-5，5 为与我们最直接相关
- `重要度`：1-5，5 为在叙事或领域中最关键
- `引用量*`：用于辅助识别路线成熟度，不直接决定最终名次
- `综合判断`：不是简单加法，而是用于形成论文中的优先引用顺序

---

## 二、总排序

| 排名 | 工作 | 相关度 | 重要度 | 引用量* | 综合定位 | 排名理由 |
|------|------|--------|--------|---------|----------|----------|
| 1 | VideoLoom | 5 | 5 | 0 | 最核心直接对照 | 与我们一样都在做时空联合理解，是当前最接近 MT-MG 方向的现有工作 |
| 2 | EASG | 5 | 4 | 13 | 最关键微观证据工作 | 最贴近我们 `Micro-Graph` 路线，尤其适合长程 egocentric procedural 场景 |
| 3 | Ego4D Goal-Step | 5 | 4 | 0 | 最关键宏观结构工作 | 最贴近我们 `Macro-Tree` 路线，直接支撑 goal-step-substep 层次建模 |
| 4 | State-Change Counterfactuals | 5 | 4 | 0 | 最关键反事实工作 | 与我们的结构性 hard negative / counterfactual 路线高度接近 |
| 5 | VideoHallucer | 4 | 5 | 4 | 最关键幻觉评测工作 | 为 Video-LLM hallucination 提供较系统的评测框架，是我们评价体系的重要依据 |
| 6 | EventHallusion | 4 | 4 | 4 | 关键事件级幻觉工作 | 强调 prior-driven event hallucination，和我们“证据不足仍作答”的问题很贴近 |
| 7 | VidHalluc | 4 | 4 | 4 | 关键时序幻觉基准 | 进一步把时序 hallucination 做成更系统化 benchmark，适合作为外部评测参照 |
| 8 | Action Genome | 4 | 5 | 207 | 微观图表示基础工作 | 虽然不是 procedural benchmark，但它是视频 scene graph 路线的重要基础 |
| 9 | GUIDE | 4 | 4 | 0 | 宏观 guideline 代表工作 | 把 procedural understanding 从实例步骤推进到 task-level guideline，叙事价值很高 |
| 10 | Video-Mined Task Graphs | 4 | 4 | 10 | 任务图代表工作 | 强调程序任务图的概率结构，是宏观图化流程的重要代表 |
| 11 | Paprika | 4 | 4 | 18 | 程序知识图代表工作 | 把程序知识图用于预训练，是“图作为监督接口”的关键代表 |
| 12 | CaptainCook4D | 4 | 4 | 2 | 真实错误执行代表工作 | 直接触及错误执行与鲁棒性，对我们真实 hard negative 设计很重要 |
| 13 | Assembly101 | 3 | 5 | 114 | 真实程序偏差数据基础 | 在“错误、纠正、非理想执行”方面非常重要，但与 MT-MG 本体距离略远一层 |
| 14 | Structured Procedural Knowledge Extraction | 4 | 3 | 8 | 细粒度结构单元补充 | 对 `verb-argument` 级结构表达很有启发，但与 Video-LLM hallucination 连接较弱 |
| 15 | COIN | 3 | 5 | 165 | 经典程序视频基准 | 是程序性视频研究的重要地基，但偏早期平坦 step 结构 |
| 16 | CrossTask | 3 | 4 | 133 | 经典弱监督程序工作 | 对步骤顺序和弱监督很关键，但宏微耦合能力不足 |
| 17 | YouCook2 | 3 | 5 | 326 | 经典起点工作 | 是程序视频 step-level 分析的重要起点，基础性强，但与我们的问题距离较远 |
| 18 | HowTo100M | 3 | 5 | 600 | 大规模弱监督代表 | 在大规模 narrated video 预训练上极其重要，但结构纯度偏弱 |
| 19 | TIPS | 3 | 3 | 5 | 自动化构建路线补充 | 对自动化 procedure segmentation 数据构建有参考意义 |
| 20 | DistantSup | 3 | 3 | 36 | 远监督路线补充 | 对低成本程序监督有价值，但仍偏 step label 层面 |

**对这张表最重要的解读**：

- `VideoLoom / Ego4D Goal-Step / State-Change Counterfactuals / VideoHallucer` 这类工作虽然引用量还低，但它们离我们的真实问题最近，所以仍然排在前面。
- `HowTo100M / YouCook2 / Action Genome / COIN / CrossTask` 这类工作引用量高，说明它们是领域共同背景；即便与我们不完全同题，也必须在叙事里交代清楚。
- 因此，论文写作时不能把“高引用”误写成“最接近”，也不能把“最接近但很新”误写成“已经是 community consensus”。

---

## 三、文献核验索引（现有 20 篇）

这张表的作用不是重新排序，而是给写论文和整理参考文献时提供一个可直接复用的“题名 + arXiv + 引用量”核验索引。

| 工作 | 正式标题 | 年份 | arXiv | 引用量* |
|------|----------|------|-------|---------|
| VideoLoom | VideoLoom: A Video Large Language Model for Joint Spatial-Temporal Understanding | 2026 | [2601.07290](https://arxiv.org/abs/2601.07290) | 0 |
| EASG | Action Scene Graphs for Long-Form Understanding of Egocentric Videos | 2024 | [2312.03391](https://arxiv.org/abs/2312.03391) | 13 |
| Ego4D Goal-Step | Ego4D Goal-Step: Toward Hierarchical Understanding of Procedural Activities | 2023 | 无公开 arXiv | 0 |
| State-Change Counterfactuals | What Changed and What Could Have Changed? State-Change Counterfactuals for Procedure-Aware Video Representation Learning | 2025 | [2503.21055](https://arxiv.org/abs/2503.21055) | 0 |
| VideoHallucer | VideoHallucer: Evaluating Intrinsic and Extrinsic Hallucinations in Large Video-Language Models | 2024 | [2406.16338](https://arxiv.org/abs/2406.16338) | 4 |
| EventHallusion | EventHallusion: Diagnosing Event Hallucinations in Video LLMs | 2024 | [2409.16597](https://arxiv.org/abs/2409.16597) | 4 |
| VidHalluc | VidHalluc: Evaluating Temporal Hallucinations in Multimodal Large Language Models for Video Understanding | 2025 | [2412.03735](https://arxiv.org/abs/2412.03735) | 4 |
| Action Genome | Action Genome: Actions As Compositions of Spatio-Temporal Scene Graphs | 2020 | [1912.06992](https://arxiv.org/abs/1912.06992) | 207 |
| GUIDE | GUIDE: A Guideline-Guided Dataset for Instructional Video Comprehension | 2024 | [2406.18227](https://arxiv.org/abs/2406.18227) | 0 |
| Video-Mined Task Graphs | Video-Mined Task Graphs for Keystep Recognition in Instructional Videos | 2023 | [2307.08763](https://arxiv.org/abs/2307.08763) | 10 |
| Paprika | Procedure-Aware Pretraining for Instructional Video Understanding | 2023 | [2303.18230](https://arxiv.org/abs/2303.18230) | 18 |
| CaptainCook4D | CaptainCook4D: A Dataset for Understanding Errors in Procedural Activities | 2024 | [2312.14556](https://arxiv.org/abs/2312.14556) | 2 |
| Assembly101 | Assembly101: A Large-Scale Multi-View Video Dataset for Understanding Procedural Activities | 2022 | [2203.14712](https://arxiv.org/abs/2203.14712) | 114 |
| Structured Procedural Knowledge Extraction | A Benchmark for Structured Procedural Knowledge Extraction from Cooking Videos | 2020 | [2005.00706](https://arxiv.org/abs/2005.00706) | 8 |
| COIN | COIN: A Large-Scale Dataset for Comprehensive Instructional Video Analysis | 2019 | [1903.02874](https://arxiv.org/abs/1903.02874) | 165 |
| CrossTask | Cross-Task Weakly Supervised Learning from Instructional Videos | 2019 | [1903.08225](https://arxiv.org/abs/1903.08225) | 133 |
| YouCook2 | Towards Automatic Learning of Procedures from Web Instructional Videos | 2018 | [1703.09788](https://arxiv.org/abs/1703.09788) | 326 |
| HowTo100M | HowTo100M: Learning a Text-Video Embedding by Watching Hundred Million Narrated Video Clips | 2019 | [1906.03327](https://arxiv.org/abs/1906.03327) | 600 |
| TIPS | Learning Temporal Video Procedure Segmentation from an Automatically Collected Large Dataset | 2022 | 无公开 arXiv | 5 |
| DistantSup | Learning To Recognize Procedural Activities With Distant Supervision | 2022 | [2201.10990](https://arxiv.org/abs/2201.10990) | 36 |

---

## 四、建议补入的 papers

如果你的担心是“这份 related work 会不会还不够全”，我的判断是：**现有 20 篇已经足以构成主线骨架，但还缺少几篇能把叙事补得更完整的关键连接点**。最值得补的不是再堆很多相近论文，而是补那些能明显改善“发展脉络完整性”的桥梁型工作。

### 4.1 建议补入主线的 3 篇

| 工作 | 年份 | arXiv | 引用量* | 为什么值得补 |
|------|------|-------|---------|--------------|
| Bridge-Prompt | 2022 | [2203.14104](https://arxiv.org/abs/2203.14104) | 45 | 它补上了 `CrossTask / COIN` 与 `Ego4D Goal-Step` 之间的“ordinal action understanding”层，说明社区不只是从 flat steps 直接跳到 hierarchy，中间还有“相邻步骤语义关系 / 顺序逻辑”这条线。 |
| Dense Procedure Captioning | 2019 | 无公开 arXiv | 38 | 它补上了 narrated instructional videos 的 dense caption / step narration 路线，让早期程序视频叙事从“step segmentation”扩展到“step-level language grounding”。 |
| InstructionBench | 2025 | [2504.05040](https://arxiv.org/abs/2504.05040) | 0 | 它直接对应“instructional video + Video-LLM benchmark”这个最接近你下游使用场景的评测空位，而且会让你在写 benchmark related work 时更显得完整。 |

### 4.2 建议作为 broader field anchor 的 2 篇

| 工作 | 年份 | arXiv | 引用量* | 更适合放在哪里 |
|------|------|-------|---------|----------------|
| Video-MME | 2025 | [2405.21075](https://arxiv.org/abs/2405.21075) | 41 | 更适合放在 `Introduction / Experiments / broader benchmark context`，用来说明我们并非脱离主流 Video-LLM evaluation 生态。 |
| TempCompass | 2024 | [2403.00476](https://arxiv.org/abs/2403.00476) | 18 | 更适合放在“temporal reasoning / temporal evaluation anchor”位置，说明时序推理已经是 broader Video-LLM 社区的共同关注点。 |

### 4.3 可选补充

如果你想把叙事再往 **egocentric task assistance / embodied assistant** 方向接一层，那么 `HoloAssist` 也值得知道：

- **HoloAssist**（2023，引用量 19，arXiv: [2309.17024](https://arxiv.org/abs/2309.17024)）
- 它不是你主线里最必须的 paper，但它能帮助你把“程序理解”与“真实交互式 AI 助手”联系起来。

---

## 五、分层理解

## S Tier：最应优先写进论文 Related Work 的核心作品

### 1. VideoLoom

- **为什么排第 1**：它是目前最接近我们整体方向的工作，直接触及“时空联合理解”这一核心命题。
- **和我们的关系**：它更偏模型中心的联合表示；我们更偏 data-centric 的结构化中间表示与证据约束。
- **写作口径**：应被写成“最接近但仍未解决 macro intention 与 micro evidence 闭环耦合”的现有工作。

### 2. EASG

- **为什么这么高**：EASG 是我们 `Micro-Graph` 路线最自然的前置工作之一。
- **和我们的关系**：它证明了长程 egocentric 视频中，动作-对象-关系的动态图表示是必要的；但它没有把微观图和宏观任务结构显式绑定。
- **写作口径**：应作为“微观证据图表示”最重要的直接前作。

### 3. Ego4D Goal-Step

- **为什么这么高**：Ego4D Goal-Step 是 `Macro-Tree` 的最强宏观结构依据之一。
- **和我们的关系**：它回答“任务目标和步骤层级如何表示”，但不回答“这些步骤究竟由哪些视觉证据支撑”。
- **写作口径**：应作为“宏观层次任务结构”的核心代表。

### 4. State-Change Counterfactuals

- **为什么这么高**：它是我们“反事实 / hard negative / 支持链断裂”逻辑里最接近的一类工作。
- **和我们的关系**：它聚焦状态变化反事实，我们想进一步走向图拓扑层面的支持链扰动。
- **写作口径**：应作为“从正确执行走向 counterfactual procedural supervision”的关键桥梁。

### 5. VideoHallucer

- **为什么这么高**：如果我们的论文主打 hallucination 抑制，这篇几乎一定要成为主文里的核心引用。
- **和我们的关系**：它更偏评测与分类，我们更偏结构化机制与训练框架。
- **写作口径**：应作为“Video-LLM hallucination benchmark”的基础参照。

---

## A Tier：非常重要，通常需要进入主文主体

### 6. EventHallusion

- 价值在于把 hallucination 具体推进到 event-level，并强调 prior-driven 错误。
- 对我们论证“模型会在缺证据时继续顺着先验生成”非常关键。

### 7. VidHalluc

- 价值在于把 temporal hallucination 问题做得更标准化、系统化。
- 适合用来支撑我们为何不仅要做结构表示，还要做拒答与支持充分性判断。

### 8. Action Genome

- 它不是程序视频专用工作，但在视频 scene graph 这条线中极重要。
- 如果我们要论证 `Micro-Graph` 不是拍脑袋发明的，Action Genome 是必须引用的基础工作。

### 9. GUIDE

- 它把 procedural understanding 推向跨实例 guideline 抽象，这对宏观任务结构叙事很重要。
- 它适合用来说明“我们并不是只关心 step 序列，而是关心 task scaffold”。

### 10. Video-Mined Task Graphs

- 它证明任务图可以从真实视频中挖掘，而不必完全依赖人工脚本。
- 这与我们未来的数据自动化构建逻辑非常一致。

### 11. Paprika

- Paprika 很重要，因为它把“程序图结构”变成了训练监督接口。
- 它为我们把 MT-MG 当作 data-centric 中间表示提供了前例支持。

### 12. CaptainCook4D

- 这篇在“真实错误执行”层面非常关键。
- 它适合支撑我们对 hard negative 的一个重要论点：真正有价值的负例应来自真实或结构性错误，而不是表层文本替换。

---

## B Tier：基础性很强，但更适合作为背景铺垫或补充引用

### 13. Assembly101

- 它不是直接的 MT-MG 工作，但它在“程序活动天然包含变体、错误和纠正”这个命题上非常重要。
- 更适合被放在“真实程序分布并非完美脚本”这一节。

### 14. Structured Procedural Knowledge Extraction

- 这篇最大的价值在于把微观结构下沉到 `verb-argument` 层面。
- 它有助于论证我们为什么要把视觉事实做成结构化中间单元，而不只是文本描述。

### 15. COIN

- COIN 是程序视频领域的标准经典工作之一，地位高，但与我们当前问题的“前沿差异化”已经拉开了一层距离。
- 在论文里适合出现在早期背景综述里。

### 16. CrossTask

- 它对弱监督与步骤顺序建模很重要。
- 但它仍然停留在 `task -> ordered steps`，离“证据支持链”还比较远。

### 17. YouCook2

- YouCook2 的重要性更多体现在“起点意义”。
- 适合当作程序视频 step-level 建模的开端引用。

### 18. HowTo100M

- 它的重要性非常高，但相关性是间接的。
- 更适合用来解释“大规模 narrated video 预训练”这条旁支路线，而不是直接 related work 核心。

### 19. TIPS

- 它对自动化数据构建有启发。
- 但更多是规模化 procedure segmentation 路线，而非宏微证据耦合路线。

### 20. DistantSup

- 它对远监督构建很有价值。
- 不过与我们“Evidence-Grounded MT-MG + hallucination suppression”的主问题距离相对更远。

---

## 六、如果只保留 8 篇最关键 Related Work

如果论文篇幅有限，建议优先保留以下 8 篇：

1. VideoLoom  
2. EASG  
3. Ego4D Goal-Step  
4. State-Change Counterfactuals  
5. VideoHallucer  
6. EventHallusion  
7. Action Genome  
8. CaptainCook4D  

这 8 篇基本覆盖了我们叙事中的四个关键面向：

- **宏观结构**：Ego4D Goal-Step
- **微观证据**：EASG, Action Genome
- **联合 / 最接近方法**：VideoLoom
- **错误与反事实**：State-Change Counterfactuals, CaptainCook4D
- **幻觉评测**：VideoHallucer, EventHallusion

如果篇幅允许扩到 **10 篇**，我建议再加：

- GUIDE
- Paprika

如果扩到 **12 篇**，我建议再加：

- Bridge-Prompt
- InstructionBench

---

## 七、适合论文写作的引用顺序

如果后面要把这份材料写进论文的 `Related Work`，我建议按下面的顺序来组织，而不是机械按年份排序：

### 1. Procedural video understanding with hierarchical task structure

建议引用：

- YouCook2
- CrossTask
- COIN
- Bridge-Prompt
- Ego4D Goal-Step
- GUIDE
- Paprika
- Video-Mined Task Graphs

这一节要讲清楚：社区已经从 step-level 分析走向 ordinal action context、goal-step-substep、guideline 和 task graph，但宏观结构并未自动带来证据可验证性。

### 2. Structured visual evidence for long-form video understanding

建议引用：

- Action Genome
- EASG
- Structured Procedural Knowledge Extraction

这一节要讲清楚：微观结构表示已经证明局部对象、动作、关系和状态变化的重要性，但这些方法通常没有与宏观任务意图形成闭环。

### 3. Errors, counterfactuals, and non-canonical procedural execution

建议引用：

- Assembly101
- CaptainCook4D
- State-Change Counterfactuals

这一节要讲清楚：真实世界程序过程天然包含错误、偏差和替代路径，因此 hard negative 不应只来自表层文本替换，而应来自结构扰动。

### 4. Hallucination diagnosis in video-language models

建议引用：

- VideoHallucer
- EventHallusion
- VidHalluc
- InstructionBench

这一节要讲清楚：现有工作已经把 hallucination 问题定义清楚、评测起来了，但尚未把“support sufficiency”建成显式学习对象；而且针对 instructional videos 的 Video-LLM benchmark 仍然很少。

### 5. Closest prior to our work

建议单独强调：

- VideoLoom

这一节要写得最锋利，因为 reviewer 最可能把它当作直接比较对象。我们的差异化最好明确写成：

- 它更偏 model-centric 时空联合建模
- 我们更偏 data-centric 结构化中间表示
- 它强调联合理解
- 我们强调 evidence-grounded support consistency、拒答与可扩展稀疏化

### 6. Broader Video-LLM evaluation anchors（可选）

如果你想在 `Introduction` 或 `Experiments` 里补一句“我们并不是脱离更大 Video-LLM 社区自说自话”，可以再轻量补上：

- Video-MME
- TempCompass

这两篇不必写成 procedural 主线的一部分，但它们能帮助你说明：**时序理解和长视频评测已经是 broader Video-LLM 社区的共同问题，而我们是在其中切了一个更难、更强调证据支撑的子问题。**

---

## 八、引用量视角下的研究路线判断

这一节是这次新增的重点，因为它能帮助你判断：**我们的研究究竟更像“主流路线的延伸”，还是“几个前沿分支的交叉点”。**

### 1. 高引用基础主干：这是 reviewer 的默认背景

当前引用量最高的一组工作是：

- HowTo100M：600
- YouCook2：326
- Action Genome：207
- COIN：165
- CrossTask：133
- Assembly101：114

这说明社区最成熟、最共识化的几条路线其实是：

- **大规模 narrated video 预训练**
- **经典程序视频 benchmark / step segmentation**
- **视频 scene graph / 结构化局部关系表示**
- **真实执行偏差与多视角程序数据**

换句话说，**主流社区记忆里的“这个领域”首先不是 hallucination，也不是 support sufficiency，而是程序视频、视频预训练、结构表示和长程时序理解。**

### 2. 中引用结构路线：这是正在成形的桥梁层

中等引用量、但已经形成稳定存在感的工作包括：

- Bridge-Prompt：45
- DistantSup：36
- Dense Procedure Captioning：38
- Paprika：18
- EASG：13
- Video-Mined Task Graphs：10
- Structured Procedural Knowledge Extraction：8

这组工作说明社区已经开始往下列方向收敛：

- 从 flat steps 走向 ordinal / contextual steps
- 从纯视觉标签走向 text-knowledge / graph-structured supervision
- 从单步动作识别走向更细粒度的结构单元与跨步骤依赖

它们是我们最值得借力的“中间桥梁”。如果没有这层桥，MT-MG 容易被 reviewer 误以为只是把树和图硬拼起来。

### 3. 低引用但高相关的前沿分支：这是我们真正的邻居

与我们最接近、但因为很新所以引用还低的工作包括：

- VideoLoom：0
- Ego4D Goal-Step：0
- GUIDE：0
- State-Change Counterfactuals：0
- VideoHallucer：4
- EventHallusion：4
- VidHalluc：4
- CaptainCook4D：2
- InstructionBench：0

这组工作的共同特点是：

- **离我们的问题最近**
- **定义了新问题或新 benchmark**
- **还没有来得及积累大规模引用**

因此，写论文时一定要避免一个常见误区：  
**不能因为这些工作引用量低，就把它们写得像边缘工作。恰恰相反，它们是最有可能在审稿时被直接拿来对照的近邻。**

### 4. 对我们研究位置的直接判断

从引用量和主题结构一起看，我认为我们的位置可以概括为：

1. **不是最大主干上的“自然下一步”**  
   最大主干目前仍是 `HowTo100M / YouCook2 / COIN / CrossTask / Action Genome` 这类程序视频与视频表示路线。

2. **是三个前沿分支的交叉点**  
   我们真正站在的是：
   - 宏观任务结构（Ego4D Goal-Step / GUIDE）
   - 微观证据结构（EASG / Action Genome）
   - 幻觉与错误诊断（VideoHallucer / EventHallusion / VidHalluc / CaptainCook4D / SCC）

3. **因此最好的论文口径不是“我们代表整个领域主流”**  
   而是：
   > 我们建立在高引用的 procedural-video / structured-video understanding 地基之上，推进的是一个更新、更尖锐的 frontier problem：evidence-grounded supported generation under long procedural videos.

### 5. 这对论文写作的实际启示

这会直接决定你写论文时的引用策略：

- **背景段落** 必须绑定高引用地基  
  否则 reviewer 会觉得你在一个小众角落自说自话。

- **related work 中心段落** 必须正面回应低引用近邻  
  否则 reviewer 会说你回避了真正最接近的工作。

- **方法贡献表述** 必须明确写成“交叉口问题”  
  不是单纯 procedural understanding，也不是单纯 hallucination benchmark，而是二者之间的 evidence-grounded coupling problem。

---

## 九、结论版排序口径

如果只用一段话概括这份排序，可以写成：

> 与我们工作最直接相关的现有研究可分为四类：一类是以 Ego4D Goal-Step、GUIDE、Paprika、Video-Mined Task Graphs 和 Bridge-Prompt 为代表的宏观程序结构建模；一类是以 Action Genome、EASG 和 Structured Procedural Knowledge Extraction 为代表的微观证据结构建模；一类是以 Assembly101、CaptainCook4D 和 State-Change Counterfactuals 为代表的错误执行与反事实程序监督；还有一类是以 VideoHallucer、EventHallusion、VidHalluc 和 InstructionBench 为代表的 Video-LLM 幻觉诊断与 instructional-video 评测。其中，VideoLoom 是当前与我们整体方向最接近的工作，因为它同样尝试联合时空结构进行视频理解。然而，现有方法仍未显式解决宏观任务意图与微观视觉证据之间的 support sufficiency 闭环建模，这正是 Evidence-Grounded MT-MG 的主要切入点。

---

## 十、最终建议

如果后续要把文献继续收敛为“论文主文必须写”的 shortlist，我建议优先锁定：

- VideoLoom
- EASG
- Ego4D Goal-Step
- State-Change Counterfactuals
- VideoHallucer
- EventHallusion
- Action Genome
- CaptainCook4D
- GUIDE
- Paprika

如果想把 shortlist 从 **10 篇扩成 12 篇**，我建议优先再加：

- Bridge-Prompt
- InstructionBench

如果你只想额外补一篇用于连接 broader Video-LLM 主流评测生态，那么优先加：

- Video-MME

一句话总结这次增补后的判断：

> 你现在这份 related work 主线已经成立；真正需要补的不是再堆更多“差不多”的论文，而是补少数几个能把“早期程序视频 -> 层次结构 -> 微观证据 -> 错误 / 反事实 -> Video-LLM 幻觉评测”这条链条接得更完整的桥梁型工作。
