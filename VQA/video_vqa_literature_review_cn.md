# Video Visual Question Answering 文献调研（Benchmark / Data-centric 聚焦版）

## 说明

- **主题收窄**：本版不再做泛泛的 Video QA / Video-LLM 方法综述，而是**聚焦 benchmark、dataset、evaluation、data-centric setting**。
- **目标**：回答两个问题：
  1. Video VQA / Video QA 领域有哪些关键的数据集、评测集和评测协议？
  2. 到 **2026-04-03** 为止，这条线在 2022–2026 期间是如何演化的，是否有遗漏？
- **排序方式**：按时间从新到旧。
- **标注规则**：
  - **严格相关**：明确属于 Video QA / Video VQA 的 benchmark、dataset、evaluation setting。
  - **邻近相关**：不是严格的 Video QA 数据集，但对 video-language QA / Video-LLM 的视频问答评测有直接影响。

---

# 1. 2026（截至 2026-04-03）

## 1.1 VideoZeroBench: Probing the Limits of Video MLLMs with Spatio-Temporal Evidence Verification
- **时间**：2026-04-02
- **地址**：https://arxiv.org/abs/2604.01569
- **发表会议/期刊/平台**：arXiv
- **类别**：邻近相关
- **目标 / 解决的问题**：
  - 面向 Video MLLM 的评测正在从“答对没有”转向“证据是否真实、时空定位是否可信”，该工作试图弥补仅看最终答案的不足。
- **做法 / 贡献**：
  - 提出强调 **spatio-temporal evidence verification** 的视频评测基准。
  - 对本文综述的重要性在于：它代表了 2026 年初视频问答/视频语言评测继续走向“答案 + 证据”双重考察的趋势。
- **不足**：
  - 截至 2026-04-03 仍是最新预印本，尚未形成充分社区共识。
  - 更偏 Video-MLLM evaluation benchmark，而不是传统 strict Video QA dataset。

## 1.2 2026 年这一段为什么仍不能省略
- **时间**：截至 2026-04-03
- **地址**：本节为检索结论，具体检索来源见文末 Sources
- **发表会议/期刊/平台**：arXiv / OpenReview / CVPR OpenAccess / ACL Anthology 等公开入口
- **目标 / 解决的问题**：
  - 明确回答：为什么 2026 这一段不能空缺，以及当前是否已经出现了足够稳定的新 benchmark / dataset 节点。
- **做法 / 贡献**：
  - 针对 **video question answering benchmark / dataset / evaluation / data-centric** 做了额外检索。
  - 检索结果显示：**截至 2026-04-03 的公开可检索文献中，已能看到 VideoZeroBench 这类值得记录的新预印本评测工作，但尚未发现已被社区广泛采用、且足以与 MVBench、Video-MME、LongVideoBench 并列的新稳定 milestone。**
  - 因此，2026 年更合理的写法不是“没有内容”，也不是“硬造一个公认代表作”，而是：**列出当前可确认的新候选工作，并同时说明其尚未沉淀为稳定共识。**
- **不足**：
  - 该结论有时效性，随着 2026 年后续论文公开，可能需要更新。
  - 某些 2026 工作可能尚在投稿、尚未被稳定索引、或还未形成社区共识。

> 因此，2026 年这一节**不能删除**；截至 2026-04-03，更严谨的写法是：**已经出现值得关注的新评测候选（如 VideoZeroBench），但尚未出现公认的新 benchmark/data-centric 稳定里程碑。**

---

# 2. 2025

## 2.1 Open-Ended and Knowledge-Intensive Video Question Answering
- **时间**：2025-02
- **地址**：https://arxiv.org/abs/2502.11747
- **发表会议/期刊/平台**：arXiv
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 面向 **open-ended**、**knowledge-intensive** 的 Video QA 设定，突破传统多选式与浅层匹配式评测。
- **做法 / 贡献**：
  - 强化了 Video QA 中的开放式回答设置与知识需求。
  - 对 benchmark/evaluation 角度的重要性在于：它提示评测不应只围绕封闭式正确率，而要考虑开放生成与知识密集型问题。
