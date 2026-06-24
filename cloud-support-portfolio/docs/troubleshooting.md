# LiteLLM + Ollama + Prometheus + Grafana 部署踩坑记录

## 项目架构

```text
OpenRouter / Ollama
        │
        ▼
    LiteLLM
        │
        ▼
   Prometheus
        │
        ▼
    Grafana
```

---

# 1. Wolfi 容器无 curl 命令

## 现象

```bash
bash: curl: command not found
```

## 原因

LiteLLM 官方镜像基于 Wolfi 构建，为最小化镜像，不包含 curl。

## 解决方案

进入容器后使用：

```bash
apk add curl
```

或者在宿主机执行测试请求。

---

# 2. LiteLLM Health Check 返回 401

## 现象

```json
{
  "error": {
    "message": "Authentication Error, No api key passed in."
  }
}
```

## 原因

启用了：

```yaml
general_settings:
  master_key: sk-test
```

所有接口需要认证。

## 解决方案

请求时增加：

```bash
-H "Authorization: Bearer sk-test"
```

---

# 3. Invalid model name passed

## 现象

```json
{
  "error": {
    "message": "Invalid model name passed in model=deepseek"
  }
}
```

## 原因

LiteLLM 中配置的 model_name 与实际请求名称不一致。

## 排查方法

查看模型列表：

```bash
curl http://localhost:4000/v1/models
```

## 解决方案

使用返回的 model_name 调用接口。

---

# 4. Ollama 无法连接

## 现象

```text
Cannot connect to host 172.17.0.1:11434
```

## 原因

Docker 容器无法访问宿主机 Ollama。

## 解决方案

### systemd 配置

```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
```

重启：

```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

### LiteLLM 配置

```yaml
model_list:
  - model_name: qwen3
    litellm_params:
      model: ollama_chat/qwen3
      api_base: http://host.docker.internal:11434
```

### Docker Compose

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

---

# 5. Prometheus 抓取 Metrics 返回 401

## 现象

```text
Error scraping target: 401 Unauthorized
```

## 原因

LiteLLM Metrics 接口启用了认证。

## 解决方案

### 方法一

Prometheus 增加认证 Header：

```yaml
authorization:
  type: Bearer
  credentials: sk-test
```

### 方法二（推荐实验环境）

```yaml
litellm_settings:
  require_auth_for_metrics_endpoint: false
```

---

# 6. Metrics 返回 307 Redirect

## 现象

```text
GET /metrics HTTP/1.1" 307 Temporary Redirect
```

## 原因

LiteLLM 实际 Metrics 路径为：

```text
/metrics/
```

而不是：

```text
/metrics
```

## 解决方案

Prometheus 配置：

```yaml
metrics_path: /metrics/
```

---

# 7. Prometheus DNS 解析失败

## 现象

```text
lookup litellm on 127.0.0.53:53: server misbehaving
```

## 原因

Prometheus 与 LiteLLM 不在同一 Docker Network。

## 解决方案

统一网络：

```yaml
networks:
  ai_net:
```

服务配置：

```yaml
services:
  litellm:
    networks:
      - ai_net

  prometheus:
    networks:
      - ai_net
```

Prometheus Target：

```yaml
targets:
  - litellm:4000
```

---

# 8. Prometheus 配置挂载失败

## 现象

```text
not a directory
Are you trying to mount a directory onto a file
```

## 原因

宿主机：

```text
prometheus.yml
```

被误创建成目录。

## 排查

```bash
ls -l prometheus.yml
```

## 解决方案

删除目录：

```bash
rm -rf prometheus.yml
```

创建文件：

```bash
touch prometheus.yml
```

---

# 9. Grafana Dashboard 重启后丢失

## 现象

Grafana 重启后：

* Dashboard 消失
* DataSource 消失

## 原因

未配置持久化 Volume。

## 解决方案

```yaml
grafana:
  volumes:
    - grafana_data:/var/lib/grafana

volumes:
  grafana_data:
```

---

# 10. Grafana 使用错误数据源

## 现象

Dashboard 有图表但数据异常。

Data Source：

```text
Grafana
```

## 原因

使用了 Grafana 内置数据源。

## 正确配置

```text
Prometheus
```

URL：

```text
http://prometheus:9090
```

---

# 11. 容器内执行 bash 失败

## 现象

```text
exec: "bash": executable file not found
```

## 原因

Prometheus、Grafana、LiteLLM 等镜像基于精简 Linux。

## 解决方案

使用：

```bash
docker exec -it <container> sh
```

代替：

```bash
docker exec -it <container> bash
```

---

# 12. Grafana 无数据排查流程

## Step1

检查 LiteLLM Metrics：

```bash
curl http://localhost:4000/metrics/
```

## Step2

检查 Prometheus Target：

```text
http://localhost:9090/targets
```

状态必须：

```text
UP
```

## Step3

Prometheus 查询：

```promql
up
```

返回：

```text
1
```

## Step4

Grafana DataSource：

```text
Prometheus
```

---

# 最终成果

成功搭建：

* LiteLLM Proxy
* Ollama (Qwen3)
* Prometheus Metrics
* Grafana Dashboard
* Model Monitoring
* QPS Monitoring
* Latency Monitoring
* Error Rate Monitoring

并完成全链路压测验证。
