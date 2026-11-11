import SwiftUI

struct MainView: View {
    @ObservedObject var engine: SalaryEngine
    @ObservedObject private var rateManager = ExchangeRateManager.shared
    @ObservedObject private var niumaGuard = NiuMaGuardManager.shared
    private let settings = Settings.shared

    @State private var wishMessage: String = ""
    @State private var currentToxicComment: String = ""
    let wishTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    @State private var isMiniMode: Bool = false
    @State private var isDataReady: Bool = true
    @State private var broadcastMessage: String? = nil

    private var effectiveDecimals: Int {
        if let fixed = settings.selectedCurrency.suggestedDecimals { return fixed }
        return settings.decimalPlaces
    }

    private func money(_ cny: Double, decimals: Int? = nil) -> String {
        let val = rateManager.convert(cnyAmount: cny, to: settings.selectedCurrency)
        let d = decimals ?? effectiveDecimals
        return "\(settings.selectedCurrency.symbol)\(String(format: "%.\(d)f", val))"
    }
    
    private func formatTimeOnly(_ timeStr: String) -> String {
        let comps = timeStr.split(separator: ":")
        if comps.count >= 2 { return "\(comps[0]):\(comps[1])" }
        return timeStr
    }
    
    private func formatCountdownMini(_ text: String) -> String {
        let regex = try! NSRegularExpression(pattern: "(\\d+)小时(\\d+)分", options: [])
        let range = NSRange(location: 0, length: text.utf16.count)
        if let match = regex.firstMatch(in: text, options: [], range: range) {
            let h = (text as NSString).substring(with: match.range(at: 1))
            let m = (text as NSString).substring(with: match.range(at: 2))
            return "\(String(format: "%d", Int(h) ?? 0)):\(String(format: "%02d", Int(m) ?? 0))"
        }
        return text
    }
    
    private func formatCountdownExpanded(_ text: String) -> String {
        let regex = try! NSRegularExpression(pattern: "(\\d+)小时(\\d+)分(\\d+)秒", options: [])
        let range = NSRange(location: 0, length: text.utf16.count)
        if let match = regex.firstMatch(in: text, options: [], range: range) {
            let h = (text as NSString).substring(with: match.range(at: 1))
            let m = (text as NSString).substring(with: match.range(at: 2))
            let s = (text as NSString).substring(with: match.range(at: 3))
            return "\(String(format: "%d", Int(h) ?? 0)):\(String(format: "%02d", Int(m) ?? 0)):\(String(format: "%02d", Int(s) ?? 0))"
        }
        return text
    }

    // 右侧图标组
    @ViewBuilder
    private var actionIcons: some View {
        HStack(spacing: 14) { // 图标间距 14
            Button { engine.maskAmount.toggle() } label: {
                Image(systemName: engine.maskAmount ? "eye.slash" : "eye").font(.system(size: 15))
            }.buttonStyle(.plain)
            
            Button { niumaGuard.togglePunctual() } label: {
                let isPunctual = niumaGuard.punctual.contains(engine.dateStr)
                Image(systemName: "figure.run")
                    .font(.system(size: 15, weight: isPunctual ? .bold : .regular))
                    .foregroundColor(isPunctual ? .green : .secondary)
            }.buttonStyle(.plain)
            
            Button { NiuMaGuardReportWindowController.shared.showWindow() } label: {
                Image(systemName: "calendar").font(.system(size: 15))
            }.buttonStyle(.plain)
            
            Button { 
                if isMiniMode {
                    isDataReady = false
                    withAnimation(.easeInOut(duration: 0.3)) { isMiniMode = false }
                    NotificationCenter.default.post(name: .niumaToggleMiniMode, object: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.easeIn(duration: 0.1)) { isDataReady = true }
                    }
                } else {
                    isDataReady = false
                    withAnimation(.easeInOut(duration: 0.3)) { isMiniMode = true }
                    NotificationCenter.default.post(name: .niumaToggleMiniMode, object: true)
                }
            } label: {
                Image(systemName: isMiniMode ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left")
                    .font(.system(size: 15))
            }.buttonStyle(.plain)
            
            Button { SettingsWindowController.shared.showWindow(engine: engine) } label: {
                Image(systemName: "gearshape").font(.system(size: 15))
            }.buttonStyle(.plain)
        }
        .foregroundStyle(.secondary)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)