- **不足**：
  - 它更偏 **evaluation setting / task reformulation**，不是典型的大型 benchmark 汇总论文。
  - 开放式问答的自动评测稳定性仍是难点。

## 2.2 V-STaR: Benchmarking Video-LLMs on Video Spatio-Temporal Reasoning
- **时间**：2025-03
- **地址**：https://arxiv.org/abs/2503.11495
- **发表会议/期刊/平台**：arXiv
- **类别**：邻近相关
- **目标 / 解决的问题**：
  - 评估 Video-LLM 的时空推理能力，避免模型只靠静态线索或语言先验获得高分。
- **做法 / 贡献**：
  - 提出面向 **video spatio-temporal reasoning** 的诊断 benchmark。
  - 对 Video QA 很重要，因为时空推理是 Video QA 的核心能力之一。
- **不足**：
  - 更偏 Video-LLM 评测，而不是传统 Video QA benchmark。
  - 仍以评测为主，不是数据集生态的唯一代表作。

---

# 3. 2024

## 3.1 LongVideoBench: A Benchmark for Long-context Interleaved Video-Language Understanding
- **时间**：2024-07
- **地址**：https://arxiv.org/abs/2407.15754
- **发表会议/期刊/平台**：arXiv
- **类别**：邻近相关
- **目标 / 解决的问题**：
  - 解决传统 Video QA 对短上下文过度依赖的问题，评估长视频与交织文本上下文理解。
- **做法 / 贡献**：
  - 提出面向长上下文的视频-语言 benchmark。
  - 对长视频问答、跨段证据整合、长程依赖分析非常关键。
- **不足**：
  - 更偏 long-context video-language understanding，而非纯传统 Video QA。
  - benchmark 很强，但和具体应用任务的映射还需更多实践验证。

## 3.2 MLVU: Benchmarking Multi-task Long Video Understanding
- **时间**：2024-06
- **地址**：https://arxiv.org/abs/2406.04264
- **发表会议/期刊/平台**：arXiv
- **类别**：邻近相关
- **目标 / 解决的问题**：
  - 长视频理解不能只看单一问答指标，需要多任务综合评测。
- **做法 / 贡献**：
  - 提出 multi-task long video benchmark。
  - 体现出 2024 年 Video QA 研究从“单 benchmark 刷分”转向“长视频综合能力画像”。
- **不足**：
  - 更偏综合评测。
  - 对具体错误类型的解释性不如专门的 QA benchmark。

## 3.3 VideoVista: A Versatile Benchmark for Video Understanding and Reasoning
- **时间**：2024-06
- **地址**：https://arxiv.org/abs/2406.11303
- **发表会议/期刊/平台**：arXiv
- **类别**：邻近相关
- **目标 / 解决的问题**：
  - 提供更广谱的视频理解与推理评测平台。
- **做法 / 贡献**：
  - 面向综合视频理解与 reasoning 的 benchmark。
  - 对 Video QA 的意义在于：它把问答能力放回更大的视频推理评测框架中考察。
- **不足**：
  - 任务范围很广，不完全等同于 Video QA benchmark。
  - 广覆盖可能牺牲某些细分 QA 能力的深刻画。

## 3.4 Video-MME: The First-Ever Comprehensive Evaluation Benchmark of Multi-modal LLMs in Video Analysis
- **时间**：2024-05
- **地址**：https://arxiv.org/abs/2405.21075
- **发表会议/期刊/平台**：arXiv
- **类别**：邻近相关
- **目标 / 解决的问题**：
  - 为 Video-LLM 建立系统、统一的视频分析 benchmark。
- **做法 / 贡献**：
  - 已成为高频使用的视频多模态评测基准之一。
  - 重要意义不在于“单项 Video QA”，而在于统一了视频分析能力的比较语境。
- **不足**：
  - 更偏综合多模态视频分析 benchmark。
  - 总分并不总能准确反映推理质量与证据质量。

