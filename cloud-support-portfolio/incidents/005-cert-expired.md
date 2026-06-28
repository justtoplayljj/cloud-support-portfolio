# Incident 005 - TLS Certificate Expired

> 模拟场景：证书、域名和时间均为实验环境示例。

## Overview

- Environment: Nginx on Ubuntu 22.04
- Severity: High
- Impact: 客户端拒绝 HTTPS 连接

## Incident Description

用户访问 `https://portal.example.test` 时收到证书过期错误。

## Investigation

检查线上证书有效期：

```bash
openssl s_client -connect portal.example.test:443 -servername portal.example.test </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates
```

确认 `notAfter` 已过期。继续检查自动续期：

```bash
systemctl status certbot.timer
journalctl -u certbot.service --since '-30 days'
sudo certbot renew --dry-run
```

timer 处于 disabled，最近没有续期执行记录。

## Root Cause

主机维护后 `certbot.timer` 未重新启用，同时缺少证书到期监控，导致证书过期未被提前发现。

## Resolution

在维护窗口内完成续期并验证配置：

```bash
sudo certbot renew
sudo nginx -t
sudo systemctl reload nginx
sudo systemctl enable --now certbot.timer
```

## Verification

重新运行 `openssl` 检查有效期，并从外部客户端执行：

```bash
curl -Iv https://portal.example.test
```

证书链、主机名和有效期验证均成功。

## Preventive Actions

- 对 30、14、7 天到期窗口设置告警。
- 定期执行 `certbot renew --dry-run`。
- 将 timer 状态纳入主机基线检查。

## Lessons Learned

自动续期服务本身也需要监控，不能只依赖一次性部署成功。
