# Superpowers Skills 使用教程

> 这份教程帮助你理解如何在日常开发中驱动 Superpowers 的各个 skill，包括每个 skill 的触发方式、完整工作流程、以及它们之间如何串联。

---

## 一、核心概念

Superpowers 是一套 AI 开发工作流 skill 系统。每个 skill 是一个标准化的工作流程，AI 会根据你的意图自动选择并执行。

你不需要记住 skill 名称。你只需要用自然语言描述你要做什么，AI 会：
1. 判断哪个 skill 适用
2. 告诉你："我正在使用 XX skill 来做 YY"
3. 按照 skill 定义的流程执行

你也可以直接指定 skill，比如："用 brainstorming skill 帮我设计登录模块"。

---

## 二、完整开发流程（从想法到上线）

下面是一个典型的端到端开发流程，展示 skill 如何串联：

```
想法 → brainstorming → writing-plans → using-git-worktrees
     → subagent-driven-development（或 executing-plans）
     → requesting-code-review → finishing-a-development-branch
```

### 阶段 1：头脑风暴（brainstorming）

**触发方式：**
- "我想做一个 XX 功能"
- "帮我设计一个 XX"
- "我有个想法，想加一个 XX"
- 任何涉及创建、修改、添加功能的请求

**流程：**
1. AI 先了解你的项目上下文（查看文件、文档、最近提交）
2. 一次问你一个问题，逐步理解需求
3. 提出 2-3 个方案，附带权衡分析和推荐
4. 分段展示设计，每段确认后再继续
5. 写设计文档并保存到 `docs/superpowers/specs/` 目录
6. 自检设计文档（查找 TBD、矛盾、模糊点）
7. 请你审阅设计文档
8. 你确认后，自动进入 writing-plans

**示例对话：**
```
你：我想给我的 CLI 工具加一个插件系统
AI：我正在使用 brainstorming skill 来探索这个想法。
    先让我看看你的项目结构...
    [查看文件]
    你希望插件能做什么？
    a) 添加新命令
    b) 修改现有命令的行为
    c) 两者都要
你：c
AI：插件的分发方式你倾向哪种？
    a) npm 包
    b) 本地目录
    c) 两者都支持
...（逐步深入）
```

### 阶段 2：写计划（writing-plans）

**触发方式：**
- brainstorming 完成后自动触发
- "帮我写个实施计划"
- "把这个需求拆成任务"

**流程：**
1. 基于设计文档，列出所有要创建/修改的文件
2. 把工作拆成极小的步骤（每步 2-5 分钟）
3. 每步包含：完整代码、测试命令、预期输出
4. 保存到 `docs/superpowers/plans/` 目录
5. 自检计划（规格覆盖、占位符扫描、类型一致性）
6. 问你选择执行方式

**任务粒度示例：**
```markdown
### Task 1: 插件加载器

- [ ] Step 1: 写失败的测试
- [ ] Step 2: 运行测试，确认失败
- [ ] Step 3: 写最小实现让测试通过
- [ ] Step 4: 运行测试，确认通过
- [ ] Step 5: 提交
```

### 阶段 3：创建隔离工作区（using-git-worktrees）

**触发方式：**
- 执行计划前自动触发
- "帮我建个隔离的工作分支"
- "创建一个 worktree"

**流程：**
1. 检查是否已有 `.worktrees/` 或 `worktrees/` 目录
2. 确认目录在 `.gitignore` 中
3. 创建 worktree 和新分支
4. 安装依赖
5. 运行测试确认基线通过

### 阶段 4：执行计划

有两种方式，计划完成后 AI 会让你选：

#### 方式 A：Subagent-Driven Development（推荐）

**触发方式：**
- 计划完成后选择 "Subagent-Driven"
- "用 subagent 方式执行"

**流程（每个任务）：**
1. 派出一个全新的 subagent 执行任务
2. Subagent 实现 → 测试 → 提交 → 自检
3. 派出规格审查 subagent（代码是否符合设计？）
4. 派出质量审查 subagent（代码质量如何？）
5. 有问题就修复并重新审查
6. 全部通过后标记完成，进入下一个任务

#### 方式 B：Executing Plans（内联执行）

**触发方式：**
- 计划完成后选择 "Inline Execution"
- "在当前会话执行"

**流程：**
1. 加载计划，逐个任务执行
2. 每步严格按计划走
3. 遇到阻塞就停下来问你

### 阶段 5：代码审查（requesting-code-review）

**触发方式：**
- 任务完成后自动触发（subagent-driven 模式下每个任务后都会审查）
- "帮我审查一下代码"
- "看看有没有问题"

### 阶段 6：完成分支（finishing-a-development-branch）

**触发方式：**
- 所有任务完成后自动触发
- "开发完了，怎么合并"
- "帮我收尾"