## 3.5 TempCompass: Do Video LLMs Really Understand Videos?
- **时间**：2024-03
- **地址**：https://arxiv.org/abs/2403.00476
- **发表会议/期刊/平台**：arXiv
- **类别**：邻近相关
- **目标 / 解决的问题**：
  - 检验 Video-LLM 是否真的具备稳健的时间理解能力，而不是只利用静态帧或语言先验取得表面高分。
- **做法 / 贡献**：
  - 提出专门面向 **temporal understanding** 的诊断式 benchmark。
  - 对 Video QA / video-language QA 文献脉络的意义很强，因为它把“时序理解是否被高估”变成了可系统测试的问题。
- **不足**：
  - 更偏 Video-LLM evaluation，而不是传统 strict Video QA dataset。
  - 其诊断性很强，但与经典 Video QA benchmark 的任务形式不完全一致。

## 3.6 STAIR: Spatial-Temporal Reasoning with Auditable Intermediate Results for Video Question Answering
- **时间**：2024-01
- **地址**：https://arxiv.org/abs/2401.03901
- **发表会议/期刊/平台**：arXiv
- **类别**：严格相关
- **目标 / 解决的问题**：
  - Video QA 评测不能只看最终答案，还要看中间推理是否可审计、是否能解释答案来源。
- **做法 / 贡献**：
  - 强调 **auditable intermediate results**。
  - 对 evaluation 的意义很大：它把可解释性与中间证据质量放到和最终准确率同等重要的位置。
- **不足**：
  - 更偏 evaluation protocol / interpretability，而非大型 benchmark 构建。
  - 需要更广泛实验才能成为标准协议。

## 3.7 MovieChat+: Question-aware Sparse Memory for Long Video Question Answering（补充说明：偏方法）
- **时间**：2024-04
- **地址**：https://arxiv.org/abs/2404.17176
- **发表会议/期刊/平台**：arXiv
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 长视频 Video QA 中，评测的核心难点是是否保留了与问题相关的证据。
- **做法 / 贡献**：
  - 提出 question-aware sparse memory。
  - 虽然它更偏方法，但其问题设定与分析角度非常 data-/evaluation-centric，直接服务于 long video QA 场景。
- **不足**：
  - 严格说不是 benchmark 论文。
  - 因而更适合作为补充说明，而非本综述的核心 benchmark 条目。

---

# 4. 2023

## 4.1 MVBench: A Comprehensive Multi-modal Video Understanding Benchmark
- **时间**：2023-11
- **地址**：https://arxiv.org/abs/2311.17005
- **发表会议/期刊/平台**：arXiv
- **类别**：邻近相关
- **目标 / 解决的问题**：
  - 为 Video-LLM 提供统一综合评测平台，而不局限于单一 Video QA 数据集。
- **做法 / 贡献**：
  - 是 2023 年后 Video benchmark 爆发的关键节点之一。
  - 为后续 Video-MME、TempCompass 等工作提供了对照系。
- **不足**：
  - 并不等同于严格 Video QA benchmark。
  - 更适合综合评测而非单任务精细分析。

## 4.2 PerceptionTest: A Diagnostic Benchmark for Multimodal Video Models
- **时间**：2023
- **地址**：https://www.perceptiontest.org/
- **发表会议/期刊/平台**：benchmark 官网 / 对应论文与数据发布体系
- **类别**：邻近相关
- **目标 / 解决的问题**：
  - 诊断多模态视频模型是否真正理解视频中的细粒度感知、事件关系与多模态线索，而不是依赖表面相关性。
- **做法 / 贡献**：
  - 提供面向视频模型的 diagnostic benchmark。
  - 虽不是 strict Video QA benchmark，但对 2023–2025 的 video-language QA / Video-LLM 评测体系影响很大，适合作为邻近相关条目纳入。
- **不足**：
  - 任务范围比传统 Video QA 更广。
  - 更偏综合视频感知诊断，而非单一问答任务数据集。

