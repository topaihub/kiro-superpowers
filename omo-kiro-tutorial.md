# 在 Kiro CLI 中使用 OMO 多智能体协作：完整教程

> 基于 Kiro CLI 的 `use_subagent` 机制，移植 OMO 的核心专家角色，实现多智能体并行协作。

## 一、安装

### 1.1 前置条件

确认 Kiro CLI 已安装：

```bash
kiro-cli --version
```

### 1.2 全新安装（还没有 ~/.kiro 配置仓库）

```bash
# 克隆配置仓库（包含 Superpowers + OMO）
git clone --recursive https://github.com/topaihub/kiro-superpowers.git ~/.kiro
```

完成后你就同时拥有了 Superpowers 技能框架和 OMO 多智能体协作能力。

### 1.3 已有配置仓库（更新到最新）

```bash
cd ~/.kiro
git pull
git submodule update --init
```

### 1.4 验证安装

```bash
# 检查三个专家 agent 存在
ls ~/.kiro/agents/oracle.json ~/.kiro/agents/explore.json ~/.kiro/agents/librarian.json

# 检查编排技能存在
ls ~/.kiro/omo-skills/omo-orchestrate/SKILL.md ~/.kiro/omo-skills/omo-init-deep/SKILL.md

# 检查 default.json 包含 omo-skills 资源
grep "omo-skills" ~/.kiro/agents/default.json
```

三项都通过就安装成功了。**重启 Kiro CLI**（或开始新会话）即可使用。

### 1.5 启用 subagent 功能

如果是首次使用 subagent，需要确认该功能已启用：

```bash
kiro-cli settings chat.enableSubagent true
```

### 1.6 不需要安装的东西

与原版 OMO 不同，Kiro 版**不需要**：
- ❌ 不需要安装 `oh-my-opencode` / `oh-my-openagent` 包
- ❌ 不需要安装 bun 或额外的 npm 包
- ❌ 不需要配置 OpenCode
- ❌ 不需要 API key（使用 Kiro CLI 自身的模型）

所有配置都是纯 JSON + Markdown 文件，随 `~/.kiro/` 仓库同步。

---

## 二、三个专家 Agent 介绍

### Oracle（架构顾问）

- **角色**：高级架构师，只分析不写代码
- **工具**：`fs_read`、`grep`、`glob`、`code`（全部只读）
- **擅长**：架构评审、风险评估、技术债分析、方案对比
- **输出格式**：Summary → Findings → Risks → Recommendations

### Explore（代码侦察兵）

- **角色**：快速搜索员，找文件找模式
- **工具**：`fs_read`、`grep`、`glob`、`code`（全部只读）
- **擅长**：搜索文件、匹配模式、映射目录结构、定位实现
- **输出格式**：Files Found → Patterns Detected → Structure Summary

### Librarian（文档研究员）

- **角色**：文档搜索员，查外部资料
- **工具**：`fs_read`、`grep`、`glob`、`web_search`、`web_fetch`（只读 + 网络）
- **擅长**：搜索外部文档、查找库和最佳实践、收集参考资料
- **输出格式**：Sources Found → Key Findings → Relevant Code References

**三个 agent 都是只读的，不会修改你的任何文件，已配置为自动信任（无需手动按 y 确认）。**

---

## 三、使用方式

你不需要记任何命令。用自然语言描述需求，Kiro 会自动判断是否需要调度专家。

### 3.1 单专家模式

直接描述你的需求，Kiro 自动选择合适的专家：

```
你：分析一下这个项目的架构，有什么风险？

Kiro：[自动派 oracle]
      
      ## Architecture Analysis
      
      ### Summary
      This is a FastAPI monolith with 3 main modules...
      
      ### Risks
      1. Database queries not using connection pooling
      2. Auth middleware has no rate limiting
      ...
```

```
你：找一下项目里所有的 API 端点

Kiro：[自动派 explore]
      
      ## Files Found
      - src/routers/users.py: 5 endpoints
      - src/routers/articles.py: 4 endpoints
      ...
```

```
你：查一下 FastAPI 里 WebSocket 的最佳实践

Kiro：[自动派 librarian]
      
      ## Key Findings
      - FastAPI native WebSocket support via @app.websocket()
      - Recommended: use starlette WebSocketEndpoint class for complex cases
      ...
```

### 3.2 并行侦察模式

当你提出一个复杂任务时，Kiro 会先派多个专家并行收集信息，再综合规划：

```
你：给这个项目加上 WebSocket 实时通知功能

Kiro：让我先派专家侦察一下...

      [并行派出 3 个专家]
      1. explore: 扫描当前项目结构和 API 设置
      2. librarian: 研究 WebSocket + 当前框架的集成方案
      3. oracle: 评估当前架构对 WebSocket 的就绪程度

      [等待专家返回]

      ## 综合分析
      
      基于三位专家的调查结果：
      
      **现状**：项目使用 FastAPI + SQLAlchemy，目前没有 WebSocket 支持...
      **推荐方案**：使用 FastAPI 原生 WebSocket + Redis pub/sub...
      **风险点**：当前部署在 serverless 上，需要改为长连接支持...
      
      ## 实施计划
      1. 添加 WebSocket 路由
      2. 实现通知 hub
      ...
```

### 3.3 全面评审模式

在合并代码或做重大决策前，让三个专家全面审查：