            VStack(alignment: .leading, spacing: 0) {
                // ================= 顶部控制栏 =================
                HStack(alignment: .center, spacing: 8) { // 元素垂直居中，间距 12
                    // 左侧关闭按钮
                    Button { NSApp.terminate(nil) } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red.opacity(0.8))
                            .font(.system(size: 16))
                    }.buttonStyle(.plain)
                    
                    // 时间与倒计时
                    Text(isMiniMode ? formatTimeOnly(engine.timeStr) : "\(engine.dateStr) \(engine.weekdayStr) \(formatTimeOnly(engine.timeStr))")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .fixedSize()

                    if isMiniMode {
                        if !engine.countdownText.isEmpty {
                            Text(formatCountdownMini(engine.countdownText))
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .fixedSize()
                        }
                        
                        OdometerText(
                            value: rateManager.convert(cnyAmount: engine.todayEarned, to: settings.selectedCurrency),
                            decimals: effectiveDecimals,
                            symbol: settings.selectedCurrency.symbol,
                            masked: engine.maskAmount
                        )
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.orange)
                        .lineLimit(1)
                        .fixedSize()
                    }

                    Spacer(minLength: 0)
                    actionIcons
                }
                // 🎯 统一控制顶部 Menu Bar 的内边距，让它在小模式和大模式下都极为舒服
                .padding(.horizontal, 16)
                .frame(height: 46) // 死锁 46 高度，绝对垂直居中

                // ================= 展开模式内容 =================
                if !isMiniMode && isDataReady {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // 1. 今日已赚
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L10n.todayEarned).font(.system(size: 15)).foregroundStyle(.secondary)
                            OdometerText(
                                value: rateManager.convert(cnyAmount: engine.todayEarned, to: settings.selectedCurrency),
                                decimals: effectiveDecimals,
                                symbol: settings.selectedCurrency.symbol,
                                masked: engine.maskAmount
                            )
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.orange)
                        }
                        .padding(.top, 8)
                        
                        // 2. 赚了什么
                        Text(wishMessage)
                            .font(.system(size: 15))
                            .foregroundStyle(.primary.opacity(0.8))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(height: 44, alignment: .top)
                        
                        Divider()
                        
                        // 3. 下班倒计时
                        HStack {
                            Text("下班倒计时").font(.system(size: 15)).foregroundStyle(.secondary)
                            Spacer()
                            Text(formatCountdownExpanded(engine.countdownText))
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundStyle(.primary)
                        }
                        
                        Divider()
                        
                        // 4. 进度条
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("今日工时进度 \(String(format: "%.1f", engine.progress * 100))%").font(.system(size: 14))
                                Spacer()
                                Text("\(engine.workedHoursStr) / \(engine.totalHoursStr) h").font(.system(size: 14)).foregroundStyle(.secondary)
                            }
                            ProgressView(value: engine.progress)
                                .tint(Color.orange)
                                .scaleEffect(x: 1, y: 1.4, anchor: .center)
                        }
                        
                        Divider()
                        
                        // 5. 本月累计
                        HStack {
                            Text(L10n.monthlyTotal).font(.system(size: 15, weight: .bold))
                            Spacer()
                            Text(money(engine.monthlyTotal, decimals: 2))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.orange)
                        }
                        
                        // 6. 距离发薪日
                        HStack {
                            Text(L10n.daysToPayday(engine.daysToPayday)).font(.system(size: 14)).foregroundStyle(.secondary)
                            Spacer()
                        }
                        
                        Divider()
                        
                        // 7. 时薪/分薪/满勤
                        HStack {
                            Text("时薪 \(money(engine.perHour, decimals: 2))").font(.system(size: 13)).foregroundStyle(.secondary)
                            Text("·").foregroundStyle(.secondary)
                            Text("分薪 \(money(engine.perMinute, decimals: 3))").font(.system(size: 13)).foregroundStyle(.secondary)
                            Spacer()
                            Text("今日满勤 \(money(settings.dailySalary, decimals: 2))").font(.system(size: 13)).foregroundStyle(.secondary)
                        }
                        
                        Spacer(minLength: 0)
                        
                        // 8. 吐槽文字
                        HStack {
                            Spacer()
                            Text("\"\(currentToxicComment)\"")
                                .font(.system(size: 16, weight: .semibold))
                                .italic()
                                .foregroundStyle(Color.cyan.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(height: 50, alignment: .center)
                            Spacer()
                        }
                        .padding(.bottom, 27)
                    }
                    .padding(.horizontal, 16)
                    .transition(.opacity)
                }
            }
            
            // ================= 跑马灯蒙版 =================
            if let message = broadcastMessage {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.85))
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                BroadcastTextView(text: message, isMiniMode: isMiniMode)
                    .transition(.opacity)
            }
        }
        // 🎯 窗口尺寸死锁：小模式 46，大模式 615
        .frame(width: 380, height: isMiniMode ? 46 : 625, alignment: .top)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear { 
            wishMessage = Wishlist.getMessage(earned: engine.todayEarned)
            currentToxicComment = ZombieQuotes.generate()
            if !isMiniMode { isDataReady = true }
        }
        .onReceive(wishTimer) { _ in 
            if !isMiniMode { 
                wishMessage = Wishlist.getMessage(earned: engine.todayEarned)
                currentToxicComment = ZombieQuotes.generate()
            } 
        }
        .onReceive(NotificationCenter.default.publisher(for: .niumaTriggerBroadcast)) { notif in
            if let text = notif.object as? String {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { 
                    self.broadcastMessage = text 
                }
                let stayDuration = Double(settings.healthReminderDuration)
                DispatchQueue.main.asyncAfter(deadline: .now() + stayDuration) {
                    withAnimation(.easeOut(duration: 0.3)) { self.broadcastMessage = nil }
                }
            }
        }
    }
}