## 4.3 EgoSchema: A Diagnostic Benchmark for Very Long-form Video Language Understanding
- **时间**：2023-08
- **地址**：https://arxiv.org/abs/2308.09126
- **发表会议/期刊/平台**：arXiv
- **类别**：邻近相关
- **目标 / 解决的问题**：
  - 缺少针对超长第一视角视频理解的可靠 benchmark。
- **做法 / 贡献**：
  - 提供 very long-form video-language diagnostic benchmark。
  - 对长视频问答、记忆保持、事件串联评测非常有参考价值。
- **不足**：
  - 数据域偏第一视角。
  - 更偏诊断 benchmark，而非传统 Video QA 数据集。

## 4.4 Confidence-based Event-centric Online Video Question Answering on a Newly Constructed ATBS Dataset
- **时间**：2023-03
- **地址**：https://arxiv.org/abs/2303.03105
- **发表会议/期刊/平台**：arXiv
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 研究在线 Video QA 场景，解决“边看边答”条件下的事件中心问答问题。
- **做法 / 贡献**：
  - 提出 **newly constructed ATBS dataset**。
  - 把 Video QA 的设定从离线整段视频扩展到在线处理场景，是很典型的 data-centric 扩展。
- **不足**：
  - 影响范围不如 NExT-QA、EgoSchema、MVBench 这类 benchmark 广。
  - 更偏特定任务设定。

## 4.5 EgoTaskQA: Understanding Human Tasks in Egocentric Videos
- **时间**：2022-10
- **地址**：https://arxiv.org/abs/2210.03929
- **发表会议/期刊/平台**：arXiv
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 面向第一视角视频中的任务理解与任务型问答，弥补传统 Video QA 对 egocentric task understanding 覆盖不足的问题。
- **做法 / 贡献**：
  - 构建聚焦 **human tasks in egocentric videos** 的 Video QA benchmark / dataset。
  - 对 2022–2023 这条线很重要，因为它把 Video QA 明确扩展到 egocentric、task-oriented 的数据设定。
- **不足**：
  - 场景集中在第一视角任务视频，通用性有限。
  - 社区影响力不如 MVBench、EgoSchema 这类后续综合 benchmark。

## 4.6 Video-ChatGPT: Towards Detailed Video Understanding via Large Vision and Language Models
- **时间**：2023-06
- **地址**：https://arxiv.org/abs/2306.05424
- **发表会议/期刊/平台**：arXiv
- **类别**：邻近相关
- **目标 / 解决的问题**：
  - 将开放式视频问答推广到大模型对话框架。
- **做法 / 贡献**：
  - 虽不是 benchmark 论文，但它极大推动了 2023–2024 的视频评测需求爆发。
  - 可以作为“为什么 2024 benchmark 激增”的上游背景工作。
- **不足**：
  - 不属于 data-centric / benchmark 主体条目。
  - 若综述严格收窄，可只在脉络中简述，不放入主表。

---

# 5. 2022

## 5.1 WildQA: In-the-Wild Video Question Answering
- **时间**：2022-09
- **地址**：https://arxiv.org/abs/2209.06650
- **发表会议/期刊/平台**：arXiv
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 解决受控数据集过于整洁的问题，面向更真实、开放、复杂的 in-the-wild 视频问答。
- **做法 / 贡献**：
  - 明显属于 benchmark / dataset 路线。
  - 引入更真实场景中的视频问答与 evidence selection 问题。
  - 是 2022 年非常值得补入的 data-centric 条目。
- **不足**：
  - 真实场景带来更高噪声与标注难度。
  - 评测一致性和数据清洗成本更高。

## 5.2 NEWSKVQA: Knowledge-Aware News Video Question Answering
- **时间**：2022-02
- **地址**：https://arxiv.org/abs/2202.04015
- **发表会议/期刊/平台**：arXiv
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 面向新闻视频中的知识感知问答，解决“仅靠视觉内容不够答题”的问题。
- **做法 / 贡献**：
  - 构建面向新闻视频与外部知识结合的 Video QA 数据集/任务设定。
  - 代表了 domain-specific、knowledge-aware 的 data-centric 扩展方向。
