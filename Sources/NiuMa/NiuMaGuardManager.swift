import Foundation
import AppKit
import SwiftUI
import CoreGraphics

@MainActor
final class NiuMaGuardManager: ObservableObject {
    static let shared = NiuMaGuardManager()

    @Published var autoLockScreen: Bool = false
    @Published var mouseJitter: Bool = true
    @Published var punctual: [String] = []
    @Published var overtime: [String] = []

    private var lunchNotified = false
    private var lunchEarlyNotified = false
    private var offWorkNotified = false
    private var locked = false
    private var lastMouse = NSPoint.zero
    private var lastJitter = Date.distantPast
    
    private var timer: Timer?
    private let settings = Settings.shared

    private let toxicMessages = [
        "老板还没走？你是想卷死同事吗？",
        "距离下班还有5分钟，请立刻保存代码跑路！",
        "你的猫/狗还在家等你，工作明天再说。",
        "再敲键盘就不礼貌了，赶紧收拾东西！",
        "工资就这么点，你拼什么命啊？",
        "老板的保时捷轮毂，有你的一份功劳。",
        "时间到了，赶紧跑，不要回头！",
        "午休时间到，闭眼，让脑子放个假。"
    ]

    private let configURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("NiuMa", isDirectory: true)
        return dir.appendingPathComponent("niuma_guard_config.json")
    }()

    private struct Config: Codable {
        var autoLockScreen: Bool
        var mouseJitter: Bool
        var punctual: [String]
        var overtime: [String]
    }

    private init() {
        load()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tickGuard() }
        }
    }

    func save() {
        let cfg = Config(autoLockScreen: autoLockScreen, mouseJitter: mouseJitter, punctual: punctual, overtime: overtime)
        if let data = try? JSONEncoder().encode(cfg) { try? data.write(to: configURL) }
    }

    private func load() {
        guard let data = try? Data(contentsOf: configURL),
              let cfg = try? JSONDecoder().decode(Config.self, from: data) else { return }
        autoLockScreen = cfg.autoLockScreen
        mouseJitter = cfg.mouseJitter
        punctual = cfg.punctual
        overtime = cfg.overtime
    }

    func togglePunctual() {
        let today = todayString()
        if punctual.contains(today) { punctual.removeAll { $0 == today } } 
        else {
            punctual.append(today)
            overtime.removeAll { $0 == today }
        }
        save()
    }

    private func todayString() -> String {
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        return df.string(from: Date())
    }

    private func todayAt(_ hm: (Int, Int)) -> Date? {
        return Calendar.current.date(bySettingHour: hm.0, minute: hm.1, second: 0, of: Date())
    }
    
    private func triggerBroadcast() {
        if let msg = toxicMessages.randomElement() {
            NotificationCenter.default.post(name: .niumaTriggerBroadcast, object: msg)
        }
    }

    private func tickGuard() {
        let now = Date()
        let today = todayString()

        if let lunchStart = todayAt(settings.lunchStart) {
            let remindTime = lunchStart.addingTimeInterval(-Double(settings.offWorkReminderMinutes) * 60)
            if now >= remindTime && now < lunchStart && !lunchEarlyNotified && settings.offWorkReminderMinutes > 0 {
                lunchEarlyNotified = true; triggerBroadcast()
            }
        }

        if let lunch = todayAt(settings.lunchStart), now >= lunch, now < lunch.addingTimeInterval(30*60), !lunchNotified {
            lunchNotified = true; triggerBroadcast()
        }

        if let end = todayAt(settings.workEnd) {
            let remindTime = end.addingTimeInterval(-Double(settings.offWorkReminderMinutes) * 60)
            if now >= remindTime && now < end && !offWorkNotified && settings.offWorkReminderMinutes > 0 {
                offWorkNotified = true; triggerBroadcast()
            }
        }

        if let off = todayAt(settings.workEnd), now >= off, !locked {
            locked = true
            if !overtime.contains(today) && !punctual.contains(today) { overtime.append(today); save() }
            triggerBroadcast()
            
            if autoLockScreen {
                let task = Process()
                task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
                task.arguments = ["-b", "com.apple.ScreenSaver.Engine"]
                try? task.run()
            }
        }

        let pos = NSEvent.mouseLocation
        let moved = pos != lastMouse && lastMouse != .zero
        lastMouse = pos

        if locked && moved && mouseJitter && now.timeIntervalSince(lastJitter) > 2 {
            let loc = NSEvent.mouseLocation
            let move = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: CGPoint(x: loc.x + 10, y: loc.y + 10), mouseButton: .left)
            move?.post(tap: .cghidEventTap)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let back = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: loc, mouseButton: .left)
                back?.post(tap: .cghidEventTap)
            }
            lastJitter = now
        }
        
        if let start = todayAt(settings.workStart), now < start {
            locked = false; lunchNotified = false; lunchEarlyNotified = false; offWorkNotified = false
        }
    }
}
