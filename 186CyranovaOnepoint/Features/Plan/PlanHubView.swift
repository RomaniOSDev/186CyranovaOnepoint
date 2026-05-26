import SwiftUI

enum PlanTool: String, Identifiable, CaseIterable, Hashable {
    case organizer = "Travel Organizer"
    case worldTime = "World Time"
    case meetingPlanner = "Meeting Planner"
    case phrases = "Essential Phrases"
    case jetLag = "Jet Lag Helper"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .organizer: return "suitcase.fill"
        case .worldTime: return "clock.fill"
        case .meetingPlanner: return "person.2.fill"
        case .phrases: return "text.bubble.fill"
        case .jetLag: return "bed.double.fill"
        }
    }
}

struct PlanHubView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    TravelSectionHeader(title: "Trip Tools", action: nil, actionHandler: nil)
                    Text("Everything you need to plan time zones, packing, and meetings.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .padding(.horizontal, 4)

                    ForEach(PlanTool.allCases) { tool in
                        NavigationLink(value: tool) {
                            TravelCard {
                                PlanToolCell(tool: tool)
                            }
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded { FeedbackManager.lightTap() })
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Plan")
        .navigationBarTitleDisplayMode(.inline)
        .travelScreenStyle()
        .navigationDestination(for: PlanTool.self) { tool in
            toolView(tool)
                .environmentObject(store)
        }
    }

    @ViewBuilder
    private func toolView(_ tool: PlanTool) -> some View {
        switch tool {
        case .organizer:
            TravelOrganizerView()
        case .worldTime:
            WorldTimeView()
        case .meetingPlanner:
            MeetingTimePlannerView()
        case .phrases:
            EssentialPhrasesView()
        case .jetLag:
            JetLagCalculatorView()
        }
    }
}
