import Foundation

struct HealthReminder {
    // 幽默的摸鱼提醒词库
    static let zhMessages: [String] = [
        "三点几啦，饮茶先啦！🍵",
        "眼保健操开始：揉天应穴，一二三四...👀",
        "站起来扭扭胯，防腰肌劳损！🕺",
        "看两章爽文吧，老板不在！📖",
        "去茶水间唠唠嗑，带薪拉屎！🚽",
        "深呼吸，假装你在思考世纪难题。🧠",
        "手腕转一转，别得鼠标手了。🖱️",
        "去窗边看看风景，保护视力。🌳",
        "下午茶时间到，补充点糖分！🍰",
        "魂兮归来，别对着屏幕发呆了。🧘‍♂️",
        "逛五分钟淘宝，看看有什么想买的。🛒",
        "去接杯水，顺便摸个鱼。🥤"
    ]
    
    static let enMessages: [String] = [
        "3 PM, time for tea! 🍵",
        "Eye exercises time: Look away! 👀",
        "Stand up and stretch your back! 🕺",
        "Read a novel, boss is away! 📖",
        "Grab some coffee and gossip! ☕",
        "Deep breath, pretend you're thinking. 🧠",
        "Rotate your wrists, avoid RSI. 🖱️",
        "Look out the window, rest your eyes. 🌳",
        "Snack time, get some sugar! 🍰",
        "Wake up, stop staring at the screen. 🧘‍♂️",
        "Window shopping for 5 mins. 🛒",
        "Go get some water and slack off. 🥤"
    ]
    
    static func getRandomMessage() -> String {
        if L10n.isEn {
            return enMessages.randomElement() ?? "Take a break!"
        } else {
            return zhMessages.randomElement() ?? "该摸鱼了！"
        }
    }
}
