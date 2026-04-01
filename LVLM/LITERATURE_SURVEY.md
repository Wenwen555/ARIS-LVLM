# 文献综述：面向 Video-LLM 幻觉抑制的程序性长视频结构化数据研究

**研究主题**：程序性长视频理解、结构化中间表示、Video-LLM 幻觉抑制  
**更新日期**：2026-04-01  
**写作目标**：在“现有文献的发展 -> 不足 -> 提出方法来解决不足 -> 为了解决这个问题需要做出哪些努力”的逻辑下，系统梳理与 Evidence-Grounded MT-MG 框架直接相关的程序性视频、图结构表示、错误感知数据和视频幻觉评测文献。

---

## 一、执行摘要

从文献发展路径看，程序性视频研究已经经历了四个清晰阶段。

第一阶段，社区主要关注如何把长视频切分成可理解的步骤片段，代表工作是 YouCook2、CrossTask 和 COIN。这一阶段解决了“程序视频能否被 step-level 地描述和评测”的问题，但整体仍停留在平坦的步骤序列层面。

第二阶段，研究开始从步骤序列走向层次化任务结构与弱监督可扩展构建，代表工作包括 HowTo100M、TIPS、DistantSup、Ego4D Goal-Step、GUIDE、Paprika 和 Video-Mined Task Graphs。此时研究重点从“识别步骤”逐步转向“理解目标、步骤依赖和任务结构”。

第三阶段，另一条重要分支开始强调微观证据建模，即对象、动作、关系和状态变化的结构化表达，代表工作包括 Action Genome、EASG 以及 Structured Procedural Knowledge Extraction。这些工作说明，如果只知道“当前是哪个步骤”，却不知道“具体有哪些对象、交互和状态变化作为支持证据”，模型很容易滑向语言猜测。

第四阶段，研究进一步进入错误感知、反事实建模和视频幻觉诊断，代表工作包括 Assembly101、CaptainCook4D、State-Change Counterfactuals、VideoHallucer、EventHallusion 和 VidHalluc。此时社区已经认识到：Video-LLM 的关键问题不仅是“能不能回答”，而是“在证据不足时是否仍然会继续回答”。

因此，现有文献已经分别提供了三类重要“积木”：

- 宏观层面的任务结构：goal-step-substep、guideline、task graph。
- 微观层面的局部事实结构：scene graph、action scene graph、verb-argument tuples。
- 面向鲁棒性的错误与幻觉研究：mistake、counterfactual、hallucination benchmark。

但真正缺失的仍然是一个统一的数据生产与监督接口，使宏观任务意图能够约束微观证据选择，微观证据又能够反证或验证宏观推断。换言之，当前文献大多证明了“宏观结构重要”和“微观证据重要”，却很少真正解决“二者如何形成支持闭环”的问题。

这正是本研究提出 **Evidence-Grounded MT-MG 框架** 的切入点：用 **Macro-Tree** 表达长程任务流程，用 **Micro-Graph** 表达局部视觉证据，再用显式 support relation、意图驱动稀疏化和拓扑反事实扰动来共同服务于 Video-LLM 幻觉抑制。

---

## 二、文献分类框架

为使文献脉络更清晰，本文将相关工作划分为四类：

### 2.1 程序性视频数据集与层次化任务结构

这一类工作关注如何把长视频组织为步骤、任务或目标层次，包括：

- YouCook2
- CrossTask
- COIN
- HowTo100M
- TIPS
- DistantSup
- Ego4D Goal-Step
- GUIDE
- Paprika
- Video-Mined Task Graphs

### 2.2 微观图表示与局部证据建模

这一类工作关注对象、动作、关系、状态变化等细粒度结构，包括：

- Action Genome
- EASG
- Structured Procedural Knowledge Extraction

### 2.3 错误感知、反事实与真实偏差建模

这一类工作关注非理想执行、错误、纠正和反事实监督，包括：

- Assembly101
- CaptainCook4D
- State-Change Counterfactuals

### 2.4 Video-LLM 幻觉诊断与评测

这一类工作从评测和诊断角度研究模型在视频理解中的 hallucination，包括：

- VideoHallucer
- EventHallusion
- VidHalluc

---

## 三、核心文献逐篇综述

### 3.1 YouCook2

**基本信息**
- **标题**：Towards Automatic Learning of Procedures from Web Instructional Videos
- **发表**：AAAI 2018
- **定位**：面向烹饪长视频的程序分段与步骤描述数据集，是程序性视频研究的重要起点之一。

**核心贡献**
- 把网页 instructional video 系统化组织为带有步骤边界和步骤文本描述的长视频数据。
- 将程序视频理解从“整段视频标签”推进到 step-level segmentation 与 dense captioning。

**方法**
- 从网络烹饪视频中构建 procedure segments，并为各步骤提供时间边界和文本描述。
- 以“步骤切分 + 步骤描述”的标注方式定义程序理解任务。

