import SwiftUI

enum HomeIllustration {
    case hero
    case beach
    case city
    case hiking
    case business

    var assetName: String {
        switch self {
        case .hero: return "illust_hero"
        case .beach: return "illust_beach"
        case .city: return "illust_city"
        case .hiking: return "illust_hiking"
        case .business: return "illust_city"
        }
    }

    static func forTripType(_ raw: String) -> HomeIllustration {
        switch TripType(rawValue: raw) {
        case .beach: return .beach
        case .city: return .city
        case .business: return .business
        case .hiking: return .hiking
        case .none: return .hero
        }
    }
}

struct HomeIllustrationImage: View {
    let illustration: HomeIllustration
    var height: CGFloat = 120

    var body: some View {
        Image(illustration.assetName)
            .resizable()
            .interpolation(.medium)
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipped()
    }
}

struct IllustrationHeader: View {
    let illustration: HomeIllustration
    var height: CGFloat = 140

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HomeIllustrationImage(illustration: illustration, height: height)
            LinearGradient(
                colors: [
                    Color("AppPrimary").opacity(0.08),
                    Color.clear,
                    Color("AppBackground").opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: height)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color("AppTextPrimary").opacity(0.08), lineWidth: 1)
        )
    }
}
