import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case zh = "zh"
    case en = "en"
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .zh: return "中文"
        case .en: return "English"
        }
    }
}

struct L10n {
    static var isEn: Bool {
        MainActor.assumeIsolated { Settings.shared.language == .en }
    }
    
    static var statusWorking: String { isEn ? "WORKING" : "上班中" }
    static var statusResting: String { isEn ? "BREAK" : "午休中" }
    static var statusOffWork: String { isEn ? "OFF WORK" : "已下班" }
    static var statusHoliday: String { isEn ? "HOLIDAY" : "休息日" }
    static var statusBeforeWork: String { isEn ? "NOT STARTED" : "还没上班" }
    
    static func countdownToOff(_ time: String) -> String { isEn ? "Off in \(time)" : "距下班还有 \(time)" }
    static func countdownToStart(_ time: String) -> String { isEn ? "Starts in \(time)" : "距上班 \(time)" }
    
    static var todayEarned: String { isEn ? "Today's Earnings" : "今日已赚" }
    static func speed(_ sec: String, _ min: String) -> String { isEn ? "Speed \(sec)/s · \(min)/m" : "速度 \(sec)/秒 · \(min)/分" }
    static var progress: String { isEn ? "Progress" : "今日工时进度" }
    static var monthlyTotal: String { isEn ? "Monthly Total" : "本月累计" }
    static func daysToPayday(_ days: Int) -> String { isEn ? "\(days) days to payday" : "距离发薪日还有 \(days) 天" }
    static func hourlyMinutely(_ h: String, _ m: String) -> String { isEn ? "Hourly \(h) · Minutely \(m)" : "时薪 \(h) · 分薪 \(m)" }
    static var fullDayPay: String { isEn ? "Full day pay" : "今日满勤可得" }
}

// 究极负能量语录生成器
struct ZombieQuotes {
    static func generate() -> String {
        if L10n.isEn {
            let p = ["You just earned some money,", "Look at the bright side,", "Keep grinding,", "Remember,", "You're doing great,"]
            let m = ["but you traded a day of your lifespan for it.", "and your boss just bought a new Porsche.", "your rent is due in 3 days.", "you are just a disposable asset.", "the company doesn't care about you."]
            let s = ["Totally worth it.", "Keep crying.", "Life is meaningless.", "Nothing matters.", "Back to the matrix."]
            return "\(p.randomElement()!) \(m.randomElement()!) \(s.randomElement()!)"
        } else {
            let p = ["往好处想，", "别难过，", "其实，", "记住，", "现实点说，", "悄悄告诉你，"]
            let m = ["你的寿命又减少了一天。", "老板马上又要换新车了。", "距离交房租只剩三天了。", "你的青春又贬值了。", "你只是个耗材。", "你的梦想正在死去。", "你的头发又少了几根。", "你离财富自由又远了一步。", "你的存款依然买不起一平米。"]
            let s = ["真划算。", "继续哭吧。", "这生活毫无意义。", "牛马永不服输！", "都没用。", "明天还得继续。", "太棒了。"]
            return "\(p.randomElement()!)\(m.randomElement()!)\(s.randomElement()!)"
        }
    }
}

struct WishItem {
    let threshold: Double
    let zh: String
    let en: String
}

