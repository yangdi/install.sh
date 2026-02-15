#!/bin/bash

# 配置信息
REPO="yourusername/picoclaw" # 替换为你的 GitHub 仓库路径
BINARY_NAME="picoclaw"
INSTALL_DIR="/usr/local/bin"

# 1. 自动检测系统架构
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "不支持的架构: $ARCH"; exit 1 ;;
esac

echo "正在检测 $OS-$ARCH 系统的最新版本..."

# 2. 通过 GitHub API 获取最新 Tag 名
LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_TAG" ]; then
    echo "无法获取最新版本，请检查仓库权限或网络。"
    exit 1
fi

echo "发现最新版本: $LATEST_TAG"

# 3. 构建下载链接 (假设你的 Release 文件命名规则为 picoclaw_Linux_x86_64.tar.gz)
# 注意：这里的命名逻辑需与 GoReleaser 或你的打包脚本一致
URL="https://github.com/$REPO/releases/download/$LATEST_TAG/${BINARY_NAME}_${OS}_${ARCH}.tar.gz"

# 4. 下载并解压
echo "正在从 $URL 下载..."
curl -L "$URL" -o "${BINARY_NAME}.tar.gz"

tar -xzf "${BINARY_NAME}.tar.gz"
chmod +x "$BINARY_NAME"

# 5. 移动到系统路径 (需要 sudo 权限)
echo "正在安装到 $INSTALL_DIR..."
sudo mv "$BINARY_NAME" "$INSTALL_DIR/"

# 清理现场
rm "${BINARY_NAME}.tar.gz"

echo "------------------------------------------"
echo "✅ PicoClaw $LATEST_TAG 安装成功！"
echo "输入 '$BINARY_NAME --help' 开始使用。"
