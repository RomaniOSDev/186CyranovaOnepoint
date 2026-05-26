import SwiftUI

// MARK: - Gradients (lightweight, no Canvas)

enum TravelVisualStyle {
    static var screenBase: LinearGradient {
        LinearGradient(
            colors: [Color("AppBackground"), Color("AppSurface"), Color("AppBackground")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surfaceGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppSurface").opacity(0.92),
                Color("AppBackground").opacity(0.55)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var shineGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppTextPrimary").opacity(0.14),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .center
        )
    }

    static var insetGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppBackground").opacity(0.55),
                Color("AppBackground").opacity(0.35)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryButtonGradient: LinearGradient {
        LinearGradient(
            colors: [Color("AppAccent"), Color("AppPrimary")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var progressGradient: LinearGradient {
        LinearGradient(
            colors: [Color("AppAccent"), Color("AppPrimary")],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var navBarGradient: LinearGradient {
        LinearGradient(
            colors: [Color("AppSurface").opacity(0.98), Color("AppSurface").opacity(0.88)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    enum Elevation {
        case low, medium, high, hero

        var radius: CGFloat {
            switch self {
            case .low: return 3
            case .medium: return 6
            case .high: return 8
            case .hero: return 10
            }
        }

        var y: CGFloat {
            switch self {
            case .low: return 1
            case .medium: return 3
            case .high: return 4
            case .hero: return 5
            }
        }

        var opacity: Double {
            switch self {
            case .low: return 0.22
            case .medium: return 0.28
            case .high: return 0.34
            case .hero: return 0.38
            }
        }
    }
}

// MARK: - Elevation modifier (single shadow — GPU friendly)

extension View {
    func travelElevatedPanel(
        cornerRadius: CGFloat = 16,
        accent: Bool = false,
        elevation: TravelVisualStyle.Elevation = .medium
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let level: TravelVisualStyle.Elevation = accent ? .high : elevation
        return self
            .background(
                shape
                    .fill(TravelVisualStyle.surfaceGradient)
            )
            .overlay(
                shape
                    .fill(TravelVisualStyle.shineGradient)
            )
            .overlay(
                shape.stroke(
                    accent
                        ? Color("AppAccent").opacity(0.55)
                        : Color("AppTextPrimary").opacity(0.1),
                    lineWidth: accent ? 1.5 : 1
                )
            )
            .shadow(
                color: Color("AppBackground").opacity(level.opacity),
                radius: level.radius,
                x: 0,
                y: level.y
            )
    }

    func travelInsetPanel(cornerRadius: CGFloat = 12) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return self
            .background(shape.fill(TravelVisualStyle.insetGradient))
            .overlay(
                shape.stroke(Color("AppTextPrimary").opacity(0.06), lineWidth: 1)
            )
    }

    func travelTagCapsule(
        top: Color = Color("AppPrimary").opacity(0.4),
        bottom: Color = Color("AppPrimary").opacity(0.22)
    ) -> some View {
        self
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [top, bottom],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }
}

// MARK: - Isolated live clock (avoids full-screen TimelineView refresh)

struct TravelLiveClockLabel: View {
    let timeZone: TimeZone
    var showsSeconds: Bool = false
    var font: Font = .title2.bold()

    var body: some View {
        TimelineView(.periodic(from: .now, by: showsSeconds ? 1 : 60)) { context in
            Text(formattedTime(context.date))
                .font(font)
                .foregroundStyle(Color("AppAccent"))
                .monospacedDigit()
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = showsSeconds ? "HH:mm:ss" : "HH:mm"
        return formatter.string(from: date)
    }
}
