# WebSSH · Serv00 专用版

这是一个精简后的 WebSSH 版本，仅保留 **Serv00 部署所需内容**。

核心功能保留：
- 浏览器 SSH 终端
- 密码 / 私钥 / 2FA 登录
- WebSocket 实时终端
- SSH Link
- 登录后执行命令
- UTF-8 默认编码

## Serv00 部署

WebSSH 使用 Tornado + WebSocket，因此在 Serv00 上建议采用：

**WebSSH → 本机保留端口 → Serv00 Proxy 网站**

Serv00 官方文档说明 Proxy 页面支持 WebSocket；端口需要先预留。 citeturn6search0turn6search4

### 1. 开启 Binexec

SSH 登录 Serv00 后执行：

```bash
devil binexec on
```

执行后重新登录 SSH。 citeturn15search9

### 2. 预留 TCP 端口

例如使用 `30000`：

```bash
devil port add 30000 TCP webssh
devil port list
```

Serv00 当前允许预留的端口范围为 1024–64000。 citeturn6search0

### 3. 创建 Python 虚拟环境

```bash
virtualenv -p python3.10 ~/webssh-env
source ~/webssh-env/bin/activate
cd ~/webssh
pip install -r requirements.txt
```

Serv00 当前提供 Python 3.10，并支持通过 virtualenv 安装独立依赖。 citeturn0search1

### 4. 启动 WebSSH

把下面的 `30000` 改成你实际预留的端口：

```bash
cd ~/webssh
source ~/webssh-env/bin/activate

python run.py \
  --address=127.0.0.1 \
  --port=30000 \
  --xheaders=True \
  --policy=warning \
  --wpintvl=30
```

如果需要后台运行：

```bash
nohup ~/webssh-env/bin/python ~/webssh/run.py \
  --address=127.0.0.1 \
  --port=30000 \
  --xheaders=True \
  --policy=warning \
  --wpintvl=30 \
  > ~/webssh.log 2>&1 &
```

### 5. 添加 Serv00 Proxy

在 DevilWEB：

**WWW Websites → Add → Advanced settings → Proxy**

将 Proxy 指向：

```
localhost:30000
```

也可以使用命令：

```bash
devil www add YOUR-DOMAIN proxy localhost 30000
```

Serv00 的 Proxy 页面支持 WebSocket，因此适合 WebSSH 的终端连接。 citeturn6search4

### 6. HTTPS

建议给域名启用 SSL / 强制 HTTPS。

浏览器访问：

```
https://YOUR-DOMAIN/
```

### 7. 设置开机自动启动

Serv00 支持 Cron 的 `@reboot`：

```bash
crontab -e
```

加入：

```cron
@reboot /usr/local/bin/bash /home/YOUR-LOGIN/webssh/serv00_start.sh >> /home/YOUR-LOGIN/webssh/serv00.log 2>&1
```

Serv00 官方 Cron 文档确认支持 `@reboot`。 citeturn15search0

## 使用启动脚本

本仓库提供：

```
serv00_start.sh
```

首次使用前修改脚本顶部的：

```bash
PORT="30000"
```

然后：

```bash
chmod +x serv00_start.sh
./serv00_start.sh
```

## SSH Link

页面中的 **SSH Link** 可以生成带有：

- SSH 主机
- SSH 端口
- 用户名
- Base64 密码
- 登录后执行命令

的链接，方便保存到浏览器书签。

**注意：SSH Link 本身包含登录密码信息，不要公开分享。**

## 项目结构

精简后主要保留：

```
webssh/
├── webssh/              # WebSSH 核心程序
├── requirements.txt     # Python 依赖
├── run.py               # 启动入口
├── serv00_start.sh      # Serv00 启动脚本
├── README.md            # Serv00 部署说明
├── LICENSE
└── .gitignore
```

不会保留 Docker、docker-compose、测试、预览图片、油猴脚本及其它平台部署文件。

## 日志

后台运行时查看：

```bash
tail -f ~/webssh.log
```

Serv00 网站本身的错误日志位于对应域名的 `logs/error.log`。 citeturn0search1
