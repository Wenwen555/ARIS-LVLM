# 优化后的研究提案：Evidence-Grounded Video Hallucination Reduction

**更新日期**: 2026-03-31
**基于**: GPT-5.4 深度批判性审查反馈
**目标评分**: 8/10+
**状态**: REVISED - 等待实验验证

---

## 核心论题（重构后）

> **Video-LLM 的 hallucination 来自 unsupported reasoning over long videos；我们要学习一个稀疏但可证据化的 support graph，并用 topology-consistent counterfactuals 训练模型学会"拒绝无证据生成"。**

这比"宏观-微观联合表示"更锋利，也更容易和 VideoLoom 拉开距离。

---

## 问题锚点

### 核心问题
Video-LLM 在长视频程序性理解中存在严重的"语言先验幻觉"问题：模型倾向于生成符合语言共现性但缺乏视觉证据支持的内容。

### 关键瓶颈
- **证据脱节**: 生成的回答无法追溯到具体的视觉证据
- **先验绑架**: 语言模型先验覆盖了视觉观察
- **拒绝机制缺失**: 模型没有学会在证据不足时"闭嘴"

### 成功条件
- 幻觉率绝对下降 >10%（有 evidence attribution 验证）
- Evidence attribution F1 > 0.7
- 模型学会 abstention（拒绝回答无证据问题）

---

## 方法论

### 主导贡献: Evidence-Grounded Support Graph

不再是泛泛的"宏观-微观联合表示"，而是：

**Support Graph Consistency Learning**:
- 每个宏观节点都必须被一组微观状态/交互/状态变化支持
- 双向一致性损失：
  - `macro→micro entailment`: 宏观意图必须有微观证据支撑
  - `micro→macro support`: 微观证据必须能追溯到宏观任务

### 支持贡献: Minimal-Edit Topological Counterfactuals

**不再是随机 rewiring，而是**:
- 只改 1-2 个关键拓扑关系
- 用 `state-change priors` 约束可行性
- 人工验证 plausible 且 genuinely hard
- 训练目标: `ranking + abstention`（模型学会拒绝无证据问题）

### 效率组件: Budgeted Evidence Selection

**不再是 heuristic pruning，而是**:
- **双通道设计**:
  - `exploit path`: 保留高 intent 相关证据
  - `explore path`: 专门保留高不确定性/反常证据
- 报告 `support-path recall`、`faithfulness`、`latency-memory-accuracy` 三维曲线
- 提供 submodular coverage 弱保证

---

## 与 VideoLoom 的差异化（强化版）

| 维度 | VideoLoom | 我们的方法 |
|------|-----------|------------|
| **核心主张** | 时空联合理解 | **Supported Generation** |
| **证据追溯** | 无 | 显式 evidence attribution |
| **拒绝机制** | 无 | Abstention training |
| **反事实** | 无 | Minimal-edit topological |
| **效率保证** | 无 | Submodular coverage guarantee |
| **验证方式** | Accuracy only | Evidence F1 + Hallucination rate |

---

## 必须证明的声明

| 声明 | 最小证据 | 指标 |
|------|----------|------|
| C1: Support graph 降低幻觉 | 幻觉率绝对下降 >10% | Hallucination rate, Evidence F1 |
| C2: 双通道稀疏化有效 | compute-accuracy tradeoff 曲线 | Latency, Recall, F1 |
| C3: Minimal-edit counterfactual 有效 | 对抗鲁棒性提升 >5% | Ranking accuracy, Abstention rate |
| C4: 模型学会拒绝无证据问题 | Abstention rate 与 evidence level 相关 | Abstention calibration |

---

## 新增组件（GPT-5.4 建议）

### 1. Evidence-Supporting Benchmark 子集

标注 `answer-supporting evidence`:
- 在 Ego4D 或 COIN 上选取 500-1000 个 QA 对
- 标注每个回答所需的视觉证据节点
- 没有这层监督，无法证明 hallucination 真的降了

### 2. 强 Baseline 对比组

必须设一组会"杀死"你的 baseline:
- `question-conditioned retrieval`: 简单检索相关帧
- `keyframe/segment selection`: 关键帧选择
- `hard negative preference tuning`: DPO-style 负样本偏好
- `long-context transformer without graphs`: 无图的长序列 Transformer

