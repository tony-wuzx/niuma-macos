# 🐮 牛马脱敏器 · macOS 版 (NiuMa macOS)

> 🍎 **本项目是 [feiyuaq/niuma](https://github.com/feiyuaq/niuma) (Windows 版) 的 macOS 移植版。**
> **非常感谢原作者 [@feiyuaq](https://github.com/feiyuaq) 提供的绝妙创意与原始设计！** 
> 原版基于 .NET 开发，**使用 Swift 完全重写并适配 macOS**。支持苹果芯片 (M1/M2/M3/M4) 及 Intel 芯片。

> 上班摸鱼时看一眼，每一秒都在到账。
> 一个基于 SwiftUI 开发的 macOS 桌面悬浮窗小工具，实时显示你今天上班已经赚了多少钱。

---

## ✨ 核心功能

- 💰 **实时薪资**：按日薪或月薪、上下班时间计算今日已赚，数字平滑递增，精确到小数点后 5 位。
- 🌍 **多币种汇率**：工资输入为人民币，根据当日汇率，一键切换显示 **人民币 / 美元 / 日元 / 英镑**。
- 🪟 **原生悬浮窗**：毛玻璃背景、可置顶、可任意拖动、菜单栏托盘常驻。
- 📏 **紧凑折叠模式**：支持一键折叠，只保留时间、金额和状态，展开后查看完整数据。
- 👕 **反差心愿单**：内置 50% 正常（如一杯瑞幸）和 50% 离谱（如一百个鸡蛋、十分之一台车）的等价物算法，根据当前金额自动匹配。
- 🕶️ **防窥模式**：一键隐藏金额，显示为 `****`，并支持鼠标穿透。
- 🌐 **双语支持**：设置中可一键切换中文 / English 界面。
- **反差心愿单 双重物价暴击**：高速你今天赚的钱能买什么。
- **震撼农业批发价**：引入产地大白菜、土豆、白萝卜等真实的极低批发价，让你直观体会到底层劳动者的不易与物价的参差。
- **极寒负能量语录**：内置庞大的虚无主义算法，包含“随机数字暴击”, 随时提醒你世界的残酷。
- **全方位细节打磨**：彻底修复排版留白、长句截断、量词错乱等问题，中英双语切换丝滑顺畅。

---

## 📸 界面预览

<img width="681" height="881" alt="image" src="https://github.com/user-attachments/assets/27121d59-0c8e-453d-9c38-7851bbeff4d2" />

<img width="1280" height="1688" alt="image" src="https://github.com/user-attachments/assets/6968d2a6-de2d-4077-b129-97875a144509" />

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
