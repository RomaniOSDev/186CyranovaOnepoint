import Foundation

enum AppLink: String {
    case privacyPolicy = "https://cyranovaonepoint186.site/privacy/206"
    case termsOfUse = "https://cyranovaonepoint186.site/terms/206"

    var url: URL? {
        URL(string: rawValue)
    }
}
