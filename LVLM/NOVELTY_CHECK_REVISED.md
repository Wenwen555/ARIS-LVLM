# 新颖性检查报告：Evidence-Grounded Support Graph

**更新日期**: 2026-03-31
**审查模型**: GPT-5.4 (xhigh reasoning)

---

## 提议方法

**核心概念**: Video-LLM 的幻觉来自 unsupported reasoning over long videos。我们要学习一个稀疏但可证据化的 support graph，并用 topology-consistent counterfactuals 训练模型学会"拒绝无证据生成"（abstention mechanism）。

---

## 核心声明新颖性评估

### 声明 1: Support Graph Consistency Learning

- **新颖性**: LOW-TO-MODERATE
- **最接近工作**:
  - [Ego4D Goal-Step (NeurIPS 2023)](https://proceedings.neurips.cc/paper_files/paper/2023/hash/7a65606fa1a6849450550325832036e5-Abstract-Datasets_and_Benchmarks.html): 已提供 goal-step-substep 层次结构和 step-to-goal 相关性
  - [EASG (CVPR 2024)](https://openaccess.thecvf.com/content/CVPR2024/html/Rodin_Action_Scene_Graphs_for_Long-Form_Understanding_of_Egocentric_Videos_CVPR_2024_paper.html): 已提供时间演化的动作场景图
  - [HyperGLM (CVPR 2025)](https://openaccess.thecvf.com/content/CVPR2025/html/Nguyen_HyperGLM_HyperGraph_for_Video_Scene_Graph_Generation_and_Anticipation_CVPR_2025_paper.html): 已统一实体场景图和程序因果图用于 LLM 推理
  
- **真正的差异**: 不是 "graph + hierarchy"（已在文献中），而是 **显式 support relation** 介于宏观声明和微观证据之间，使用 **双向 support consistency** 训练用于幻觉控制。如果简化为 "hierarchical graph reasoning"，审稿人将拒绝新颖性声明。

- **审稿人会引用**: Goal-Step, EASG, HyperGLM, Chain-of-Frames, Video-VER

- **关键结论**: 表示层的故事是增量式的。唯一可辩护的新颖性是将 support graph 作为 **faithfulness object**，而不仅仅是更好的编码器。

### 声明 2: Minimal-Edit Topological Counterfactuals ⭐ **最强声明**

- **新颖性**: MODERATE — **可能是最强的声明**
- **最接近工作**:
  - [State-Change Counterfactuals (ICCV 2025)](https://openaccess.thecvf.com/content/ICCV2025/html/Kung_What_Changed_and_What_Could_Have_Changed_State-Change_Counterfactuals_for_ICCV_2025_paper.html): 已引入状态变化、缺失步骤、顺序错误的反事实
  - [CaptainCook4D (NeurIPS 2024)](https://proceedings.neurips.cc/paper_files/paper/2024/hash/f4a04396c2ed1342a5d8d05e94cb6101-Abstract-Datasets_and_Benchmarks_Track.html): 已聚焦真实程序错误
  - [Causal-VidQA (CVPR 2022)](https://openaccess.thecvf.com/content/CVPR2022/html/Li_From_Representation_to_Reasoning_Towards_Both_Evidence_and_Commonsense_Reasoning_CVPR_2022_paper.html): 已有反事实式推理问题
  
- **真正的差异**: 扰动是 **拓扑层面** 和 **最小化** 的，不是仅仅状态文本或步骤顺序扰动。如果真正修改 1-2 个 support edges/relations 同时保留其余证据结构，可以创造更难、更精确的负样本。将这些负样本与 **abstention** 关联（而非仅更好的表示学习）也是有意义的差异。

- **审稿人会引用**: SCC 2025, CaptainCook4D, Causal-VidQA, Reliable VQA, CARA

- **关键结论**: 如果编辑看起来像 "翻转一个关系标签"，将被视为现有反事实增强的显见图域实例。如果能证明 **最小 support-topology violations** 教授拒绝行为，这成为真正的贡献。

### 声明 3: Budgeted Evidence Selection (Dual-Channel)

- **新颖性**: LOW
- **最接近工作**:
  - [Frame-Voyager (2024)](https://arxiv.org/abs/2410.03226): 学习查询依赖的帧组合
  - [Q-Frame (2025)](https://arxiv.org/abs/2506.22139): 查询感知帧选择和多分辨率适应
  - [FrameMind (2025)](https://arxiv.org/abs/2509.24008): 主动请求帧/片段
  - [HERBench](https://herbench.github.io/): 显式分离检索缺陷和融合缺陷
  
- **真正的差异**: "exploit 相关证据 + explore 不确定/反常证据" 是合理的，但听起来像标准 active learning/bandit/retrieval-diversity 语言转移到 video QA。唯一可能新鲜的部分是 explore branch 显式旨在 **找到应导致 abstention 的反证**，而非仅仅增加多样性。

- **审稿人会引用**: Frame-Voyager, Q-Frame, FrameMind, HERBench, LongVidSearch

- **关键结论**: **不要作为核心新颖性出售**。"Submodular coverage guarantee" 不是新颖性声明，是技术选择。审稿人将视为支持模块，除非它直接服务于 abstention 故事。

### 声明 4: Evidence Attribution Benchmark

- **新颖性**: MODERATE (如果正确执行), LOW (如果弱标注)
- **最接近工作**:
  - [Causal-VidQA (CVPR 2022)](https://openaccess.thecvf.com/content/CVPR2022/html/Li_From_Representation_to_Reasoning_Towards_Both_Evidence_and_Commonsense_Reasoning_CVPR_2022_paper.html): 已前推证据推理
  - [AGQA](https://cs.stanford.edu/people/ranjaykrishna/agqa/): 已提供基于场景图的组合推理结构
  - [ANetQA (CVPR 2023)](https://openaccess.thecvf.com/content/CVPR2023/html/Yu_ANetQA_A_Large-Scale_Benchmark_for_Fine-Grained_Compositional_Reasoning_Over_Untrimmed_CVPR_2023_paper.html): 组合推理
  - [QGAC-TR (EMNLP 2024)](https://aclanthology.org/2024.findings-emnlp.176/): 视觉定位 VideoQA
  - [VCR-Bench (2025)](https://arxiv.org/abs/2504.07956): 手工标注的分步 CoT rationales
  - [HERBench](https://herbench.github.io/): 多证据需求显式化
  - [VidHalluc](https://vid-halluc.github.io/): 视频幻觉评估
  
- **真正的差异**: 最佳版本是 **最小支持证据标注** + **联合评分**（答案正确性、证据归因、校准、abstention）。这种组合比单纯的 "video reasoning benchmark" 饱和度低。

- **审稿人会引用**: VCR-Bench, HERBench, AGQA, ANetQA, QGAC-TR, VidHalluc

- **关键结论**: "小而硬的子集" 无法支撑论文，除非标注质量优秀且任务明确是现有 benchmark 不测量的。如果只是时间戳 rationale 标注，审稿人会说 VCR-Bench 和 HERBench 已经在那里了。

---

## 最近相关工作对比表

| 论文 | 年份 | 会议 | 重叠度 | 关键差异 |
|------|------|------|--------|----------|
| **HyperGLM** | 2025 | CVPR | HIGH | 已统一场景图+因果图；无显式 support relation + abstention |
| **State-Change Counterfactuals** | 2025 | ICCV | HIGH | 状态变化反事实；非拓扑层面最小编辑 |
| **Ego4D Goal-Step** | 2023 | NeurIPS | MEDIUM | 仅宏观结构；无微观证据支撑验证 |
| **EASG** | 2024 | CVPR | MEDIUM | 仅微观场景图；无宏观任务耦合 |
| **CaptainCook4D** | 2024 | NeurIPS | MEDIUM | 真实错误；非系统化反事实生成 |
| **VCR-Bench** | 2025 | ArXiv | MEDIUM | CoT rationales；无最小支持集标注 + abstention |
| **HERBench** | 2025 | ArXiv | MEDIUM | 多证据需求；无拓扑反事实 + abstention 训练 |
| **Frame-Voyager** | 2024 | ArXiv | LOW | 查询依赖帧选择；非 support-topology 导向 |

---

## 整体新颖性评估

- **评分**: **5.5/10**
- **建议**: **PROCEED WITH CAUTION（谨慎推进）**
- **关键差异化因素**: **基于显式 support insufficiency 的 abstention**，使用 **最小 support-topology counterfactuals** 训练。这是唯一感觉非显见的部分。

- **最大审稿人风险**: 论文读起来像一堆已流行的成分组合：层次化视频图、接地推理、反事实增强、自适应证据选择、校准、abstention。如果作为四个独立新颖性声明呈现，审稿人将拆解它。

---

## 建议定位以最大化新颖性感知

### 应该声称的

1. **"一个统一框架学习何时不应回答，通过建模候选答案是否有视频中的 consistent support topology"**

2. **"反事实监督应用于 support relations 层面，产生 near-miss 负样本，目标幻觉推理而非通用表示学习"**

3. **"评估联合测量 answering、grounding、calibration 和 abstention，在显式证据充分性下"**

### 不应声称的

- ❌ "首个层次化 macro-micro graph 用于视频推理"
- ❌ "首个反事实训练用于程序性视频"
- ❌ "首个 abstention mechanism 用于多模态 QA"
- ❌ "首个证据 benchmark 用于视频推理"
- ❌ "新颖的 submodular evidence selection"

---

## 论文策略建议

### 1. 收敛到一个核心声明
将论文围绕 **一个** 核心声明："Video hallucination reduction via explicit support insufficiency modeling and abstention"

### 2. 将 support graph 作为 faithfulness certificate
而非通用的场景/程序图

### 3. 强调反事实破坏 support topology
而非仅仅状态描述或步骤顺序

### 4. 强推 abstention 角度
"refuse when no consistent support subgraph exists under the evidence budget"

### 5. 降级证据选择为系统组件
而非标题贡献

### 6. 收窄域到长视频程序性视频
状态变化和 support topology 在那里比任意开放域视频更清晰

### 7. 如果构建 benchmark
标注 **最小支持集**，而非仅仅粗粒力 rationales 或时间戳

### 8. 添加强人工验证
证明反事实编辑是自然的、最小差异的、选择性翻转答案的

---

## 下一步建议

1. [ ] 重构论文题为 "Video hallucination reduction via explicit support insufficiency modeling and abstention"
2. [ ] 设计最小支持集标注协议
3. [ ] 实现最小拓扑编辑反事实算法
4. [ ] 设计 ranking + abstention 训练目标
5. [ ] 添加人工验证实验证明反事实质量
6. [ ] 收窄域到程序性视频（Ego4D/COIN）