**基准**
- 主要聚焦 cooking domain。
- 适用于 procedure segmentation、dense video captioning、step-level retrieval 等任务。

**主要发现**
- 证明了程序性长视频可以被有效拆分为具有语义边界的步骤单元。
- 为后续 instructional video 研究提供了统一的 step-level 评测入口。

**局限**
- 领域较单一，以烹饪为主。
- 结构仍然偏平坦，缺少 goal-step-substep、object-state 和错误执行等更深层监督。

### 3.2 CrossTask

**基本信息**
- **标题**：Cross-Task Weakly Supervised Learning from Instructional Videos
- **发表**：CVPR 2019
- **定位**：利用步骤顺序和 narration 的弱监督框架学习 ordinary tasks 的步骤视觉模型。

**核心贡献**
- 提出用 ordered step list 和 instructional narrations 替代昂贵的精确时间标注。
- 强调 task 之间的共享结构，为跨任务迁移和步骤对齐提供了新视角。

**方法**
- 使用任务脚本中的有序步骤作为先验。
- 结合 narration 与视频内容进行弱监督步骤学习与对齐。

**基准**
- 覆盖多种 everyday tasks。
- 主要评测 step localization、task understanding 与跨任务共享能力。

**主要发现**
- 仅依赖弱监督信号也可以学到有用的步骤表示。
- 程序知识不一定必须来自昂贵的逐帧标注，也可以来自任务脚本和语音描述。

**局限**
- 结构本质上仍是“task -> ordered steps”，缺少更高层目标语义。
- 没有显式建模对象交互、状态变化和局部视觉证据。

### 3.3 COIN

**基本信息**
- **标题**：COIN: A Large-Scale Dataset for Comprehensive Instructional Video Analysis
- **发表**：CVPR 2019
- **定位**：面向多领域 instructional video 的大规模数据集，强调 domain-task-step 的层次组织。

**核心贡献**
- 把程序性视频从单一 cooking 场景扩展到多领域、多任务设置。
- 明确提出 domain-task-step 的层次框架，推动程序理解走向更通用的现实任务空间。

**方法**
- 汇集多域 instructional videos，并提供任务、步骤和时间边界等标注。
- 以综合性 instructional video analysis 为目标设计评测任务。

**基准**
- 覆盖 12 个领域、180 个任务。
- 主要任务包括 step recognition、temporal localization、procedure learning 等。

**主要发现**
- 证明程序性视频研究不能局限于烹饪场景。
- 多域、多任务设置能够更真实地暴露程序理解的泛化难点。

**局限**
- 虽然有任务层级，但主要还是 task-step 组织，缺乏更细粒度的证据层表示。
- 真实错误执行、状态偏差和反事实信息仍然缺位。

### 3.4 HowTo100M

**基本信息**
- **标题**：HowTo100M: Learning a Text-Video Embedding by Watching Hundred Million Narrated Video Clips
- **发表**：ICCV 2019
- **定位**：大规模 narrated instructional videos 数据与视频语言预训练框架的代表性工作。

**核心贡献**
- 用 1.22M instructional web videos 和约 1.36 亿 clip-caption pairs 将程序视频研究推进到 web-scale。
- 证明弱对齐 narration 可以成为大规模视频语言预训练的重要监督来源。

**方法**
- 从 instructional videos 中自动切分 clip，并利用 narration/ASR 形成弱监督文本对齐。
- 学习共享的 text-video embedding，用于下游检索、定位和理解任务。

**基准**
- 数据规模极大，覆盖超过两万类视觉任务。
- 常用于 retrieval、action localization、video-language pretraining 等评测。

**主要发现**
- 大规模 narrated video 预训练可以显著提升视频语言表征质量。
- 在程序视频场景中，规模可以弥补部分人工标注不足。

**局限**
- narration 与真实视觉步骤往往并不严格同步。
- 该路线强调“规模优先”，但结构纯度较弱，容易把噪声和语言偏差一并带入模型。

### 3.5 TIPS

**基本信息**
- **标题**：Learning Temporal Video Procedure Segmentation from an Automatically Collected Large Dataset
- **发表**：WACV 2022
- **定位**：通过自动收集构建大规模 procedure segmentation 数据集，代表程序视频可扩展构建路线。

**核心贡献**
- 证明 procedure segmentation 数据不一定依赖高成本人工精标，也可以通过自动化流程扩展规模。
- 提供大规模 procedure segments，为多域步骤分割提供了可训练数据基础。

**方法**
- 从网络视频中自动搜集 well-structured procedural videos。
- 借助语音线索和视频结构特征进行数据过滤与步骤边界建模。

**基准**
- 数据规模约 63K videos、300K+ procedure segments。
- 覆盖 cooking、health、beauty、parenting、gardening 等多个生活场景。

**主要发现**
- 自动收集与自动过滤可以有效支持 procedure segmentation 研究。
- 程序性视频构建可以从“少量精标”走向“中大规模自动化”。

