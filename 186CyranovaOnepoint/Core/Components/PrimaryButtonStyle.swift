import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(Color("AppTextPrimary"))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(TravelVisualStyle.primaryButtonGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(TravelVisualStyle.shineGradient)
                    .opacity(0.35)
            )
            .shadow(
                color: Color("AppBackground").opacity(configuration.isPressed ? 0.15 : 0.3),
                radius: configuration.isPressed ? 2 : 5,
                y: configuration.isPressed ? 1 : 3
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct FloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            FeedbackManager.lightTap()
            action()
        }) {
            Image(systemName: "plus")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(TravelVisualStyle.primaryButtonGradient)
                )
                .overlay(
                    Circle()
                        .fill(TravelVisualStyle.shineGradient)
                        .opacity(0.3)
                )
                .shadow(color: Color("AppBackground").opacity(0.35), radius: 6, y: 3)
        }
        .accessibilityLabel("Add")
    }
}