- **不足**：
  - 领域特化较强。
  - 新闻场景的知识需求与通用视频场景之间有分布差异。

## 5.3 FrozenBiLM: A Joint Video and Image Encoder for End-to-End Retrieval and Question Answering
- **时间**：2022
- **地址**：https://arxiv.org/abs/2206.00693
- **发表会议/期刊/平台**：NeurIPS 2022 / arXiv
- **类别**：邻近相关
- **目标 / 解决的问题**：
  - 通过统一图像-视频编码与语言建模处理 retrieval 和 question answering。
- **做法 / 贡献**：
  - 它不是 data-centric benchmark 论文，但对 2022 年之后“统一 video-language QA 范式”有重要过渡意义。
- **不足**：
  - 不是本综述主线中的核心 benchmark/data 条目。
  - 若需要进一步收窄，可移入背景部分。

## 5.4 2022 年这一段的补充判断
- **时间**：2022
- **目标 / 解决的问题**：
  - 说明 2022 年在这条线中的位置，避免把它误读成“缺少代表作”的空档年。
- **做法 / 贡献**：
  - 从当前能确认的条目看，2022 年更像是从 2021 年的推理型/长视频 benchmark，过渡到后续 **in-the-wild、domain-specific、knowledge-aware、egocentric/task-oriented** 设定扩展的一年。
  - 因而 2022 的意义不在于出现一个绝对统治性的统一 benchmark，而在于数据分布和任务边界开始明显扩张。
- **不足**：
  - 这一年的 benchmark 影响力整体不如 2023–2024 的综合评测爆发期。
  - 各条扩展路线较分散，社区共识尚未完全收束。

---

# 6. 2021

## 6.1 STAR: A Benchmark for Situated Reasoning in Real-World Videos
- **时间**：2021
- **地址**：https://bobbywu.com/STAR/
- **发表会议/期刊/平台**：NeurIPS 2021
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 评估真实世界视频中的 situated reasoning，而不只是浅层事件识别。
- **做法 / 贡献**：
  - 是 Video QA benchmark 史上的关键节点之一。
  - 把意图、因果、交互等高层推理纳入评测。
- **不足**：
  - 题型设计依然可能带来模板偏置。
  - benchmark 贡献强于方法贡献。

## 6.2 NExT-QA: Next Phase of Question-Answering to Explaining Temporal Actions
- **时间**：2021
- **地址**：https://openaccess.thecvf.com/content/CVPR2021/html/Xiao_NExT-QA_Next_Phase_of_Question-Answering_to_Explaining_Temporal_Actions_CVPR_2021_paper.html
- **发表会议/期刊/平台**：CVPR 2021
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 从动作识别转向 temporal / causal explanation 的问答评测。
- **做法 / 贡献**：
  - 是 Video QA 从“识别型 benchmark”走向“解释型 benchmark”的关键一步。
- **不足**：
  - 仍以 benchmark 为主。
  - 与真实开放式长视频场景相比复杂度有限。

## 6.3 How2QA: A Dataset for Multimodal Long-Form Video Question Answering
- **时间**：2021
- **地址**：https://arxiv.org/abs/2104.00727
- **发表会议/期刊/平台**：arXiv
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 引入长视频、多模态条件下的 Video QA benchmark。
- **做法 / 贡献**：
  - 是长视频 Video QA 的重要早期代表作。
- **不足**：
  - 数据域偏教程类视频。
  - 容易对字幕产生依赖。

---

# 7. 2020 及以前的基础 benchmark

## 7.1 Video Question Answering on Screencast Tutorials
- **时间**：2020-08
- **地址**：https://arxiv.org/abs/2008.00544
- **发表会议/期刊/平台**：arXiv
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 面向 screencast tutorial 场景构建更具领域特性的 Video QA 数据。
- **做法 / 贡献**：
  - 属于较早、很典型的 data-centric Video QA 工作之一。
  - 强调 domain grounding。
- **不足**：
  - 场景较专门。
  - 对通用视频的迁移有限。