**局限**
- 主要仍解决步骤边界问题，结构粒度有限。
- 自动构建的标签质量与数据纯度受启发式规则影响较大。

### 3.6 DistantSup

**基本信息**
- **标题**：Learning To Recognize Procedural Activities With Distant Supervision
- **发表**：CVPR 2022
- **定位**：利用 wikiHow、ASR 和 narration matching 构建步骤级远监督的代表性方法。

**核心贡献**
- 把 textual knowledge base 正式引入程序视频监督构建过程。
- 证明可以借助语言模型把知识库步骤与嘈杂 narration 对齐，从而生成 step-level supervision。

**方法**
- 以 wikiHow 为上层程序知识源。
- 使用语言模型将视频 ASR 与知识库 step descriptions 进行匹配，再将匹配结果用于视频表示学习。

**基准**
- 主要评测 procedural activity recognition、step classification、step forecasting 等任务。
- 强调在无人工逐帧标注条件下的远监督泛化能力。

**主要发现**
- 文本知识库可以成为程序视频监督的重要外部先验。
- 远监督不仅能降低标注成本，也能保留一定的程序结构信息。

**局限**
- 上层知识与视频内容之间仍存在较强噪声。
- 学到的监督主要集中在步骤标签层，尚未深入到实体关系和证据链层面。

### 3.7 Ego4D Goal-Step

**基本信息**
- **标题**：Ego4D Goal-Step: Toward Hierarchical Understanding of Procedural Activities
- **发表**：NeurIPS 2023 Datasets and Benchmarks
- **定位**：面向 egocentric procedural videos 的 goal-step-substep 层次标注数据集，是宏观层次结构文献中的关键工作。

**核心贡献**
- 把程序理解从步骤识别推进到 goal-step-substep 的功能层级表示。
- 提供 step completion、step-to-goal relevance 等辅助信息，使任务结构不仅是“顺序”，还是“目标驱动”。

**方法**
- 基于 Ego4D 长视频引入目标、步骤、子步骤和关联属性的层次标注。
- 将程序理解扩展为 goal inference、step prediction、hierarchical relation learning 等任务。

**基准**
- 覆盖大规模 egocentric 长视频。
- 包含大量 procedural step segments 与高层 goal annotations。

**主要发现**
- 程序活动理解需要显式目标层，而不仅是局部动作标签。
- 任务完成状态和 step-goal 关联是研究长程推理的重要监督信号。

**局限**
- 重点仍在宏观层次结构，缺少对局部对象交互和状态变化的细粒度证据表达。
- 层次结构与视觉事实之间尚未建立稳定的显式 support relation。

### 3.8 GUIDE

**基本信息**
- **标题**：GUIDE: A Guideline-Guided Dataset for Instructional Video Comprehension
- **发表**：IJCAI 2024
- **定位**：将 task-level guideline 引入 instructional video 理解，是从实例步骤走向跨实例抽象流程的重要工作。

**核心贡献**
- 引入“guideline”这一跨视频共享的任务级抽象表示。
- 把程序视频研究从“单视频步骤标注”推进到“同任务多实例共享规范”的层面。

**方法**
- 为同类任务视频抽象出共享 guideline，再在视频级对齐具体步骤。
- 设计 guideline summarization、guideline-guided captioning 等任务，强调抽象流程与实例流程的映射。

**基准**
- 数据集约包含 3.5K videos、560 个任务、8 个日常生活领域。
- 适用于 instructional video comprehension 与跨实例流程抽象研究。

**主要发现**
- 程序理解不仅要建模视频内部顺序，还要建模跨实例共享的 canonical task scaffold。
- 高层 guideline 对于新手任务学习和长程过程组织具有重要价值。

**局限**
- 更偏向宏观任务抽象，缺少与局部视觉证据的精确耦合。
- guideline 虽能约束流程，但不能直接回答“当前答案由哪些视觉事实支撑”。

### 3.9 Paprika

**基本信息**
- **标题**：Procedure-Aware Pretraining for Instructional Video Understanding
- **发表**：CVPR 2023
- **定位**：通过 Procedural Knowledge Graph 引入程序知识的预训练方法，强调图结构作为监督载体。

**核心贡献**
- 构建 Procedural Knowledge Graph（PKG）作为 step-level procedural knowledge 的组织形式。
- 证明“程序图”不仅是分析工具，也可以作为有效的预训练监督接口。

**方法**
- 从文本知识库构建 PKG，节点表示离散步骤，边表示顺序和程序依赖。
- 以图结构生成 pseudo labels，进行 procedure-aware 预训练。

**基准**
- 主要在 COIN、CrossTask 等 instructional video benchmark 上评测。
- 任务涵盖 task recognition、step recognition、step forecasting 等。

**主要发现**
- 将程序知识显式注入预训练过程，能够显著改善程序视频表征。
- 程序图是连接语言知识与视觉学习的有效中介。

**局限**
- 图结构主要停留在 step-level procedural knowledge，而不是局部事实图。
- 更偏向 representation learning，尚未用于 evidence-grounded QA 数据生产。

