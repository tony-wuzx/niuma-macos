import SwiftUI
import AppKit

@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()
    private var window: NSWindow?
    private var engineRef: SalaryEngine?

    func showWindow(engine: SalaryEngine) {
        self.engineRef = engine
        if window == nil {
            let view = SettingsView(engine: engine)
            let hosting = NSHostingView(rootView: view)
            let w = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 540, height: 820),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            w.title = "设置"
            w.contentView = hosting
            w.standardWindowButton(.miniaturizeButton)?.isHidden = true
            w.standardWindowButton(.zoomButton)?.isHidden = true
            w.standardWindowButton(.miniaturizeButton)?.isHidden = true
            w.standardWindowButton(.zoomButton)?.isHidden = true
            w.center()
            w.isReleasedWhenClosed = false
            w.minSize = NSSize(width: 480, height: 700)
            window = w
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct SettingsView: View {
    var engine: SalaryEngine
    private let s = Settings.shared
    @ObservedObject private var rateManager = ExchangeRateManager.shared
    @ObservedObject private var niumaGuard = NiuMaGuardManager.shared

    @State private var monthlySalary: Double = 15000
    @State private var payday: Int = 15
    @State private var workStartHour: Int = 9
    @State private var workStartMin: Int = 0
    @State private var workEndHour: Int = 18
    @State private var workEndMin: Int = 0
    @State private var lunchStartHour: Int = 12
    @State private var lunchStartMin: Int = 0
    @State private var lunchEndHour: Int = 13
    @State private var lunchEndMin: Int = 0
    @State private var selectedCurrency: Currency = .cny
    @State private var language: AppLanguage = .zh
    @State private var decimalPlaces: Int = 5
    @State private var workdays: Set<Int> = []
    
    @State private var offWorkReminderMinutes: Int = 30
    @State private var healthReminderMinutes: Int = 30
    @State private var healthReminderDuration: Int = 8
    
    var body: some View {
        Form {
            Section("Language / 语言") {
                Picker("Language", selection: $language) {
                    ForEach(AppLanguage.allCases) { l in
                        Text(l.displayName).tag(l)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: language) { v in
                    s.language = v; s.save()
                }
            }

            Section(L10n.isEn ? "Salary" : "薪资") {
                TextField(L10n.isEn ? "Monthly Salary (CNY)" : "月薪（人民币）", value: $monthlySalary, format: .number)
                    .onChange(of: monthlySalary) { v in
                        s.monthlySalary = v; s.save()
                    }
                
                HStack {
                    Text(L10n.isEn ? "Payday (Day)" : "发薪日 (号)")
                    Spacer()
                    Picker("", selection: $payday) {
                        ForEach(1...31, id: \.self) { day in
                            Text("\(day)").tag(day)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
                .onChange(of: payday) { v in
                    s.payday = v; s.save()
                }
                
                Text("\(L10n.isEn ? "Daily approx" : "当前日薪约"): \(String(format: "%.2f", s.dailySalary))")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section(L10n.isEn ? "Work Time" : "工作时间") {
                timeRow(L10n.isEn ? "Start" : "上班", hour: $workStartHour, minute: $workStartMin) {
                    s.workStart = (workStartHour, workStartMin); s.save()
                }
                timeRow(L10n.isEn ? "End" : "下班", hour: $workEndHour, minute: $workEndMin) {
                    s.workEnd = (workEndHour, workEndMin); s.save()
                }
                timeRow(L10n.isEn ? "Lunch Start" : "午休开始", hour: $lunchStartHour, minute: $lunchStartMin) {
                    s.lunchStart = (lunchStartHour, lunchStartMin); s.save()
                }
                timeRow(L10n.isEn ? "Lunch End" : "午休结束", hour: $lunchEndHour, minute: $lunchEndMin) {
                    s.lunchEnd = (lunchEndHour, lunchEndMin); s.save()
                }
            }

            Section("牛马守卫") {
                HStack {
                    Text("下班/午休提前提醒 (分钟)")
                    Spacer()
                    Picker("", selection: $offWorkReminderMinutes) {
                        ForEach(1...30, id: \.self) { min in
                            Text("\(min)").tag(min)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
                .onChange(of: offWorkReminderMinutes) { v in
                    s.offWorkReminderMinutes = v; s.save()
                }

                HStack {
                    Text("摸鱼横幅提醒频率 (分钟)")
                    Spacer()
                    Picker("", selection: $healthReminderMinutes) {
                        ForEach(1...30, id: \.self) { min in
                            Text("\(min)").tag(min)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
                .onChange(of: healthReminderMinutes) { v in
                    s.healthReminderMinutes = v
                    s.save()
                    // 通知 AppDelegate 重启定时器
                    if let appDelegate = NSApp.delegate as? AppDelegate {
                        appDelegate.startHealthTimer()
                    }
                }
                
                HStack {
                    Text("横幅停留时间 (秒)")
                    Spacer()
                    Picker("", selection: $healthReminderDuration) {
                        ForEach(3...10, id: \.self) { sec in
                            Text("\(sec)").tag(sec)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
                .onChange(of: healthReminderDuration) { v in
                    s.healthReminderDuration = v
                    s.save()
                }

                Toggle("到点自动锁屏", isOn: $niumaGuard.autoLockScreen)
                    .onChange(of: niumaGuard.autoLockScreen) { _ in niumaGuard.save() }
                Toggle("锁屏后鼠标晃动调戏", isOn: $niumaGuard.mouseJitter)
                    .onChange(of: niumaGuard.mouseJitter) { _ in niumaGuard.save() }
            }

            Section(L10n.isEn ? "Currency" : "显示货币") {
                Picker("Currency", selection: $selectedCurrency) {
                    ForEach(Currency.allCases) { c in
                        Text("\(c.displayName) \(c.symbol)").tag(c)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedCurrency) { v in
                    s.selectedCurrency = v; s.save()
                }

                HStack {
                    if let t = rateManager.lastUpdated {
                        Text("\(L10n.isEn ? "Updated" : "汇率更新于") \(t.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption).foregroundStyle(.secondary)
                    } else {
                        Text(L10n.isEn ? "No rate data" : "暂无汇率数据")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(rateManager.isLoading ? (L10n.isEn ? "Loading" : "刷新中") : (L10n.isEn ? "Refresh" : "刷新")) {
                        Task { await rateManager.fetchRates() }
                    }
                    .controlSize(.small)
                    .disabled(rateManager.isLoading)
                }

                Stepper("\(L10n.isEn ? "Decimals" : "小数位数"): \(decimalPlaces)", value: $decimalPlaces, in: 0...6)
                    .onChange(of: decimalPlaces) { v in
                        s.decimalPlaces = v; s.save()
                    }
            }

            Section(L10n.isEn ? "Workdays" : "工作日") {
                HStack {
                    ForEach([2,3,4,5,6,7,1], id: \.self) { wd in
                        Toggle(weekdayName(wd), isOn: Binding(
                            get: { workdays.contains(wd) },
                            set: { on in
                                if on { workdays.insert(wd) } else { workdays.remove(wd) }
                                s.workdays = workdays; s.save()
                            }
                        )).toggleStyle(.button)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .onAppear { loadFromSettings() }
    }

    private func loadFromSettings() {
        monthlySalary = s.monthlySalary
        payday = s.payday
        workStartHour = s.workStart.0
        workStartMin = s.workStart.1
        workEndHour = s.workEnd.0
        workEndMin = s.workEnd.1
        lunchStartHour = s.lunchStart.0
        lunchStartMin = s.lunchStart.1
        lunchEndHour = s.lunchEnd.0
        lunchEndMin = s.lunchEnd.1
        selectedCurrency = s.selectedCurrency
        language = s.language
        decimalPlaces = s.decimalPlaces
        workdays = s.workdays
        offWorkReminderMinutes = max(1, s.offWorkReminderMinutes)
        healthReminderMinutes = max(1, s.healthReminderMinutes)
        healthReminderDuration = s.healthReminderDuration
    }

    private func timeRow(_ title: String,
                         hour: Binding<Int>,
                         minute: Binding<Int>,
                         onChange: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
            Spacer()
            Picker("", selection: hour) {
                ForEach(0..<24) { Text(String(format: "%02d", $0)).tag($0) }
            }
            .labelsHidden()
            .frame(width: 70)
            .onChange(of: hour.wrappedValue) { _ in onChange() }

            Text(":")

            Picker("", selection: minute) {
                ForEach(0..<60) { Text(String(format: "%02d", $0)).tag($0) }
            }
            .labelsHidden()
            .frame(width: 70)
            .onChange(of: minute.wrappedValue) { _ in onChange() }
        }
    }

    private func weekdayName(_ wd: Int) -> String {
        if L10n.isEn {
            let names = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
            return names[wd - 1]
        } else {
            return ["日","一","二","三","四","五","六"][wd - 1]
        }
    }
}
