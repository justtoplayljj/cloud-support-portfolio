# Nginx Restart Procedure

## Purpose

规范 Nginx 服务重启流程，降低因配置错误或操作失误导致业务中断的风险。

---

## Scope

适用于：

* Ubuntu 20.04+
* CentOS 7+
* Rocky Linux 8+

服务类型：

* Nginx Reverse Proxy
* Nginx Web Server

---

## Preconditions

执行前确认：

* 已获得变更授权
* 当前业务处于允许维护窗口
* 已备份 Nginx 配置文件

备份命令：

```bash
cp -a /etc/nginx /etc/nginx.bak.$(date +%F)
```

---

## Step 1 - Check Configuration

重启前必须验证配置文件。

```bash
nginx -t
```

正常输出：

```text
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

如果验证失败：

```text
emerg
failed
syntax error
```

停止后续操作并修复配置。

---

## Step 2 - Check Service Status

查看当前运行状态。

```bash
systemctl status nginx
```

确认：

* active (running)
* 无异常报错

---

## Step 3 - Reload Configuration

如仅修改配置文件：

推荐使用 Reload。

```bash
systemctl reload nginx
```

优点：

* 不中断现有连接
* 风险较低

---

## Step 4 - Restart Service

如涉及模块更新或服务异常：

执行重启。

```bash
systemctl restart nginx
```

确认执行成功：

```bash
systemctl status nginx
```

---

## Step 5 - Verify Service

检查监听端口：

```bash
ss -lntp | grep nginx
```

示例：

```text
LISTEN 0 511 0.0.0.0:80
LISTEN 0 511 0.0.0.0:443
```

访问验证：

```bash
curl -I http://127.0.0.1
```

返回：

```text
HTTP/1.1 200 OK
```

---

## Rollback Plan

若重启后服务异常：

恢复备份配置。

```bash
cp -a /etc/nginx.bak.2026-06-23/* /etc/nginx/
```

重新验证：

```bash
nginx -t
```

重启服务：

```bash
systemctl restart nginx
```

---

## Success Criteria

满足以下条件：

* nginx -t 成功
* 服务状态正常
* 80/443端口监听
* HTTP返回200
* 无业务告警

---

## References

Official Documentation

https://nginx.org/en/docs/
