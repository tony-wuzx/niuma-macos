#!/bin/bash
set -e
APP_NAME="NiuMa"
BUILD_DIR=".build/release"
APP_BUNDLE="$APP_NAME.app"

echo "==> 编译 Swift 项目..."
swift build -c release

echo "==> 创建 .app 包结构..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

echo "==> 拷贝可执行文件..."
cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

echo "==> 拷贝 Info.plist..."
cp "Resources/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

echo "==> 生成 PkgInfo..."
echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

echo "==> 本地 ad-hoc 签名..."
codesign --force --deep --sign - "$APP_BUNDLE" 2>/dev/null || echo "（签名跳过）"

echo ""
echo "✅ 打包完成：$PWD/$APP_BUNDLE"
echo "   运行：open $APP_BUNDLE"
