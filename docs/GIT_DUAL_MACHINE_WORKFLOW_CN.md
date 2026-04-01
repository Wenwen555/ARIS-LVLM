# Git 双机协作指南

这份指南适用于当前仓库已经拆分为两个 remote 的情况：

- `origin` 是我们自己的私有仓库，用于双机同步与研究提交
- `upstream` 是原始 ARIS 仓库，用于持续接收原项目更新

## 当前推荐结构

```text
origin   -> https://github.com/<your-name>/ARIS-LVLM.git
upstream -> https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep.git
```

查看当前配置：

```powershell
git remote -v
```

## 第一次配置

### 电脑 A

在仓库根目录执行：

```powershell
.\tools\setup_git_dual_machine.ps1
```

这会为当前仓库设置：

- `pull.rebase=true`
- `rebase.autoStash=true`
- `fetch.prune=true`
- `git ll`
- `git sync-research`

### 电脑 B

建议直接从自己的私有仓库克隆，而不是从 `upstream` 克隆：

```powershell
git clone https://github.com/<your-name>/ARIS-LVLM.git
cd ARIS-LVLM
git remote add upstream https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep.git
.\tools\setup_git_dual_machine.ps1
```

如果两台电脑使用不同 Git 身份，也可以分别设置：

```powershell
git config user.name "你的名字"
git config user.email "你的邮箱"
```

## 日常协作流程

### 开始工作前

每次在任意一台电脑开始之前，先同步自己的私有仓库：

```powershell
git sync-research
```

如果还没有配置别名，也可以直接执行：

```powershell
.\tools\git_sync_research.ps1
```

### 工作完成后

保存并推送当前改动：

```powershell
.\tools\git_sync_research.ps1 -CommitMessage "research: update LVLM literature survey"
```

这个命令会自动执行：

1. `git add -A`
2. `git commit -m "..."`
3. `git fetch origin 当前分支`
4. `git pull --rebase origin 当前分支`
5. `git push origin 当前分支`

### 切换到另一台电脑

到另一台电脑后只需要：

```powershell
git sync-research
```

然后继续工作即可。

## 同步上游更新

为了获取原始 ARIS 仓库的新脚本、新工作流和 bugfix，定期执行：

```powershell
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

推荐使用 `merge`，因为它对两台电脑协作更稳，且不会改写已经在另一台电脑使用的提交历史。

## 推荐习惯

- 同一份研究记录不要在两台电脑上并行修改太久
- 每结束一个小阶段就提交一次
- 提交信息尽量描述研究动作，例如：
  - `research: expand LVLM literature survey`
  - `research: add supplementary papers`
  - `research: refine idea report notes`
- 如果研究线较多，可以使用长期分支，例如：

```powershell
git checkout -b research/lvlm
git push -u origin research/lvlm
```

之后两台电脑都在这个分支上工作。

## 冲突处理

如果两台电脑修改了同一个文件，`git pull --rebase` 可能会提示冲突。常见处理流程：

```powershell
git status
```

打开冲突文件，手动保留正确内容后：

```powershell
git add 冲突文件
git rebase --continue
git push origin 当前分支
```

如果想放弃本次 rebase：

```powershell
git rebase --abort
```

## 当前仓库的注意事项

- `.claude/`、`.venv/`、缓存目录和日志文件已经加入 `.gitignore`
- 双机之间的日常同步只走 `origin`
- 需要接收原仓库更新时，才显式执行 `git fetch upstream`
