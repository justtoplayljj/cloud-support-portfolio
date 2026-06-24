# MySQL Backup Procedure

## Purpose

规范 MySQL 数据库备份流程，确保业务数据可恢复。

---

## Scope

适用于：

* MySQL 5.7
* MySQL 8.0

备份方式：

* Logical Backup (mysqldump)

---

## Preconditions

确认：

* MySQL 服务正常运行
* 备份目录空间充足
* 备份账号具备权限

检查磁盘：

```bash
df -h
```

---

## Step 1 - Verify Database Status

确认服务状态：

```bash
systemctl status mysql
```

确认数据库可访问：

```bash
mysql -uroot -p
```

查看数据库：

```sql
SHOW DATABASES;
```

---

## Step 2 - Create Backup Directory

创建备份目录：

```bash
mkdir -p /backup/mysql
```

检查目录：

```bash
ls -ld /backup/mysql
```

---

## Step 3 - Perform Backup

备份所有数据库：

```bash
mysqldump \
-u root \
-p \
--single-transaction \
--routines \
--events \
--all-databases \
> /backup/mysql/full_backup.sql
```

查看文件：

```bash
ls -lh /backup/mysql
```

示例：

```text
full_backup.sql 2.1G
```

---

## Step 4 - Compress Backup

压缩备份文件：

```bash
gzip /backup/mysql/full_backup.sql
```

结果：

```text
full_backup.sql.gz
```

---

## Step 5 - Verify Backup

验证文件完整性：

```bash
gzip -t full_backup.sql.gz
```

查看大小：

```bash
ls -lh full_backup.sql.gz
```

---

## Restore Test

恢复测试数据库：

```bash
gunzip full_backup.sql.gz
```

恢复：

```bash
mysql -uroot -p < full_backup.sql
```

确认：

```sql
SHOW DATABASES;
```

数据存在即验证成功。

---

## Retention Policy

建议：

* Daily Backup：保留7天
* Weekly Backup：保留4周
* Monthly Backup：保留6个月

清理命令：

```bash
find /backup/mysql \
-name "*.gz" \
-mtime +30 \
-delete
```

---

## Automation Example

Crontab：

```bash
0 2 * * * /opt/scripts/mysql-backup.sh
```

每天凌晨2点执行备份。

---

## Success Criteria

满足以下条件：

* 备份成功生成
* 文件可解压
* 恢复测试成功
* 保留策略正常执行

---

## References

Official Documentation

https://dev.mysql.com/doc/
