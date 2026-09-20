# WebSSH — Serv00 专用版

本仓库已精简为 **Serv00 部署专用版本**。

## 保留内容

- WebSSH 核心 SSH / WebSocket 终端
- SSH 密码、公钥和 2FA 登录
- SSH Link 功能
- Python 运行依赖
- Serv00 启动脚本 `serv00_start.sh`

## 已删除

- Docker / docker-compose
- Python 打包文件
- 测试代码和测试密钥
- 预览图片
- UserScript
- 其他非 Serv00 部署内容

## Serv00 部署

### 1. 克隆项目

进入你的 Serv00 应用目录：

```bash
git clone https://github.com/tuzili/webssh.git
cd webssh
```

如果目录已经存在，直接进入项目目录即可。

### 2. 创建 Python 虚拟环境

当前启动脚本使用：

```
~/webssh-env/bin/python
```

创建并安装依赖：

```bash
virtualenv -p python3.10 ~/webssh-env
~/webssh-env/bin/pip install -r requirements.txt
```

### 3. 配置 Serv00 端口

编辑 `serv00_start.sh`：

```bash
PORT="30000"
```

把 `30000` 改成你在 Serv00 中实际分配给 WebSSH 的 TCP 端口。

WebSSH 监听：

```
127.0.0.1:30000
```

### 4. 启动

```bash
chmod +x serv00_start.sh
./serv00_start.sh
```

启动脚本会：

- 后台运行 WebSSH
- 写入 `webssh.pid`
- 输出日志到 `webssh.log`
- 防止重复启动

### 5. Serv00 网站反向代理

将你的 Serv00 网站反向代理到：

```
http://127.0.0.1:30000
```

其中 `30000` 必须替换成你自己的端口。

由于 WebSSH 使用 WebSocket，反向代理需要支持 WebSocket Upgrade。

### 6. HTTPS

建议通过 Serv00 网站的 HTTPS 域名访问 WebSSH。

不需要在 WebSSH 进程中配置 `cert.crt` / `cert.key`。

## SSH Link

登录页面保留了 SSH Link 功能，可以生成方便收藏的连接地址。

## 安全

- 不要把 SSH 私钥、密码、TLS 私钥提交到 GitHub。
- 不要把测试密钥上传到生产仓库。
- 公网访问建议使用 HTTPS。
- 生产环境可以考虑使用 `--policy=reject` 并配置可信 `known_hosts`。

## 运行文件

Serv00 实际运行入口：

```
serv00_start.sh
  ↓
run.py
  ↓
webssh.main
```
