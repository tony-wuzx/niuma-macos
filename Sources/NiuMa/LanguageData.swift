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

// 究极负能量/虚无主义/随机暴击语录生成器
struct ZombieQuotes {
    static func generate() -> String {
        if L10n.isEn {
            let p = ["Good news,", "Look on the bright side,", "Don't forget,", "Smile,", "Just a reminder,", "Truth is,"]
            let m = ["you sold another 8 hours of your finite life for pennies.", "your boss just bought a new Porsche with your sweat.", "you are literally dying for a corporation.", "your youth is depreciating faster than a used car.", "you are one minor mistake away from being fired.", "you are just a replaceable gear in the machine.", "nobody actually cares about your hard work."]
            let s = ["Sleep well.", "Enjoy the matrix.", "Totally worth it.", "Keep crying.", "See you tomorrow.", "Back to work."]
            
            // 英文独立暴击句
            let directBlows = [
                "You are not building a career, you are just paying rent.",
                "Your dream is dead, and you are just too tired to notice.",
                "The company will replace you in 3 days if you die today.",
                "You traded your freedom for a paycheck you can barely survive on.",
                "Remember, you are dispensable. The boss is not."
            ]
            
            if Bool.random() {
                return "\(p.randomElement()!) \(m.randomElement()!) \(s.randomElement()!)"
            } else {
                return directBlows.randomElement()!
            }
        } else {
            // 50% 概率直接触发独立暴击句
            if Bool.random() {
                let directBlows = [
                    "你的工位随时可以被清理干净，老板的保时捷可不行。",
                    "你的努力只能感动你自己，老板只在乎他的财报。",
                    "别把公司当家，你只是个随时可替换的耗材。",
                    "你死后，公司只会在群里发个复联通知，然后立刻招人。",
                    "别以为是生活辜负了你，生活根本没空搭理你。",
                    "你的理想早就在那个加班的深夜死透了。",
                    "老板的岁月静好，全靠你在替他负重前行。",
                    "你连请假都要做心理建设，这就是你的尊严吗？",
                    "你赚的钱，连首付的利息都不够，更别提什么诗和远方了。",
                    "今天你努力了吗？努力了就好，反正也买不起房。",
                    "没人会真的在意你，除了催你交房租的房东。",
                    "你以为你在成长，其实你只是在变老。",
                    "明天依然是这烂透的一天，洗洗睡吧。",
                    "你的存在，只是为了证明老板是个有钱人。",
                    "你越拼命，你的体检报告就越难看。"
                ]
                return directBlows.randomElement()!
            } else {
                // 50% 概率触发组合句（加入随机变量）
                let p = [
                    "好消息：", "往好处想，", "温馨提示：", "别灰心，", "记住，", 
                    "残酷的真相是：", "悄悄告诉你：", "笑一笑吧，", "其实，", 
                    "你以为你在赚钱，其实", "恭喜你，", "现实点说：", "别做梦了，"
                ]
                
                let randomNum = [3, 5, 7, 14, 30, 100, 500, 1000, 8000, 9999].randomElement()!
                
                let m = [
                    "你的寿命又减少了一天。", "老板马上又要换保时捷了。", "距离交下个月房租只剩 \(randomNum) 天了。", 
                    "你的青春又贬值了。", "你只是个随时可替换的耗材。", "你的梦想死在了工位上。", 
                    "你的头发又少了几根。", "你离财富自由还差 \(randomNum) 年。", "你赚的钱连买一平米厕所都不够。", 
                    "你干得再好，公司也不会分你股份。", "你的努力只能感动你自己。", "你在用命换钱，然后再用钱买药。", 
                    "你的灵魂正在被打卡机抽干。", "你已经连续加班第 \(randomNum) 天了。", "你越努力，老板的别墅越大。", 
                    "你只是个会呼吸的印钞机。", "你已经被生活彻底驯化了。", "你明天早上依然会被闹钟惊醒。",
                    "离你猝死可能只剩 \(randomNum) 次打卡了。"
                ]
                
                let s = [
                    "真划算。", "继续搬砖吧。", "这生活毫无意义。", "牛马永不服输！", "都没用。", 
                    "明天还得继续。", "太棒了。", "感恩吧。", "这就是你的福报。", "洗洗睡吧，梦里什么都有。", 
                    "笑不出来了吧。", "太真实了。", "放弃吧。", "你活该。"
                ]
                
                return "\(p.randomElement()!)\(m.randomElement()!)\(s.randomElement()!)"
            }
        }
    }
}

struct WishItem {
    let price: Double
    let zhUnit: String
    let zhName: String
    let enName: String
}

