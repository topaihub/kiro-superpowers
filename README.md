# Kiro CLI + Superpowers + OpenSpec 配置同步

将 Kiro CLI 配置托管到 GitHub，集成 [obra/superpowers](https://github.com/obra/superpowers) 技能框架和 [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) 规范驱动开发框架，支持跨设备同步和一键更新。

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

## 目录结构

```
~/.kiro/
├── agents/
│   └── default.json              # agent 配置，加载 superpowers + openspec skills
├── superpowers/                   # submodule → github.com/obra/superpowers
│   └── skills/
├── skills -> superpowers/skills   # 软链接
├── openspec-skills/               # OpenSpec 技能（基于官方模板）
│   ├── openspec-explore/          # 探索模式：讨论需求，不写代码
│   │   └── SKILL.md
│   ├── openspec-propose/          # 一步生成全套规划文档
│   │   └── SKILL.md
│   ├── openspec-apply-change/     # 按 tasks.md 逐项实施
│   │   └── SKILL.md
│   └── openspec-archive-change/   # 归档完成的变更
│       └── SKILL.md
├── update-superpowers.sh          # 更新脚本
└── README.md
```

## OpenSpec 使用前提

需要先安装 OpenSpec CLI：

```bash
npm install -g @fission-ai/openspec@latest
```

然后在项目中初始化：

```bash
cd your-project
openspec init
```

## 在 Kiro CLI 中使用 OpenSpec

技能会按需自动加载。你可以用自然语言触发：

- **探索需求**："let's explore how to handle authentication"（触发 openspec-explore）
- **创建提案**："propose a change for add-dark-mode"（触发 openspec-propose）
- **实施任务**："implement the tasks for add-dark-mode"（触发 openspec-apply-change）
- **归档变更**："archive the add-dark-mode change"（触发 openspec-archive-change）
