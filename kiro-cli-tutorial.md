# Kiro CLI 使用教程

## 1. 启动与基本用法

```bash
# 启动交互式会话
kiro-cli chat

# 带初始问题启动
kiro-cli chat "帮我分析这个项目的结构"

# 指定 agent 启动
kiro-cli chat --agent superpowers

# 跳过所有工具确认（省去反复按确认）
kiro-cli chat --trust-all-tools

# 只信任特定工具
kiro-cli chat --trust-tools=fs_read,grep,glob
```

## 2. 常用斜杠命令速查

| 命令 | 作用 |
|------|------|
| `/help` | 切换到帮助 Agent，问任何 Kiro 相关问题 |
| `/agent` | 切换 Agent |
| `/plan` | 切换到规划 Agent（只读，专注需求分析） |
| `/model` | 切换模型 |
| `/tools` | 查看可用工具和权限 |
| `/context` | 管理上下文文件，查看上下文窗口使用率 |
| `/compact` | 压缩对话历史，释放上下文空间 |
| `/chat save <path>` | 保存对话到文件 |
| `/chat load <path>` | 加载之前保存的对话 |
| `/mcp` | 查看已加载的 MCP 服务器 |
| `/hooks` | 查看已配置的 hooks |
| `/prompts` | 管理 prompt 模板 |
| `/todos` | 查看和管理待办列表 |
| `/editor` | 打开编辑器写长 prompt |
| `/clear` | 清空对话历史 |
| `/quit` | 退出 |

## 3. Agent 系统

Agent 是 Kiro CLI 的核心概念，定义了 AI 的行为、可用工具和上下文。

### 切换 Agent

```
/agent                    # 显示可用 agent 列表并选择
/agent superpowers        # 直接切换到指定 agent
```

### 创建自定义 Agent

三种方式：

```bash
# 方式一：AI 辅助生成
/agent generate

# 方式二：CLI 命令
kiro-cli agent create --name my-agent

# 方式三：手动创建 JSON 文件
```

Agent 配置文件位置：
- 项目级：`.kiro/agents/<name>.json`
- 全局：`~/.kiro/agents/<name>.json`

### Agent 配置示例

```json
{
  "name": "my-dev",
  "description": "我的开发 Agent",
  "prompt": "你是一个专注于代码质量的开发助手。",
  "tools": ["fs_read", "fs_write", "execute_bash", "code"],
  "allowedTools": ["fs_read", "grep", "glob"],
  "resources": [
    "file://README.md",
    "skill://.kiro/skills/**/SKILL.md"
  ],
  "keyboardShortcut": "ctrl+shift+d",
  "welcomeMessage": "准备好开始开发了！"
}
```

### 关键字段说明

- `tools` — 可用工具列表
- `allowedTools` — 自动批准的工具（不需要确认），支持通配符如 `fs_*`、`@builtin`
- `resources` — 上下文资源，`file://` 始终加载，`skill://` 按需加载
- `mcpServers` — 配置 MCP 服务器
- `hooks` — 在特定时机执行命令
- `keyboardShortcut` — 快捷键切换，如 `ctrl+shift+a`

## 4. Skills 系统

Skills 是按需加载的知识文件，通过 YAML frontmatter 描述触发条件。

### Skill 文件格式

```markdown
---
name: my-skill
description: 在需要做 X 的时候使用这个 skill
---

# Skill 内容

具体的指导和流程...
```

### 加载 Skills

在 agent 配置的 `resources` 中引用：

```json
{
  "resources": [
    "skill://.kiro/skills/**/SKILL.md"
  ]
}
```

启动时只加载元数据（name + description），内容在需要时才按需加载。

## 5. Plan Agent（规划模式）

专门用于需求分析和任务拆解，不会修改任何文件。

```
/plan                              # 切换到规划模式
/plan 做一个用户认证系统            # 带问题直接进入
Shift + Tab                        # 快捷键切换规划/执行模式
```

