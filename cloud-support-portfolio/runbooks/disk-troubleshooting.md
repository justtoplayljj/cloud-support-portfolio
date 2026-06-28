# Disk Troubleshooting Runbook

## Purpose

安全定位 Linux 磁盘空间或 inode 耗尽问题，避免因盲目删除导致数据丢失。

## Scope

适用于本地文件系统空间告警、inode 告警及“删除后空间未释放”场景。

## Preconditions

- 确认受影响挂载点、告警阈值和业务影响。
- 删除或压缩文件前确认所有者、保留策略和备份要求。
- 对数据库、容器存储和系统日志操作需获得授权。

## Safety Notes

禁止直接执行未经限定的 `rm -rf` 或按文件大小批量删除。优先移动、压缩或使用服务自带清理命令。

## Procedure

### 1. 确认空间和 inode

```bash
df -hT
df -ih
findmnt
```

### 2. 定位高占用目录

保持在目标文件系统内，避免跨挂载扫描：

```bash
sudo du -xhd1 <MOUNT_POINT> | sort -h
sudo find <MOUNT_POINT> -xdev -type f -size +500M -printf '%s %p\n' | sort -n
```

### 3. 检查已删除但仍打开的文件

```bash
sudo lsof +L1
```

若文件仍被进程持有，优先 reload/restart 对应服务，不要操作 `/proc/<PID>/fd`。

### 4. 检查日志和容器

```bash
journalctl --disk-usage
sudo logrotate -d /etc/logrotate.conf
docker system df 2>/dev/null || true
```

### 5. 缓解

依据保留策略压缩或删除已确认的历史文件；Docker 使用 dry-run 清单后再清理。

## Verification

```bash
df -hT <MOUNT_POINT>
df -ih <MOUNT_POINT>
```

确认服务可写、日志继续生成且告警恢复。

## Rollback Plan

从备份或临时移动目录恢复文件；若服务重启失败，恢复配置并升级处理。

## Escalation Criteria

- 文件系统只读、出现 I/O error 或 SMART 告警。
- 数据库文件、容器 overlay 或未知大文件占用空间。
- 清理后空间仍未释放。

## Success Criteria

空间和 inode 回到安全阈值，业务写入正常，已建立容量与保留策略行动项。
