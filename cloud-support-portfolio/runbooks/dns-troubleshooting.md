# DNS Troubleshooting Runbook

## Purpose

区分 DNS、网络和应用问题，定位客户端到权威 DNS 的解析链路故障。

## Scope

适用于 Linux 主机的解析失败、错误地址、间歇性超时和容器内 DNS 问题。

## Preconditions

- 准备失败域名、预期记录、发生时间和受影响范围。
- 确认是否允许查询公共或内部 DNS。
- 修改 resolver、NetworkManager 或 netplan 前备份配置。

## Safety Notes

不要直接覆盖 `/etc/resolv.conf`，先确认它是否由 systemd-resolved、NetworkManager 或 DHCP 管理。

## Procedure

### 1. 建立对照

```bash
getent hosts <FQDN>
resolvectl query <FQDN>
dig <FQDN>
```

### 2. 检查 resolver 配置

```bash
ls -l /etc/resolv.conf
cat /etc/resolv.conf
resolvectl status
```

### 3. 查询指定服务器

```bash
dig @<DNS_SERVER> <FQDN> A
dig @<DNS_SERVER> <FQDN> +trace
```

比较本机 resolver、指定 DNS 和另一台正常主机的结果。

### 4. 验证网络路径

```bash
ip route
nc -vz -w3 <DNS_SERVER> 53
sudo tcpdump -ni any port 53
```

同时检查 UDP/TCP 53、防火墙、VPN 和容器网络。

### 5. 缓解

恢复已验证的 resolver 配置，然后按管理方式重新加载：

```bash
sudo systemctl restart systemd-resolved
sudo resolvectl flush-caches
```

## Verification

使用 `getent`、`dig` 和真实应用请求验证记录、TTL、延迟及连续成功率。

## Rollback Plan

恢复 resolver 或网络配置备份，重新应用原配置并刷新缓存。

## Escalation Criteria

- 多区域或多个 DNS 服务器同时失败。
- 权威记录、DNSSEC 或委派链异常。
- 需要修改生产域名记录或防火墙策略。

## Success Criteria

系统与应用解析结果一致，查询延迟恢复，无持续超时或 SERVFAIL。