struct Wishlist {
    static let normalItems: [WishItem] = [
        .init(price: 2, zhUnit: "瓶", zhName: "农夫山泉", enName: "bottle of water"),
        .init(price: 5, zhUnit: "根", zhName: "烤肠", enName: "sausage"),
        .init(price: 10, zhUnit: "份", zhName: "煎饼果子", enName: "pancake roll"),
        .init(price: 15, zhUnit: "杯", zhName: "蜜雪冰城", enName: "cheap milk tea"),
        .init(price: 25, zhUnit: "份", zhName: "黄焖鸡米饭", enName: "chicken rice"),
        .init(price: 30, zhUnit: "杯", zhName: "瑞幸咖啡", enName: "Luckin coffee"),
        .init(price: 40, zhUnit: "份", zhName: "麦当劳套餐", enName: "McDonald's meal"),
        .init(price: 65, zhUnit: "件", zhName: "优衣库短袖", enName: "Uniqlo T-shirt"),
        .init(price: 100, zhUnit: "箱", zhName: "纯牛奶", enName: "box of pure milk"),
        .init(price: 200, zhUnit: "顿", zhName: "海底捞", enName: "Haidilao hotpot meal"),
        .init(price: 300, zhUnit: "支", zhName: "平价口红", enName: "lipstick"),
        .init(price: 400, zhUnit: "个", zhName: "罗技鼠标", enName: "Logitech mouse"),
        .init(price: 500, zhUnit: "双", zhName: "回力球鞋", enName: "pair of sneakers"),
        .init(price: 1000, zhUnit: "张", zhName: "短途高铁票", enName: "short-distance train ticket"),
        .init(price: 1500, zhUnit: "瓶", zhName: "神仙水", enName: "bottle of SK-II"),
        .init(price: 2000, zhUnit: "台", zhName: "红米手机", enName: "Redmi phone"),
        .init(price: 5000, zhUnit: "台", zhName: "iPad", enName: "iPad"),
        .init(price: 8000, zhUnit: "台", zhName: "iPhone", enName: "iPhone"),
        .init(price: 15000, zhUnit: "台", zhName: "MacBook", enName: "MacBook")
    ]
    
    static let absurdItems: [WishItem] = [
        .init(price: 0.5, zhUnit: "个", zhName: "鸡蛋", enName: "egg"),
        .init(price: 1, zhUnit: "个", zhName: "馒头", enName: "steamed bun"),
        .init(price: 2, zhUnit: "斤", zhName: "挂面", enName: "pound of noodles"),
        .init(price: 5, zhUnit: "斤", zhName: "老鼠药", enName: "pound of rat poison"),
        .init(price: 100, zhUnit: "吨", zhName: "自来水", enName: "ton of tap water"),
        .init(price: 200, zhUnit: "头", zhName: "猪", enName: "pig"),
        .init(price: 300, zhUnit: "根", zhName: "橡皮筋", enName: "rubber band"),
        .init(price: 0.1, zhUnit: "张", zhName: "A4纸", enName: "sheet of A4 paper"),
        .init(price: 800, zhUnit: "个", zhName: "不锈钢脸盆", enName: "stainless steel basin"),
        .init(price: 1000, zhUnit: "年", zhName: "视频会员", enName: "year of video streaming sub"),
        .init(price: 1500, zhUnit: "辆", zhName: "二手电动车", enName: "second-hand e-bike"),
        .init(price: 2000, zhUnit: "台", zhName: "低配微波炉", enName: "low-end microwave"),
        .init(price: 3000, zhUnit: "只", zhName: "纯种土狗", enName: "purebred local dog"),
        .init(price: 5000, zhUnit: "平米", zhName: "海景房", enName: "sqm of a sea-view house"),
        .init(price: 8000, zhUnit: "辆", zhName: "二手五菱宏光", enName: "second-hand Wuling van"),
        .init(price: 10000, zhUnit: "台", zhName: "普通轿车", enName: "basic car"),
        .init(price: 15000, zhUnit: "个", zhName: "镶金马桶", enName: "gold-plated toilet"),
        .init(price: 30000, zhUnit: "平米", zhName: "北京五环外厕所", enName: "sqm of a toilet in Beijing suburbs")
    ]
    
    static func getMessage(earned: Double) -> String {
        let isEn = L10n.isEn
        
        if earned < 0.5 {
            return isEn ? "Keep going, you can almost buy an egg." : "稳住，马上就够买一个鸡蛋了。"
        }
        
        var targetItem: WishItem?
        
        if Bool.random() {
            targetItem = normalItems.randomElement()
        } else {
            targetItem = absurdItems.randomElement()
        }
        
        guard let item = targetItem else { return "" }
        
        let count = earned / item.price
        
        if count < 1 {
            let remain = item.price - earned
            let prefix = isEn ? "Need" : "还差"
            let suffix = isEn ? "more for a \(item.enName)." : "就能买 1 \(item.zhUnit)\(item.zhName)了。"
            return "\(prefix) ¥\(String(format: "%.1f", remain)) \(suffix)"
        } else {
            let countStr: String
            if count >= 100 {
                countStr = "\(Int(count))"
            } else if count.truncatingRemainder(dividingBy: 1) == 0 {
                countStr = "\(Int(count))"
            } else {
                countStr = String(format: "%.1f", count)
            }
            
            if isEn {
                let plural = count > 1 ? "s" : ""
                return "Keep going, you've earned \(countStr) \(item.enName)\(plural)."
            } else {
                return "稳住，今天已经赚到 \(countStr) \(item.zhUnit)\(item.zhName)了。"
            }
        }
    }
}
