import SwiftUI
import AppKit

@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()
    private var window: NSWindow?

    func showWindow(engine: SalaryEngine) {
        if window == nil {
            let view = SettingsView()
            let hosting = NSHostingView(rootView: view)
            // 稍微放宽一点默认宽度
            let w = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 540, height: 680),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            w.title = "牛马脱敏器 · 设置"
            w.contentView = hosting
            w.center()
            w.isReleasedWhenClosed = false
            // 限制最小尺寸，防止被缩得太小
            w.minSize = NSSize(width: 480, height: 600)
            window = w
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct SettingsView: View {
    private let s = Settings.shared
    @ObservedObject private var rateManager = ExchangeRateManager.shared

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
    @State private var decimalPlaces: Int = 5
    @State private var workdays: Set<Int> = []
    @State private var quotesText: String = ""

    var body: some View {
        Form {
            Section("薪资") {
                TextField("月薪（人民币）", value: $monthlySalary, format: .number)
                    .onChange(of: monthlySalary) { v in
                        s.monthlySalary = v; s.save()
                    }
                Stepper("发薪日：\(payday) 号", value: $payday, in: 1...28)
                    .onChange(of: payday) { v in
                        s.payday = v; s.save()
                    }
                Text("当前日薪约：\(String(format: "%.2f", s.dailySalary)) 元")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("工作时间") {
                timeRow("上班", hour: $workStartHour, minute: $workStartMin) {
                    s.workStart = (workStartHour, workStartMin); s.save()
                }
                timeRow("下班", hour: $workEndHour, minute: $workEndMin) {
                    s.workEnd = (workEndHour, workEndMin); s.save()
                }
                timeRow("午休开始", hour: $lunchStartHour, minute: $lunchStartMin) {
                    s.lunchStart = (lunchStartHour, lunchStartMin); s.save()
                }
                timeRow("午休结束", hour: $lunchEndHour, minute: $lunchEndMin) {
                    s.lunchEnd = (lunchEndHour, lunchEndMin); s.save()
                }
            }

            Section("显示货币") {
                Picker("货币", selection: $selectedCurrency) {
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
                        Text("汇率更新于 \(t.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption).foregroundStyle(.secondary)
                    } else {
                        Text("暂无汇率数据")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    // 缩短按钮文字
                    Button(rateManager.isLoading ? "刷新中" : "刷新") {
                        Task { await rateManager.fetchRates() }
                    }
                    .controlSize(.small)
                    .disabled(rateManager.isLoading)
                }

                Stepper("小数位数：\(decimalPlaces)", value: $decimalPlaces, in: 0...6)
                    .onChange(of: decimalPlaces) { v in
                        s.decimalPlaces = v; s.save()
                    }
                Text("提示：日元固定显示 0 位小数")
                    .font(.caption2).foregroundStyle(.tertiary)
            }

            Section("工作日") {
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

            Section("毒鸡汤（每行一条）") {
                TextEditor(text: $quotesText)
                    .frame(height: 100)
                    .onChange(of: quotesText) { v in
                        s.quotes = v.components(separatedBy: "\n").filter { !$0.isEmpty }
                        s.save()
                    }
            }
        }
        // 关键：使用 grouped 样式，它会自动适配宽度
        .formStyle(.grouped)
        .onAppear { loadFromSettings() }
        // 去掉了原有的 .frame(width:height:) 强制尺寸，让窗口自适应拉伸
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
        decimalPlaces = s.decimalPlaces
        workdays = s.workdays
        quotesText = s.quotes.joined(separator: "\n")
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
        ["日","一","二","三","四","五","六"][wd - 1]
    }
}
