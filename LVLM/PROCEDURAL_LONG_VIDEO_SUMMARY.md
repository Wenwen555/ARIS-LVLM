# 程序性长视频文献总结：为什么它在 Video-LLM 中并不是“小众方向”

**整理日期**：2026-04-01  
**目的**：回答“程序性长视频会不会太窄”这一问题，并给出可直接用于汇报的数量证据。  

## 一句话结论

如果把“程序性长视频”理解为 `instructional / procedural / task-structured / long-video reasoning` 这一簇问题，那么它在 Video-LLM 中**绝不是边角方向**。  

从三类证据看，这个判断都成立：

1. **近邻核心文献中占比高**：在当前课题最相关的 20 篇核心文献里，至少有 `15/20 = 75%` 直接属于程序性长视频、程序结构建模、程序错误/反事实监督或其数据基础。
2. **arXiv 检索占比不低**：以 `video llm` 为检索锚点，和 `instructional / procedural / long video` 共现的结果约占 `36.1%`；即便使用更保守的结构化 procedural 关键词，仍有 `22.0%`。
3. **主流 benchmark 和数据集持续加码**：从 `COIN / CrossTask / YouCook2 / Assembly101` 到 `Ego4D Goal-Step / EASG / InstructionBench / Video-MME / TempCompass`，社区一直在用更大规模、更长时序、更强结构化标注来推动这个方向。

因此，更准确的表述不是“这个领域窄”，而是：

> 这是在更大的 Video-LLM 长视频理解与证据驱动推理问题中，一个有清晰结构、强数据基础、并且已被 benchmark 反复验证的重要子方向。

---

## 二、这个方向到底包含什么

这里的“程序性长视频”不应只狭义理解为“做菜视频”或“教程视频”，而应理解为一类具有以下共同特征的长视频任务：

- 视频包含明确的 `goal-step-substep` 结构；
- 理解必须依赖步骤顺序、状态变化、对象交互和阶段切换；
- 错误往往不是“看错一帧”，而是“把整个过程理解错了”；
- Video-LLM 容易在证据不足时，沿着常识或语言先验继续生成。

这也是它与 Video-LLM 三个主流难点天然重叠的原因：

1. **long-video understanding**
2. **temporal reasoning**
3. **grounding / hallucination suppression**

换句话说，程序性长视频不是与主流 Video-LLM 脱节的特殊角落，而是上述三个主流问题的交叉点。

---

## 三、文献演进脉络

### 1. 早期基础：从 step segmentation 到 procedure learning

