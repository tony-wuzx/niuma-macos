# 🐮 牛马脱敏器 · macOS 版 (NiuMa macOS)

> 🍎 **本项目是 [feiyuaq/niuma](https://github.com/feiyuaq/niuma) (Windows 版) 的 macOS 移植版。**
> **非常感谢原作者 [@feiyuaq](https://github.com/feiyuaq) 提供的绝妙创意与原始设计！** 
> 原版基于 .NET 开发，**使用 Swift 完全重写并适配 macOS**。支持苹果芯片 (M1/M2/M3/M4) 及 Intel 芯片。

> 上班摸鱼时看一眼，每一秒都在到账。
> 一个基于 SwiftUI 开发的 macOS 桌面悬浮窗小工具，实时显示你今天上班已经赚了多少钱。

---

## 📸 界面预览

<img width="764" height="93" alt="image" src="https://github.com/user-attachments/assets/f0afcdaf-85bf-4b4d-a791-c406f1522fde" />


<img width="760" height="90" alt="image" src="https://github.com/user-attachments/assets/2e343963-76c6-4416-8ab7-13c56efeb9eb" />


<img width="680" height="1064" alt="image" src="https://github.com/user-attachments/assets/b0db18d2-ea54-4186-a817-b0cb55db83c3" />


<img width="1865" height="1697" alt="image" src="https://github.com/user-attachments/assets/188fd7a3-521a-4078-8f3c-d28095450967" />


---

## ✨ 核心功能 (v4.1.0 史诗级更新)

### 💰 基础摸鱼
- **实时薪资**：按日薪或月薪、上下班时间计算今日已赚，数字平滑递增，精确到小数点后 5 位。
- **多币种汇率**：工资输入为人民币，根据当日汇率，一键切换显示 **人民币 / 美元 / 日元 / 英镑**。
- **原生悬浮窗**：毛玻璃背景、可置顶、可任意拖动、菜单栏托盘常驻。
- **双模式无缝切换**：全面移除旧版折叠模式！现支持 **展开模式（大平层看板）** 与 **迷你模式（极简悬浮条）**。切换动画极度顺滑，没有任何布局抽搐。
- **防窥模式**：一键隐藏金额，显示为 `****`，并支持鼠标穿透。
- **双语支持**：设置中可一键切换中文 / English 界面。

### 💔 扎心暴击
- **反差心愿单**：内置真实物价算法，支持华强北手机、莆田鞋等极客平价，也支持大白菜、土豆等真实的农业批发价。
- **双重物价暴击**：告诉你今天赚的钱能买什么。
- **极寒负能量语录**：底部吐槽文字每分钟自动轮换，内置防重复算法，随时提醒你世界的残酷。

### 🛡️ v4.1.0 全新功能：牛马守卫 & 反内卷
- **🏃 提桶跑路**：右上角新增奔跑小人图标。平时灰色，准点打卡变绿，超时未打卡变红（超时自动记录为加班）。
- **📅 毒舌报表**：点击日历图标，查看当月打卡日历。绿格子准点，红格子加班，底部附带极其毒舌的“月度总结”。
- **🔒 到点锁屏**：可设置到点自动调用系统锁屏，且鼠标移动会被自动“抖回”调戏。
- **🚨 全窗口跑马灯蒙版**：告别无聊的系统通知！摸鱼或下班提醒触发时，窗口将强制覆盖全屏渐变色蒙版。大模式下居中静止，小模式下超长自动滚动，极其醒目。
- **☕ 海量摸鱼文案**：内置 30+ 条摸鱼提醒（“带薪拉屎”、“假装找文件”）和 15+ 条催下班毒舌，配置修改后立即生效。
- **🚪 一键退出**：右上角新增红色叉号，一键退出应用，拒绝任何打扰的系统弹窗。

---

## 📦 安装与使用 (普通用户)

1. 前往本仓库的 [Releases](https://github.com/tony-wuzx/niuma-macos/releases) 页面。
2. 下载最新的 `NiuMa-macOS-v4.1.0.zip` 并解压。
3. 将解压出的 `NiuMa.app` 拖入你的“应用程序”文件夹。

> ⚠️ **首次打开提示（绕过苹果安全拦截）**
> 因为本项目是个人开源作品，未购买苹果每年 $99 的开发者签名。首次打开时 macOS 会提示“无法验证开发者”。
> **解决方法**：在“应用程序”文件夹里，**按住键盘上的 `Control` 键（或右键）点击 `NiuMa.app`**，选择“**打开**”，在弹窗中再次点击“打开”即可。
> 如果仍然提示文件已损坏，请打开终端运行：`sudo xattr -cr /Applications/NiuMa.app`。

---

## 🛠️ 从源码编译 (开发者)

本项目基于 Swift Package Manager (SPM) 构建，不需要安装完整的 Xcode，只需 macOS 自带的命令行工具即可。

```bash
# 1. 克隆项目
git clone https://github.com/tony-wuzx/niuma-macos.git
cd niuma-macos

# 2. 赋予编译脚本权限并执行打包
chmod +x build-app.sh
./build-app.sh

# 3. 运行
open NiuMa.app