struct Wishlist {
    static let normalItems: [WishItem] = [
        .init(threshold: 2, zh: "一瓶农夫山泉", en: "a bottle of water"),
        .init(threshold: 5, zh: "一根烤肠", en: "a sausage"),
        .init(threshold: 10, zh: "一份煎饼果子", en: "a pancake roll"),
        .init(threshold: 15, zh: "一杯蜜雪冰城", en: "a cheap milk tea"),
        .init(threshold: 25, zh: "一份黄焖鸡米饭", en: "a chicken rice"),
        .init(threshold: 30, zh: "一杯瑞幸咖啡", en: "a Luckin coffee"),
        .init(threshold: 40, zh: "一份麦当劳套餐", en: "a McDonald's meal"),
        .init(threshold: 65, zh: "一件优衣库短袖", en: "a Uniqlo T-shirt"),
        .init(threshold: 100, zh: "一箱纯牛奶", en: "a box of pure milk"),
        .init(threshold: 200, zh: "一顿海底捞", en: "a Haidilao hotpot meal"),
        .init(threshold: 300, zh: "一支平价口红", en: "a lipstick"),
        .init(threshold: 400, zh: "一个罗技鼠标", en: "a Logitech mouse"),
        .init(threshold: 500, zh: "一双回力球鞋", en: "a pair of sneakers"),
        .init(threshold: 1000, zh: "一张短途高铁票", en: "a short-distance train ticket"),
        .init(threshold: 1500, zh: "一瓶神仙水", en: "a bottle of SK-II"),
        .init(threshold: 2000, zh: "一台红米手机", en: "a Redmi phone"),
        .init(threshold: 5000, zh: "一台 iPad", en: "an iPad"),
        .init(threshold: 8000, zh: "一台 iPhone", en: "an iPhone"),
        .init(threshold: 15000, zh: "一台 MacBook", en: "a MacBook")
    ]
    
    static let absurdItems: [WishItem] = [
        .init(threshold: 5, zh: "半斤老鼠药", en: "half a pound of rat poison"),
        .init(threshold: 10, zh: "一百个鸡蛋", en: "100 eggs"),
        .init(threshold: 20, zh: "十斤挂面", en: "10 pounds of noodles"),
        .init(threshold: 50, zh: "一百个馒头", en: "100 steamed buns"),
        .init(threshold: 100, zh: "一吨自来水", en: "a ton of tap water"),
        .init(threshold: 200, zh: "半头猪", en: "half a pig"),
        .init(threshold: 300, zh: "五百根橡皮筋", en: "500 rubber bands"),
        .init(threshold: 500, zh: "一千张 A4 纸", en: "1000 sheets of A4 paper"),
        .init(threshold: 800, zh: "一个不锈钢脸盆", en: "a stainless steel basin"),
        .init(threshold: 1000, zh: "一年的视频会员", en: "a year of video streaming subscription"),
        .init(threshold: 1500, zh: "一辆二手电动车", en: "a second-hand e-bike"),
        .init(threshold: 2000, zh: "一台低配微波炉", en: "a low-end microwave"),
        .init(threshold: 3000, zh: "一只纯种土狗", en: "a purebred local dog"),
        .init(threshold: 5000, zh: "一套海景房的一平米", en: "1 sqm of a sea-view house"),
        .init(threshold: 8000, zh: "一台二手五菱宏光", en: "a second-hand Wuling van"),
        .init(threshold: 10000, zh: "十分之一台普通轿车", en: "1/10 of a basic car"),
        .init(threshold: 15000, zh: "半个镶金马桶", en: "half a gold-plated toilet"),
        .init(threshold: 30000, zh: "一平米北京五环外的厕所", en: "1 sqm of a toilet in Beijing suburbs")
    ]
    
    static func getMessage(earned: Double) -> String {
        let isEn = L10n.isEn
        
        let affordableNormal = normalItems.filter { earned >= $0.threshold }
        let affordableAbsurd = absurdItems.filter { earned >= $0.threshold }
        
        var targetItem: WishItem?
        
        if earned >= 5 {
            if Bool.random() {
                targetItem = affordableAbsurd.last ?? affordableNormal.last
            } else {
                targetItem = affordableNormal.last ?? affordableAbsurd.last
            }
        }
        
        if let item = targetItem {
            // 把“稳住”或 "Keep going" 放到了最前面
            return isEn ? "Keep going, you've earned \(item.en)." : "稳住，今天已经赚到\(item.zh)了。"
        } else {
            let allItems = normalItems + absurdItems
            let nextItems = allItems.filter { earned < $0.threshold }.sorted { $0.threshold < $1.threshold }
            
            if let next = nextItems.first {
                let remain = next.threshold - earned
                let prefix = isEn ? "Keep going, you need" : "稳住，还差"
                let suffix = isEn ? "more for \(next.en)." : "就能买\(next.zh)了。"
                return "\(prefix) ¥\(String(format: "%.1f", remain)) \(suffix)"
            } else {
                return isEn ? "You are rich!" : "你已经买下全世界了！"
            }
        }
    }
}
