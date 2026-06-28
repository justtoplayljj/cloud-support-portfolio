# SSL/TLS Troubleshooting Runbook

## Purpose

定位证书过期、主机名不匹配、证书链不完整和 TLS 握手失败问题。

## Scope

适用于 Nginx、负载均衡器及客户端访问 HTTPS 服务的常见故障。

## Preconditions

- 准备域名、端口、预期证书和失败客户端信息。
- 确认 TLS 在哪一层终止。
- 替换证书或 reload 服务前完成备份并获得授权。

## Safety Notes

私钥不得写入工单、日志或仓库。不要使用 `-k` 作为生产修复方案。

## Procedure

### 1. 检查线上证书

```bash
openssl s_client -connect <FQDN>:443 -servername <FQDN> -showcerts </dev/null
```

提取关键信息：

```bash
openssl s_client -connect <FQDN>:443 -servername <FQDN> </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates -ext subjectAltName
```

### 2. 验证客户端结果

```bash
curl -Iv https://<FQDN>
date -u
```

确认客户端时间、SNI、代理和 CA trust store。

### 3. 检查本地文件和链

```bash
openssl x509 -in <CERT_FILE> -noout -dates -subject -issuer
openssl verify -CAfile <CA_BUNDLE> <CERT_FILE>
```

对比线上证书指纹和期望文件，检查 intermediate certificate 是否完整。

### 4. 检查服务配置

```bash
sudo nginx -T | grep -n 'ssl_certificate'
sudo nginx -t
```

### 5. 恢复

安装完整证书链，保持私钥权限最小化，配置测试成功后 reload：

```bash
sudo systemctl reload nginx
```

## Verification

从外部和内部客户端重新执行 `openssl s_client` 与 `curl -Iv`，确认有效期、SAN、链和协议均正确。

## Rollback Plan

保留上一版本证书和配置；reload 失败时恢复备份，执行配置测试后再次 reload。

## Escalation Criteria

- 私钥可能泄露或证书被错误签发。
- 涉及 CDN、云负载均衡或多个证书终止层。
- 客户端兼容性要求需要降低 TLS 安全级别。

## Success Criteria

受支持客户端握手成功，无证书告警，监控确认到期时间和链状态正常。
