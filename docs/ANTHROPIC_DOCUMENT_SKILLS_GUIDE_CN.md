# Anthropic 官方 Document Skills 接入 ARIS 指南

本文档说明如何把 Anthropic 官方 `document-skills` 接入到 ARIS，并配合本仓库新增的：

- `document-reader`
- `read-pdf`
- `read-docx`
- `read-xlsx`
- `read-pptx`

一起使用。

## 设计思路

采用两层结构：

1. **上游官方能力层**
   - 来自 `anthropics/skills`
   - 通过 Claude Code plugin marketplace 安装
   - 提供官方 `pdf`、`docx`、`pptx`、`xlsx` skills
2. **ARIS 适配层**
   - 位于本仓库 `skills/`
   - 提供科研工作流导向的统一入口和输出规范
   - 不重复实现底层 Office/PDF 处理逻辑

这样做的好处是：

- 上游能力更新时更容易跟进
- ARIS 保持自己的科研输出格式
- 不把 Anthropic 的 source-available 文档技能直接 vendoring 进仓库

## 官方来源

Anthropic 官方 GitHub：

- `https://github.com/anthropics/skills`

该仓库包含官方文档技能：

- `skills/pdf`
- `skills/docx`
- `skills/pptx`
- `skills/xlsx`

## 安装方式

在 Claude Code 中执行：

```bash
claude plugin marketplace add anthropics/skills
claude plugin install document-skills@anthropic-agent-skills
claude plugin list
```

安装成功后，应该能看到：

```text
document-skills@anthropic-agent-skills
```

## 本仓库新增的技能结构

```text
skills/
  document-reader/
    SKILL.md
    references/
      install.md
      output-contract.md
  read-pdf/
    SKILL.md
  read-docx/
    SKILL.md
  read-xlsx/
    SKILL.md
  read-pptx/
    SKILL.md
```

## 调用关系

- `document-reader` 是总入口
- `read-pdf` 对接 Anthropic 官方 `pdf`
- `read-docx` 对接 Anthropic 官方 `docx`
- `read-xlsx` 对接 Anthropic 官方 `xlsx`
- `read-pptx` 对接 Anthropic 官方 `pptx`

推荐用法：

- 读单个 PDF：`/read-pdf path/to/file.pdf`
- 读单个 Word：`/read-docx path/to/file.docx`
- 读单个 Excel：`/read-xlsx path/to/file.xlsx`
- 读单个 PPT：`/read-pptx path/to/file.pptx`
- 读混合材料包：`/document-reader docs/`

## 输出约定

ARIS 适配层统一要求输出：

- 文件身份
- 结构清单
- 关键内容
- 科研结论
- 提取风险
- 下一步建议

这样后续更容易接入：

- `research-lit`
- `idea-discovery`
- `paper-plan`
- `paper-write`
- `paper-slides`
- `paper-poster`

## 可选自动化

如果你想在本机一键安装官方 document-skills，可以运行：

```bash
python tools/install_anthropic_document_skills.py
```

该脚本会：

1. 检查 Claude CLI 是否存在
2. 添加 `anthropics/skills` marketplace
3. 安装 `document-skills@anthropic-agent-skills`
4. 打印最终 plugin 列表
