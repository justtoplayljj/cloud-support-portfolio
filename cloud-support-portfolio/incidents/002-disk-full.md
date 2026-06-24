# Incident 002 - Linux Disk Full

## Overview

Environment: CentOS 7

Severity: Medium

---

## Incident Description

监控系统告警：

Disk Usage > 95%

---

## Investigation

查看磁盘：

```bash
df -h
```

结果：

```text
/ 98%
```

定位目录：

```bash
du -sh /* | sort -hr
```

发现：

```text
/var/log 15G
```

继续分析：

```bash
find /var/log -type f -size +100M
```

发现：

```text
access.log 8G
```

---

## Root Cause

日志切割配置失效。

Nginx日志持续增长。

最终占满磁盘空间。

---

## Resolution

压缩日志：

```bash
gzip access.log
```

删除历史日志：

```bash
find /var/log -name "*.gz" -mtime +30 -delete
```

执行logrotate：

```bash
logrotate -f /etc/logrotate.conf
```

---

## Preventive Actions

配置Logrotate。

增加磁盘告警阈值。

建立日志保留策略。

---

## Lessons Learned

日志增长是Linux最常见磁盘问题之一。

需要：

* 定期检查
* 自动切割
* 自动清理
