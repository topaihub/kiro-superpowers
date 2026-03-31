# Kiro CLI + Superpowers + OMO 配置同步

将 Kiro CLI 配置托管到 GitHub，集成 [obra/superpowers](https://github.com/obra/superpowers) 技能框架和 OMO 多智能体协作能力，支持跨设备同步和一键更新。

## 换电脑同步

```bash
git clone --recursive git@github.com:topaihub/kiro-superpowers.git ~/.kiro
```

如果忘了 `--recursive`：

```bash
cd ~/.kiro
git submodule update --init
```

## 更新 Superpowers

```bash
~/.kiro/update-superpowers.sh
cd ~/.kiro && git push
```

## 集成 OpenSpec

OpenSpec 是项目级的，在每个项目中运行：

```bash
npm install -g @fission-ai/openspec@latest
cd your-project
openspec init --tools kiro
openspec update                    # 随 CLI 版本更新技能文件
```

## OMO 多智能体协作

基于 Kiro CLI 的 `use_subagent` 机制，移植了 OMO 的核心专家角色。

### 三个专家 Agent

| Agent | 角色 | 工具权限 | 信任级别 |
|-------|------|---------|---------|
| **oracle** | 架构顾问 | 只读（fs_read/grep/glob/code） | 自动信任 |
| **explore** | 代码侦察兵 | 只读（fs_read/grep/glob/code） | 自动信任 |
| **librarian** | 文档研究员 | 只读 + 网络搜索 | 自动信任 |

### 使用方式

技能自动触发，用自然语言即可：

- **架构分析**："analyze the architecture of this project" → 派 oracle
- **代码搜索**："find all API endpoints in the codebase" → 派 explore
- **文档研究**："research best practices for JWT authentication" → 派 librarian
- **复杂任务**："implement user notifications" → 先并行派 explore + librarian 侦察，再规划实施
- **项目扫描**："init deep" → 扫描项目生成分层 AGENTS.md

### 调度模式

1. **单专家** — 简单任务直接派一个
2. **并行侦察** — 复杂任务先派 2-3 个专家并行收集信息
3. **全面评审** — 重大决策三个专家全派，综合建议

## 目录结构

```
~/.kiro/
├── agents/
│   ├── default.json              # 主 agent（Superpowers + OMO 编排）
│   ├── oracle.json               # 架构顾问（只读）
│   ├── explore.json              # 代码侦察兵（只读）
│   └── librarian.json            # 文档研究员（只读 + 网络搜索）
├── superpowers/                   # submodule → github.com/obra/superpowers
│   └── skills/
├── skills -> superpowers/skills   # 软链接
├── omo-skills/                    # OMO 编排技能
│   ├── omo-orchestrate/SKILL.md   # 多智能体调度
│   └── omo-init-deep/SKILL.md    # 项目扫描生成上下文
├── update-superpowers.sh
└── README.md
```
