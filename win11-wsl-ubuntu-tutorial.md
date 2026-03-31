# Win11 下使用 WSL Ubuntu 教程

## 1. 安装 WSL + Ubuntu

以管理员身份打开 PowerShell：

```powershell
wsl --install
```

默认安装 Ubuntu。安装完成后重启电脑，首次启动会要求设置用户名和密码。

如果想安装特定版本：

```powershell
# 查看可用发行版
wsl --list --online

# 安装指定版本
wsl --install -d Ubuntu-24.04
```

## 2. 启动 Ubuntu

三种方式：

- 开始菜单搜索 `Ubuntu` 点击打开
- PowerShell 中输入 `wsl`
- Windows Terminal 中新建 Ubuntu 标签页

## 3. 基础配置

### 更新系统

```bash
sudo apt update && sudo apt upgrade -y
```

### 安装常用工具

```bash
sudo apt install -y git curl wget unzip build-essential
```

### 配置 Git

```bash
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

## 4. Windows 与 Ubuntu 文件互访

### Ubuntu 访问 Windows 文件

Windows 的 C 盘挂载在 `/mnt/c/`：

```bash
# 访问桌面
cd /mnt/c/Users/你的用户名/Desktop

# 访问下载文件夹
cd /mnt/c/Users/你的用户名/Downloads
```

### Windows 访问 Ubuntu 文件

在文件资源管理器地址栏输入：

```
\\wsl$
```

或者在 Ubuntu 终端中：

```bash
# 用文件资源管理器打开当前目录
explorer.exe .
```

### 路径转换

```bash
# Linux 路径 → Windows 路径
wslpath -w ~/.kiro
# 输出: \\wsl$\Ubuntu\home\你的用户名\.kiro

# Windows 路径 → Linux 路径
wslpath 'C:\Users\你的用户名\Desktop'
# 输出: /mnt/c/Users/你的用户名/Desktop
```

## 5. 用 VS Code 连接 WSL

1. 在 Windows 上安装 [VS Code](https://code.visualstudio.com/)
2. 安装扩展：`WSL`（微软官方）
3. 在 Ubuntu 终端中打开项目：

```bash
cd ~/my-project
code .
```

VS Code 会自动通过 WSL 连接，左下角显示 `WSL: Ubuntu`。

## 6. 网络与代理

WSL 和 Windows 共享网络。如果 Windows 开了代理，Ubuntu 中需要手动设置：

```bash
# 获取 Windows 主机 IP
WIN_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')

# 设置代理（假设代理端口 7890）
export http_proxy="http://$WIN_IP:7890"
export https_proxy="http://$WIN_IP:7890"
```

写入 `~/.bashrc` 可以持久化：

```bash
echo 'export WIN_IP=$(cat /etc/resolv.conf | grep nameserver | awk "{print \$2}")' >> ~/.bashrc
echo 'export http_proxy="http://$WIN_IP:7890"' >> ~/.bashrc
echo 'export https_proxy="http://$WIN_IP:7890"' >> ~/.bashrc
```

注意：代理软件需要开启「允许局域网连接」。

## 7. 常用 WSL 管理命令（PowerShell 中执行）

```powershell
# 查看已安装的发行版
wsl --list --verbose

# 关闭 WSL
wsl --shutdown

# 设置默认发行版
wsl --set-default Ubuntu

# 导出备份
wsl --export Ubuntu D:\backup\ubuntu.tar

# 从备份恢复
wsl --import Ubuntu-new D:\wsl\ubuntu-new D:\backup\ubuntu.tar

# 卸载发行版
wsl --unregister Ubuntu
```

## 8. 在 WSL 中安装 Kiro CLI

```bash
# 下载安装
curl -fsSL https://kiro.dev/install.sh | bash

# 验证
kiro-cli --version

# 启动
kiro-cli chat
```

## 9. 常见问题

### WSL 占用内存过大

创建 `C:\Users\你的用户名\.wslconfig`：

```ini
[wsl2]
memory=4GB
swap=2GB
```

保存后执行 `wsl --shutdown` 重启生效。

### 复制粘贴

- Windows Terminal 中：`Ctrl+Shift+C` 复制，`Ctrl+Shift+V` 粘贴
- 右键也可以粘贴（取决于终端设置）

### 中文显示乱码

```bash
sudo apt install -y locales
sudo locale-gen zh_CN.UTF-8
echo 'export LANG=zh_CN.UTF-8' >> ~/.bashrc
source ~/.bashrc
```

### systemd 支持

编辑 `/etc/wsl.conf`：

```ini
[boot]
systemd=true
```

然后 `wsl --shutdown` 重启。

### DNS 解析失败

```bash
sudo rm /etc/resolv.conf
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo bash -c 'echo "[network]\ngenerateResolvConf=false" > /etc/wsl.conf'
```
