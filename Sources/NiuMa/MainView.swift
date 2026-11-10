import SwiftUI

struct MainView: View {
    @ObservedObject var engine: SalaryEngine
    @ObservedObject private var rateManager = ExchangeRateManager.shared
    @ObservedObject private var niumaGuard = NiuMaGuardManager.shared
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
    
    @ViewBuilder
    private var runIconView: some View {
        let todayStr = engine.dateStr
        let isPunctual = niumaGuard.punctual.contains(todayStr)
        
        let now = Date()
        let cal = Calendar.current
        let today = cal.startOfDay(for: now)
        let end = cal.date(bySettingHour: settings.workEnd.0, minute: settings.workEnd.1, second: 0, of: today) ?? now
        let isOvertime = now >= end
        
        let color: Color = isPunctual ? .green : (isOvertime ? .red : .secondary)
        
        Button {
            niumaGuard.togglePunctual()
        } label: {
            Image(systemName: "figure.run")
                .font(.system(size: 15, weight: isPunctual ? .bold : .regular))
                .foregroundColor(color)
        }
        .buttonStyle(.plain)
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
                    
                    HStack(spacing: 10) {
                        runIconView
                        
                        Button { NiuMaGuardReportWindowController.shared.showWindow() } label: {
                            Image(systemName: "calendar")
                        }
                        
                        Divider().frame(height: 12)

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
                        
                        // 一键退出
                        Button { NSApp.terminate(nil) } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .font(.system(size: 14))
                }

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
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L10n.speed(money(engine.perSecond, decimals: 4), money(engine.perMinute, decimals: 2)))
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            
                            Text(wishMessage)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
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

                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.hourlyMinutely(money(engine.perHour, decimals: 2), money(engine.perMinute, decimals: 3)))
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            Text("\(L10n.fullDayPay) \(money(settings.dailySalary, decimals: 2))")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }

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
        .overlay(alignment: .top) {
            if engine.showHealthReminder {
                HStack {
                    Text(engine.healthMessage)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(colors: [.pink, .purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(10)
                .shadow(color: .purple.opacity(0.4), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 8)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(width: 340, height: engine.isCollapsed ? 160 : 480)
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