- [YouCook2](https://arxiv.org/abs/1703.09788) 把问题明确成“从长视频中自动学习 procedure segments”。
- [CrossTask](https://arxiv.org/abs/1903.08225) 强调跨任务共享与弱监督学习，让 step learning 不再依赖昂贵强标注。
- [COIN](https://arxiv.org/abs/1903.02874) 把程序视频扩展到 `11,827` 个视频、`180` 个任务、`12` 个 domain，说明程序性视频并不是一个只局限于少量 toy tasks 的小数据方向。

这一阶段的核心贡献是：研究社区已经把“程序视频”从普通动作识别中分离出来，承认它是一类需要长程流程建模的问题。

### 2. 结构升级：从步骤序列到层次任务结构

- `Ego4D Goal-Step`（NeurIPS 2023）把程序活动显式组织成 `goals - steps - substeps` 层级，并提供 `48K` procedural step segments（`430` 小时）以及 `2,807` 小时的 goal annotations。
- [Video-Mined Task Graphs](https://arxiv.org/abs/2307.08763) 说明 task graph 可以直接从 how-to videos 中自动挖掘出来，而不必完全依赖手工脚本。
- [Paprika](https://arxiv.org/abs/2303.18230) 进一步把 procedural knowledge graph 用作预训练监督接口，说明“程序结构”已经不只是分析对象，而开始成为 representation learning 的核心中介。

这一阶段的关键信号是：程序性长视频不再只是“切步骤”，而是开始进入“任务图、层次结构、程序知识”的阶段。

### 3. 微观证据层：从步骤走向对象、关系和状态变化

- [Action Genome](https://arxiv.org/abs/1912.06992) 提供视频 scene graph 的基础表达。
- [EASG](https://arxiv.org/abs/2312.03391) 则把这一思路推进到 `long-form egocentric video`，引入随时间演化的 action scene graph，用对象、关系和动作展开过程理解。

这一阶段很重要，因为它把“程序结构”与“视觉证据”真正接近了一步，也为后续做 evidence-grounded Video-LLM 提供了最自然的结构基础。

### 4. Video-LLM 阶段：从理解任务到 benchmark 与诊断

- [InstructionBench](https://arxiv.org/abs/2504.05040) 明确把 **instructional video understanding benchmark** 放到 Video-LLM 语境下，包含 `5k` questions、`700+` videos，并额外提供 `19k+` Q&A / `~2.5k` videos 的扩展资源。
- [TempCompass](https://arxiv.org/abs/2403.00476) 直接指出现有 Video-LLM 在 temporal perception 上存在系统性短板，并评测了 `8` 个 Video-LLMs 和 `3` 个 Image-LLMs。
- [Video-MME](https://arxiv.org/abs/2405.21075) 作为更 broad 的主流 benchmark，明确把视频时长覆盖到 `11` 秒到 `1` 小时，包含 short / medium / long-term 三档，说明长视频与时序理解已经进入主流 Video-LLM 评测框架。

这说明在 Video-LLM 时代，程序性长视频并没有被边缘化，反而正被纳入 benchmark 化、标准化和大模型化的主赛道。

---

## 四、数量证据：为什么说“占比不低”

### 证据 A：在当前课题的近邻核心文献中，占比很高

以 [`LVLM/Related_Work_Rank.md`](./Related_Work_Rank.md) 当前整理的 `20` 篇核心文献为样本，可以把其中直接属于程序性长视频或其直接支撑路线的工作划为以下几类：

- 程序视频基础数据与任务：`YouCook2 / CrossTask / COIN / Assembly101 / TIPS / DistantSup`
- 宏观程序结构：`Ego4D Goal-Step / GUIDE / Video-Mined Task Graphs / Paprika`
- 微观证据结构：`EASG / Structured Procedural Knowledge Extraction`
- 程序错误与反事实：`State-Change Counterfactuals / CaptainCook4D`
- 大规模程序视频预训练基础：`HowTo100M`

按这个口径统计：

- **直接 procedural/long-video 相关工作数**：`15 / 20 = 75.0%`
- **这些工作的累计引用量**（按当前文档中的 OpenAlex/COCI 统计口径）：`1430 / 1649 = 86.7%`

这说明一件事：**在与你当前问题真正贴近的文献邻域里，程序性长视频不是少数派，而是主干部分。**

需要说明的是，这组统计来自“课题近邻语料”，天然会偏向你的研究方向，因此它更适合用来证明“这不是孤立问题”，而不是用来代表整个 Video-LLM 社区的绝对全貌。

### 证据 B：arXiv 检索下，这个方向在 Video-LLM 语料中的比例不低

为避免只看自己整理的文献，这里额外用 arXiv API 做了一个粗粒度但可复现的检索统计。检索日期为 `2026-04-01`。

| 检索式 | 结果数 | 占基准比例 | 解释 |
|------|------:|------:|------|
| `all:\"video llm\"` | 191 | 100% | 作为 Video-LLM 锚点语料 |
| `(all:\"video llm\") AND (all:\"instructional\" OR all:\"procedural\" OR all:\"long video\")` | 69 | 36.1% | broad procedural-long-video 口径 |
| `(all:\"video llm\") AND (all:\"instructional\" OR all:\"procedure\" OR all:\"goal-step\" OR all:\"task graph\" OR all:\"assembly\" OR all:\"egocentric\")` | 42 | 22.0% | 更保守、更结构化 procedural 口径 |
| `all:\"video-language model\"` | 188 | 100% | 第二个锚点语料 |
| `(all:\"video-language model\") AND (all:\"instructional\" OR all:\"procedural\" OR all:\"long video\")` | 54 | 28.7% | broad 口径的鲁棒性对照 |

这组数字至少支持两个判断：

1. 即便采用更保守的关键词集合，程序性长视频 / 结构化长视频相关结果也达到了 `22%` 左右，已经不能算“小众角落”。
2. 如果把 `long video` 作为程序性长视频的自然外延纳入，比例会升到 `28.7% ~ 36.1%`，说明该方向与 long-video 主赛道高度重叠。

这组检索的局限也需要明确说明：

- arXiv 是关键词共现统计，不是人工逐篇判定；
- 它更适合用来反映“研究注意力”和“话题覆盖”，不适合声称为严格的学科 census；
- 但用于回答“这个方向是否太窄”，已经足够有力。

### 证据 C：benchmark 和数据资源在持续扩张，而不是缩小

下面这些数据最能说明社区并没有把这个方向当作边缘题材：

| 资源 | 年份 | 数据/规模信号 | 说明 |
|------|------|------|------|
| [YouCook2](https://arxiv.org/abs/1703.09788) | 2018 | 大规模 cooking instructional videos | 程序分段与程序学习的起点 |
| [COIN](https://arxiv.org/abs/1903.02874) | 2019 | `11,827` videos, `180` tasks, `12` domains | 明确证明程序视频不是单一垂类 |
| [Assembly101](https://arxiv.org/abs/2203.14712) | 2022 | `4,321` videos, `100K+` coarse / `1M+` fine-grained segments | 长视频、错误、纠正、顺序变体都被显式建模 |
| `Ego4D Goal-Step` | 2023 | `48K` procedural step segments（`430h`）+ `2,807h` goals | 层次程序结构正式大规模化 |
| [EASG](https://arxiv.org/abs/2312.03391) | 2024 | 长程 egocentric action scene graphs | 微观证据结构进入长视频领域 |
| [InstructionBench](https://arxiv.org/abs/2504.05040) | 2025 | `5k` Qs / `700+` videos；另有 `19k+` Q&A / `~2.5k` videos | procedural understanding 直接进入 Video-LLM benchmark |
| [Video-MME](https://arxiv.org/abs/2405.21075) | 2025 | `900` videos, `254h`, `2,700` QAs, 覆盖 `11s-1h` | 主流 benchmark 已把 long-video 时序理解写进标准评测 |
| [TempCompass](https://arxiv.org/abs/2403.00476) | 2024 | 评测 `8` 个 Video-LLMs + `3` 个 Image-LLMs | temporal perception 已是社区共同诊断问题 |

如果一个方向真的很窄，通常会出现三个现象：数据少、任务单一、benchmark 缺席。  
而程序性长视频刚好相反：**数据在扩、结构在深、benchmark 在增。**

---

## 五、对汇报最有用的表述方式

### 1. 最稳的回答版本

> 如果把程序性长视频只理解成“教程视频”，听起来好像会有点窄；但如果从 Video-LLM 的研究问题来看，它对应的是 long-video understanding、temporal reasoning 和 evidence grounding 三个主流难点的交叉点。  
> 从数据上看，这个方向并不小：在我当前最相关的 20 篇核心文献里，75% 都直接落在程序性长视频及其结构化建模上；而在 arXiv 的 Video-LLM 检索结果里，和 instructional / procedural / long-video 共现的比例大约在 22% 到 36% 之间。再加上 InstructionBench、Video-MME、TempCompass 这些 benchmark 都在持续加码时序和长视频理解，所以我更倾向于把它理解成 Video-LLM 主问题里的一个高价值切口，而不是一个边缘小题。


---

## 六、建议你在报告里怎么用

如果你要把这份总结嵌回主报告，最建议加在 `Introduction / Research Positioning` 里的不是大量 paper list，而是下面这三句话：

1. **大领域**：我们关心的是 Video-LLM 在长视频中的证据驱动理解与幻觉抑制。  
2. **落地点**：程序性长视频是这一大问题中结构最清晰、最适合机制验证的子场景。  
3. **数量依据**：无论看近邻文献、arXiv 检索，还是主流 benchmark，程序性长视频都已经形成稳定研究簇，并不属于边缘方向。  

---

## 七、来源与说明

### 本地整理

- [`LVLM/Related_Work_Rank.md`](./Related_Work_Rank.md)
- [`LVLM/COMPREHENSIVE_REPORT.md`](./COMPREHENSIVE_REPORT.md)

### 关键论文与 benchmark 页面

- [YouCook2](https://arxiv.org/abs/1703.09788)
- [CrossTask](https://arxiv.org/abs/1903.08225)
- [COIN](https://arxiv.org/abs/1903.02874)
- [Assembly101](https://arxiv.org/abs/2203.14712)
- [Paprika](https://arxiv.org/abs/2303.18230)
- [Video-Mined Task Graphs](https://arxiv.org/abs/2307.08763)
- [EASG](https://arxiv.org/abs/2312.03391)
- [InstructionBench](https://arxiv.org/abs/2504.05040)
- [TempCompass](https://arxiv.org/abs/2403.00476)
- [Video-MME](https://arxiv.org/abs/2405.21075)
- [Ego4D Goal-Step (NeurIPS 2023)](https://proceedings.neurips.cc/paper_files/paper/2023/hash/7a65606fa1a6849450550325832036e5-Abstract-Datasets_and_Benchmarks.html)