如果这些简单法接近你，你的方法故事就站不住。

### 3. 多维指标体系

不只报告 accuracy:
- `hallucination rate`: 事实一致性
- `evidence attribution F1`: 证据追溯精度
- `calibration`: 置信度校准
- `compute-accuracy tradeoff`: 效率曲线

---

## 实验计划（更新）

### 块 1: 主锚点结果（Evidence-Grounded）
- 数据集: Ego4D + Evidence-Supporting 子集
- 比较: 基线 + MT-MG (旧) + Support Graph (新)
- 指标: Hallucination rate + Evidence F1

### 块 2: 双通道稀疏化验证
- 比较: 单通道 vs 双通道 vs 全量图
- 指标: Latency + Recall + Faithfulness

### 块 3: Minimal-Edit Counterfactual 验证
- 比较: 随机 rewiring vs minimal-edit vs 无 counterfactual
- 指标: Ranking accuracy + Abstention rate

### 块 4: 强 Baseline 对比
- 比较: retrieval + keyframe + preference tuning + long-context
- 指标: 全量指标

### 块 5: 失败分析
- 分析: hallucination case vs abstention case
- 目标: 理解边界条件

---

## 计算预算

| 里程碑 | 内容 | GPU 小时 |
|--------|------|----------|
| M0 | Evidence benchmark 标注 + 健全性 | 0.5 |
| M1 | 强 baseline 复现 | 1 |
| M2 | Support graph 主方法 | 2 |
| M3 | 双通道稀疏化 + Counterfactual | 2 |
| M4 | 全量指标 + 失败分析 | 1 |
| **总计** | | **6.5 GPU 天** |

---

## 风险和缓解

| 风险 | 缓解措施 |
|------|----------|
| 宏观意图预测错误传播 | 加 `off-script` 通道 + unexpected-event 检测 |
| 稀疏化过滤关键证据 | 双通道设计 + uncertainty-aware |
| Counterfactual 太 synthetic | Minimal-edit + 人工验证 |
| Baseline 太强 | 调整任务选择，选 evidence-grounding 要求高的任务 |

---

## Scope 控制

**明确不做的**:
- ❌ Cross-Lingual Routing（单独论文）
- ❌ 端到端图神经网络
- ❌ 纯文本重写增强
- ❌ 模型架构设计

**只做**:
- ✅ Support graph consistency
- ✅ Minimal-edit counterfactuals
- ✅ Budgeted evidence selection

---

## 论文叙事模板

### Title
Evidence-Grounded Video Question Answering: Learning to Generate with Support and Abstain without Evidence

### Abstract Template
Video-LLMs suffer from hallucination when generating answers unsupported by visual evidence. We propose Evidence-Grounded Support Graph, a data-centric approach that... Key findings: (1) hallucination rate reduced by X%, (2) evidence attribution F1 reaches Y, (3) model learns to abstain when evidence insufficient.

### Introduction 叙事线
1. Problem: hallucination from unsupported reasoning
2. Gap: no evidence attribution in existing methods
3. Our approach: learn support graph + abstention mechanism
4. Contributions: support graph consistency + minimal-edit counterfactuals + budgeted selection

---

## 下一步行动

1. [ ] 设计 Evidence-Supporting benchmark 子集（500-1000 QA）
2. [ ] 实现双通道稀疏化（exploit + explore）
3. [ ] 实现 minimal-edit counterfactual 算法
4. [ ] 设计 ranking + abstention 训练目标
5. [ ] 设置强 baseline 对比组
6. [ ] 运行 M0-M4 实验
7. [ ] 准备 rebuttal-ready novelty framing

---

## 附录：Cross-Lingual 扩展（单独论文）

如资源充足，可并行开展：

### 想法: Adaptive Cross-Lingual Routing for Multilingual VLMs

- **核心创新**: Script detection + Resource level + Syntax complexity → Dynamic pathway routing
- **解决问题**: 27% performance gap (high vs low-resource languages)
- **预期收益**: 12.7% low-resource accuracy improvement
- **定位**: 单独论文，不混入主线

详见: `LVLM/CROSS_LINGUAL_EXTENSION.md`（待创建）