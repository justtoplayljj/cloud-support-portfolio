# Incident 007 - Application Memory Leak

> 模拟场景：指标、进程和时间均为实验环境示例。

## Overview

- Environment: Java application on Linux
- Severity: High
- Impact: 实例周期性被 OOM Killer 终止

## Incident Description

应用内存连续增长，重启后短暂恢复，约 6 小时后再次不可用。

## Investigation

```bash
free -h
ps -eo pid,etimes,rss,%mem,cmd --sort=-rss | head
journalctl -k | grep -i 'out of memory\|killed process'
```

内核日志确认 Java 进程被终止。检查 JVM 和 GC：

```bash
jcmd <PID> GC.heap_info
jcmd <PID> GC.class_histogram | head -30
```

缓存对象数量持续增长，GC 后堆占用没有回落。流量、线程数和宿主机其他进程正常。

## Root Cause

新版本的本地缓存缺少过期与容量上限，唯一键持续累积，最终耗尽容器内存限制。

## Resolution

先将实例摘出流量并滚动回退到上一版本，再逐个恢复：

```bash
sudo systemctl stop app
# 恢复已验证版本和配置
sudo systemctl start app
```

后续版本为缓存增加最大条目数和 TTL。

## Verification

连续观察两个高峰周期：

```bash
watch -n 30 'ps -o pid,rss,%mem,cmd -C java'
journalctl -k --since '-1 hour' | grep -i oom
```

内存稳定，无新 OOM 记录，错误率恢复基线。

## Preventive Actions

- 对 RSS、堆使用率和 OOM 事件设置告警。
- 在压测中加入长时间稳定性测试。
- 为缓存配置容量上限、TTL 和命中率指标。

## Lessons Learned

重启只能缓解泄漏；必须通过趋势和堆对象证据定位持续持有内存的组件。