```
你：review 一下这个 feature 分支，准备合并了

Kiro：[并行派出 3 个专家]
      1. oracle: 审查架构和风险
      2. explore: 检查变更文件和一致性
      3. librarian: 验证是否符合框架最佳实践

      ## Review Summary
      
      **Status: Changes Requested**
      
      ### Critical
      - [oracle] 新增的数据库查询缺少索引，高并发下会有性能问题
      
      ### Suggestions
      - [explore] tests/test_api.py 缺少对错误路径的测试
      - [librarian] FastAPI 官方推荐用 Depends() 注入数据库会话，当前用的是全局变量
```

### 3.4 项目扫描（init-deep）

首次进入一个项目时，生成分层上下文文件：

```
你：init deep

Kiro：[派 explore 扫描项目结构]
      [根据扫描结果生成 AGENTS.md 文件]

      ## Generated Context Files
      
      project/
      ├── AGENTS.md              ← 项目概览、技术栈、约定
      ├── src/
      │   ├── AGENTS.md          ← src 目录职责、关键模块
      │   └── routers/
      │       └── AGENTS.md      ← 路由层约定、端点列表
      └── tests/
          └── AGENTS.md          ← 测试约定、fixture 说明
      
      Generated 4 AGENTS.md files.
```

生成后，后续专家 agent 工作时会自动读取对应目录的 `AGENTS.md` 获取上下文。

---

## 四、进阶用法

### 4.1 手动指定专家

如果你想明确指定用哪个专家：

```
你：用 oracle 分析一下 auth 模块的安全性
你：让 explore 找一下所有用了 deprecated API 的地方
你：让 librarian 查一下 argon2 和 bcrypt 的对比
```

### 4.2 与 Superpowers 协同

OMO 专家负责**信息收集**，Superpowers 负责**工程纪律**：

```
你：实现用户通知功能

流程：
1. [OMO] explore + librarian 并行侦察 → 收集信息
2. [Superpowers] brainstorming → 基于侦察结果细化设计
3. [Superpowers] writing-plans → 拆解为小任务
4. [Superpowers] TDD → 先写测试再写代码
5. [OMO] oracle 审查 → 架构评审
6. [Superpowers] code-review → 代码质量审查
```

### 4.3 与 OpenSpec 协同

```
你：propose a change for add-websocket-support

流程：
1. [OpenSpec] propose → 生成 proposal/specs/design/tasks
2. [OMO] explore + librarian → 补充技术调研
3. [OpenSpec] apply → 按 tasks 实施
4. [OMO] oracle → 实施后架构审查
5. [OpenSpec] archive → 归档规范
```

---

## 五、配置说明

### 5.1 文件位置

所有配置在 `~/.kiro/`（全局级），所有项目共享：

```
~/.kiro/
├── agents/
│   ├── default.json       # 主 agent：加载技能 + 信任专家
│   ├── oracle.json        # 架构顾问
│   ├── explore.json       # 代码侦察兵
│   └── librarian.json     # 文档研究员
└── omo-skills/
    ├── omo-orchestrate/
    │   └── SKILL.md       # 编排调度技能
    └── omo-init-deep/
        └── SKILL.md       # 项目扫描技能
```

### 5.2 信任配置

在 `default.json` 中配置：

```json
{
  "toolsSettings": {
    "subagent": {
      "availableAgents": ["oracle", "explore", "librarian"],
      "trustedAgents": ["oracle", "explore", "librarian"]
    }
  }
}
```

- `availableAgents`：允许被调度的 agent 列表
- `trustedAgents`：自动信任的 agent（不需要手动确认）

### 5.3 项目级覆盖

如果某个项目需要不同的配置，在项目目录创建 `.kiro/agents/oracle.json` 等文件，项目级配置优先于全局。

---

## 六、与原版 OMO 的差异

| 能力 | 原版 OMO（OpenCode） | Kiro CLI 版 |
|------|---------------------|-------------|
| 专家角色 | 11 个智能体 | 3 个核心角色（oracle/explore/librarian） |
| 并行执行 | 无限制（受提供商限制） | 最多 4 个并行 subagent |
| 后台执行 | ✅ 支持 | ✅ 支持（delegate 工具） |
| 模型路由 | 每个智能体独立模型 + 回退链 | 每个 agent 可指定模型，无回退链 |
| Hashline 编辑 | ✅ 哈希锚定编辑 | ❌ 使用标准 fs_write |
| `ulw` 关键词 | 硬触发器 | 通过 skill 自动匹配触发 |
| 内置 MCP | Exa/Context7/Grep.app | 可手动配置 MCP |
| `/init-deep` | ✅ 内置 | ✅ 通过 skill 实现 |
| Sisyphus 编排 | ~1100 行专用提示词 | 通过 omo-orchestrate skill 实现 |

**核心能力保留了，主要损失的是 Hashline 和模型回退链。**

---

## 七、常见问题

**Q：专家 agent 会修改我的文件吗？**

不会。三个专家都没有 `fs_write` 和 `execute_bash` 工具，只能读取和搜索。

**Q：为什么只有 3 个专家，不是 OMO 的 11 个？**

OMO 的很多智能体（Sisyphus、Atlas、Prometheus、Metis、Momus）是编排和规划角色，在 Kiro 中由主 agent + Superpowers 技能承担。Hephaestus 依赖特定模型无法移植。保留的 3 个是最实用的信息收集角色。

**Q：可以自己添加更多专家吗？**

可以。在 `~/.kiro/agents/` 下创建新的 JSON 文件，然后在 `default.json` 的 `availableAgents` 中添加即可。

**Q：并行 4 个不够用怎么办？**

分批执行。先派第一批 4 个，等结果回来后再派第二批。omo-orchestrate skill 会自动处理这个。