struct BroadcastTextView: View {
    let text: String
    let isMiniMode: Bool
    @State private var offset: CGFloat = 0
    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 380

    var body: some View {
        GeometryReader { geo in
            let displayString = "🚨 \(text) 🚨"
            Text(displayString)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.orange)
                .multilineTextAlignment(.center)
                .lineLimit(isMiniMode ? 1 : nil)
                .fixedSize(horizontal: isMiniMode ? true : false, vertical: true)
                .background(GeometryReader { textGeo in
                    Color.clear.onAppear {
                        textWidth = textGeo.size.width
                        containerWidth = geo.size.width
                        if isMiniMode && textWidth > containerWidth { startMarquee() }
                    }
                })
                .frame(width: geo.size.width, height: geo.size.height, alignment: (isMiniMode && textWidth > containerWidth) ? .leading : .center)
                .offset(x: (isMiniMode && textWidth > containerWidth) ? offset : 0)
        }
        .padding(.horizontal, isMiniMode ? 0 : 24)
    }

    private func startMarquee() {
        offset = containerWidth
        let duration = Double(containerWidth + textWidth) / 80.0
        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) { offset = -textWidth }
    }
}

extension Notification.Name {
    static let niumaToggleMiniMode = Notification.Name("niumaToggleMiniMode")
    static let niumaTriggerBroadcast = Notification.Name("niumaTriggerBroadcast")
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
                if abs(diff) < 0.00001 { displayed = value } else { displayed += diff * 0.15 }
            }
    }
}
