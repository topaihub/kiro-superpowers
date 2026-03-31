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
