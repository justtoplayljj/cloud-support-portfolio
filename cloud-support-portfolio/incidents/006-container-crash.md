# Incident 006 - Docker Container Crash

> 模拟场景：容器名称、镜像和日志均为实验示例。

## Overview

- Environment: Docker Engine 26
- Severity: Medium
- Impact: 单个 API 实例不可用

## Incident Description

`orders-api` 容器反复退出并被 restart policy 拉起。

## Investigation

```bash
docker ps -a --filter name=orders-api
docker inspect orders-api --format '{{.State.ExitCode}} {{.State.Error}}'
docker logs --tail 100 orders-api
```

退出码为 `1`，日志显示缺少 `DATABASE_URL`。对比容器配置和部署文件：

```bash
docker inspect orders-api --format '{{json .Config.Env}}'
docker compose config
```

镜像可以正常启动，主机资源和 Docker daemon 无异常。

## Root Cause

部署时引用了错误的环境文件，必需变量 `DATABASE_URL` 未注入容器。

## Resolution

恢复正确的环境文件引用，先渲染配置再重建服务：

```bash
docker compose config >/tmp/compose-rendered.yml
docker compose up -d --no-deps --force-recreate orders-api
```

## Verification

```bash
docker ps --filter name=orders-api
docker inspect orders-api --format '{{.State.Health.Status}}'
curl -fsS http://127.0.0.1:8080/health
```

容器持续运行且健康检查返回成功。

## Preventive Actions

- 部署前校验必需环境变量，但不在日志中打印变量值。
- 为镜像配置健康检查和有限的重启策略。
- 对 Compose 渲染结果执行 CI 检查。

## Lessons Learned

容器重启循环只是现象，应结合退出码、应用日志和最终渲染配置确定根因。
