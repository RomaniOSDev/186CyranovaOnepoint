import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showDocuments = false
    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 14) {
                        statsCard

                        legalSection

                        TravelSectionHeader(title: "Travel", action: nil, actionHandler: nil)
                        settingsButton(icon: "doc.text.fill", title: "Travel Documents") {
                            showDocuments = true
                        }

                        TravelSectionHeader(title: "Data", action: nil, actionHandler: nil)
                        TravelCard {
                            Button(role: .destructive) {
                                FeedbackManager.lightTap()
                                showResetAlert = true
                            } label: {
                                HStack(spacing: 14) {
                                    TravelIconBadge(systemImage: "trash.fill", style: .muted)
                                    Text("Reset All Data")
                                        .font(.headline)
                                        .foregroundStyle(.red)
                                    Spacer()
                                }
                            }
                        }

                        Text("Version \(appVersion)")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                    }
                    .padding(16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .travelScreenStyle()
            .sheet(isPresented: $showDocuments) {
                NavigationStack {
                    TravelDocumentsView()
                        .environmentObject(store)
                }
            }
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { FeedbackManager.lightTap() }
                Button("Reset", role: .destructive) {
                    store.resetAllData()
                    FeedbackManager.warning()
                }
            } message: {
                Text("This will permanently delete all destinations, tasks, clocks, and progress.")
            }
        }
        .preferredColorScheme(.dark)
    }

    private var statsCard: some View {
        TravelCard(accent: true) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Statistics")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                HStack(spacing: 8) {
                    TravelMetricTile(icon: "list.bullet", label: "Entries", value: "\(store.destinations.count)")
                    TravelMetricTile(icon: "clock.fill", label: "Minutes", value: "\(store.totalMinutesUsed)")
                    TravelMetricTile(icon: "flame.fill", label: "Streak", value: "\(store.streakDays)")
                }
            }
        }
    }

    private var legalSection: some View {
        VStack(spacing: 14) {
            TravelSectionHeader(title: "Legal", action: nil, actionHandler: nil)
            settingsButton(icon: "star.fill", title: "Rate Us") {
                rateApp()
            }
            settingsButton(icon: "hand.raised.fill", title: "Privacy Policy") {
                openLink(.privacyPolicy)
            }
            settingsButton(icon: "doc.plaintext.fill", title: "Terms of Use") {
                openLink(.termsOfUse)
            }
        }
    }

    private func settingsButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            TravelCard {
                SettingsActionCell(title: title, icon: icon)
            }
        }
        .buttonStyle(.plain)
    }

    private func openLink(_ link: AppLink) {
        guard let url = link.url else { return }
        UIApplication.shared.open(url)
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
