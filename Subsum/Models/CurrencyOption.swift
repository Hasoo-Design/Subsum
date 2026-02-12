import Foundation

struct CurrencyOption: Identifiable, Hashable {
    let code: String
    let symbol: String
    let name: String

    var id: String { code }

    static let all: [CurrencyOption] = [
        CurrencyOption(code: "USD", symbol: "$", name: "US Dollar"),
        CurrencyOption(code: "EUR", symbol: "€", name: "Euro"),
        CurrencyOption(code: "GBP", symbol: "£", name: "British Pound"),
        CurrencyOption(code: "JPY", symbol: "¥", name: "Japanese Yen"),
        CurrencyOption(code: "CAD", symbol: "CA$", name: "Canadian Dollar"),
        CurrencyOption(code: "AUD", symbol: "A$", name: "Australian Dollar"),
        CurrencyOption(code: "SEK", symbol: "kr", name: "Swedish Krona"),
        CurrencyOption(code: "NOK", symbol: "kr", name: "Norwegian Krone"),
        CurrencyOption(code: "DKK", symbol: "kr", name: "Danish Krone"),
        CurrencyOption(code: "CHF", symbol: "CHF", name: "Swiss Franc"),
    ]

    static func symbol(for code: String) -> String {
        all.first { $0.code == code }?.symbol ?? code
    }
}
