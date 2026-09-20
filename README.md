# WebSSH — Serv00 专用版

这是一个精简后的 WebSSH 版本，目标是直接部署到 Serv00。

## 保留内容

- WebSSH 核心程序
- SSH 密码、公钥和 2FA 登录
- WebSocket 终端
- SSH Link 功能
- Python 依赖
- Serv00 启动脚本

## Serv00 部署

### 1. 上传项目

将仓库文件放到 Serv00 的应用目录，例如：

```bash
cd ~/domains/你的域名/public_python
git clone https://github.com/tuzili/webssh.git .
```

如果已经上传项目，则直接进入项目目录。

### 2. 安装依赖

建议使用 Python 虚拟环境：

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 3. 分配 Serv00 端口

在 Serv00 中为 WebSSH 分配一个可用 TCP 端口，然后让网站反向代理到：

```
127.0.0.1:你的端口
```

### 4. 启动 WebSSH

```bash
chmod +x start.sh
./start.sh
```

也可以直接运行：

```bash
python3 run.py --address=127.0.0.1 --port=你的端口 --policy=warning --xheaders=True --fbidhttp=False
```

如果设置了环境变量 `PORT`，`start.sh` 会优先使用该端口；否则默认使用 `8080`。

### 5. 网站反向代理

将 Serv00 网站的反向代理目标设置为：

```
http://127.0.0.1:你的端口
```

WebSSH 使用 WebSocket，代理配置必须允许 WebSocket Upgrade。

### 6. HTTPS

建议使用 Serv00 网站提供的 HTTPS 访问 WebSSH，不需要在 WebSSH 进程中额外配置证书。

## SSH Link

项目保留了 SSH Link 功能。登录页面可以生成带参数的 SSH Link，方便以后直接打开。

## 安全提示

- 不要把 SSH 私钥、密码、TLS 私钥或测试密钥提交到 GitHub。
- 生产环境建议使用 HTTPS。
- 如果使用 `--policy=reject`，请提前准备可信的 `known_hosts`。
- 不要为了省事关闭 SSH 主机密钥校验。

## 启动脚本

`start.sh` 默认监听：

```
127.0.0.1:8080
```

可以通过环境变量修改：

```bash
PORT=你的Serv00端口 ./start.sh
```
