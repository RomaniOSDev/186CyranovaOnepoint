import Foundation

enum AppLink: String {
    case privacyPolicy = "https://cyranovaonepoint.com/privacy-policy.html"
    case termsOfUse = "https://cyranovaonepoint.com/support.html"

    var url: URL? {
        URL(string: rawValue)
    }
}
