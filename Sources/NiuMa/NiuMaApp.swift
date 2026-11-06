import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var statusItem: NSStatusItem!
    
    // 延迟初始化，确保在主线程
    var engine: SalaryEngine!
    var settings: Settings!

    func applicationDidFinishLaunching(_ notification: Notification) {
        MainActor.assumeIsolated {
            self.settings = Settings.shared
            self.engine = SalaryEngine()
            self.createWindow()
            self.createStatusItem()
            self.engine.start()
        }
    }

    private func createWindow() {
        MainActor.assumeIsolated {
            let content = MainView(engine: self.engine)
            let hosting = NSHostingView(rootView: content)

            self.window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 380, height: 600),
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

            if let saved = self.settings.windowPosition {
                self.window.setFrameOrigin(saved)
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

    @objc func togglePrivacy() { 
        MainActor.assumeIsolated {
            self.engine.maskAmount.toggle() 
        }
    }

    @objc func toggleClickThrough() {
        MainActor.assumeIsolated {
            self.engine.clickThrough.toggle()
            self.window.ignoresMouseEvents = self.engine.clickThrough
        }
    }

    @objc func openSettings() {
        MainActor.assumeIsolated {
            SettingsWindowController.shared.showWindow(engine: self.engine)
        }
    }

    @objc func quit() { 
        NSApp.terminate(nil) 
    }

    func applicationWillTerminate(_ notification: Notification) {
        MainActor.assumeIsolated {
            self.settings.windowPosition = self.window.frame.origin
            self.settings.save()
        }
    }
}
