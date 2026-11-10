import Foundation
import AppKit

enum DayOverride: String, Codable {
    case none, leave, makeup
}

@MainActor
final class Settings {
    static let shared = Settings()

    var appName = "牛马脱敏器"
    var monthlySalary: Double = 15000
    var workdays: Set<Int> = [2,3,4,5,6]
    var workStart: (Int, Int) = (9, 0)
    var workEnd: (Int, Int) = (18, 0)
    var lunchStart: (Int, Int) = (12, 0)
    var lunchEnd: (Int, Int) = (13, 0)
    var payday = 15
    var decimalPlaces = 5
    var selectedCurrency: Currency = .cny
    var language: AppLanguage = .zh
    var windowPosition: NSPoint?

    // 守卫配置
    var offWorkReminderMinutes: Int = 30
    var healthReminderMinutes: Int = 30
    var healthReminderDuration: Int = 8 // 横幅显示秒数

    var dailySalary: Double {
        let cal = Calendar.current
        let now = Date()
        let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: now))!
        let days = cal.range(of: .day, in: .month, for: monthStart)?.count ?? 30
        var workdaysInMonth = 0
        for d in 1...days {
            if let date = cal.date(byAdding: .day, value: d - 1, to: monthStart) {
                let wd = cal.component(.weekday, from: date)
                if workdays.contains(wd) { workdaysInMonth += 1 }
            }
        }
        return monthlySalary / Double(max(1, workdaysInMonth))
    }

    var dayOverrides: [Date: DayOverride] = [:]

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("NiuMa", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("settings.json")
    }()

    private struct Stored: Codable {
        var appName: String
        var monthlySalary: Double
        var workdays: [Int]
        var workStart: [Int]
        var workEnd: [Int]
        var lunchStart: [Int]
        var lunchEnd: [Int]
        var payday: Int
        var decimalPlaces: Int
        var selectedCurrency: String
        var language: String?
        var windowX: Double?
        var windowY: Double?
        var offWorkReminderMinutes: Int?
        var healthReminderMinutes: Int?
        var healthReminderDuration: Int?
    }

    private init() { load() }

    func save() {
        let s = Stored(
            appName: appName,
            monthlySalary: monthlySalary,
            workdays: Array(workdays),
            workStart: [workStart.0, workStart.1],
            workEnd: [workEnd.0, workEnd.1],
            lunchStart: [lunchStart.0, lunchStart.1],
            lunchEnd: [lunchEnd.0, lunchEnd.1],
            payday: payday,
            decimalPlaces: decimalPlaces,
            selectedCurrency: selectedCurrency.rawValue,
            language: language.rawValue,
            windowX: windowPosition.map { Double($0.x) },
            windowY: windowPosition.map { Double($0.y) },
            offWorkReminderMinutes: offWorkReminderMinutes,
            healthReminderMinutes: healthReminderMinutes,
            healthReminderDuration: healthReminderDuration
        )
        if let data = try? JSONEncoder().encode(s) {
            try? data.write(to: fileURL)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let s = try? JSONDecoder().decode(Stored.self, from: data) else { return }
        appName = s.appName
        monthlySalary = s.monthlySalary
        workdays = Set(s.workdays)
        workStart = (s.workStart[0], s.workStart[1])
        workEnd = (s.workEnd[0], s.workEnd[1])
        lunchStart = (s.lunchStart[0], s.lunchStart[1])
        lunchEnd = (s.lunchEnd[0], s.lunchEnd[1])
        payday = s.payday
        decimalPlaces = s.decimalPlaces
        if let c = Currency(rawValue: s.selectedCurrency) { selectedCurrency = c }
        if let l = s.language, let lang = AppLanguage(rawValue: l) { language = lang }
        if let x = s.windowX, let y = s.windowY {
            windowPosition = NSPoint(x: CGFloat(x), y: CGFloat(y))
        }
        if let off = s.offWorkReminderMinutes { offWorkReminderMinutes = off }
        if let health = s.healthReminderMinutes { healthReminderMinutes = health }
        if let duration = s.healthReminderDuration { healthReminderDuration = duration }
    }
}