### 3.10 Video-Mined Task Graphs

**基本信息**
- **标题**：Video-Mined Task Graphs for Keystep Recognition in Instructional Videos
- **发表**：NeurIPS 2023
- **定位**：直接从 how-to videos 中发现 probabilistic task graph，用于 keystep recognition。

**核心贡献**
- 证明任务图不必完全依赖人工脚本，也可以从真实 instructional videos 中自动挖掘。
- 强调程序流程具有概率性、多路径和柔性执行顺序，而非僵硬的线性脚本。

**方法**
- 从视频中自动发现 keystep 之间的依赖结构。
- 用 task graph 正则化 keystep recognition，在新视频中利用图先验提升识别。

**基准**
- 面向 instructional videos 的 keystep recognition 场景。
- 重点评测图结构对程序步骤识别与泛化的帮助。

**主要发现**
- 真实程序流程往往存在可变顺序与多种执行路径。
- 任务图能够为步骤识别提供比平坦标签更强的结构先验。

**局限**
- 图结构仍然主要服务于步骤层建模，而不是局部证据层验证。
- 没有解决长视频全量图建模的噪声控制与稀疏化问题。

### 3.11 Action Genome

**基本信息**
- **标题**：Action Genome: Actions As Compositions of Spatio-Temporal Scene Graphs
- **发表**：CVPR 2020
- **定位**：视频时空 scene graph 的代表性基准，为微观关系结构建模奠定基础。

**核心贡献**
- 把视频动作理解表示为对象、关系和状态变化的时空 scene graph 组合。
- 说明动作并非孤立标签，而是多实体交互和状态演化的结构化结果。

**方法**
- 在视频中标注对象、交互关系和状态，形成 spatio-temporal scene graphs。
- 将 scene graph 作为动作理解与关系推理的特征库和监督对象。

**基准**
- 基于 Charades 场景扩展出时空图结构标注。
- 主要评测 spatio-temporal scene graph prediction 与相关下游理解任务。

**主要发现**
- 图结构比扁平动作标签更适合描述复杂动作的组成。
- 局部交互关系和状态变化是视频细粒度推理的重要基础。

**局限**
- 它是微观证据建模的重要基础，但并非 procedural benchmark。
- 缺乏目标层、任务层和长程步骤结构，无法单独支撑程序性长视频理解。

### 3.12 EASG

**基本信息**
- **标题**：Action Scene Graphs for Long-Form Understanding of Egocentric Videos
- **发表**：CVPR 2024
- **定位**：面向 egocentric long-form videos 的动态 action scene graph，是 Micro-Graph 路线中最贴近本研究的工作之一。

**核心贡献**
- 在 Ego4D 上扩展出 Egocentric Action Scene Graphs，显式编码时间演化的对象交互与动作关系。
- 把传统 verb-noun 标注推进到时变图结构，增强长视频细粒度理解能力。

**方法**
- 通过人工标注和动态图建模，为 egocentric 视频构建 action scene graphs。
- 将图结构用于 long-form understanding 与 action anticipation 等任务。

**基准**
- 基于 Ego4D 长视频场景。
- 重点面向 egocentric long-form understanding、动态图预测与关系推理。

**主要发现**
- 对于长视频理解，局部交互的时序演化比单帧关系更关键。
- egocentric 场景中，动作、对象和关系必须联合建模，才能支持真实的过程推理。

**局限**
- 重点仍是微观图表示，缺少与宏观任务结构的显式耦合。
- 没有进一步把图表示转化为面向幻觉抑制的 support graph 学习目标。

### 3.13 Structured Procedural Knowledge Extraction

**基本信息**
- **标题**：A Benchmark for Structured Procedural Knowledge Extraction from Cooking Videos
- **发表**：ACL 2020
- **定位**：从 instructional videos 与 transcripts 中抽取 verb-argument tuples 的跨模态结构化知识提取基准。

**核心贡献**
- 说明程序结构并不只存在于 step boundary 层，也可以下沉到动作-论元-对象单元。
- 把 procedure understanding 与结构化知识抽取连接起来，拓宽了中间表示的形式。

**方法**
- 基于 cooking videos 与文本转录抽取结构化 procedural units。
- 以 verb-argument tuple 的形式组织动作和参与实体。

**基准**
- 包含数百个烹饪 instructional videos 与大量 clip/sentence-level annotations。
- 适用于 procedure unit extraction、cross-modal alignment 和结构化语义解析。

**主要发现**
- 视频中的程序知识可以被抽象为半符号化结构，而不是只能保留为自然语言描述。
- 更细粒度的结构单元有助于连接视觉事实和文本知识。

**局限**
- 主要聚焦结构化抽取任务，未直接面向 Video-LLM 推理或幻觉抑制。
- 领域集中在 cooking，且对长程目标层建模较弱。

### 3.14 Assembly101

