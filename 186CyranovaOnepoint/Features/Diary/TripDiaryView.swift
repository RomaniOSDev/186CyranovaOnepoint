import SwiftUI

struct TripDiaryView: View {
    @EnvironmentObject private var store: AppDataStore
    let trip: Trip

    @State private var showAdd = false
    @State private var newText = ""
    @State private var newMood = TripMood.happy.rawValue
    @State private var newDate = Date()

    private var entries: [DiaryEntry] { store.diaryEntries(for: trip.id) }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 12) {
                    if entries.isEmpty {
                        TravelCard {
                            TravelEmptyState(
                                icon: "book.closed.fill",
                                title: "No entries yet",
                                message: "Record memories from your trip with text and mood.",
                                buttonTitle: "Add Entry",
                                action: { showAdd = true }
                            )
                        }
                    } else {
                        ForEach(entries) { entry in
                            TravelCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(entry.mood)
                                            .font(.largeTitle)
                                        VStack(alignment: .leading) {
                                            Text(entry.date.formatted(date: .long, time: .omitted))
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(Color("AppTextSecondary"))
                                        }
                                        Spacer()
                                    }
                                    Text(entry.text)
                                        .font(.body)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                }
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    store.deleteDiaryEntry(id: entry.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Trip Diary")
        .navigationBarTitleDisplayMode(.inline)
        .travelScreenStyle()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    FeedbackManager.lightTap()
                    showAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .sheet(isPresented: $showAdd) { addEntrySheet }
        .preferredColorScheme(.dark)
    }

    private var addEntrySheet: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    TravelCard {
                        VStack(spacing: 16) {
                            Picker("Mood", selection: $newMood) {
                                ForEach(TripMood.allCases) { mood in
                                    Text(mood.rawValue).tag(mood.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                            DatePicker("Date", selection: $newDate, displayedComponents: .date)
                            TextField("What happened today?", text: $newText, axis: .vertical)
                                .lineLimit(4...10)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { FeedbackManager.lightTap(); showAdd = false }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !newText.trimmingCharacters(in: .whitespaces).isEmpty else {
                            FeedbackManager.warning()
                            return
                        }
                        let entry = DiaryEntry(tripId: trip.id, date: newDate, mood: newMood, text: newText)
                        store.addDiaryEntry(entry)
                        FeedbackManager.success()
                        newText = ""
                        showAdd = false
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
