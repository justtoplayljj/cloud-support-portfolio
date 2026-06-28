# TASKS.md

本文件记录 Cloud Support Portfolio 的项目任务。任务完成后，将复选框从 `[ ]` 改为 `[x]`，并在必要时补充验证结果。

## P0 - 修复阻塞问题

- [x] 修复 `automation/backup.sh` 第 53 行附近的语法错误。
  - 完成标准：`bash -n automation/backup.sh` 返回成功。
- [x] 补全原为空的自动化脚本：
  - `automation/docker-cleanup.sh`
  - `automation/rotate-log.sh`
  - `automation/system-report.sh`
  - 完成标准：脚本符合 `AGENTS.md` 中的 Shell 规范，`bash -n automation/*.sh` 全部通过。
- [x] 修正 `README.md` 中与实际仓库不一致的文件名和路径。
  - 检查 `automation/health-check.sh` 与实际的 `automation/healthcheck.sh`。
  - 检查 Incident 编号、标题和文件路径。
  - 删除不存在内容的链接，或先完成对应文件再加入索引。
  - 完成标准：README 中所有本地文件引用均存在并可打开。

## P1 - 补全核心故障案例

以下文件已补全，后续仍可继续统一语言和细化技术证据：

- [x] `incidents/001-high-cpu.md`
- [x] `incidents/004-dns-failure.md`
- [x] `incidents/005-cert-expired.md`
- [x] `incidents/006-container-crash.md`
- [x] `incidents/007-memory-leak.md`
- [x] `incidents/008-node-down.md`
- [x] `incidents/009-pod-crashloop.md`
- [x] `incidents/010-ingress-failure.md`
- [x] 修正 `incidents/003-nginx-502.md` 内部标题编号，目前标题写作 `Incident 001`。
- [ ] 统一全部 Incident 文档的章节结构、编号格式和语言风格。
  - 完成标准：每篇案例都有可复现的诊断命令、明确根因、恢复验证和预防措施。

## P1 - 补全 Runbook

以下文件已补全，后续仍可继续统一术语和操作深度：

- [x] `runbooks/cpu-troubleshooting.md`
- [x] `runbooks/disk-troubleshooting.md`
- [x] `runbooks/dns-troubleshooting.md`
- [x] `runbooks/k8s-pod-troubleshooting.md`
- [x] `runbooks/network-troubleshooting.md`
- [x] `runbooks/ssl-troubleshooting.md`
- [ ] 统一现有 Runbook 的结构和术语。
  - 完成标准：操作步骤可直接执行，高风险操作有前置检查、验证方式和回滚方案。

## P2 - 完善自动化与质量检查

- [ ] 为 `automation/healthcheck.sh` 增加参数校验、错误处理和清晰的退出码。
- [ ] 为 `automation/backup.sh` 增加备份验证、保留策略和失败清理逻辑。
- [ ] 为自动化脚本提供安全的 dry-run 模式，适用于删除、清理或覆盖操作。
- [ ] 安装或配置 ShellCheck，并修复 `automation/*.sh` 的告警。
- [ ] 为脚本增加最小测试用例，覆盖成功、参数错误和依赖缺失场景。
- [ ] 增加统一验证脚本，例如 `scripts/validate.sh`。
  - 完成标准：该脚本可一次性检查 Bash 语法、ShellCheck 和 Markdown 本地链接。

## P2 - 完善作品集内容

- [ ] 为 `monitoring/` 添加 Prometheus 监控概览。
- [ ] 为 `monitoring/` 添加 Grafana Dashboard 说明和截图。
- [ ] 为 `kubernetes/` 添加部署清单或操作示例。
- [ ] 为 `postmortems/` 添加至少一篇完整复盘报告。
- [ ] 为 `tickets/` 添加脱敏后的技术支持工单案例。
- [ ] 明确 `cloud/` 目录用途，并补充内容或删除空目录。
- [ ] 更新架构文档，确保 `architecture/web-platform.drawio` 与导出的 PNG 一致。
- [ ] 在 README 中增加每类内容的可点击索引和简短成果说明。

## P3 - 持续集成与发布检查

- [ ] 添加 CI 工作流，自动执行 Bash 语法检查和 ShellCheck。
- [ ] 添加 Markdown 链接检查。
- [ ] 添加敏感信息扫描，防止提交令牌、私钥或真实凭据。
- [ ] 定义发布前检查清单。
  - 完成标准：新提交可自动发现语法错误、失效链接和敏感信息。

## 每次修改后的检查

```bash
bash -n automation/*.sh
shellcheck automation/*.sh
rg -n 'architecture/|automation/|docs/|incidents/|runbooks/' README.md docs incidents runbooks
```

如果本地未安装某项工具，应在任务记录或交付说明中注明未执行的检查及原因。
