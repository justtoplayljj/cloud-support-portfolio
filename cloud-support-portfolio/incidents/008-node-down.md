# Incident 008 - Kubernetes Node NotReady

> 模拟场景：节点名、地址和输出均为实验环境示例。

## Overview

- Environment: Kubernetes worker node
- Severity: High
- Impact: 节点上的工作负载被重新调度，集群容量下降

## Incident Description

监控报告 `worker-02` 进入 `NotReady`，节点心跳超时。

## Investigation

```bash
kubectl get nodes -o wide
kubectl describe node worker-02
kubectl get events --all-namespaces --sort-by=.lastTimestamp | tail -30
```

Condition 显示 `KubeletNotReady`。通过带外管理登录节点后检查：

```bash
systemctl status kubelet containerd
journalctl -u kubelet --since '-30 minutes'
ip route
ping -c 3 <CONTROL_PLANE_IP>
```

kubelet 和 containerd 正常，但到控制平面的路由缺失。审查网络变更发现错误的静态路由配置刚被应用。

## Root Cause

网络配置模板删除了 Kubernetes 控制平面网段的静态路由，节点无法发送心跳。

## Resolution

先 cordon 节点，恢复已验证的网络配置和路由，再重启 kubelet：

```bash
kubectl cordon worker-02
sudo netplan apply
sudo systemctl restart kubelet
```

## Verification

```bash
kubectl get node worker-02
kubectl describe node worker-02
kubectl uncordon worker-02
```

节点稳定保持 `Ready`，系统 Pod 正常，业务副本重新均衡。

## Preventive Actions

- 网络变更前验证控制平面、DNS 和镜像仓库连通性。
- 对 NodeReady 和 kubelet 心跳设置告警。
- 网络模板加入静态校验和分批发布。

## Lessons Learned

Node NotReady 不等于 kubelet 故障，应同时检查运行时、资源、证书和网络路径。
