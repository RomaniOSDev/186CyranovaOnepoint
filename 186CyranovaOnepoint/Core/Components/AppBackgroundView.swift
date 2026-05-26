import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            TravelVisualStyle.screenBase

            // Static glow spots — cheap vs Canvas dots
            RadialGradient(
                colors: [Color("AppPrimary").opacity(0.18), Color.clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 220
            )

            RadialGradient(
                colors: [Color("AppAccent").opacity(0.12), Color.clear],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 200
            )
        }
        .ignoresSafeArea()
    }
}
