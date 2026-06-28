# Incident 004 - DNS Resolution Failure

> 模拟场景：域名、地址和命令输出均为实验示例。

## Overview

- Environment: Ubuntu 22.04
- Severity: High
- Impact: 应用无法访问外部 API，但直接访问 IP 正常

## Incident Description

应用日志出现 `Temporary failure in name resolution`，同网段其他主机正常。

## Investigation

区分网络和 DNS 问题：

```bash
ping -c 3 203.0.113.10
getent hosts api.example.test
resolvectl status
```

IP 连通但名称解析失败。检查 resolver 配置：

```bash
ls -l /etc/resolv.conf
cat /etc/resolv.conf
dig @<DNS_SERVER> api.example.test
```

直接查询正确 DNS 成功，系统配置却指向一个已下线的地址。审查变更记录发现网络模板刚被更新。

## Root Cause

自动化网络模板覆盖了 systemd-resolved 配置，并写入已退役的 DNS 服务器地址。

## Resolution

恢复正确的 DNS 配置后重新加载 resolver：

```bash
sudo netplan apply
sudo systemctl restart systemd-resolved
sudo resolvectl flush-caches
```

## Verification

```bash
resolvectl query api.example.test
getent hosts api.example.test
curl -I https://api.example.test
```

解析和 HTTPS 请求恢复，应用错误率回到基线。

## Preventive Actions

- 在网络模板发布前验证 DNS 地址可达性。
- 监控 DNS 查询成功率和延迟。
- 避免直接覆盖由 systemd-resolved 管理的文件。

## Lessons Learned

“网络不可用”需要分层验证；IP 可达而域名失败时应优先检查 resolver 链路。
