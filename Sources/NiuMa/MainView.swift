import SwiftUI

struct MainView: View {
    @ObservedObject var engine: SalaryEngine
    @ObservedObject private var rateManager = ExchangeRateManager.shared
    private let settings = Settings.shared

    @State private var wishMessage: String = ""
    let wishTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

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
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)

            VStack(alignment: .leading, spacing: 10) {
                // 顶部
                HStack(alignment: .center) {
                    Text("\(engine.dateStr) \(engine.weekdayStr) \(engine.timeStr)")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button { engine.maskAmount.toggle() } label: {
                            Image(systemName: engine.maskAmount ? "eye.slash" : "eye")
                        }
                        Button { 
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                engine.isCollapsed.toggle() 
                            }
                        } label: {
                            Image(systemName: engine.isCollapsed ? "chevron.down" : "chevron.up")
                        }
                        Button { SettingsWindowController.shared.showWindow(engine: engine) } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .font(.system(size: 14))
                }

                // 状态行
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(engine.statusText)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.blue.opacity(0.85))
                    
                    if !engine.countdownText.isEmpty {
                        Text(engine.countdownText)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }

                // 金额
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.todayEarned)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    
                    OdometerText(
                        value: rateManager.convert(cnyAmount: engine.todayEarned, to: settings.selectedCurrency),
                        decimals: effectiveDecimals,
                        symbol: settings.selectedCurrency.symbol,
                        masked: engine.maskAmount
                    )
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.orange)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                }
                .padding(.top, -4)

                if !engine.isCollapsed {
                    VStack(alignment: .leading, spacing: 12) {
                        // 速度 + 心愿单
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L10n.speed(money(engine.perSecond, decimals: 4), money(engine.perMinute, decimals: 2)))
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            
                            // 注意这里：去掉了 lineLimit(2)，改成 fixedSize 让文字自动撑开换行
                            Text(wishMessage)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // 进度条
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("\(L10n.progress) \(String(format: "%.1f", engine.progress * 100))%")
                                    .font(.system(size: 12))
                                Spacer()
                                Text("\(engine.workedHoursStr) / \(engine.totalHoursStr) h")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            ProgressView(value: engine.progress)
                                .tint(Color.orange)
                                .scaleEffect(x: 1, y: 1.2, anchor: .center)
                        }
                        
                        Divider()
                        
                        // 本月累计
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(L10n.monthlyTotal)
                                    .font(.system(size: 14, weight: .bold))
                                Spacer()
                                Text(money(engine.monthlyTotal, decimals: 2))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color.blue.opacity(0.85))
                            }
                            
                            Text(L10n.daysToPayday(engine.daysToPayday))
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }

                        // 时薪 / 分薪 / 满勤
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.hourlyMinutely(money(engine.perHour, decimals: 2), money(engine.perMinute, decimals: 3)))
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            Text("\(L10n.fullDayPay) \(money(settings.dailySalary, decimals: 2))")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }

                        // 底部毒鸡汤
                        HStack {
                            Spacer()
                            Text("\"\(engine.quote)\"")
                                .font(.system(size: 12, weight: .medium))
                                .italic()
                                .foregroundStyle(Color.green.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    Spacer(minLength: 0)
                }
            }
            .padding(16)
        }
        .frame(width: 340, height: engine.isCollapsed ? 160 : 440)
        .onAppear {
            wishMessage = Wishlist.getMessage(earned: engine.todayEarned)
        }
        .onReceive(wishTimer) { _ in
            if !engine.isCollapsed {
                wishMessage = Wishlist.getMessage(earned: engine.todayEarned)
            }
        }
        .contextMenu {
            Button(L10n.isEn ? "Hide Amount" : "隐藏/显示金额") { engine.maskAmount.toggle() }
            Button(L10n.isEn ? "Click Through" : "鼠标穿透") {
                engine.clickThrough.toggle()
                NSApp.keyWindow?.ignoresMouseEvents = engine.clickThrough
            }
            Button(L10n.isEn ? "Mark Leave" : "标记今天为请假") { markOverride(.leave) }
            Button(L10n.isEn ? "Mark Makeup" : "标记今天为补班") { markOverride(.makeup) }
            Divider()
            Button(L10n.isEn ? "Settings..." : "设置…") { SettingsWindowController.shared.showWindow(engine: engine) }
            Button(L10n.isEn ? "Quit" : "退出") { NSApp.terminate(nil) }
        }
    }

    private func markOverride(_ o: DayOverride) {
        let today = Calendar.current.startOfDay(for: Date())
        settings.dayOverrides[today] = o
        settings.save()
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
