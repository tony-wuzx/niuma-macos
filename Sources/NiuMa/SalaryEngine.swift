import Foundation
import Combine
import SwiftUI

@MainActor
final class SalaryEngine: ObservableObject {
    @Published var todayEarned: Double = 0
    @Published var statusText: String = "休息中"
    @Published var countdownText: String = ""
    @Published var progress: Double = 0
    @Published var perSecond: Double = 0
    @Published var perMinute: Double = 0
    @Published var perHour: Double = 0
    @Published var monthlyTotal: Double = 0
    @Published var daysToPayday: Int = 0
    @Published var quote: String = ""
    
    @Published var dateStr: String = ""
    @Published var timeStr: String = ""
    @Published var weekdayStr: String = ""
    
    @Published var workedHoursStr: String = "0.00"
    @Published var totalHoursStr: String = "0.00"

    @Published var maskAmount = false
    @Published var lastHealthTriggerTime: Date = .distantPast
    @Published var clickThrough = false
    @Published var isCollapsed = false

    @Published var showHealthReminder = false
    @Published var healthMessage = ""

    private let settings = Settings.shared
    private var timer: Timer?
    private var quoteTimer: Timer?
    private var healthTimer: Timer?
    private var dismissTimer: Timer?

    func start() {
        tick()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        rotateQuote()
        quoteTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.rotateQuote() }
        }
        
        print("🚀 [SalaryEngine] 引擎启动，准备初始化摸鱼定时器...")
        setupHealthTimer()
    }

    func setupHealthTimer() {
        healthTimer?.invalidate()
        
        // 读取配置
        let minutes = settings.healthReminderMinutes
        print("🔧 [NiuMa] 读取到摸鱼提醒配置: \(minutes) 分钟")
        
        if minutes <= 0 {
            print("❌ [NiuMa] 配置为 0 或负数，定时器不启动。请去设置界面改成 1 分钟并保存。")
            return
        }
        
        // 为了防止是秒数还是分钟数的逻辑错误，直接按分钟算
        let interval = TimeInterval(minutes * 60)
        print("✅ [NiuMa] 摸鱼定时器已成功启动！间隔: \(interval) 秒")
        
        healthTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { 
                print("⏰ [NiuMa] 摸鱼时间到，触发广播！")
                self?.triggerHealthReminder() 
            }
        }
    }

    func stop() {
        timer?.invalidate()
        quoteTimer?.invalidate()
        healthTimer?.invalidate()
        dismissTimer?.invalidate()
    }

    func triggerHealthReminder() {
        // 强制使用摸鱼健康文案
        healthMessage = HealthReminder.getRandomMessage()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showHealthReminder = true
        }
        
        let duration = Double(max(1, settings.healthReminderDuration))
        
        dismissTimer?.invalidate()
        dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated {
                withAnimation(.easeOut) {
                    self?.showHealthReminder = false
                }
            }
        }
    }
    
    func dismissHealthReminder() {
        dismissTimer?.invalidate()
        withAnimation {
            showHealthReminder = false
        }
    }

    private func tick() {
        let now = Date()
        let cal = Calendar.current
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        dateStr = df.string(from: now)
        
        df.dateFormat = "HH:mm:ss"
        timeStr = df.string(from: now)
        
        let weekdays = L10n.isEn ? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] : ["日", "一", "二", "三", "四", "五", "六"]
        let wd = cal.component(.weekday, from: now)
        weekdayStr = L10n.isEn ? weekdays[wd - 1] : "周" + weekdays[wd - 1]
        
        let today = cal.startOfDay(for: now)
        let override = settings.dayOverrides[today] ?? .none
        let effectiveWorkday = override == .leave ? false : (override == .makeup ? true : settings.workdays.contains(wd))

        guard effectiveWorkday else {
            statusText = L10n.statusHoliday
            todayEarned = 0
            perSecond = 0; perMinute = 0; perHour = 0; progress = 0
            countdownText = ""
            return
        }

        let start = dateAt(settings.workStart, on: today)
        let end   = dateAt(settings.workEnd, on: today)
        let lunchStart = dateAt(settings.lunchStart, on: today)
        let lunchEnd   = dateAt(settings.lunchEnd, on: today)

        let secondsPerDay = dailyWorkSeconds()
        totalHoursStr = String(format: "%.2f", secondsPerDay / 3600)
        
        perSecond = settings.dailySalary / secondsPerDay
        perMinute = perSecond * 60
        perHour = perSecond * 3600

        if now < start {
            statusText = L10n.statusBeforeWork
            todayEarned = 0
            progress = 0
            countdownText = L10n.countdownToStart(formatCountdown(start.timeIntervalSince(now)))
            workedHoursStr = "0.00"
            return
        }

        if now >= end {
            statusText = L10n.statusOffWork
            todayEarned = settings.dailySalary
            progress = 1
            countdownText = ""
            workedHoursStr = totalHoursStr
            return
        }

        var worked: TimeInterval = 0
        let clampedNow = min(now, end)

        if clampedNow <= lunchStart {
            worked = clampedNow.timeIntervalSince(start)
            statusText = L10n.statusWorking
        } else if clampedNow < lunchEnd {
            worked = lunchStart.timeIntervalSince(start)
            statusText = L10n.statusResting
        } else {
            worked = lunchStart.timeIntervalSince(start) + clampedNow.timeIntervalSince(lunchEnd)
            statusText = now > end ? L10n.statusOffWork : L10n.statusWorking
        }

        todayEarned = perSecond * worked
        progress = worked / secondsPerDay
        workedHoursStr = String(format: "%.2f", worked / 3600)
        countdownText = L10n.countdownToOff(formatCountdown(end.timeIntervalSince(now)))

        monthlyTotal = estimateMonthly(now: now)
        daysToPayday = daysUntilPayday(now: now)
    }

    private func dailyWorkSeconds() -> TimeInterval {
        let cal = Calendar.current
        let d = cal.startOfDay(for: Date())
        let start = dateAt(settings.workStart, on: d)
        let end   = dateAt(settings.workEnd, on: d)
        let ls = dateAt(settings.lunchStart, on: d)
        let le = dateAt(settings.lunchEnd, on: d)
        return end.timeIntervalSince(start) - le.timeIntervalSince(ls)
    }

    private func dateAt(_ hm: (Int, Int), on day: Date) -> Date {
        let cal = Calendar.current
        return cal.date(bySettingHour: hm.0, minute: hm.1, second: 0, of: day) ?? day
    }

    private func formatCountdown(_ t: TimeInterval) -> String {
        let s = max(0, Int(t))
        if L10n.isEn {
            return String(format: "%02dh %02dm %02ds", s / 3600, (s % 3600) / 60, s % 60)
        } else {
            return String(format: "%d小时%02d分%02d秒", s / 3600, (s % 3600) / 60, s % 60)
        }
    }

    private func estimateMonthly(now: Date) -> Double {
        let cal = Calendar.current
        let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: now))!
        let day = cal.component(.day, from: now)
        var workdays = 0
        for d in 1...day {
            if let date = cal.date(byAdding: .day, value: d - 1, to: monthStart) {
                let wd = cal.component(.weekday, from: date)
                if settings.workdays.contains(wd) { workdays += 1 }
            }
        }
        return Double(workdays) * settings.dailySalary
    }

    private func daysUntilPayday(now: Date) -> Int {
        let cal = Calendar.current
        let day = cal.component(.day, from: now)
        let target = settings.payday
        if target >= day { return target - day }
        guard let nextMonth = cal.date(byAdding: .month, value: 1, to: now) else { return 0 }
        let daysInNext = cal.range(of: .day, in: .month, for: nextMonth)?.count ?? 30
        return (daysInNext - day) + target
    }

    private func rotateQuote() {
        quote = ZombieQuotes.generate()
    }
}
