# Git 双机协作指南

这份指南适用于当前仓库已经托管到 GitHub 的情况。目标是让两台电脑都围绕同一个远程仓库协作研究内容，避免文件来回手动复制。

## 当前仓库状态

- 远程仓库: `origin = https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep.git`
- 默认分支: `main`
- 推荐方式: 两台电脑都连接同一个 GitHub 仓库，通过 `commit + pull --rebase + push` 同步

## 第一次配置

### 电脑 A

在仓库根目录执行:

```powershell
.\tools\setup_git_dual_machine.ps1
```

这会为当前仓库设置:

- `pull.rebase=true`
- `rebase.autoStash=true`
- `fetch.prune=true`
- `git ll` 日志别名
- `git sync-research` 同步别名

### 电脑 B

先克隆仓库:

```powershell
git clone https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep.git
cd Auto-claude-code-research-in-sleep
.\tools\setup_git_dual_machine.ps1
```

如果两台电脑使用不同 Git 身份，也可以分别设置:

```powershell
git config user.name "你的名字"
git config user.email "你的邮箱"
```

## 日常协作流程

### 开始工作前

每次在任意一台电脑开始之前，先同步远程最新进度:

```powershell
git sync-research
```

如果你还没有配置别名，也可以直接执行:

```powershell
.\tools\git_sync_research.ps1
```

### 工作完成后

把当前改动保存并推送到远程:

```powershell
.\tools\git_sync_research.ps1 -CommitMessage "research: update LVLM literature survey"
```

这个命令会自动执行:

1. `git add -A`
2. `git commit -m "..."`
3. `git fetch origin 当前分支`
4. `git pull --rebase origin 当前分支`
5. `git push origin 当前分支`

### 切换到另一台电脑

到另一台电脑后，只需要:

```powershell
git sync-research
```

然后继续编辑即可。

## 推荐习惯

- 同一份研究记录不要在两台电脑上同时修改后再一起推送，最好是一台提交后，另一台先拉取再继续。
- 每次结束一个小阶段就提交一次，提交信息尽量描述研究动作，例如:
  - `research: expand LVLM literature survey`
  - `research: add supplementary papers`
  - `research: refine idea report notes`
- 如果你想把研究和项目主线隔离开，可以新建长期分支，例如:

```powershell
git checkout -b research/lvlm
git push -u origin research/lvlm
```

之后两台电脑都在这个分支上工作。

## 冲突处理

如果两台电脑修改了同一个文件，`git pull --rebase` 可能会提示冲突。常见处理流程:

```powershell
git status
```

打开冲突文件，手动保留正确内容后:

```powershell
git add 冲突文件
git rebase --continue
git push origin 当前分支
```

如果想放弃这次 rebase:

```powershell
git rebase --abort
```

## 当前仓库的注意事项

- `.claude/`、`.venv/`、缓存目录和日志文件已经加入 `.gitignore`，避免把机器本地状态同步到另一台电脑。
- 你当前工作区里已经有未提交改动。在切换到另一台电脑之前，建议先运行:

```powershell
.\tools\git_sync_research.ps1 -CommitMessage "research: checkpoint current LVLM work"
```

这样第二台电脑就能直接拉到你现在的研究进度。
