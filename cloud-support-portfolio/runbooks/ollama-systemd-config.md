# 在 Linux 上通过 systemd 设置 Ollama 监听地址

默认情况下，Ollama 仅监听本地回环地址（127.0.0.1），Docker 容器中的 LiteLLM 无法直接访问。可以通过 systemd 环境变量配置 Ollama 监听所有网卡地址。

## 1. 编辑 Ollama 服务配置

执行：

```bash
sudo systemctl edit ollama.service
```

系统会打开一个编辑器。

## 2. 添加环境变量

在 `[Service]` 段落中加入：

```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
```

说明：

* `0.0.0.0`：监听所有网络接口
* `11434`：Ollama 默认 API 端口

## 3. 重新加载 systemd 配置

保存并退出后执行：

```bash
sudo systemctl daemon-reload
```

## 4. 重启 Ollama 服务

```bash
sudo systemctl restart ollama
```

## 5. 验证监听状态

查看监听端口：

```bash
ss -tlnp | grep 11434
```

正常情况下应看到：

```text
LISTEN 0 4096 0.0.0.0:11434
```

## 6. 测试 API

本机测试：

```bash
curl http://localhost:11434/api/tags
```

如果返回模型列表，则说明配置成功。

## 7. LiteLLM 配置示例

如果 LiteLLM 运行在 Docker 中：

```yaml
model_list:
  - model_name: qwen3
    litellm_params:
      model: ollama_chat/qwen3
      api_base: http://host.docker.internal:11434
```

Docker Compose 中增加：

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

完成后即可实现：

LiteLLM(Docker) → Ollama(Host:11434) → Qwen3
