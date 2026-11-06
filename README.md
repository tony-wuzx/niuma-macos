# 🐮 牛马脱敏器 · macOS 版 (NiuMa macOS)

> 🍎 **本项目是 [feiyuaq/niuma](https://github.com/feiyuaq/niuma) (Windows 版) 的 macOS 移植版。**
> **非常感谢原作者 [@feiyuaq](https://github.com/feiyuaq) 提供的绝妙创意与原始设计！** 
> 原版基于 .NET 开发，**使用 Swift 完全重写并适配 macOS**。支持苹果芯片 (M1/M2/M3/M4) 及 Intel 芯片。

> 上班摸鱼时看一眼，每一秒都在到账。
> 一个基于 SwiftUI 开发的 macOS 桌面悬浮窗小工具，实时显示你今天上班已经赚了多少钱。

---

## 📸 界面预览

<img width="761" height="1163" alt="image" src="https://github.com/user-attachments/assets/2bcf6b3c-920d-4e88-bacd-f1f48a6cff4c" />

<img width="1506" height="1680" alt="image" src="https://github.com/user-attachments/assets/2b76a7ba-a131-40d6-b668-3b27de50181f" />

---

## ✨ 核心功能

- 💰 **实时薪资**：按日薪或月薪、上下班时间计算今日已赚，数字平滑递增，精确到小数点后 5 位。
- 🌍 **多币种汇率**：工资输入为人民币，根据当日汇率，一键切换显示 **人民币 / 美元 / 日元 / 英镑**。
- 🧘 **状态显示**：上班中 / 午休中 / 已下班 / 休息日，附精确到秒的下班倒计时。
- 📈 **进度面板**：今日工时进度条、当前赚钱速度（每秒/每分钟）、本月累计、距离发薪日天数。
- 👕 **心愿单**：“今天已经赚到一件 T 恤了”。
- 💬 **毒鸡汤**：内置组合算法，每分钟随机轮换一条牛马语录，支持自定义。
- 🪟 **原生悬浮窗**：毛玻璃背景、可置顶、可任意拖动、菜单栏托盘常驻。
- 🕶️ **防窥模式**：一键隐藏金额，显示为 `****`，并支持鼠标穿透。

---

## 📦 安装与使用 (普通用户)

1. 前往本仓库的 [Releases](https://github.com/tony-wuzx/niuma-macos/releases) 页面。
2. 下载最新的 `NiuMa-macOS-v1.0.0.zip` 并解压。
3. 将解压出的 `NiuMa.app` 拖入你的“应用程序”文件夹。

> ⚠️ **首次打开提示（绕过苹果安全拦截）**
> 因为本项目是个人开源作品，未购买苹果每年 $99 的开发者签名。首次打开时 macOS 会提示“无法验证开发者”。
> **解决方法**：在“应用程序”文件夹里，**按住键盘上的 `Control` 键（或右键）点击 `NiuMa.app`**，选择“**打开**”，在弹窗中再次点击“打开”即可。以后就可以正常双击打开了。
> 如果仍然提示文件已损坏，请打开终端运行：`sudo xattr -cr /Applications/NiuMa.app`。

---

## 🛠️ 从源码编译 (开发者)

本项目不需要安装完整的几十 GB 的 Xcode，只需要 macOS 自带的命令行工具即可编译。

```bash
# 1. 克隆项目
git clone https://github.com/tony-wuzx/niuma-macos.git
cd niuma-macos

# 2. 赋予编译脚本权限并执行打包
chmod +x build-app.sh
./build-app.sh

# 3. 运行
open NiuMa.app