## 7.2 ActivityNet-QA: A Dataset for Understanding Complex Web Videos via Question Answering
- **时间**：2019
- **地址**：https://arxiv.org/abs/1906.02467
- **发表会议/期刊/平台**：AAAI 2019 / arXiv
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 为复杂 web 视频构建开放域问答 benchmark。
- **做法 / 贡献**：
  - 是开放域 Video QA benchmark 的经典条目。
- **不足**：
  - 语言偏置仍存在。
  - 证据定位不够细。

## 7.3 MSRVTT-QA: Visual Question Answering on MSR-VTT Videos
- **时间**：2019
- **地址**：https://arxiv.org/abs/1905.05010
- **发表会议/期刊/平台**：arXiv
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 提供标准化短视频问答 benchmark，用于模型横向比较。
- **做法 / 贡献**：
  - 与 MSVD-QA 一起构成许多 Video QA 论文的基础对比集。
- **不足**：
  - 偏短视频。
  - 高层推理能力评估有限。

## 7.4 TVQA: Localized, Compositional Video Question Answering
- **时间**：2018
- **地址**：https://aclanthology.org/D18-1167/
- **发表会议/期刊/平台**：EMNLP 2018
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 在视频、字幕、对白中定位证据并做组合推理。
- **做法 / 贡献**：
  - 是最经典的多模态 Video QA benchmark 之一。
- **不足**：
  - 易出现“读字幕答题”。
  - 多为多选题。

## 7.5 MSVD-QA: Video Question Answering on MSVD Dataset
- **时间**：2018
- **地址**：https://arxiv.org/abs/1812.02141
- **发表会议/期刊/平台**：arXiv
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 提供早期标准化短视频问答 benchmark。
- **做法 / 贡献**：
  - 长期作为基础对比集使用。
- **不足**：
  - 规模和复杂度有限。
  - 难以评估高层推理与长视频能力。

## 7.6 TGIF-QA: Toward Spatio-Temporal Reasoning in Visual Question Answering
- **时间**：2017
- **地址**：https://openaccess.thecvf.com/content_cvpr_2017/html/Jang_TGIF-QA_Toward_Spatio-Temporal_CVPR_2017_paper.html
- **发表会议/期刊/平台**：CVPR 2017
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 将问答从静态图像推进到动态图像/GIF 的时空推理。
- **做法 / 贡献**：
  - 是视频问答 benchmark 历史上的起点之一。
- **不足**：
  - GIF 场景较简单。
  - 存在模板偏置。

## 7.7 MovieQA: Understanding Stories in Movies through Question-Answering
- **时间**：2016
- **地址**：https://openaccess.thecvf.com/content_cvpr_2016/html/Tapaswi_MovieQA_Understanding_Stories_CVPR_2016_paper.html
- **发表会议/期刊/平台**：CVPR 2016
- **类别**：严格相关
- **目标 / 解决的问题**：
  - 推动电影故事理解中的问答研究。
- **做法 / 贡献**：
  - 为后续叙事型视频问答 benchmark 奠基。
- **不足**：
  - 很容易借助文本旁路答题。
  - 纯视觉能力不易单独评估。

---

# 8. 清晰脉络：Benchmark / Data-centric 视角下的演化主线

## 8.1 第一阶段：把图像 VQA 扩展到视频（2016–2019）
代表工作：MovieQA、TGIF-QA、MSVD-QA、TVQA、MSRVTT-QA、ActivityNet-QA

这一阶段的核心是：
- 先把 **Video QA 作为任务定义出来**；
- 再建立一批可以横向比较的 benchmark；
- 但同时暴露出语言偏置、字幕依赖、短视频局限等问题。

## 8.2 第二阶段：把“高层理解”纳入 benchmark（2021）
代表工作：How2QA、NExT-QA、STAR

这一阶段的变化是：
- 不再只问表层动作识别；
- 开始问因果、解释、意图、长程依赖；
- benchmark 从“识别型”走向“推理型”和“长视频型”。

## 8.3 第三阶段：data-centric 扩展到更真实、更专门场景（2022–2023）
代表工作：WildQA、NEWSKVQA、EgoTaskQA、ATBS Dataset

