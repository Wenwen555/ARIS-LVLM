# 文献调研补充：视频幻觉诊断与抑制

**更新日期**: 2026-03-31
**来源**: GPT-5.4 深度文献分析

---

## 一、视频幻觉基准与诊断方法

### 1.1 VideoHallucer (2024-06-24)

**基本信息**
- **标题**: VideoHallucer: Evaluating Intrinsic and Extrinsic Hallucinations in Large Video-Language Models
- **作者**: Yuxuan Wang, Yueqian Wang, Dongyan Zhao, Cihang Xie, Zilong Zheng
- **发表**: arXiv:2406.16338, 2024-06-24

**核心贡献**
- **首个综合视频幻觉基准**：覆盖 5 种幻觉类型
- **幻觉分类**：
  - **Intrinsic（内在）**: Object-relation, Temporal, Semantic-detail
  - **Extrinsic（外在）**: Factual, Non-factual

**方法**
- **配对问题设计**：
  - Basic question：测试模型是否识别正确内容
  - Hallucinated question：注入误导性内容
- **评估指标**：
  - Overall paired accuracy（必须同时答对两题）
  - Yes Percentage Difference (Pct. Diff)
  - False Positive Ratio (FP Ratio)

**基准详情**
| 设置 | 问题数 | 数据来源 |
|------|--------|----------|
| Object-relation | 400 | VidOR, VidVRD |
| Temporal | 400 | ActivityNet |
| Semantic-detail | 400 | HawkEye |
| Extrinsic factual | 400 | YouCook, COIN, EDUVSUM |
| Extrinsic non-factual | 400 | YouCook, COIN, EDUVSUM |
| **总计** | **1,800** | **948 视频** |

**主要发现**
- GPT-4o 最强：53.3% overall accuracy（人类 85.0%）
- PLLaVA-34B 最强开源：45.0%
- Self-PEP 改进 5.38%

**局限**
- 人工标注噪声
- 仅限 binary VQA，非开放式生成

---

### 1.2 EventHallusion (2024-09-25)

**基本信息**
- **标题**: EventHallusion: Diagnosing Event Hallucinations in Video LLMs
- **作者**: Jiacheng Zhang, Yang Jiao, Shaoxiang Chen, et al.
- **发表**: arXiv:2409.16597, 2024-09-25

**核心贡献**
- 聚焦 **Event Hallucination**
- 分析 **Prior-driven 错误**：
  - Visual/content priors（视觉先验）
  - Language priors（语言先验）

**方法**
- **三个评估类别**：
  - Entire rare events（稀有事件）
  - Interleave common-rare events（交替事件）
  - Misleading（误导性问题）

- **Temporal Contrastive Decoding (TCD)**：
  - 比较原始视频 vs 时间退化版本
  - 减少先验驱动的幻觉

**基准详情**
| 维度 | 值 |
|------|------|
| 视频 | 400 个（手动收集） |
| 域 | 7 个（宠物、运动、食物、健身、车辆、生活、自然） |
| 任务 | Binary classification + Description matching |

**主要发现**
- VILA 最强开源：65.04% binary, 33.25% description
- GPT-4o 最强：84.11% binary, 56.17% description
- TCD 改进 2-4%

**局限**
- 基准较小（400 视频）
- 依赖 GPT-4o 作为评估器

---

### 1.3 VidHalluc (CVPR 2025)

**基本信息**
- **标题**: VidHalluc: Evaluating Temporal Hallucinations in Multimodal Large Language Models for Video Understanding
- **作者**: Chaoyu Li, Eun Woo Im, Pooyan Fazli
- **发表**: arXiv:2412.03735 → CVPR 2025

**核心贡献**
- **最大视频幻觉基准**（当时）
- **半自动化大规模构建**
- **DINO-HEAL**：基于 DINOv2 的免训练缓解方法

**方法**
- **视频对选择**：
  - CLIP/SigLIP 语义相似
  - DINOv2 视觉不同
- **三种幻觉类型**：
  - Action Hallucination (ACH)
  - Temporal Sequence Hallucination (TSH)
  - Scene Transition Hallucination (STH)

**基准详情**
| 类型 | 视频 | QA 对 | 平均时长 |
|------|------|-------|----------|
| ACH | 3,957 | 8,250 | 21.79s |
| TSH | 600 | 600 | 41.19s |
| STH | 445 | 445 | 28.72s |
| **总计** | **5,002** | **9,295** | **24.70s** |

**主要发现**
- GPT-4o：ACH 81.15%, TSH 82.00%, STH 71.58%
- 人类：ACH 95.14%, TSH 90.17%, STH 87.43%
- DINO-HEAL 平均改进 3.02%

**局限**
- 仅 3 种幻觉类型
- DINO-HEAL 空间显著性为主，时序信息不足

---

## 二、文献演进脉络

```
2024-06  VideoHallucer    → 综合幻觉分类，配对评估
    ↓
2024-09  EventHallusion   → 事件幻觉聚焦，Prior 分析
    ↓
2024-12  VidHalluc (CVPR) → 大规模时序幻觉，半自动化构建
```

**关键进展**：
1. **评估粒度**：Broad → Event-focused → Temporal-dynamic
2. **基准规模**：1,800 → 400 → 9,295 QA 对
3. **构建方法**：人工 → 人工 → 半自动化
4. **缓解方法**：Self-PEP → TCD → DINO-HEAL

---

## 三、与本研究的关系

### 差异化定位

| 维度 | VideoHallucer | EventHallusion | VidHalluc | **本研究 (SSV)** |
|------|---------------|----------------|-----------|------------------|
| 任务 | 诊断 | 诊断 | 诊断 | **抑制 + Abstention** |
| Abstention | 无 | 无 | 无 | **Support-insufficient 触发** |
| Evidence | 无 | 无 | DINOv2 saliency | **答案条件检索** |
| 训练 | Self-PEP | TCD（推理） | 无训练 | **最小支持破坏** |

### 可复用的基准

本研究应在以下基准上评估：

| 基准 | 适用性 | 用途 |
|------|--------|------|
| **VideoHallucer** | 高 | 5 种幻觉类型诊断 |
| **VidHalluc** | 高 | 时序幻觉评估 |
| EventHallusion | 中 | 事件幻觉补充 |
| COIN/Ego4D | 高 | 主实验 + 数据构建 |

---

## 四、建议的评估协议

### 主实验

1. **VideoHallucer**：报告 overall paired accuracy
2. **VidHalluc**：报告 ACH/TSH/STH 分数
3. **COIN/Ego4D**：报告 hallucination rate + abstention calibration

### 新增指标

- **Abstention Rate**: 拒绝回答的比例
- **False-Abstain Rate**: 正确答案被拒绝的比例
- **Risk-Coverage Curve**: 不同 τ 下的性能