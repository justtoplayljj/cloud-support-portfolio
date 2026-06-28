# Network Troubleshooting Runbook

## Purpose

按链路层、网络层、传输层和应用层定位 Linux 网络连接问题。

## Scope

适用于单主机连接失败、超时、端口拒绝和路由异常，不包含未经授权的网络设备变更。

## Preconditions

- 准备源、目标、端口、协议、时间和预期路径。
- 确认问题范围以及近期网络、防火墙或应用变更。
- 抓包前确认权限和数据处理要求。

## Safety Notes

不要直接关闭主机防火墙作为测试。使用精确规则检查和最小范围变更。

## Procedure

### 1. 检查本机接口和路由

```bash
ip -br address
ip route
ip route get <DESTINATION_IP>
```

### 2. 验证邻居和基础连通

```bash
ip neigh
ping -c 3 <GATEWAY_IP>
ping -c 3 <DESTINATION_IP>
```

注意 ICMP 被禁不能单独证明目标不可达。

### 3. 验证端口和监听

```bash
ss -lntup
nc -vz -w3 <DESTINATION_IP> <PORT>
curl -v --connect-timeout 5 http://<HOST>:<PORT>/health
```

连接拒绝通常表示路径可达但端口未监听；超时更可能涉及路由或过滤。

### 4. 检查防火墙和路径

```bash
sudo nft list ruleset
traceroute <DESTINATION_IP>
```

### 5. 必要时抓包

```bash
sudo tcpdump -ni any host <DESTINATION_IP> and port <PORT>
```

确认 SYN 是否发出、是否收到响应，以及重传发生位置。

## Verification

重复端口测试和真实应用请求，检查延迟、丢包和服务日志。

## Rollback Plan

网络配置变更前保存配置；异常时通过控制台恢复原地址、路由或防火墙规则。

## Escalation Criteria

- 网关不可达或多个主机/网段受影响。
- 出现重复 IP、MTU、VLAN、BGP 或云安全组问题。
- 只能通过带外控制台访问主机。

## Success Criteria

目标路径、端口和应用请求均恢复，且变更记录和证据完整。
