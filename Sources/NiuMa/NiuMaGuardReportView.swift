import SwiftUI
import AppKit

struct NiuMaGuardDayCell: View {
    var day: Int
    var dateStr: String
    @ObservedObject var niumaGuard: NiuMaGuardManager
    
    var isPunctual: Bool { niumaGuard.punctual.contains(dateStr) }
    var isOvertime: Bool { niumaGuard.overtime.contains(dateStr) }
    
    var body: some View {
        Text("\(day)")
            .font(.system(size: 13, weight: .bold))
            .frame(width: 32, height: 32)
            .background(isOvertime ? Color.red.opacity(0.8) : (isPunctual ? Color.green.opacity(0.8) : Color.gray.opacity(0.1)))
            .foregroundColor((isPunctual || isOvertime) ? .white : .primary)
            .cornerRadius(8)
            .onTapGesture {
                if isPunctual {
                    niumaGuard.punctual.removeAll { $0 == dateStr }
                } else if isOvertime {
                    niumaGuard.overtime.removeAll { $0 == dateStr }
                } else {
                    niumaGuard.punctual.append(dateStr)
                }
                niumaGuard.save()
            }
    }
}

struct NiuMaGuardReportView: View {
    @ObservedObject var niumaGuard = NiuMaGuardManager.shared
    @State private var currentMonth = Date()
    
    private var daysInMonth: [Int?] {
        let cal = Calendar.current
        let range = cal.range(of: .day, in: .month, for: currentMonth)!
        let firstWeekday = cal.component(.weekday, from: currentMonth)
        var days: [Int?] = Array(repeating: nil, count: firstWeekday - 1)
        for day in range { days.append(day) }
        return days
    }
    
    private var monthStats: (punctual: Int, overtime: Int, total: Int) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM"
        let prefix = df.string(from: currentMonth)
        
        let p = niumaGuard.punctual.filter { $0.hasPrefix(prefix) }.count
        let o = niumaGuard.overtime.filter { $0.hasPrefix(prefix) }.count
        return (p, o, p + o)
    }
    
    private var toxicEvaluation: String {
        let stats = monthStats
        if stats.total == 0 { return "这个月你一条记录都没有，连摸鱼都不积极，没救了。" }
        
        let overtimeRatio = Double(stats.overtime) / Double(stats.total)
        
        if overtimeRatio == 0 {
            return "全勤准点下班！你是资本家眼里的刺头，打工人里的楷模。继续保持！"
        } else if overtimeRatio < 0.2 {
            return "偶尔加班，总体准点。你掌握了职场生存的微妙平衡，是个聪明的老油条。"
        } else if overtimeRatio < 0.5 {
            return "加班天数不少啊，老板的保时捷轮毂有你的一份功劳。注意身体，别猝死了。"
        } else if overtimeRatio < 0.8 {
            return "你这个月基本都在加班。你这不是在打工，你是在卖命。你的青春正在加速贬值。"
        } else {
            return "纯种极品牛马！你几乎每天都在加班，公司没你不行，但老板不会分你一分钱股份。"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button("<") { changeMonth(-1) }
                Spacer()
                Text(monthString(currentMonth)).font(.headline)
                Spacer()
                Button(">") { changeMonth(1) }
            }
            .padding(.horizontal)
            
            HStack {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { wd in
                    Text(wd).font(.caption).frame(width: 32)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<daysInMonth.count, id: \.self) { i in
                    if let day = daysInMonth[i] {
                        let dateStr = String(format: "%04d-%02d-%02d", 
                                             Calendar.current.component(.year, from: currentMonth),
                                             Calendar.current.component(.month, from: currentMonth),
                                             day)
                        NiuMaGuardDayCell(day: day, dateStr: dateStr, niumaGuard: niumaGuard)
                    } else {
                        Text("").frame(width: 32, height: 32)
                    }
                }
            }
            .padding(.horizontal)
            
            HStack {
                Label("准点下班", systemImage: "square.fill").foregroundColor(.green).font(.caption)
                Label("被迫加班", systemImage: "square.fill").foregroundColor(.red).font(.caption)
            }
            .padding(.top, 5)
            
            Divider().padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("月度总结")
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                    Text("准点 \(monthStats.punctual) 天 · 加班 \(monthStats.overtime) 天")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Text(toxicEvaluation)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.primary.opacity(0.85))
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .padding()
        .frame(width: 340, height: 500)
    }
    
    private func changeMonth(_ offset: Int) {
        currentMonth = Calendar.current.date(byAdding: .month, value: offset, to: currentMonth) ?? currentMonth
    }
    
    private func monthString(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy年 MM月"
        return df.string(from: date)
    }
}

@MainActor
final class NiuMaGuardReportWindowController {
    static let shared = NiuMaGuardReportWindowController()
    private var window: NSWindow?
    
    func showWindow() {
        if window == nil {
            let view = NiuMaGuardReportView()
            let hosting = NSHostingView(rootView: view)
            let w = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 340, height: 520),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            w.title = "牛马守卫报表"
            w.contentView = hosting
            w.center()
            w.isReleasedWhenClosed = false
            window = w
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
