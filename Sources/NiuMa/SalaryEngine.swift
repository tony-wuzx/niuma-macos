import Foundation
import Combine

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
    
    // 时间显示
    @Published var dateStr: String = ""
    @Published var timeStr: String = ""
    @Published var weekdayStr: String = ""
    
    // 工作时长显示
    @Published var workedHoursStr: String = "0.00"
    @Published var totalHoursStr: String = "0.00"

    @Published var maskAmount = false
    @Published var clickThrough = false
    @Published var miniMode = false

    private let settings = Settings.shared
    private var timer: Timer?
    private var quoteTimer: Timer?
    private var lastQuoteIndex = -1

    func start() {
        tick()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        rotateQuote()
        // 一分钟轮换一次
        quoteTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.rotateQuote() }
        }
    }

    func stop() {
        timer?.invalidate()
        quoteTimer?.invalidate()
    }

    private func tick() {
        let now = Date()
        let cal = Calendar.current
        
        // 更新时间信息
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        dateStr = df.string(from: now)
        
        df.dateFormat = "HH:mm:ss"
        timeStr = df.string(from: now)
        
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        let wd = cal.component(.weekday, from: now)
        weekdayStr = "周" + weekdays[wd - 1]
        
        let today = cal.startOfDay(for: now)
        let override = settings.dayOverrides[today] ?? .none
        let effectiveWorkday = override == .leave ? false : (override == .makeup ? true : settings.workdays.contains(wd))

        guard effectiveWorkday else {
            statusText = "休息日"
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
            statusText = "还没上班"
            todayEarned = 0
            progress = 0
            countdownText = "距上班 " + formatCountdown(start.timeIntervalSince(now))
            workedHoursStr = "0.00"
            return
        }

        if now >= end {
            statusText = "已下班"
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
            statusText = "上班中"
        } else if clampedNow < lunchEnd {
            worked = lunchStart.timeIntervalSince(start)
            statusText = "午休中"
        } else {
            worked = lunchStart.timeIntervalSince(start) + clampedNow.timeIntervalSince(lunchEnd)
            statusText = now > end ? "已下班" : "上班中"
        }

        todayEarned = perSecond * worked
        progress = worked / secondsPerDay
        workedHoursStr = String(format: "%.2f", worked / 3600)
        countdownText = "距离下班还有 " + formatCountdown(end.timeIntervalSince(now))

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
        return String(format: "%d小时%02d分%02d秒", s / 3600, (s % 3600) / 60, s % 60)
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
        // 组合生成近万条毒鸡汤，每次随机拼装一条
        let prefixes = ["今天的你，", "不要抱怨，", "加油打工人，", "每一秒的坚持，", "看看余额，", "想想房租，", "记住，"]
        let middles = ["又为老板的新车贡献了一个轮毂", "你的努力正在让老板换更大的别墅", "每一分钱都在为别人的财富自由添砖加瓦", "只要够努力，老板明年就能换保时捷", "你的汗水是公司上市敲钟的基石", "你的福报正在路上", "公司没你不行，但没老板更不行"]
        let suffixes = ["稳住，我们能赢。", "继续干，不要停。", "牛马永不服输！", "这就是生活的意义。", "加油，明天会更好。"]
        
        let p = prefixes.randomElement() ?? "今天的你，"
        let m = middles.randomElement() ?? ""
        let s = suffixes.randomElement() ?? ""
        quote = "\(p)\(m)，\(s)"
    }
}
