# 在 Kiro CLI 中使用 OpenSpec：完整教程

> OpenSpec 原生支持 Kiro CLI。运行 `openspec init --tools kiro` 即可自动生成技能文件，`openspec update` 随版本同步更新。

## 一、前置条件

### 1.1 确认 Kiro CLI 已安装

```bash
kiro-cli --version
```

### 1.2 确认 Node.js 已安装

OpenSpec CLI 依赖 Node.js 20.19.0+。

```bash
node --version   # 需要 v20.19.0 或更高
npm --version
```

如果 WSL 中没有 Node.js，推荐用 fnm 安装：

```bash
# 安装 fnm（Rust 写的 Node 版本管理器）
curl -fsSL https://fnm.vercel.app/install | bash
source ~/.bashrc

# 安装 Node LTS
fnm install --lts
fnm default lts-latest

# 验证
node --version
```

### 1.3 安装 OpenSpec CLI

```bash
npm install -g @fission-ai/openspec@latest
openspec --version
```

---

## 二、在项目中初始化 OpenSpec

进入你的项目目录，运行：

```bash
cd your-project
openspec init --tools kiro
```

这一条命令会自动完成所有配置：

```
✔ Setup complete for Kiro

Created: Kiro
4 skills and 4 commands in .kiro/
```

### 生成的文件结构

```
your-project/
├── .kiro/
│   ├── skills/                          # Kiro CLI 自动发现的技能
│   │   ├── openspec-explore/SKILL.md
│   │   ├── openspec-propose/SKILL.md
│   │   ├── openspec-apply-change/SKILL.md
│   │   └── openspec-archive-change/SKILL.md
│   └── prompts/                         # Kiro CLI 的 prompt 文件
│       ├── opsx-explore.prompt.md
│       ├── opsx-propose.prompt.md
│       ├── opsx-apply.prompt.md
│       └── opsx-archive.prompt.md
└── openspec/
    ├── specs/                           # 系统规范（初始为空）
    └── changes/                         # 变更提案（初始为空）
```

- `.kiro/skills/` 下的 SKILL.md 文件会被 Kiro CLI 自动发现并按需加载
- `.kiro/prompts/` 下的 prompt.md 文件提供斜杠命令支持
- `openspec/` 是规范和变更的存储目录

### 建议的 .gitignore

OpenSpec 的规范文件应该提交到仓库（它们是项目文档的一部分）。`.kiro/skills/` 和 `.kiro/prompts/` 中的 OpenSpec 文件是自动生成的，可以选择提交或忽略：

```gitignore
# 如果选择不提交（其他人 clone 后运行 openspec init 即可恢复）
# .kiro/skills/openspec-*/
# .kiro/prompts/opsx-*
```

---

## 三、更新 OpenSpec 技能文件

当你升级了 OpenSpec CLI 版本后，在项目中运行：

```bash
openspec update
```

输出示例：

```
✓ All 1 tool(s) up to date (v1.2.0)
  Tools: kiro
```

这会自动将 `.kiro/skills/` 和 `.kiro/prompts/` 中的文件更新到与当前 CLI 版本匹配的最新模板。

如果想强制刷新（即使版本没变）：

```bash
openspec update --force
```

---

## 四、在 Kiro CLI 中使用

重启 Kiro CLI（或开始新会话），OpenSpec 的 4 个技能会自动可用。

### 4.1 核心工作流

```
explore（探索）→ propose（提案）→ apply（实施）→ archive（归档）
```

### 4.2 探索需求

当思路不清晰时，先进入探索模式：

```
你：我想给应用加个通知系统，但不确定怎么做

Kiro：[openspec-explore 技能自动激活]
      让我先看看你的代码库...
      [分析代码，画 ASCII 图，讨论方案]
```

探索模式只讨论不写代码，帮你理清思路。

### 4.3 创建提案

思路清晰后，创建变更提案：

