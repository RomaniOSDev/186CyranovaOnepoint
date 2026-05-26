import SwiftUI

struct CountryBriefView: View {
    @EnvironmentObject private var store: AppDataStore
    let country: String

    private var brief: CountryBrief? { CountryBriefService.brief(for: country) }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                if let brief {
                    VStack(spacing: 12) {
                        TravelCard(accent: true) {
                            HStack(spacing: 14) {
                                TravelIconBadge(systemImage: "globe.americas.fill", size: 52, style: .primary)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(country)
                                        .font(.title2.bold())
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Text(brief.currency)
                                        .font(.subheadline)
                                        .foregroundStyle(Color("AppAccent"))
                                }
                            }
                        }
                        briefCard("Tipping", brief.tipping, icon: "hand.thumbsup.fill")
                        briefCard("Power", "\(brief.power) • \(brief.voltage)", icon: "powerplug.fill")
                        briefCard("Emergency", brief.emergency, icon: "phone.fill")
                        briefCard("Exchange", "≈ \(String(format: "%.4f", brief.exchangeRateUSD)) per 1 USD", icon: "dollarsign.circle.fill")
                        phrasesSection(brief.phrases)
                    }
                    .padding(16)
                } else {
                    TravelCard {
                        TravelEmptyState(
                            icon: "book.fill",
                            title: "No brief available",
                            message: "Try: France, Japan, Spain, United States, United Kingdom"
                        )
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Country Brief")
        .navigationBarTitleDisplayMode(.inline)
        .travelScreenStyle()
        .preferredColorScheme(.dark)
    }

    private func briefCard(_ title: String, _ body: String, icon: String) -> some View {
        TravelCard {
            HStack(alignment: .top, spacing: 14) {
                TravelIconBadge(systemImage: icon, size: 40, style: .accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppAccent"))
                    Text(body)
                        .font(.body)
                        .foregroundStyle(Color("AppTextPrimary"))
                }
            }
        }
    }

    private func phrasesSection(_ phrases: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            TravelSectionHeader(title: "Useful Phrases", action: nil, actionHandler: nil)
            ForEach(phrases, id: \.self) { phrase in
                Button {
                    FeedbackManager.lightTap()
                    store.recordPhraseViewed("country-\(country)-\(phrase)")
                } label: {
                    TravelCard {
                        PhraseListCell(
                            english: phrase,
                            translation: "",
                            language: country,
                            isViewed: store.viewedPhraseIDs.contains("country-\(country)-\(phrase)")
                        )
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
