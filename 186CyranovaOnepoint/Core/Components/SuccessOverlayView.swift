import SwiftUI

struct SuccessCheckmarkOverlay: View {
    @Binding var isVisible: Bool

    var body: some View {
        Group {
            if isVisible {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color("AppAccent"))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
        .onChange(of: isVisible) { visible in
            if visible {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isVisible = false
                }
            }
        }
    }
}

struct RowPulseModifier: ViewModifier {
    let isPulsing: Bool

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("AppAccent").opacity(isPulsing ? 0.35 : 0))
                    .animation(.easeInOut(duration: 0.4), value: isPulsing)
            )
    }
}

extension View {
    func rowPulse(_ isPulsing: Bool) -> some View {
        modifier(RowPulseModifier(isPulsing: isPulsing))
    }
}