**基本信息**
- **标题**：Assembly101: A Large-Scale Multi-View Video Dataset for Understanding Procedural Activities
- **发表**：CVPR 2022
- **定位**：面向 assembly 场景的大规模 multi-view procedural dataset，是“真实偏差与纠错”研究的重要起点。

**核心贡献**
- 将程序视频从教程式演示扩展到 assembly 场景，并显式保留真实世界中的 variations、mistakes 和 corrections。
- 提供多视角、第一视角和长时间过程数据，增强了对真实执行偏差的建模价值。

**方法**
- 采集多视角 assembly 过程视频，并对动作、对象和流程片段进行大规模标注。
- 将错误、修正和顺序偏差纳入数据分布，而不只保留 canonical execution。

**基准**
- 数据规模大，覆盖数百小时、多视角、多参与者的 assembly activities。
- 适用于 action recognition、mistake detection、procedure understanding 等任务。

**主要发现**
- 真实程序活动天然包含顺序变化、失误和纠正，不能被简化为单一路径脚本。
- 非理想执行是 procedure learning 中必须正视的数据分布，而非噪声。

**局限**
- 主要是数据资源层贡献，对结构化 support relation 的定义较弱。
- 任务域为 assembly，迁移到开放程序视频仍需额外适配。

### 3.15 CaptainCook4D

**基本信息**
- **标题**：CaptainCook4D: A Dataset for Understanding Errors in Procedural Activities
- **发表**：NeurIPS 2024 Datasets and Benchmarks
- **定位**：专门聚焦正确执行与错误执行对比的 egocentric cooking dataset，是错误感知程序数据的重要代表。

**核心贡献**
- 直接把“错误执行”作为一等公民纳入 procedural dataset，而不是只在文本层伪造负例。
- 提供正确与错误两类真实执行视频，为 error recognition、multistep localization 和 procedure learning 建立基准。

**方法**
- 在真实厨房环境中采集遵循 recipe 与故意引入错误的 egocentric 4D recordings。
- 提供 step annotations 和 fine-grained action annotations，用于多任务评测。

**基准**
- 数据约包含 384 段录制、94.5 小时视频、5.3K step annotations 和约 10K 细粒度动作标注。
- 主要面向 error recognition、multistep localization 和 procedure learning。

**主要发现**
- 真实错误执行数据能暴露传统“正确流程偏置”下模型的脆弱性。
- 在程序性长视频中，错误不是边角情况，而是鲁棒理解的重要训练信号。

**局限**
- 重点在真实错误采集，还未形成系统化的结构反事实生成机制。
- 错误类型和场景多样性仍受采集成本限制。

### 3.16 State-Change Counterfactuals

**基本信息**
- **标题**：What Changed and What Could Have Changed? State-Change Counterfactuals for Procedure-Aware Video Representation Learning
- **发表**：ICCV 2025
- **定位**：将 actual state changes 与 counterfactual state changes 一并引入程序视频表示学习，是反事实程序监督的重要新进展。

**核心贡献**
- 把程序视频学习从“观察到什么状态变化”扩展到“如果失败或替代执行，可能发生什么状态变化”。
- 将反事实引入 procedure-aware representation learning，使模型学习“结果本可不同”的结构知识。

**方法**
- 使用 LLM 生成状态变化描述及其反事实版本。
- 在 clip-level 和 video-level 融合状态变化与 counterfactual supervision，训练程序感知的视频表示。

**基准**
- 面向 procedure-aware video representation learning 场景。
- 关注状态变化理解、程序泛化和反事实感知能力。

**主要发现**
- 反事实状态变化能帮助模型超越表面共现，理解步骤失败或替代结果的后果。
- 对程序视频而言，结果状态和潜在状态同样重要。

**局限**
- 反事实主要围绕 state change，本质上仍偏“状态层”而非“图拓扑层”。
- 尚未显式建模 support insufficiency 或拒答机制。

### 3.17 VideoHallucer

**基本信息**
- **标题**：VideoHallucer: Evaluating Intrinsic and Extrinsic Hallucinations in Large Video-Language Models
- **发表**：arXiv 2024-06-24
- **定位**：首个较系统的视频幻觉基准之一，从 intrinsic 与 extrinsic 两大类定义视频 hallucination。

**核心贡献**
- 将视频幻觉细分为 object-relation、temporal、semantic-detail、factual 和 non-factual 等类型。
- 通过配对问题设计，把“是否答对”和“是否被误导”同时纳入评估。

**方法**
- 为每个样本构造 basic question 与 hallucinated question。
- 使用 overall paired accuracy、Yes Percentage Difference 与 False Positive Ratio 评估模型可靠性。

**基准**
- 共约 1,800 个问题、948 个视频。
- 数据来源包括 VidOR、VidVRD、ActivityNet、HawkEye、YouCook、COIN、EDUVSUM 等。

**主要发现**
- 当前最强模型与人类之间仍存在显著差距。
- 视频幻觉并非单一现象，而是涉及关系、时序、细节和事实层面的多维错误。

