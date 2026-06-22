# Incident 002 - MySQL Service Down

## Overview

Environment: Ubuntu 22.04

Service: MySQL 8.0

Severity: High

---

## Incident Description

业务系统无法登录。

应用报错：

Database Connection Failed

---

## Investigation

检查服务状态：

```bash
systemctl status mysql
```

结果：

```text
failed
```

查看日志：

```bash
journalctl -u mysql -n 50
```

发现：

```text
No space left on device
```

---

检查磁盘：

```bash
df -h
```

结果：

```text
/dev/sda1 100%
```

磁盘已满。

---

## Root Cause

MySQL Binlog长期未清理。

累计占用大量空间。

导致服务启动失败。

---

## Resolution

查看Binlog：

```bash
ls -lh /var/lib/mysql
```

清理历史日志：

```sql
PURGE BINARY LOGS BEFORE DATE(NOW() - INTERVAL 7 DAY);
```

重启服务：

```bash
systemctl restart mysql
```

---

## Preventive Actions

配置Binlog自动过期：

```ini
expire_logs_days=7
```

增加磁盘容量告警。

增加MySQL健康检查。

---

## Lessons Learned

磁盘满是数据库故障的常见原因。

需要持续监控：

* 磁盘使用率
* Binlog增长速度
* 数据目录容量