**流程：**
1. 验证测试通过
2. 给你 4 个选项：
   - 本地合并到主分支
   - 推送并创建 PR
   - 保持现状（你自己处理）
   - 丢弃这次工作
3. 执行你的选择
4. 清理 worktree（如果需要）

---

## 三、独立使用的 Skill

以下 skill 不一定在完整流程中使用，可以随时独立触发：

### systematic-debugging（系统化调试）

**触发方式：**
- "这个 bug 怎么回事"
- "测试挂了"
- "为什么会出现 XX 错误"
- 任何 bug、测试失败、异常行为

**核心原则：** 找到根因之前不允许尝试修复。

**四个阶段：**
1. 根因调查 → 读错误信息、复现、查最近改动、追踪数据流
2. 模式分析 → 找到类似的正常代码，对比差异
3. 假设与测试 → 形成假设，做最小改动验证
4. 实施修复 → 先写失败测试，再修复，验证

**重要规则：** 如果连续 3 次修复都失败，停下来质疑架构，不要继续打补丁。

### test-driven-development（测试驱动开发）

**触发方式：**
- "帮我实现 XX 功能"（会自动采用 TDD）
- "先写测试再实现"
- 修复 bug 时也会自动使用

**核心循环：** RED → GREEN → REFACTOR
1. RED：写一个会失败的测试
2. 确认测试确实失败（必须看到失败）
3. GREEN：写最少的代码让测试通过
4. 确认测试通过
5. REFACTOR：清理代码，保持测试通过
6. 重复

### verification-before-completion（完成前验证）

**触发方式：**
- 自动触发 — 在声称任何工作完成之前
- "做完了吗？"

**核心原则：** 没有运行验证命令就不能声称完成。

**规则：**
- 必须运行实际的测试/构建命令
- 必须看到实际输出
- 不能说"应该没问题"、"看起来对了"
- 证据在前，结论在后

### receiving-code-review（接收代码审查）

**触发方式：**
- "有人给了我 review 意见"
- "这是审查反馈，帮我处理"

**流程：**
1. 完整阅读反馈
2. 用自己的话复述需求
3. 对照代码库验证
4. 评估技术合理性
5. 如果反馈有误，用技术理由反驳
6. 逐项实施，每项单独测试

### dispatching-parallel-agents（并行派发）

**触发方式：**
- "这几个任务可以同时做"
- 当有 2+ 个独立问题需要解决时
- "3 个测试文件都挂了，互不相关"

**适用条件：**
- 任务之间没有依赖
- 不会编辑同一个文件
- 每个问题可以独立理解

### writing-skills（编写 Skill）

**触发方式：**
- "帮我创建一个新 skill"
- "编辑 XX skill"

---

## 四、触发对照速查表

| 你说的话 | 触发的 Skill |
|---|---|
| "我想做/加/建一个 XX" | brainstorming |
| "帮我设计 XX" | brainstorming |
| "帮我写个计划" | writing-plans |
| "把需求拆成任务" | writing-plans |
| "开始执行计划" | subagent-driven-development 或 executing-plans |
| "这个 bug 怎么回事" | systematic-debugging |
| "测试挂了 / 报错了" | systematic-debugging |
| "帮我实现 XX"（新功能） | brainstorming → writing-plans → 执行 |
| "修复这个 bug" | systematic-debugging（+ TDD） |
| "帮我审查代码" | requesting-code-review |
| "有人给了 review 意见" | receiving-code-review |
| "做完了，帮我合并" | finishing-a-development-branch |
| "建个隔离分支" | using-git-worktrees |
| "这几个任务同时做" | dispatching-parallel-agents |
| "做完了吗？" | verification-before-completion |
| "帮我创建一个 skill" | writing-skills |

---

## 五、常见问题

**Q: 我怎么知道 AI 用了哪个 skill？**
A: AI 会在开始时主动告诉你，比如："我正在使用 brainstorming skill 来探索这个想法。"

**Q: 我可以跳过某个 skill 吗？**
A: 可以。直接告诉 AI 你想跳过，比如："不用 brainstorming 了，直接写计划。"

**Q: 我可以指定用某个 skill 吗？**
A: 可以。直接说："用 systematic-debugging skill 帮我排查这个问题。"

**Q: Skill 之间会自动串联吗？**
A: 会。brainstorming → writing-plans → 执行 → code-review → finishing 是自动串联的。每个 skill 完成后会自动进入下一个。

**Q: 如果 AI 选错了 skill 怎么办？**
A: 直接告诉它。比如："这不需要 brainstorming，直接帮我修 bug。"

**Q: 我只想问个简单问题，会触发 skill 吗？**
A: 不会。简单的问答、查询、解释不会触发任何 skill。只有涉及实际开发工作时才会。
