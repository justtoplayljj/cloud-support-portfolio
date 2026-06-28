# PROMPTS.md

本文件收集用于维护 Cloud Support Portfolio 的可复用提示词。使用前请将 `<占位符>` 替换为实际内容，并要求生成结果遵循 `AGENTS.md`、`TASKS.md` 和 `ROADMAP.md`。

## 通用工作提示词

```text
请在当前 Cloud Support Portfolio 仓库中完成以下任务：

任务：<任务描述>

要求：
1. 开始前阅读 AGENTS.md，并检查相关现有文件。
2. 只修改完成任务所需的文件，保留其他已有修改。
3. 不使用真实凭据、私钥、内部地址或个人敏感信息。
4. 所有模拟场景和模拟数据必须明确标注。
5. 完成后执行与变更范围匹配的验证。
6. 更新 TASKS.md 中对应任务的状态；如里程碑发生变化，再更新 ROADMAP.md。
7. 最终说明修改文件、验证结果和仍存在的限制。
```

## 创建 Incident 案例

```text
请创建 Incident 文档：<文件路径>。

场景：<故障场景>
影响：<用户或业务影响>
技术环境：<Linux/Nginx/MySQL/Docker/Kubernetes 等>

文档必须包含：
- Overview
- Incident Description
- Symptoms / Impact
- Investigation
- Root Cause
- Resolution
- Verification
- Preventive Actions
- Lessons Learned

要求：
1. 排查过程按时间或决策顺序展开，说明每条命令的目的和判断依据。
2. 包含关键命令、示例输出和对输出的解释。
3. 不直接跳到根因，要展示如何排除其他可能性。
4. 恢复步骤必须包含成功判定和失败时的回滚方式。
5. 数据为模拟数据时明确标注，不虚构为真实生产事故。
6. 标题编号必须与文件名一致。
7. 完成后检查 README.md 是否需要新增或修正索引。
```

## 创建 Runbook

```text
请创建 Runbook：<文件路径>。

主题：<操作或故障排查主题>
适用系统：<系统或服务>
目标读者：Cloud Support Engineer / Linux System Engineer

文档必须包含：
- Purpose
- Scope
- Preconditions
- Safety Notes
- Procedure
- Verification
- Rollback Plan
- Escalation Criteria
- Success Criteria

要求：
1. 步骤必须可直接执行，并解释关键命令的用途。
2. 在修改配置、重启服务、删除文件前加入前置检查。
3. 使用通用占位符，不硬编码环境专属地址或凭据。
4. 每个关键步骤都提供预期结果和异常分支。
5. 明确什么情况下应停止操作并升级处理。
6. 完成后检查 README.md 是否需要新增或修正索引。
```

## 创建 Shell 自动化脚本

```text
请实现 Shell 脚本：<文件路径>。

用途：<脚本用途>
输入：<参数或环境变量>
输出：<标准输出、日志或生成文件>
运行环境：<Linux 发行版及依赖>

要求：
1. 使用 Bash，并以 #!/usr/bin/env bash 开头。
2. 默认启用 set -euo pipefail。
3. 提供 --help，校验参数和依赖命令。
4. 正常信息写入 stdout，错误信息写入 stderr。
5. 失败时返回非零退出码。
6. 对删除、覆盖、清理或服务变更提供 --dry-run 或明确确认机制。
7. 正确引用变量，避免依赖隐式工作目录。
8. 脚本可重复执行，不硬编码凭据。
9. 执行 bash -n 和 ShellCheck；如 ShellCheck 不可用，应明确说明。
10. 给出安全的使用示例和验证方法。
```

## 审查 Shell 脚本

```text
请审查 <脚本路径或 automation/*.sh>，重点检查：

- Bash 语法和可移植性
- 未引用变量、空变量和单词分割风险
- 错误处理、退出码和管道失败
- 临时文件、并发执行和重复执行安全性
- 删除、覆盖、权限修改和服务操作风险
- 凭据泄露及日志敏感信息
- 参数校验、依赖检查和帮助信息
- ShellCheck 告警

先按严重程度列出问题，包含文件和行号；不要先修改。随后给出最小修复方案和验证命令。只有在明确要求实施修复时才修改文件。
```

