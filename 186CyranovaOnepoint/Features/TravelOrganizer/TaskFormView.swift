import SwiftUI

struct TaskFormView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    let checklistType: String
    let categories: [String]

    @State private var title = ""
    @State private var category: String
    @State private var shakeTrigger = 0
    @State private var titleError = ""

    init(checklistType: String, categories: [String]) {
        self.checklistType = checklistType
        self.categories = categories
        _category = State(initialValue: categories.first ?? "General")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    TravelCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("New checklist item")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            TextField("Task name", text: $title)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .padding(10)
                                .travelInsetPanel(cornerRadius: 8)
                                .shake(trigger: shakeTrigger)
                            if !titleError.isEmpty {
                                Text(titleError)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                            Text("Category")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color("AppTextSecondary"))
                            Picker("Category", selection: $category) {
                                ForEach(categories, id: \.self) { cat in
                                    Text(cat).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color("AppPrimary"))
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .travelInsetPanel(cornerRadius: 10)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("New Item")
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
                    Button("Add") {
                        save()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        titleError = ""
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            titleError = "Please enter a task name."
            FeedbackManager.warning()
            shakeTrigger += 1
            return
        }
        let tasksInCategory = store.travelTasks.filter {
            $0.category == category && $0.checklistType == checklistType
        }
        let task = TravelTask(
            title: title.trimmingCharacters(in: .whitespaces),
            category: category,
            checklistType: checklistType,
            sortOrder: tasksInCategory.count
        )
        store.addTravelTask(task)
        FeedbackManager.success()
        dismiss()
    }
}