**局限**
- 以二分类 VQA 为主，尚未覆盖开放式生成情形。
- 更偏诊断工具，尚未给出结构化证据层面的解决机制。

### 3.18 EventHallusion

**基本信息**
- **标题**：EventHallusion: Diagnosing Event Hallucinations in Video LLMs
- **发表**：arXiv 2024-09-25
- **定位**：聚焦事件级 hallucination，强调模型在稀有事件和误导问题上的 prior-driven 错误。

**核心贡献**
- 将视频幻觉研究从广义错误进一步收缩到 event hallucination。
- 系统分析 visual/content prior 与 language prior 如何共同驱动错误判断。

**方法**
- 构建 rare events、common-rare interleave 和 misleading 三类评测样本。
- 提出 Temporal Contrastive Decoding，通过比较原视频与时间退化版本减轻先验驱动错误。

**基准**
- 约 400 个视频，覆盖宠物、运动、食物、健身、车辆、生活、自然等 7 个领域。
- 任务包含 binary classification 与 description matching。

**主要发现**
- 模型在稀有事件、复杂事件切换和误导性问题上更容易暴露 prior bias。
- 简单的时间对比推理可带来一定改善，但无法根治问题。

**局限**
- 基准规模相对较小。
- 仍主要停留在诊断和 decoding 修补层面，没有显式证据图或支持链建模。

### 3.19 VidHalluc

**基本信息**
- **标题**：VidHalluc: Evaluating Temporal Hallucinations in Multimodal Large Language Models for Video Understanding
- **发表**：CVPR 2025
- **定位**：面向 temporal hallucination 的大规模视频幻觉基准，强调半自动构建和时序扰动。

**核心贡献**
- 建立当时规模最大的时序视频幻觉基准之一。
- 提出 ACH、TSH、STH 三类时序幻觉，并设计大规模半自动化构建流程。

**方法**
- 结合 CLIP/SigLIP 与 DINOv2 选择语义相近但视觉差异明显的视频对。
- 提出 DINO-HEAL 作为免训练缓解方法，以视觉显著性信息辅助推理。

**基准**
- 共约 5,002 个视频、9,295 个 QA 对。
- 涵盖 Action Hallucination、Temporal Sequence Hallucination 和 Scene Transition Hallucination。

**主要发现**
- 即使是最强闭源模型，在时序幻觉上仍明显落后于人类表现。
- 时序动态与场景切换是视频理解中最容易被模型“脑补”的部分。

**局限**
- 主要聚焦三类时序幻觉，问题覆盖面仍有限。
- 缓解方法更偏后处理层，不涉及程序结构与证据充足性的原则化建模。

---

## 四、整体文献演进脉络

如果把上述文献放在同一条研究主线上，可以看到一条较为清晰的演进路径：

### 4.1 从“视频切分”到“步骤理解”

以 YouCook2、CrossTask 和 COIN 为代表的早期工作，首先解决的是一个基础问题：程序性长视频并不是普通动作识别，它需要被拆分为语义明确的步骤片段。这个阶段的主要成果是让 “step” 成为可学习、可评测、可比较的基本分析单元。

### 4.2 从“步骤列表”到“层次化任务结构”

随后，HowTo100M、TIPS 和 DistantSup 让社区看到，程序理解不可能永远依赖少量精标数据，必须走向弱监督、远监督和自动化构建。与此同时，Ego4D Goal-Step、GUIDE、Paprika 和 Video-Mined Task Graphs 把研究对象进一步从“平坦步骤”推进到“目标驱动的层次结构”“跨实例 guideline”和“概率任务图”。这一阶段的重要转变是：研究者开始意识到，真正决定程序理解上限的，不只是局部动作识别，而是任务流程的组织方式。

### 4.3 从“步骤结构”到“局部事实结构”

但是，仅有宏观任务结构并不足以支撑高可信的视频问答。Action Genome、EASG 和 Structured Procedural Knowledge Extraction 这条支线说明，视频中的可验证证据往往体现在对象、动作、交互和状态变化上。换句话说，宏观结构回答的是“当前大概在做什么”，微观图结构回答的是“具体看到了什么”，两者承担的是不同但互补的职责。

### 4.4 从“正确执行”到“错误、偏差与反事实”

Assembly101、CaptainCook4D 和 State-Change Counterfactuals 则进一步指出，真实世界的程序过程并不总是沿着标准脚本展开。顺序偏差、遗漏、错误执行和潜在反事实后果，本身就是 procedure understanding 的核心组成部分。这一阶段为“hard negatives 应该来自结构扰动而不是表层文本替换”提供了坚实依据。

### 4.5 从“理解能力评测”到“幻觉问题显式化”

最后，VideoHallucer、EventHallusion 和 VidHalluc 让社区开始系统讨论一个新的核心问题：Video-LLM 即使在证据不足时，也可能给出高度流畅但并不正确的回答。此时研究焦点从“能否识别/定位/描述视频内容”进一步转向“模型是否真的依赖了视频证据”。

