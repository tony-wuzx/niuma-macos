import Foundation

enum Currency: String, CaseIterable, Identifiable, Codable {
    case cny = "CNY"
    case usd = "USD"
    case jpy = "JPY"
    case gbp = "GBP"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .cny, .jpy: return "¥"
        case .usd: return "$"
        case .gbp: return "£"
        }
    }

    var displayName: String {
        switch self {
        case .cny: return "人民币"
        case .usd: return "美元"
        case .jpy: return "日元"
        case .gbp: return "英镑"
        }
    }

    /// 建议小数位数：日元习惯不显示小数，其他币种用用户设置
    var suggestedDecimals: Int? {
        switch self {
        case .jpy: return 0
        default: return nil
        }
    }
}

@MainActor
final class ExchangeRateManager: ObservableObject {
    static let shared = ExchangeRateManager()

    /// 相对人民币的汇率：rates[.usd] = 0.14 表示 1 CNY = 0.14 USD
    @Published var rates: [Currency: Double] = [.cny: 1.0]
    @Published var lastUpdated: Date?
    @Published var isLoading = false

    private let cacheKey = "niuma_exchange_rates"
    private let cacheTimeKey = "niuma_exchange_rates_time"
    private let cacheTTL: TimeInterval = 24 * 60 * 60  // 一天

    private init() {
        loadCache()
        Task { await refreshIfNeeded() }
    }

    /// 若缓存未过期直接返回；过期则后台拉新
    func refreshIfNeeded() async {
        if let t = lastUpdated, Date().timeIntervalSince(t) < cacheTTL {
            return
        }
        await fetchRates()
    }

    func fetchRates() async {
        isLoading = true
        defer { isLoading = false }

        let urlStr = "https://api.frankfurter.app/latest?from=CNY&to=USD,JPY,GBP"
        guard let url = URL(string: urlStr) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let ratesDict = json["rates"] as? [String: Double] {
                var newRates: [Currency: Double] = [.cny: 1.0]
                for (code, rate) in ratesDict {
                    if let c = Currency(rawValue: code) {
                        newRates[c] = rate
                    }
                }
                rates = newRates
                lastUpdated = Date()
                saveCache()
            }
        } catch {
            print("汇率获取失败（继续使用缓存）: \(error)")
        }
    }

    /// 人民币金额 → 目标币种金额
    func convert(cnyAmount: Double, to currency: Currency) -> Double {
        let rate = rates[currency] ?? 1.0
        return cnyAmount * rate
    }

    private func saveCache() {
        if let data = try? JSONEncoder().encode(rates) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
        UserDefaults.standard.set(Date(), forKey: cacheTimeKey)
    }

    private func loadCache() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let cached = try? JSONDecoder().decode([Currency: Double].self, from: data) {
            rates = cached
            lastUpdated = UserDefaults.standard.object(forKey: cacheTimeKey) as? Date
        }
    }
}