工作流程：提问收集需求 → 分析代码库 → 生成实施计划 → 确认后交接给执行 Agent。

## 6. Prompts（提示模板）

可复用的 prompt 模板，存放在 `.kiro/prompts/` 或 `~/.kiro/prompts/`。

```
/prompts list                      # 列出所有可用 prompt
/prompts create --name code-review # 创建新 prompt
/prompts get code-review           # 使用 prompt
/prompts edit code-review          # 编辑 prompt
@code-review                       # 快捷方式，输入 @ 后按 Tab 自动补全
```

## 7. MCP 服务器

在 agent 配置中添加 MCP 服务器来扩展工具能力：

```json
{
  "mcpServers": {
    "git": {
      "command": "mcp-server-git",
      "args": ["--stdio"]
    },
    "github": {
      "command": "mcp-server-github",
      "args": ["--stdio"],
      "env": { "GITHUB_TOKEN": "$GITHUB_TOKEN" }
    }
  }
}
```

```
/mcp                               # 查看已加载的 MCP 服务器
/tools                             # 查看所有可用工具（含 MCP 工具）
```

## 8. Hooks（钩子）

在 agent 生命周期的特定时机自动执行命令：

```json
{
  "hooks": {
    "agentSpawn": [
      { "command": "git status", "description": "显示仓库状态" }
    ],
    "preToolUse": [
      { "matcher": "fs_write", "command": "echo '即将写入文件'", "description": "写入前提醒" }
    ],
    "stop": [
      { "command": "date", "description": "记录完成时间" }
    ]
  }
}
```

触发时机：
- `agentSpawn` — Agent 初始化时
- `userPromptSubmit` — 用户发送消息时
- `preToolUse` — 工具执行前（exit 2 可阻止执行）
- `postToolUse` — 工具执行后
- `stop` — AI 回复完成后

## 9. 对话管理

```bash
# 保存对话
/chat save my-session.json

# 加载对话
/chat load my-session.json

# 恢复上次对话
kiro-cli chat --resume

# 选择历史对话恢复
kiro-cli chat --resume-picker

# 列出保存的对话
kiro-cli chat --list-sessions

# 删除对话
kiro-cli chat --delete-session <session-id>
```

## 10. Code Intelligence（代码智能）

基于 LSP 的语义代码理解，支持 TypeScript、Rust、Python、Go、Java、Ruby、C/C++。

```
/code init                         # 在项目根目录初始化
```

初始化后 AI 可以：搜索符号定义、查找引用、跳转到定义、获取编译诊断、安全重命名。

删除 `.kiro/settings/lsp.json` 可禁用。

## 11. 常用键盘快捷键

| 快捷键 | 作用 |
|--------|------|
| `Shift + Tab` | 切换规划/执行模式 |
| `Ctrl + R` | 搜索命令历史 |
| `Ctrl + C` | 取消当前操作 |
| `Ctrl + T` | 切换 Tangent 模式（需启用） |
| `↑ / ↓` | 浏览命令历史 |

## 12. 实用设置

通过终端命令管理（不是斜杠命令）：

```bash
# 查看当前模型
/model

# 启用思考模式（复杂推理）
kiro-cli settings set chat.enableThinking true

# 启用代码智能
kiro-cli settings set chat.enableCodeIntelligence true

# 禁用自动压缩
kiro-cli settings set chat.disableAutoCompaction true

# 显示上下文使用率
kiro-cli settings set chat.enableContextUsageIndicator true

# 启用桌面通知
kiro-cli settings set chat.enableNotifications true
```

## 13. Headless 模式（自动化）

用于脚本和 CI/CD：

```bash
# 非交互式执行
kiro-cli chat --no-interactive --trust-all-tools "运行测试并分析结果"

# 要求 MCP 服务器必须启动成功
kiro-cli chat --require-mcp-startup --no-interactive "执行分析"
```
