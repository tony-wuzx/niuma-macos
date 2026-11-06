import SwiftUI

struct MainView: View {
    @ObservedObject var engine: SalaryEngine
    @ObservedObject private var rateManager = ExchangeRateManager.shared
    private let settings = Settings.shared

    private var effectiveDecimals: Int {
        if let fixed = settings.selectedCurrency.suggestedDecimals { return fixed }
        return settings.decimalPlaces
    }

    private func money(_ cny: Double, decimals: Int? = nil) -> String {
        let val = rateManager.convert(cnyAmount: cny, to: settings.selectedCurrency)
        let d = decimals ?? effectiveDecimals
        return "\(settings.selectedCurrency.symbol)\(String(format: "%.\(d)f", val))"
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 毛玻璃背景
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)

            VStack(alignment: .leading, spacing: 12) {
                // 顶部：日期 / 时间 / 右上角操作按钮
                HStack(alignment: .top) {
                    Text("\(engine.dateStr) \(engine.weekdayStr) \(engine.timeStr)")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                    
                    Spacer()
                    
                    // 快捷操作按钮 (原版中的图标)
                    HStack(spacing: 12) {
                        Button { engine.maskAmount.toggle() } label: {
                            Image(systemName: engine.maskAmount ? "eye.slash" : "eye")
                        }
                        Button { engine.miniMode.toggle() } label: {
                            Image(systemName: "arrow.down.right.and.arrow.up.left")
                        }
                        Button { SettingsWindowController.shared.showWindow(engine: engine) } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .font(.system(size: 16))
                }
                .padding(.bottom, 4)
                
                // 状态大字
                Text(engine.statusText)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.blue.opacity(0.85))
                
                if !engine.countdownText.isEmpty {
                    Text(engine.countdownText)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                }
                
                // 今日已赚
                VStack(alignment: .leading, spacing: 2) {
                    Text("今日已赚")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    
                    OdometerText(
                        value: rateManager.convert(cnyAmount: engine.todayEarned, to: settings.selectedCurrency),
                        decimals: effectiveDecimals,
                        symbol: settings.selectedCurrency.symbol,
                        masked: engine.maskAmount
                    )
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.orange)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                }

                // 速度 + 心愿单
                VStack(alignment: .leading, spacing: 6) {
                    Text("当前赚钱速度 \(money(engine.perSecond, decimals: 4)) / 秒 · \(money(engine.perMinute, decimals: 2)) / 分钟")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    
                    // 心愿单（T恤）
                    let tShirtPrice: Double = 100.0
                    if engine.todayEarned >= tShirtPrice {
                        Text("今天已经赚到一件T恤了，稳住。")
                            .font(.system(size: 15, weight: .medium))
                    } else {
                        Text("距离一件T恤还差 \(money(tShirtPrice - engine.todayEarned, decimals: 2))")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 2)

                // 工时进度
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("今日工时进度 \(String(format: "%.1f", engine.progress * 100))%")
                            .font(.system(size: 14))
                        Spacer()
                        Text("\(engine.workedHoursStr) / \(engine.totalHoursStr) 小时")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: engine.progress)
                        .tint(Color.orange)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                }
                .padding(.top, 4)
                
                Divider()

                // 本月累计
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("本月累计")
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                        Text(money(engine.monthlyTotal, decimals: 2))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.blue.opacity(0.85))
                    }
                    
                    Text("已过的工作日按满勤计，本月满勤约 \(money(engine.monthlyTotal, decimals: 0)) · 距离发薪日还有 \(engine.daysToPayday) 天")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // 时薪 / 分薪 / 满勤
                VStack(alignment: .leading, spacing: 4) {
                    Text("时薪 \(money(engine.perHour, decimals: 2)) · 分薪 \(money(engine.perMinute, decimals: 3))")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Text("今日满勤可得 \(money(settings.dailySalary, decimals: 2))")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                // 底部毒鸡汤
                HStack {
                    Spacer()
                    Text("\"\(engine.quote)\"")
                        .font(.system(size: 13, weight: .medium))
                        .italic()
                        .foregroundStyle(Color.green.opacity(0.8))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .padding(.bottom, 4)
            }
            .padding(20)
        }
        .frame(width: 380, height: engine.miniMode ? 100 : 580)
        // 移除原来的双击，改用右上角按钮
        .contextMenu {
            Button("显示/隐藏金额") { engine.maskAmount.toggle() }
            Button("鼠标穿透") {
                engine.clickThrough.toggle()
                NSApp.keyWindow?.ignoresMouseEvents = engine.clickThrough
            }
            Button("标记今天为请假") { markOverride(.leave) }
            Button("标记今天为补班") { markOverride(.makeup) }
            Divider()
            Button("设置…") { SettingsWindowController.shared.showWindow(engine: engine) }
            Button("退出") { NSApp.terminate(nil) }
        }
        .if(engine.miniMode) { view in
            view.opacity(0)
        }
    }

    private func markOverride(_ o: DayOverride) {
        let today = Calendar.current.startOfDay(for: Date())
        settings.dayOverrides[today] = o
        settings.save()
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct OdometerText: View {
    let value: Double
    let decimals: Int
    let symbol: String
    let masked: Bool

    @State private var displayed: Double = 0

    var body: some View {
        Text(masked ? "****" : "\(symbol)\(String(format: "%.\(decimals)f", displayed))")
            .monospacedDigit()
            .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
                guard !masked else { return }
                let diff = value - displayed
                if abs(diff) < 0.00001 {
                    displayed = value
                } else {
                    displayed += diff * 0.15
                }
            }
    }
}
