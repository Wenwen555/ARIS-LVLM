# ARIS-LVLM Research Workspace

本仓库是基于 ARIS 工作流改造的私有研究工作区，用于持续推进我们的 LVLM 研究，并支持两台电脑协同处理同一项目。

当前研究主线聚焦于：

- 长程程序性视频理解
- 结构化中间表示与证据约束
- Video-LLM 幻觉诊断与抑制
- 基于意图驱动的 MT-MG 数据构建与问答生成

仓库既保留了 ARIS 的研究自动化能力，也改造成了适合个人/小团队长期研究的 Git 工作流：

- `origin` 指向我们自己的私有仓库，用于双机同步
- `upstream` 指向原始 ARIS 仓库，用于持续获取上游更新

## Research Focus

我们的核心研究假设是：

1. 长程程序性视频理解不仅需要时序切分，还需要宏观任务结构和微观视觉证据之间的显式对齐。
2. 仅依赖语言先验的视频问答容易产生 hallucination，需要让回答过程受到结构化证据约束。
3. 通过 `Macro-Tree + Micro-Graph` 的联合表示，可以为 Video-LLM 提供更稳健的中间层监督。
4. 通过意图驱动的数据构建与稀疏化策略，可以降低长视频建模成本，并提升问答质量与真实性。

当前正在围绕 `Evidence-Grounded MT-MG` 方向推进研究设计、文献调研、方案细化和实验准备。

## Key Documents

| File | Purpose |
|------|---------|
| [`LVLM/LITERATURE_SURVEY.md`](LVLM/LITERATURE_SURVEY.md) | 主文献综述，梳理程序性长视频、结构化表示、幻觉抑制相关工作 |
| [`LVLM/LITERATURE_SUPPLEMENT.md`](LVLM/LITERATURE_SUPPLEMENT.md) | 面向视频幻觉诊断与抑制的补充文献 |
| [`LVLM/IDEA_REPORT.md`](LVLM/IDEA_REPORT.md) | 候选研究方向、筛选结果与优先级 |
| [`LVLM/RESEARCH_REVIEW.md`](LVLM/RESEARCH_REVIEW.md) | 外部批判性评审与风险分析 |
| [`LVLM/COMPREHENSIVE_REPORT.md`](LVLM/COMPREHENSIVE_REPORT.md) | 研究脉络与整体方案的综合性汇总 |
| [`LVLM/基于意图驱动 MT-MG 架构的高质量多维问答数据构建.md`](LVLM/%E5%9F%BA%E4%BA%8E%E6%84%8F%E5%9B%BE%E9%A9%B1%E5%8A%A8%20MT-MG%20%E6%9E%B6%E6%9E%84%E7%9A%84%E9%AB%98%E8%B4%A8%E9%87%8F%E5%A4%9A%E7%BB%B4%E9%97%AE%E7%AD%94%E6%95%B0%E6%8D%AE%E6%9E%84%E5%BB%BA.md) | 当前最接近论文题目的方案草稿 |
| [`docs/GIT_DUAL_MACHINE_WORKFLOW_CN.md`](docs/GIT_DUAL_MACHINE_WORKFLOW_CN.md) | 双机协作与上游同步操作指南 |

## Repository Layout

```text
.
├─ LVLM/                 # 研究主文档、proposal、survey、review、refine logs
├─ docs/                 # 工作流说明、环境配置、双机协作说明
├─ skills/               # ARIS / Codex / Claude 相关技能文件
├─ tools/                # Git 同步脚本、文献工具、安装脚本
├─ templates/            # 研究模板
└─ tests/                # 脚本或工作流相关测试
```

## Dual-Machine Workflow

### Remote Roles

- `origin`: 我们自己的私有仓库，用于日常提交、双机同步、研究版本管理
- `upstream`: 原始 ARIS 仓库，用于拉取原项目更新

查看当前 remote：

```powershell
git remote -v
```

推荐结果：

```text
origin   https://github.com/<your-name>/ARIS-LVLM.git
upstream https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep.git
```

### First-Time Setup

第一台电脑在仓库根目录执行：

```powershell
.\tools\setup_git_dual_machine.ps1
```

第二台电脑建议直接从自己的私有仓库克隆：

```powershell
git clone https://github.com/<your-name>/ARIS-LVLM.git
cd ARIS-LVLM
git remote add upstream https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep.git
.\tools\setup_git_dual_machine.ps1
```

### Daily Sync

开始工作前：

```powershell
git sync-research
```

结束工作后：

```powershell
.\tools\git_sync_research.ps1 -CommitMessage "research: checkpoint current LVLM work"
```

这个脚本会自动执行：

1. `git add -A`
2. `git commit -m "..."`
3. `git fetch origin 当前分支`
4. `git pull --rebase origin 当前分支`
5. `git push origin 当前分支`

### Switching Between Two Computers

在电脑 A 推送后，到电脑 B 只需要：

```powershell
git sync-research
```

然后继续编辑即可。建议不要在两台电脑上同时修改同一份核心文档后再一起推送。

## Syncing Upstream ARIS

为了持续获取原始 ARIS 仓库的新能力、脚本和工作流，建议定期在本仓库执行：

```powershell
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

推荐使用 `merge` 而不是 `rebase` 来引入上游更新，这样对双机协作更稳，也更容易排查冲突。

如果出现冲突：

```powershell
git status
```

手动解决冲突后：

```powershell
git add <conflicted-files>
git commit
git push origin main
```

## Recommended Working Style

- 每完成一个小阶段就做一次 checkpoint 提交
- 研究内容尽量用清晰的提交信息，例如 `research: expand LVLM literature survey`
- 如果某条研究线需要隔离，可以建立长期分支，例如 `research/lvlm`
- 在引入 `upstream` 更新之前，先确保本地改动已经提交
- 双机之间只通过 `origin` 同步，不要直接在第二台电脑上重新从 `upstream` 开始做研究

## Scripts

| Script | Purpose |
|--------|---------|
| [`tools/setup_git_dual_machine.ps1`](tools/setup_git_dual_machine.ps1) | 初始化当前仓库的双机协作 Git 配置 |
| [`tools/git_sync_research.ps1`](tools/git_sync_research.ps1) | 一键提交、同步并推送到 `origin` |

## Upstream Attribution

本仓库源自：

- Upstream project: [`wanshuiyin/Auto-claude-code-research-in-sleep`](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep)

我们在其基础上保留研究自动化能力，并进一步将其改造成适合当前 LVLM 课题的长期研究工作区。

## Language

本仓库当前以中文研究记录为主。`README_CN.md` 为中文版镜像说明。