### 4.6 一条更凝练的脉络总结

用一句话概括，这条文献线索的发展是：

> 从“程序视频如何被切分和描述”，发展到“程序流程如何被层次化和图结构化”，再发展到“错误与反事实如何被纳入监督”，最终走向“模型是否真正依据证据作答”的幻觉诊断与抑制问题。

这条主线直接解释了为什么本研究不宜停留在纯 caption 重写或纯长上下文建模，而需要引入一个能同时刻画任务流程和局部证据的结构化中间表示。

---

## 五、现有工作的共同不足

基于上述综述，现有文献虽然已提供丰富基础，但仍存在四类关键缺口。

### 5.1 宏观任务结构与微观证据结构仍然割裂

Ego4D Goal-Step、GUIDE、Paprika 和 Video-Mined Task Graphs 强调宏观结构；Action Genome、EASG 和 Structured Procedural Knowledge Extraction 强调微观结构。但两类工作通常被分别用于 benchmark、representation learning 或 recognition task，很少在同一条自动化数据生产链中形成稳定耦合。

结果是：

- 只有宏观结构时，模型“知道流程”，却未必知道证据在哪里。
- 只有微观结构时，模型“看到局部事实”，却未必知道这些事实在任务流程中意味着什么。

### 5.2 现有反事实与负样本多停留在状态层或文本层

CaptainCook4D 和 State-Change Counterfactuals 已经把研究推向真实错误与反事实，但现有监督多数仍以状态变化、顺序偏差或错误执行片段为核心。真正面向“支持链是否断裂”的最小图拓扑编辑仍然缺位。

### 5.3 视频幻觉研究以“诊断”为主，以“证据充分性判定”为辅

VideoHallucer、EventHallusion 和 VidHalluc 显著推进了 hallucination benchmark 的建设，但更多回答的是“模型哪里会出错”“在哪些事件或时序设置下会被误导”。它们尚未真正把“support sufficiency”建成一个结构化判断对象，也未把“拒答”自然纳入学习目标。

### 5.4 长视频联合建模的代价和噪声问题仍然突出

一旦试图对长视频的所有片段、所有对象和所有关系做全量联合建模，系统就会同时面对三重问题：

- 计算复杂度过高；
- 低价值背景信息过多；
- 模型更容易在稠密但不关键的信号上过拟合。

因此，程序性长视频研究真正缺少的不是“再加一个更大的 backbone”，而是一套可解释、可稀疏、可质控的结构化中间表示。

---

## 六、与本研究的关系：为什么需要 Evidence-Grounded MT-MG

### 6.1 现有文献为本研究提供了哪些直接基础

本研究并不是从零开始，而是直接建立在三类既有成果之上：

- **宏观结构基础**：Ego4D Goal-Step、GUIDE、Paprika、Video-Mined Task Graphs 证明了程序视频应被理解为目标驱动、层次化或图化的流程结构。
- **微观证据基础**：Action Genome、EASG、Structured Procedural Knowledge Extraction 证明了对象、关系、状态和动作论元可以作为局部事实表示。
- **鲁棒性与评测基础**：Assembly101、CaptainCook4D、State-Change Counterfactuals、VideoHallucer、EventHallusion、VidHalluc 证明了错误执行、反事实和 hallucination 都是必须正视的问题，而不是评测边角。

### 6.2 现有文献尚未解决什么

尽管基础已经具备，但仍然缺少一个统一机制，把下面三件事真正连起来：

1. 让 **宏观任务意图** 约束当前应该关注哪些局部证据；
2. 让 **微观局部证据** 反过来验证宏观任务推断是否成立；
3. 让模型在 **支持链不充分** 时学会拒答，而不是继续依赖语言先验生成。

换言之，现有工作已经分别回答了“如何表示流程”“如何表示局部事实”“如何构造错误或诊断幻觉”，但尚未回答“如何把流程、事实和证据充分性统一起来”。

### 6.3 为什么本研究采用 MT-MG，而不是其他结构

本研究选择 **MT-MG（Macro-Tree + Micro-Graph）**，原因不是为了叠加复杂性，而是因为程序性长视频天然同时包含两类不可替代的结构。

| 结构选择 | 优势 | 根本不足 |
|------|------|------|
| 扁平 caption / QA 重写 | 构建简单、扩展方便 | 容易丢失流程结构和证据关系，最容易诱发语言先验幻觉 |
| 仅用宏观树 | 能表达 goal、step、substep 与长程规划 | 无法回答“这个答案具体由哪些视觉事实支撑” |
| 仅用微观图 | 能表达对象交互、状态变化和局部时空关系 | 缺少任务阶段语义，难以判断局部事实在整体流程中的合理性 |
| 全量时空联合表示 | 信息最丰富 | 代价高、噪声大、不易做 data-centric 质量控制 |
| **MT-MG** | 同时保留任务流程与局部证据，并可建立双向校验 | 需要设计显式耦合、稀疏化和反事实机制 |

