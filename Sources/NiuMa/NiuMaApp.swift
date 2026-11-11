import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var statusItem: NSStatusItem!
    
    var engine: SalaryEngine!
    var settings: Settings!
    
    // 🎯 原生级别的死循环定时器
    var healthTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        MainActor.assumeIsolated {
            self.settings = Settings.shared
            self.engine = SalaryEngine()
            self.createWindow()
            self.createStatusItem()
            self.engine.start()
            
            // 启动原生定时器
            startHealthTimer()
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleMiniModeToggle(_:)), name: .niumaToggleMiniMode, object: nil)
        }
    }
    
    @MainActor
    func startHealthTimer() {
        healthTimer?.invalidate()
        let minutes = settings.healthReminderMinutes
        print("🚀 [AppDelegate] 启动原生摸鱼定时器，读取配置：\(minutes) 分钟")
        guard minutes > 0 else { return }
        
        healthTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(minutes * 60), repeats: true) { _ in
            MainActor.assumeIsolated {
                print("⏰ [AppDelegate] 触发摸鱼提醒！")
                let msg = HealthReminder.getRandomMessage()
                NotificationCenter.default.post(name: .niumaTriggerBroadcast, object: msg)
            }
        }
    }

    private func createWindow() {
        MainActor.assumeIsolated {
            let content = MainView(engine: self.engine)
            let hosting = NSHostingView(rootView: content)

            self.window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 380, height: 320),
                styleMask: [.borderless, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            self.window.contentView = hosting
            self.window.isOpaque = false
            self.window.backgroundColor = .clear
            self.window.level = .floating
            self.window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            self.window.isMovableByWindowBackground = true
            self.window.hasShadow = true
            
            self.window.center()
            self.window.makeKeyAndOrderFront(nil)
            // 🎯 强制每次都在屏幕正中央启动，无视之前的错误坐标
        }
    }

    @objc private func handleMiniModeToggle(_ notification: Notification) {
        MainActor.assumeIsolated {
            guard let isMini = notification.object as? Bool else { return }
            let targetHeight: CGFloat = isMini ? 46 : 320
            
            var newFrame = self.window.frame
            newFrame.origin.y += newFrame.size.height - targetHeight
            newFrame.size.height = targetHeight
            
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                self.window.animator().setFrame(newFrame, display: true, animate: true)
            }
        }
    }

    private func createStatusItem() {
        MainActor.assumeIsolated {
            self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            self.statusItem.button?.title = "🐮"

            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "显示/隐藏窗口", action: #selector(self.toggleWindow), keyEquivalent: "m"))
            menu.addItem(NSMenuItem(title: "隐藏金额", action: #selector(self.togglePrivacy), keyEquivalent: "h"))
            menu.addItem(NSMenuItem(title: "鼠标穿透", action: #selector(self.toggleClickThrough), keyEquivalent: "t"))
            menu.addItem(.separator())
            menu.addItem(NSMenuItem(title: "设置…", action: #selector(self.openSettings), keyEquivalent: ","))
            menu.addItem(.separator())
            menu.addItem(NSMenuItem(title: "退出", action: #selector(self.quit), keyEquivalent: "q"))
            self.statusItem.menu = menu
        }
    }

    @objc func toggleWindow() {
        MainActor.assumeIsolated {
            self.window.isVisible ? self.window.orderOut(nil) : self.window.makeKeyAndOrderFront(nil)
        }
    }

    @objc func togglePrivacy() { MainActor.assumeIsolated { self.engine.maskAmount.toggle() } }

    @objc func toggleClickThrough() {
        MainActor.assumeIsolated {
            self.engine.clickThrough.toggle()
            self.window.ignoresMouseEvents = self.engine.clickThrough
        }
    }

    @objc func openSettings() { MainActor.assumeIsolated { SettingsWindowController.shared.showWindow(engine: self.engine) } }

    @objc func quit() { NSApp.terminate(nil) }

    func applicationWillTerminate(_ notification: Notification) {
        MainActor.assumeIsolated {
            self.settings.windowPosition = self.window.frame.origin
            self.settings.save()
        }
    }
}
