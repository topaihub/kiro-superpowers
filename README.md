# Kiro CLI + Superpowers 配置同步

将 Kiro CLI 配置托管到 GitHub，集成 [obra/superpowers](https://github.com/obra/superpowers) 技能框架，支持跨设备同步和一键更新。

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
npm install -g @fission-ai/openspec@latest   # 首次安装
cd your-project
openspec init --tools kiro                     # 自动生成 .kiro/skills/ 和 .kiro/prompts/
openspec update                                # 随 CLI 版本更新技能文件
```

生成的文件结构：

```
your-project/
├── .kiro/
│   ├── skills/                    # openspec init 自动生成
│   │   ├── openspec-explore/
│   │   ├── openspec-propose/
│   │   ├── openspec-apply-change/
│   │   └── openspec-archive-change/
│   └── prompts/                   # openspec init 自动生成
│       ├── opsx-explore.prompt.md
│       ├── opsx-propose.prompt.md
│       ├── opsx-apply.prompt.md
│       └── opsx-archive.prompt.md
└── openspec/
    ├── specs/
    └── changes/
```

## 目录结构

```
~/.kiro/
├── agents/
│   └── default.json              # agent 配置，加载 superpowers skills
├── superpowers/                   # submodule → github.com/obra/superpowers
│   └── skills/
├── skills -> superpowers/skills   # 软链接
├── update-superpowers.sh          # 更新脚本
└── README.md
```
