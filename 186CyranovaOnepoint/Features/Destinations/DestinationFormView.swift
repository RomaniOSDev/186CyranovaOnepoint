import SwiftUI

struct DestinationFormView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    let existing: Destination?
    let onSaved: () -> Void

    @State private var name = ""
    @State private var country = ""
    @State private var plannedDate = Date()
    @State private var notes = ""
    @State private var tripType: TripType = .city
    @State private var estimatedBudget = ""
    @State private var preferredSeason = ""
    @State private var durationDays = 7
    @State private var applyTemplate = true
    @State private var copyFromTripId: UUID?
    @State private var shakeTrigger = 0
    @State private var nameError = ""
    @State private var countryError = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 14) {
                        TravelCard {
                            VStack(alignment: .leading, spacing: 12) {
                                TravelSectionHeader(title: "Destination", action: nil, actionHandler: nil)
                                field("Destination name", text: $name, error: nameError)
                                field("Country", text: $country, error: countryError)
                                DatePicker("Planned date", selection: $plannedDate, displayedComponents: .date)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                TextField("Notes", text: $notes, axis: .vertical)
                                    .lineLimit(2...5)
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                        }

                        if existing == nil {
                            TravelCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    TravelSectionHeader(title: "Trip Type", action: nil, actionHandler: nil)
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                        ForEach(TripType.allCases) { type in
                                            tripTypeChip(type)
                                        }
                                    }
                                    Toggle("Apply packing template", isOn: $applyTemplate)
                                        .tint(Color("AppPrimary"))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    if !store.pastTripsForCopy(excluding: nil).isEmpty {
                                        Picker("Copy checklist from", selection: Binding(
                                            get: { copyFromTripId?.uuidString ?? "none" },
                                            set: { newValue in
                                                if newValue == "none" {
                                                    copyFromTripId = nil
                                                    applyTemplate = true
                                                } else {
                                                    copyFromTripId = UUID(uuidString: newValue)
                                                    applyTemplate = false
                                                }
                                            }
                                        )) {
                                            Text("None").tag("none")
                                            ForEach(store.pastTripsForCopy(excluding: nil)) { past in
                                                Text(past.title).tag(past.id.uuidString)
                                            }
                                        }
                                        .tint(Color("AppPrimary"))
                                    }
                                }
                            }
                        }

                        TravelCard {
                            VStack(alignment: .leading, spacing: 12) {
                                TravelSectionHeader(title: "Planning", action: nil, actionHandler: nil)
                                TextField("Budget estimate (USD)", text: $estimatedBudget)
                                    .keyboardType(.decimalPad)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                TextField("Best season", text: $preferredSeason)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Stepper("Duration: \(durationDays) days", value: $durationDays, in: 1...90)
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(existing == nil ? "New Destination" : "Edit Destination")
            .navigationBarTitleDisplayMode(.inline)
            .travelScreenStyle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
            .onAppear { loadExisting() }
        }
        .preferredColorScheme(.dark)
    }

    private func field(_ placeholder: String, text: Binding<String>, error: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(placeholder, text: text)
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(10)
                .travelInsetPanel(cornerRadius: 8)
                .shake(trigger: shakeTrigger)
            if !error.isEmpty {
                Text(error).font(.caption).foregroundStyle(.red)
            }
        }
    }

    private func tripTypeChip(_ type: TripType) -> some View {
        let selected = tripType == type
        return Button {
            FeedbackManager.lightTap()
            tripType = type
        } label: {
            VStack(spacing: 6) {
                Image(systemName: type.systemImage)
                    .font(.title3)
                Text(type.rawValue)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(selected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selected ? Color("AppPrimary").opacity(0.45) : Color("AppBackground").opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(selected ? Color("AppAccent") : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func loadExisting() {
        guard let existing else { return }
        name = existing.name
        country = existing.country
        plannedDate = existing.plannedDate
        notes = existing.notes
        tripType = TripType(rawValue: existing.tripType) ?? .city
        estimatedBudget = existing.estimatedBudget > 0 ? String(Int(existing.estimatedBudget)) : ""
        preferredSeason = existing.preferredSeason
        durationDays = existing.durationDays
    }

    private func save() {
        nameError = ""
        countryError = ""
        var valid = true
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = "Please enter a destination name."
            valid = false
        }
        if country.trimmingCharacters(in: .whitespaces).isEmpty {
            countryError = "Please enter a country."
            valid = false
        }
        guard valid else {
            FeedbackManager.warning()
            shakeTrigger += 1
            return
        }
        let budget = Double(estimatedBudget) ?? 0
        let destination = Destination(
            id: existing?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            country: country.trimmingCharacters(in: .whitespaces),
            plannedDate: plannedDate,
            notes: notes.trimmingCharacters(in: .whitespaces),
            isVisited: existing?.isVisited ?? false,
            tripType: tripType.rawValue,
            estimatedBudget: budget,
            preferredSeason: preferredSeason.trimmingCharacters(in: .whitespaces),
            durationDays: durationDays,
            tripId: existing?.tripId
        )
        if existing != nil {
            store.updateDestination(destination)
        } else {
            store.addDestination(
                destination,
                tripType: tripType,
                applyTemplate: applyTemplate && copyFromTripId == nil,
                copyFromTripId: copyFromTripId
            )
        }
        FeedbackManager.success()
        onSaved()
        dismiss()
    }
}
