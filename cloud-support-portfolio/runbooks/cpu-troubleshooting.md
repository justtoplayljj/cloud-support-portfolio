# CPU Troubleshooting Runbook

## Purpose

定位 Linux 主机 CPU 使用率或 load average 持续过高的问题，并在可控范围内恢复服务。

## Scope

适用于 Ubuntu、CentOS 和 Rocky Linux。命令输出需结合主机 CPU 核数和历史基线判断。

## Preconditions

- 已确认告警主机、时间窗口和业务影响。
- 具备只读诊断权限；终止进程或重启服务前已获得授权。
- 已记录近期发布、计划任务和配置变更。

## Safety Notes

不要直接执行 `kill -9`。先保存进程、日志和调用关系证据，并优先使用 `SIGTERM`。

## Procedure

### 1. 确认现象

```bash
uptime
top -b -n1 | head -30
mpstat -P ALL 1 5
```

区分用户态、内核态、IO wait、steal time 和单核热点。

### 2. 定位进程和线程

```bash
ps -eo pid,ppid,etimes,%cpu,%mem,stat,cmd --sort=-%cpu | head -20
top -H -p <PID>
pstree -sp <PID>
```

### 3. 检查常见原因

```bash
vmstat 1 5
pidstat -u -p <PID> 1 5
journalctl --since '-30 minutes' -p warning
systemctl list-timers --all
```

检查发布后循环、任务重叠、锁竞争、异常流量和内核错误。

### 4. 缓解

根据根因选择限流、摘流量、暂停定时任务或优雅停止异常进程。示例：

```bash
sudo systemctl stop <TIMER_NAME>
sudo kill -TERM <PID>
```

## Verification

重新检查 `uptime`、`top`、应用延迟和错误率，至少观察一个业务高峰或调度周期。

## Rollback Plan

若缓解操作扩大影响，重新启用暂停的 timer/service，恢复原配置并按变更流程回滚版本。

## Escalation Criteria

- 内核态 CPU 持续异常或出现硬件错误。
- 无法识别进程来源，或涉及数据库核心线程。
- 所有实例同时接近饱和且容量不足。

## Success Criteria

CPU 和负载回到基线，业务指标恢复，根因和后续行动项已记录。
