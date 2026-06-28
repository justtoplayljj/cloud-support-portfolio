# Incident 010 - Kubernetes Ingress Failure

> 模拟场景：域名、服务和输出均为实验环境示例。

## Overview

- Environment: Kubernetes with Nginx Ingress Controller
- Severity: High
- Impact: 外部请求返回 502，集群内 Pod 健康

## Incident Description

发布 Service 变更后，`https://shop.example.test` 全部返回 502。

## Investigation

```bash
kubectl get ingress,service,endpoints -n shop
kubectl describe ingress shop -n shop
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller --tail=100
```

Controller 日志显示连接 upstream 失败。绕过 Ingress 验证 Service：

```bash
kubectl port-forward -n shop service/shop-api 18080:80
curl -I http://127.0.0.1:18080/health
```

请求同样失败。对比 Service 和 Pod：

```bash
kubectl get service shop-api -n shop -o yaml
kubectl get pod -n shop -l app=shop-api -o jsonpath='{.items[0].spec.containers[0].ports}'
```

Pod 监听 8080，而 Service `targetPort` 被改成 8081。

## Root Cause

Service 的 `targetPort` 与容器监听端口不一致，Endpoint 存在但流量被发送到错误端口。

## Resolution

恢复 `targetPort: 8080`，审查差异后应用 Manifest：

```bash
kubectl apply -f service.yaml
```

## Verification

```bash
kubectl get endpoints shop-api -n shop
curl -I https://shop.example.test/health
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller --since=5m
```

外部请求返回 200，Controller 不再产生 upstream 错误。

## Preventive Actions

- CI 校验 Service `targetPort` 与容器端口。
- 发布后执行集群内、Service 和 Ingress 三层探测。
- 对 5xx 比率和无可用 upstream 设置告警。

## Lessons Learned

Ingress 故障应沿 DNS/TLS、Ingress、Service、Endpoint、Pod 分层定位，避免直接重启 Controller。