这一阶段的核心是：
- 从干净 benchmark 走向 **in-the-wild**；
- 从通用视频走向 **新闻、教程、在线处理、第一视角任务理解** 等专门场景；
- 说明社区开始意识到：**数据分布与任务设定本身就是研究问题**。

## 8.4 第四阶段：Video-LLM 倒逼 benchmark 爆发（2023–2026）
代表工作：MVBench、PerceptionTest、EgoSchema、TempCompass、Video-MME、VideoVista、MLVU、LongVideoBench、V-STaR、VideoZeroBench

这一阶段的关键变化是：
- 以前的 benchmark 已不足以评估 Video-LLM；
- 社区开始重新问：
  - 模型是否真的理解时间？
  - 是否能处理长视频？
  - 是否能做空间-时间联合推理？
  - 是否能给出可信中间证据？
- 于是 benchmark / diagnostic benchmark / comprehensive evaluation 在 2024 年后集中爆发，并在 2026 年继续朝 **evidence-aware evaluation** 延伸。

## 8.5 2026 的位置：不是“缺失”，而是“出现候选，但尚未形成稳定共识”
截至 2026-04-03，更合理的判断不是“2026 被漏掉了”，而是：
- **2026 年已经出现值得记录的新评测候选（如 VideoZeroBench）；**
- **但截至该日期，尚未看到一个已被社区广泛采用、足以作为新稳定里程碑写入综述的 benchmark/data-centric 节点。**
- 因此综述里应该明确写出这个状态，而不是跳过不写。

---

# 9. 当前最值得关注的研究问题（benchmark / data-centric 视角）

1. **是否仍然存在字幕/语言捷径？**  
   这是从 TVQA 一直到 Video-LLM benchmark 都没有彻底解决的问题。

2. **长视频 benchmark 是否真的测到了“记忆 + 证据定位”？**  
   LongVideoBench、MLVU、EgoSchema 都在尝试回答这个问题。

3. **时序理解是否被高估？**  
   TempCompass、V-STaR 说明很多模型在时间推理上仍不稳。

4. **开放式问答如何评测？**  
   Open-ended and Knowledge-Intensive Video QA 说明，未来评测会越来越依赖开放生成，而不只是多选题。

5. **是否需要更多 domain-specific benchmark？**  
   NEWSKVQA、Screencast Tutorials、ATBS 说明答案很可能是“需要”。

---

# 10. 如果后续写 related work，建议这样分组

## 10.1 基础 Video QA benchmark
- MovieQA
- TGIF-QA
- MSVD-QA
- TVQA
- MSRVTT-QA
- ActivityNet-QA

## 10.2 推理型 / 长视频 benchmark
- How2QA
- NExT-QA
- STAR

## 10.3 data-centric / domain-specific / in-the-wild benchmark
- WildQA
- NEWSKVQA
- Video Question Answering on Screencast Tutorials
- ATBS Dataset

## 10.4 Video-LLM 时代的综合评测 benchmark
- MVBench
- PerceptionTest
- EgoSchema
- TempCompass
- Video-MME
- VideoVista
- MLVU
- LongVideoBench
- V-STaR
- VideoZeroBench

---

# 11. 总结

如果把 Video VQA 的 **benchmark / data-centric** 演化压缩成一句话，可以概括为：

**从短视频与多选式基础 benchmark 出发，逐步扩展到推理型、长视频型、领域型和 in-the-wild 数据集，最终在 Video-LLM 时代演化为大规模综合评测与诊断 benchmark 爆发。**

而对 **2026**，当前更严谨的写法不是把这一段留空，也不是强行列一个“已成定论”的代表作，而是明确说明：

> **截至 2026-04-03，已能检索到 VideoZeroBench 这类值得记录的最新视频评测预印本；但尚未发现一个已被社区广泛采用、且足以作为新稳定里程碑写入本综述的 strict Video QA benchmark / dataset / data-centric 代表作。**

这不是漏写，而是当前文献状态本身的一部分。
