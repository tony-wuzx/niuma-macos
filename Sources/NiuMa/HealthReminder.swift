import Foundation

struct HealthReminder {
    // 幽默的摸鱼提醒词库
    static let zhMessages: [String] = [
        "去接杯水，顺便摸个鱼。",
        "站起来伸个懒腰吧，你的腰椎在求救。",
        "看看窗外，放过你的眼睛。",
        "喝口水，去个洗手间，假装自己很忙。",
        "别盯屏幕了，老板不在，快歇会儿。",
        "深呼吸，你不需要这么拼命。",
        "摸鱼是对抗资本家最有效的武器。",
        "起来走走，预防久坐带来的工伤。",
        "带薪拉屎的时间到了，快去。",
        "喝杯咖啡，假装在思考人生。",
        "你的大脑需要重启，请闭眼 5 分钟。",
        "转头看看同事在干嘛，顺便活动下颈椎。",
        "去窗边晒晒太阳，补补钙。",
        "键盘敲得再响，老板也听不见。",
        "打工而已，别把命搭进去。",
        "去茶水间巡视一圈，彰显你的存在感。",
        "该去给绿植浇浇水了。",
        "闭上眼睛，想象一下你在马尔代夫。",
        "把椅子放倒，躺平一会儿。",
        "找个没人的会议室，独自放空。",
        "去洗手间洗个脸，清醒一下。",
        "把工位收拾一下，假装在找文件。",
        "去楼下便利店买个零食。",
        "打开手机刷刷短视频，劳逸结合。",
        "深呼吸，把工作压力吐出去。",
        "站起来做几个深蹲，提神醒脑。",
        "去接杯热水，吹一吹，能多摸五分钟。",
        "看看时钟，告诉自己快下班了。",
        "去阳台吹吹风，假装抽根烟。",
        "老板不在，此时不摸更待何时。"
    ]
    
    static let enMessages: [String] = [
        "Go grab some water and take a break.",
        "Stand up and stretch, your back needs it.",
        "Look out the window, give your eyes a rest.",
        "Drink some water, go to the bathroom, pretend to be busy.",
        "Stop staring at the screen, take a breather.",
        "Take a deep breath, you don't need to work this hard.",
        "Slacking off is your best weapon.",
        "Walk around to prevent occupational injuries.",
        "It's time for a paid bathroom break.",
        "Grab a coffee and pretend to think about life.",
        "Your brain needs a reboot, close your eyes for 5 minutes.",
        "Look at your colleagues, stretch your neck.",
        "Go to the window and get some sun.",
        "Typing louder won't make your boss notice.",
        "It's just a job, don't sacrifice your life.",
        "Patrol the pantry to show your presence.",
        "Time to water the plants.",
        "Close your eyes, imagine you're in the Maldives.",
        "Recline your chair and lie flat for a while.",
        "Find an empty meeting room and zone out.",
        "Go wash your face to wake up.",
        "Organize your desk, pretend to look for documents.",
        "Go to the convenience store downstairs for a snack.",
        "Scroll through short videos on your phone.",
        "Take a deep breath, exhale the stress.",
        "Stand up and do some squats.",
        "Go get hot water, blow on it, and slack for 5 minutes.",
        "Look at the clock, tell yourself it's almost time.",
        "Go to the balcony for some fresh air.",
        "The boss is away, slack off now."
    ]
    
    static func getRandomMessage() -> String {
        if L10n.isEn {
            return enMessages.randomElement() ?? "Take a break!"
        } else {
            return zhMessages.randomElement() ?? "该摸鱼了！"
        }
    }
}
