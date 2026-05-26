import SwiftUI

struct EssentialPhrasesView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 12) {
                    TravelCard {
                        HStack(spacing: 12) {
                            TravelIconBadge(systemImage: "text.bubble.fill", style: .primary)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tap a phrase to mark it learned")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Text("\(store.phrasesViewed) phrases viewed")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }
                    }

                    ForEach(TravelPhraseCatalog.essential) { phrase in
                        Button {
                            FeedbackManager.lightTap()
                            store.recordPhraseViewed(phrase.id)
                        } label: {
                            TravelCard {
                                PhraseListCell(
                                    english: phrase.english,
                                    translation: phrase.translation,
                                    language: phrase.language,
                                    isViewed: store.viewedPhraseIDs.contains(phrase.id)
                                )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Essential Phrases")
        .travelScreenStyle()
        .preferredColorScheme(.dark)
    }
}
