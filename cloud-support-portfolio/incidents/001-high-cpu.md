# Incident 001 - Linux High CPU

> 模拟场景：以下主机名、时间和输出均为实验环境示例。

## Overview

- Environment: Ubuntu 22.04
- Severity: Medium
- Impact: Web API 响应时间由 200 ms 上升至 4 s

## Incident Description

监控持续 10 分钟报告 CPU 使用率超过 95%，但主机仍可登录。

## Investigation

确认负载和 CPU：

```bash
uptime
top -b -n1 | head -20
```

`gzip` 进程占用约 180% CPU。定位进程及父进程：

```bash
ps -o pid,ppid,etime,%cpu,cmd -p <PID>
pstree -sp <PID>
```

结果显示进程由定时备份脚本启动，多个任务发生重叠。检查计划任务：

```bash
systemctl list-timers --all
journalctl -u backup.service --since '-2 hours'
```

未发现内核错误或异常登录，问题限定在备份任务。

## Root Cause

备份任务没有并发锁，前一次压缩尚未结束，下一次任务再次启动，多个 `gzip` 进程竞争 CPU。

## Resolution

停止重复任务，仅保留运行时间最短的一次：

```bash
sudo systemctl stop backup.timer
sudo kill -TERM <DUPLICATE_PID>
```

在脚本入口增加 `flock`，确认无任务运行后重新启用 timer。

## Verification

```bash
uptime
ps -C gzip -o pid,etime,%cpu,cmd
systemctl status backup.timer
```

CPU 降至正常基线，API 延迟恢复，连续两个调度周期未出现并发任务。

## Preventive Actions

- 为所有定时任务增加并发锁和最大执行时间。
- 监控任务持续时间、失败次数和 CPU 饱和度。
- 备份压缩使用较低的 CPU/IO 优先级。

## Lessons Learned

高 CPU 告警应先确认具体进程，再结合父进程、调度记录和变更记录定位来源。
