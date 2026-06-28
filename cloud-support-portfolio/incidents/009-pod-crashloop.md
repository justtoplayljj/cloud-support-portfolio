# Incident 009 - Kubernetes Pod CrashLoopBackOff

> 模拟场景：命名空间、Pod 和配置名称均为实验示例。

## Overview

- Environment: Kubernetes 1.30
- Severity: Medium
- Impact: 新版本无法提供服务，旧版本仍保持部分容量

## Incident Description

部署后新 Pod 进入 `CrashLoopBackOff`，readiness probe 始终失败。

## Investigation

```bash
kubectl get pods -n shop
kubectl describe pod <POD_NAME> -n shop
kubectl logs <POD_NAME> -n shop --previous
```

应用日志显示配置文件 `/etc/app/config.yaml` 缺少 `database.host`。检查挂载：

```bash
kubectl get pod <POD_NAME> -n shop -o yaml
kubectl get configmap shop-config -n shop -o yaml
kubectl rollout history deployment/shop-api -n shop
```

ConfigMap 中键名为 `config.yml`，Deployment 却通过 `subPath` 引用了 `config.yaml`。

## Root Cause

Deployment 与 ConfigMap 的文件键名不一致，容器读取了镜像内的空默认配置并启动失败。

## Resolution

回滚到上一稳定版本恢复容量：

```bash
kubectl rollout undo deployment/shop-api -n shop
```

修正键名后重新发布，并等待 rollout 完成。

## Verification

```bash
kubectl rollout status deployment/shop-api -n shop --timeout=5m
kubectl get pods -n shop
kubectl logs deployment/shop-api -n shop --tail=50
```

所有副本 Ready，重启计数不再增长，服务探测成功。

## Preventive Actions

- CI 中渲染并校验 Manifest。
- 启动前检查必需配置并输出非敏感错误。
- 使用分批发布和自动回滚条件。

## Lessons Learned

排查 CrashLoopBackOff 时，`--previous` 日志和 Pod Event 通常比当前容器日志更有价值。