更具体地说，选择 MT-MG 具有四个直接理由：

1. **它符合程序性长视频的真实结构**

程序性视频并不是一串平面事件，而是“目标驱动的任务流程”叠加“对象、动作、状态的局部变化”。树更适合表示前者，图更适合表示后者。

2. **它比单一树或单一图更接近最小充分表示**

只用树，模型知道“做到哪一步”；只用图，模型知道“看到了什么”；只有把二者联结起来，模型才可能知道“为什么这个答案在当前步骤下是成立的”。

3. **它天然适合作为 data-centric 中间表示**

本研究的目标不是发明一个更重的端到端 architecture，而是建立一个可自动生成、可验证、可质控的中间表示，用于数据生产、训练监督和 hallucination 分析。相较于全量时空 token 联合表示，MT-MG 更便于解释和控制。

4. **它能自然支撑后续的两个关键机制**

- **意图驱动稀疏化**：由 Macro-Tree 的任务阶段约束 Micro-Graph 的证据选择。
- **拓扑反事实扰动**：在 Micro-Graph 的支持关系上做最小编辑，构造 near-miss hard negatives。

因此，MT-MG 的真正意义不在于“把树和图放在一起”，而在于把它们组织成一个面向 **support consistency** 的统一中间表示。

### 6.4 本研究相对于现有工作的准确定位

如果用一句话概括本研究与既有工作的关系，可以写成：

> 现有工作已经分别提供了宏观程序结构、微观场景图和错误/幻觉评测，但它们大多是被孤立使用的；本研究的贡献在于将二者作为联合约束接口嵌入自动化数据生产流程，并以显式证据支撑关系为目标，服务于 Video-LLM 幻觉抑制。

本研究并不主张“首个做层次结构”或“首个做场景图”，而是更准确地强调三点：

- **把 macro intent 与 micro evidence 联结为 support relation**；
- **把反事实从状态层推进到支持拓扑层**；
- **把 hallucination 抑制从诊断层推进到 evidence-grounded decision 层**。

---

## 七、对本研究设计的直接启示

基于上述综述，本研究若要形成一条清晰、可辩护的论文主线，应重点落实以下四点。

### 7.1 把“结构化中间表示”讲成“证据对象”，而不是“更复杂的编码器”

如果只说“联合宏观树和微观图”，审稿人很容易将其理解为已有结构的工程拼接。更有说服力的表述应该是：MT-MG 被设计为 **faithfulness object**，用于显式判断一个候选答案是否存在一致的支持子结构。

### 7.2 把“负样本”讲成“最小支持破坏”，而不是“普通数据增强”

现有反事实工作已说明状态和顺序扰动有效，但本研究需要进一步强调：我们并不是简单修改文本答案，而是在支持图上做最小拓扑编辑，使负样本更接近真实的 near-miss hallucination。

### 7.3 把“稀疏化”讲成“长视频证据预算管理”，而不是“启发式剪枝”

长视频联合建模的难点不只是算力，而是如何在有限预算下保留关键支持链条。因此，意图驱动稀疏化不应被表述为一般性的 pruning，而应被表述为一种与任务阶段语义对齐的 evidence budget allocation。

### 7.4 把“评测”讲成“回答、归因、校准、拒答”的联合评价

如果只看答案正确率，就无法说明本研究是否真正减轻了 hallucination。更合理的评测方式应同时关注：

- 答案是否正确；
- 证据归因是否成立；
- 置信与正确性是否校准；
- 在证据不足时能否恰当地拒答。

---

## 八、结论

总体来看，程序性长视频文献已经完成了从步骤切分、弱监督扩展、层次结构建模，到局部图表示、错误感知数据、视频幻觉评测的连续发展。现有工作已经分别证明：

- 宏观任务结构对长程过程理解不可或缺；
- 微观局部证据对高可信推理不可或缺；
- 错误执行、反事实和 hallucination 不是附属问题，而是程序视频理解的核心挑战。

但到目前为止，文献仍缺少一个能够把“任务意图”和“局部证据”显式绑定起来的统一接口。正因为如此，**Evidence-Grounded MT-MG 框架** 才具有明确的研究空间：它并不是简单重复已有的层次结构或图结构，而是试图把二者组织为一个可验证的 support object，并进一步以意图驱动稀疏化和拓扑反事实机制服务于 Video-LLM 幻觉抑制。

如果将来把这条线继续往前推进，一个真正强的论文叙事应当是：

> 现有文献已经分别发展出了宏观程序结构、微观事实图和视频幻觉评测，但仍缺少一个能把“流程理解”与“证据支撑”闭环起来的统一中间表示；因此，我们提出面向 Video-LLM 幻觉抑制的 Evidence-Grounded MT-MG 框架，以 Macro-Tree 对齐任务阶段，以 Micro-Graph 表达局部证据，并通过 support consistency、意图驱动稀疏化和拓扑反事实扰动，让模型在有证据时回答、证据不足时拒答。  
