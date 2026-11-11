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
        guard let range = cal.range(of: .day, in: .month, for: currentMonth) else { return [] }
        
        // 获取当月第一天是星期几 (1=周日, 2=周一, ... 7=周六)
        let components = cal.dateComponents([.year, .month], from: currentMonth)
        let firstOfMonth = cal.date(from: components)!
        let weekday = cal.component(.weekday, from: firstOfMonth)
        
        // 计算第一天前面需要补几个空格。如果是周日(1)，补 0 个；如果是周六(7)，补 6 个。
        var days: [Int?] = Array(repeating: nil, count: weekday - 1)
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
        if stats.total == 0 { 
            return "这个月你一条记录都没有，连摸鱼都不积极，没救了。" 
        }
        
        let overtimeRatio = Double(stats.overtime) / Double(stats.total)
        
        let perfectComments = [
            "全勤准点下班！你是资本家眼里的刺头，打工人里的楷模。继续保持！",
            "太爽了，一天班都没加！你的老板现在估计正在办公室摔杯子。",
            "完美避开所有加班，你的下班跑路速度堪比博尔特。",
            "全绿！这个月的你让老板感到十分头疼，请务必保持这个优良传统。",
            "一天没加班，看来你已经彻底掌握了带薪摸鱼的核心科技。",
            "这个月你完美捍卫了打工人的尊严，建议给你颁发反内卷勋章。"
        ]
        
        let okComments = [
            "偶尔加班，总体准点。你掌握了职场生存的微妙平衡，是个聪明的老油条。",
            "加班不多，说明你既有能力把活干完，又有胆量准时下班。",
            "踩点下班是你的常态，偶尔加个班就当是给资本家的一点安慰奖吧。",
            "不错，大部分时间都在准点跑路，没有被工作完全绑架。",
            "你有几次没跑掉，但总体依然是个清醒的打工人。",
            "张弛有度，偶尔加加班也算是对得起那份工资了。"
        ]
        
        let badComments = [
            "加班天数不少啊，老板的保时捷轮毂有你的一份功劳。注意身体，别猝死了。",
            "你加的这些班，换来了老板新换的真皮沙发。你的奉献精神令人感动。",
            "加班频率有点高了，是不是该反思一下，是活太多，还是你太卷？",
            "经常加班说明你是个负责任的人，但公司往往不这么想，他们只会觉得你好欺负。",
            "你这个加班频率，你的工位都快长蘑菇了吧？",
            "老板最喜欢你这种默默加班不求回报的员工了，因为真的不用给回报。",
            "你的下班时间已经被工作吞噬了一半，醒醒！"
        ]
        
        let worstComments = [
            "你这个月基本都在加班。你这不是在打工，你是在卖命。你的青春正在加速贬值。",
            "纯种极品牛马！你几乎每天都在加班，公司没你不行，但老板不会分你一分钱股份。",
            "这个月你回家的次数屈指可数吧？你的颈椎和腰椎正在联合抗议。",
            "你已经把公司当家了，但请记住，公司永远不会把你当家人。",
            "几乎全红的日历，看着都让人心梗。你是要用生命点亮老板的别墅吗？",
            "这哪里是打卡记录，这明明是你的受难史。",
            "你加班加到连看这个报表的时间都没有了吧？"
        ]
        
        let maxComments = [
            "你已经被彻底异化成了工具人，老板不给你发工资都算做慈善了。",
            "纯种极品牛马！...不，说你是牛马都抬举你了，你是被榨干的电池。快跑吧！",
            "这个月你是不是就住在公司了？建议直接向老板申请一张行军床。",
            "资本家看了你的打卡记录都要流下感动的泪水（然后换辆新车）。",
            "命是你自己的，钱是老板的。再这么加下去，下个月你可能就得在ICU打卡了。"
        ]
        
        if overtimeRatio == 0 {
            return perfectComments.randomElement()!
        } else if overtimeRatio < 0.2 {
            return okComments.randomElement()!
        } else if overtimeRatio < 0.5 {
            return badComments.randomElement()!
        } else if overtimeRatio < 0.8 {
            return worstComments.randomElement()!
        } else {
            return maxComments.randomElement()!
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
                        let year = Calendar.current.component(.year, from: currentMonth)
                        let month = Calendar.current.component(.month, from: currentMonth)
                        let dateStr = String(format: "%04d-%02d-%02d", year, month, day)
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
            w.standardWindowButton(.miniaturizeButton)?.isHidden = true
            w.standardWindowButton(.zoomButton)?.isHidden = true
            w.center()
            w.isReleasedWhenClosed = false
            window = w
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
