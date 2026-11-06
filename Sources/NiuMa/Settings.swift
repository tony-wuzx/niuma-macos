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
    var quotes: [String] = [
        "每一秒都在到账，每一分都是牛马的勋章。",
        "你不是在打工，你是在为老板的梦想添砖加瓦。",
        "工资不是老板给的，是你用时间换的。",
        "今天也是努力成为更好牛马的一天。"
    ]
    var windowPosition: NSPoint?

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
        var quotes: [String]
        var windowX: Double?
        var windowY: Double?
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
            quotes: quotes,
            windowX: windowPosition.map { Double($0.x) },
            windowY: windowPosition.map { Double($0.y) }
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
        if let c = Currency(rawValue: s.selectedCurrency) {
            selectedCurrency = c
        }
        quotes = s.quotes
        if let x = s.windowX, let y = s.windowY {
            windowPosition = NSPoint(x: CGFloat(x), y: CGFloat(y))
        }
    }
}
