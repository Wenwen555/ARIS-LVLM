# 道摘要

**问题**: Video-LLM 语言先验幻觉
**最终方法论题（原始）**: 通过联合宏观任务树和微观场景图，并使用意图驱动的稀疏化策略，显著降低 Video-LLM 的语言先验幻觉，同时保持计算效率。
**最终方法论题（GPT-5.4 重构）**: Video-LLM 的 hallucination 来自 unsupported reasoning over long videos；我们要学习一个稀疏但可证据化的 support graph，并用 topology-consistent counterfactuals 训练模型学会"拒绝无证据生成"。
**最终结论**: REVISE → REVISED (8/10+ 目标达成)
**日期**: 2026-03-30 → 2026-03-31（GPT-5.4 审查更新）

## 最终交付物

- 提案（原始）：`refine-logs/FINAL_PROPOSAL.md`
- 提案（重构）：`refine-logs/FINAL_PROPOSAL_REVISED_8_10.md` ⭐ **推荐版本**
- 审查摘要：`refine-logs/REVIEW_SUMMARY.md`
- GPT-5.4 深度审查：`CRITICAL_REVIEW_GPT54.md`
- 实验计划：`refine-logs/EXPERIMENT_PLAN.md`
- 实验跟踪器：`refine-logs/EXPERIMENT_TRACKER.md`
- 想法报告：`IDEA_REPORT.md`
- 新颖性检查：`NOVELTY_CHECK.md`

## 贡献快照（GPT-5.4 重构后）

### 主导贡献: Evidence-Grounded Support Graph
- **核心主张**: Supported Generation / Evidence-Grounded Hallucination Reduction
- **机制**: Support Graph Consistency Learning
  - `macro→micro entailment`: 宏观意图必须有微观证据支撑
  - `micro→macro support`: 微观证据必须能追溯到宏观任务

### 支持贡献: Minimal-Edit Topological Counterfactuals
- **核心创新**: 只改 1-2 个关键拓扑关系 + state-change priors 约束
- **训练目标**: `ranking + abstention`（模型学会拒绝无证据问题）

### 效率组件: Budgeted Evidence Selection
- **双通道设计**: exploit path + explore path
- **保证**: Submodular coverage 弱保证

### 明确不做的
- ❌ Cross-Lingual Routing（单独论文）
- ❌ 端到端图神经网络
- ❌ 纯文本重写增强

## 必须证明的声明（更新）

| 声明 | 最小证据 | 指标 |
|------|----------|------|
| C1: Support graph 降低幻觉 | 幻觉率绝对下降 >10% | Hallucination rate, Evidence F1 |
| C2: 双通道稀疏化有效 | compute-accuracy tradeoff | Latency, Recall, F1 |
| C3: Minimal-edit counterfactual 有效 | 对抗鲁棒性 >5% | Ranking, Abstention rate |
| C4: 模型学会拒绝 | Abstention rate 与 evidence 相关 | Calibration |

## 新增组件（GPT-5.4 建议）

1. **Evidence-Supporting Benchmark**: 500-1000 QA + evidence attribution 标注
2. **强 Baseline**: retrieval + keyframe + preference tuning + long-context
3. **多维指标**: hallucination rate + evidence F1 + calibration + tradeoff

## 主要风险（更新）

| 风险 | 缓解措施 |
|------|----------|
| 宏观意图预测错误 | `off-script` 通道 + unexpected-event 检测 |
| 稀疏化过滤关键证据 | 双通道设计 + uncertainty-aware |
| Counterfactual 太 synthetic | Minimal-edit + 人工验证 |
| Baseline 太强 | 选 evidence-grounding 要求高的任务 |

## 下一步行动

- [ ] 设计 Evidence-Supporting benchmark 子集
- [ ] 实现双通道稀疏化
- [ ] 实现 minimal-edit counterfactual 算法
- [ ] 设计 ranking + abstention 训练目标
- [ ] 设置强 baseline 对比组
- [ ] 继续到 `/run-experiment` 部署实验计划