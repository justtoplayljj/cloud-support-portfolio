# Kubernetes Pod Troubleshooting Runbook

## Purpose

使用一致的顺序排查 Pending、CrashLoopBackOff、ImagePullBackOff、NotReady 和运行中异常的 Pod。

## Scope

适用于具备 `kubectl` 访问权限的 Kubernetes 集群，不包含控制平面修复。

## Preconditions

- 确认集群、namespace、workload 和变更时间。
- 使用最小权限账号，避免直接编辑生产对象。
- 删除 Pod、回滚或修改资源前获得授权。

## Safety Notes

不要把反复删除 Pod 当作修复。先保存 Event、日志、配置和资源状态证据。

## Procedure

### 1. 获取状态和事件

```bash
kubectl get pod <POD> -n <NAMESPACE> -o wide
kubectl describe pod <POD> -n <NAMESPACE>
kubectl get events -n <NAMESPACE> --sort-by=.lastTimestamp | tail -30
```

### 2. 检查日志

```bash
kubectl logs <POD> -n <NAMESPACE> --all-containers --tail=200
kubectl logs <POD> -n <NAMESPACE> --previous --tail=200
```

### 3. 按状态分支

- Pending：检查资源、调度约束、PVC 和 node taint。
- ImagePullBackOff：检查镜像名称、registry、Secret 和节点网络。
- CrashLoopBackOff：检查退出码、previous 日志、command、配置和探针。
- NotReady：检查 readiness probe、依赖服务和监听端口。

```bash
kubectl get pod <POD> -n <NAMESPACE> -o jsonpath='{.status.containerStatuses}'
kubectl top pod <POD> -n <NAMESPACE>
```

### 4. 对比声明和历史

```bash
kubectl get deployment <DEPLOYMENT> -n <NAMESPACE> -o yaml
kubectl rollout history deployment/<DEPLOYMENT> -n <NAMESPACE>
kubectl diff -f <MANIFEST>
```

### 5. 缓解

优先回滚已确认的错误版本：

```bash
kubectl rollout undo deployment/<DEPLOYMENT> -n <NAMESPACE>
```

## Verification

```bash
kubectl rollout status deployment/<DEPLOYMENT> -n <NAMESPACE> --timeout=5m
kubectl get pods -n <NAMESPACE>
```

确认副本 Ready、重启次数稳定并通过服务端到端探测。

## Rollback Plan

保留修改前 Manifest 和 revision；修复失败时回滚到明确的稳定 revision。

## Escalation Criteria

- 多 namespace 或系统 Pod 同时异常。
- 节点、CNI、CSI 或 API Server 错误。
- 涉及数据恢复、安全策略或集群级配置。

## Success Criteria

目标副本全部 Ready，错误率恢复，事件中无持续失败，并记录根因。