## 审查 Incident 或 Runbook

```text
请审查 <文档路径>，判断它是否适合作为 Cloud Support Portfolio 展示材料。

检查内容：
- 结构是否符合 AGENTS.md
- 技术步骤是否正确且顺序合理
- 命令是否有目的、预期结果和判断依据
- 根因是否由证据支持
- 恢复验证和回滚方案是否充分
- 是否缺少升级条件或预防措施
- 是否存在虚构、含糊或无法验证的陈述
- 是否包含敏感信息
- 标题、编号、术语和 README 索引是否一致

先按严重程度列出问题并引用文件行号，再提出具体修改建议。除非明确要求，否则不要改写整篇文档。
```

## 修复 README 索引

```text
请核对并修复 README.md 的仓库索引。

要求：
1. 枚举仓库中 architecture、automation、docs、incidents、monitoring 和 runbooks 的实际文件。
2. 找出 README 中不存在的路径、错误编号、错误文件名和遗漏内容。
3. 将纯文本路径改为可点击的相对 Markdown 链接。
4. 不为尚未完成的空文件编写虚假介绍；可以标记为 Planned。
5. 保留 README 的项目定位，但删除与实际仓库不一致的陈述。
6. 修改后再次验证所有本地链接。
```

## 创建 Postmortem

```text
请基于 <Incident 文件或故障摘要> 创建 Postmortem：<文件路径>。

必须包含：
- Executive Summary
- Impact
- Timeline
- Detection
- Root Cause
- Contributing Factors
- Resolution and Recovery
- What Went Well
- What Went Poorly
- Corrective Actions
- Owners and Target Dates

要求：
1. 使用无责复盘语言，关注系统和流程改进。
2. 时间线区分事实、推断和未知信息。
3. 行动项必须具体、可验证，并标明优先级。
4. 不虚构负责人姓名；使用角色或占位符。
5. 与源 Incident 的事实、编号和根因保持一致。
```

## 创建技术支持工单案例

```text
请创建脱敏的技术支持工单案例：<文件路径>。

问题：<客户问题>
环境：<系统、服务和版本>

必须包含：
- Customer Report
- Scope and Impact
- Clarifying Questions
- Evidence Collected
- Troubleshooting
- Root Cause or Final Diagnosis
- Resolution / Workaround
- Customer Communication
- Closure Criteria
- Follow-up Actions

要求：
1. 展示如何澄清问题和缩小范围，而不是只给技术答案。
2. 所有客户、域名、IP、账号和日志内容必须脱敏。
3. 区分临时缓解、长期修复和无法确认的假设。
4. 包含一段清晰、专业、可直接发送给客户的结案回复。
```

## 执行仓库质量检查

```text
请对当前仓库执行只读质量检查，不要修改文件。

检查项目：
1. 查找空文件和空目录。
2. 执行 bash -n automation/*.sh。
3. 如可用，执行 shellcheck automation/*.sh。
4. 检查 README.md 中的本地路径是否存在。
5. 检查 Incident 文件名、标题和编号是否一致。
6. 检查文档是否缺少验证、回滚或预防措施。
7. 检查可能的凭据、私钥和敏感信息。
8. 对照 TASKS.md 和 ROADMAP.md 判断当前进度。

结果按 P0、P1、P2、P3 分类。每个问题给出证据、影响和建议的下一步，不要把未执行的检查描述为通过。
```

## 规划下一项工作

```text
请阅读 AGENTS.md、TASKS.md、ROADMAP.md 和当前仓库状态，选择下一项最有价值且范围可控的任务。

输出：
1. 建议执行的任务。
2. 选择该任务的依据。
3. 将修改的文件。
4. 验证方法。
5. 风险和明确不在本次范围内的事项。

优先处理会阻塞后续工作的 P0 问题。除非明确要求，否则只制定计划，不修改文件。
```