```
你：propose a change for add-notification-system

Kiro：[openspec-propose 技能自动激活]
      [运行 openspec new change "add-notification-system"]
      [运行 openspec status --json 获取制品依赖]
      [运行 openspec instructions --json 获取模板]
      [依次生成 proposal.md → specs → design.md → tasks.md]
      
      All artifacts created! Ready for implementation.
```

生成的文件：

```
openspec/changes/add-notification-system/
├── proposal.md     # 为什么做、做什么
├── design.md       # 技术方案
├── tasks.md        # 实施清单（带复选框）
└── specs/
    └── notifications/
        └── spec.md # 需求规范（GIVEN/WHEN/THEN 格式）
```

### 4.4 实施任务

```
你：implement the tasks for add-notification-system

Kiro：[openspec-apply-change 技能自动激活]
      Using change: add-notification-system
      
      Working on task 1/5: Create notification model
      [写代码]
      ✓ Task complete
      
      Working on task 2/5: Add API endpoints
      [写代码]
      ✓ Task complete
      ...
```

Kiro 会逐个完成 tasks.md 中的任务，每完成一个就标记 `[x]`。中途被打断后再次触发会从上次停止的地方继续。

### 4.5 归档变更

所有任务完成后：

```
你：archive the notification system change

Kiro：[openspec-archive-change 技能自动激活]
      ✓ Synced specs to openspec/specs/notifications/spec.md
      ✓ Moved to openspec/changes/archive/2026-03-31-add-notification-system/
      
      Archive complete!
```

归档后：
- Delta specs 合并到 `openspec/specs/`（系统规范更新）
- 变更文件夹移到 `openspec/changes/archive/`（保留完整历史）

---

## 五、与 Superpowers 的协作

如果你同时使用 Superpowers（通过 `~/.kiro/skills` 全局加载），两者可以协同工作：

| 工具 | 层级 | 职责 |
|------|------|------|
| OpenSpec | 项目级（`.kiro/skills/`） | 管理需求规范和变更文档 |
| Superpowers | 全局级（`~/.kiro/skills/`） | 强制 TDD、代码审查、系统化调试 |

典型流程：
1. **OpenSpec** `explore` → 讨论需求
2. **OpenSpec** `propose` → 生成规范文档
3. **Superpowers** `brainstorming` → 细化技术设计
4. **Superpowers** `writing-plans` → 拆解为小任务
5. **OpenSpec** `apply` → 按规范实施（Superpowers 的 TDD 技能会自动介入）
6. **OpenSpec** `archive` → 归档规范

---

## 六、CLI 常用命令速查

```bash
# 初始化（每个项目一次）
openspec init --tools kiro

# 更新技能文件（升级 CLI 后）
openspec update

# 查看活跃变更
openspec list

# 查看变更状态
openspec status --change "change-name"

# 验证规范格式
openspec validate "change-name"

# 查看变更详情
openspec show "change-name"

# 交互式仪表板
openspec view

# 查看当前配置
openspec config list

# 查看 CLI 版本
openspec --version
```

---

## 七、常见问题

**Q：`openspec` 命令报 `node: not found`？**

WSL 中没有安装 Node.js。参考第一节用 fnm 安装。

**Q：Kiro CLI 没有识别 OpenSpec 技能？**

- 确认已运行 `openspec init --tools kiro`
- 确认 `.kiro/skills/openspec-*/SKILL.md` 文件存在
- 重启 Kiro CLI 会话

**Q：升级 OpenSpec 后技能文件过时？**

```bash
npm install -g @fission-ai/openspec@latest
cd your-project
openspec update
```

**Q：多个项目都要运行 `openspec init` 吗？**

是的。OpenSpec 是项目级的，每个项目需要独立初始化。这是设计使然——不同项目可能用不同的 schema 和配置。

**Q：`openspec init` 生成的文件要提交到 Git 吗？**

- `openspec/` 目录（规范和变更）—— **建议提交**，这是项目文档
- `.kiro/skills/` 和 `.kiro/prompts/` —— **可选**，提交方便团队成员直接使用，不提交的话其他人运行 `openspec init --tools kiro` 即可恢复
