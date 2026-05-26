import SwiftUI

struct TravelOrganizerView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = TravelOrganizerViewModel()

    private var checklistType: ChecklistType {
        ChecklistType(rawValue: store.selectedChecklistType) ?? .packing
    }

    private var categories: [String] {
        checklistType == .packing ? store.packingCategories : store.itineraryCategories
    }

    private var filteredTasks: [TravelTask] {
        store.tasksForActiveTrip(checklistType: checklistType.rawValue)
    }

    private var progress: Double {
        guard let tripId = store.activeTripId else { return 0 }
        return store.packingProgress(for: tripId)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 0) {
                headerPanel

                if filteredTasks.isEmpty {
                    Spacer()
                    TravelEmptyState(
                        icon: "suitcase.fill",
                        title: "No items yet",
                        message: "Start your travel prep! Tap '+' to add your first item.",
                        buttonTitle: "Add Item",
                        action: { viewModel.showingAddSheet = true }
                    )
                    .padding(24)
                    Spacer()
                } else {
                    List {
                        ForEach(categories, id: \.self) { category in
                            let tasks = viewModel.sortedTasks(
                                filteredTasks.filter { $0.category == category }
                            )
                            if !tasks.isEmpty {
                                Section {
                                    if viewModel.expandedCategories.contains(category) {
                                        ForEach(tasks) { task in
                                            taskRow(task)
                                                .rowPulse(viewModel.pulsingTaskID == task.id)
                                        }
                                        .onMove { source, destination in
                                            store.reorderTasks(
                                                in: category,
                                                checklistType: checklistType.rawValue,
                                                tripId: store.activeTripId,
                                                from: source,
                                                to: destination
                                            )
                                        }
                                    }
                                } header: {
                                    categoryHeader(category, count: tasks.count)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .environment(\.editMode, .constant(.active))
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingAddButton { viewModel.showingAddSheet = true }
                        .padding(.trailing, 20)
                        .padding(.bottom, 8)
                }
            }
        }
        .navigationTitle("Travel Organizer")
        .travelScreenStyle()
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Menu {
                    ForEach(TaskSortOrder.allCases, id: \.self) { order in
                        Button(order.rawValue) {
                            FeedbackManager.lightTap()
                            viewModel.sortOrder = order
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .onAppear { viewModel.ensureExpanded(categories) }
        .onChange(of: store.selectedChecklistType) { _ in
            viewModel.expandedCategories = Set(categories)
        }
        .sheet(isPresented: $viewModel.showingAddSheet) {
            TaskFormView(checklistType: checklistType.rawValue, categories: categories)
                .environmentObject(store)
        }
        .preferredColorScheme(.dark)
    }

    private var headerPanel: some View {
        VStack(spacing: 12) {
            Picker("Checklist", selection: Binding(
                get: { store.selectedChecklistType },
                set: { newValue in
                    FeedbackManager.lightTap()
                    store.selectedChecklistType = newValue
                }
            )) {
                ForEach(ChecklistType.allCases, id: \.rawValue) { type in
                    Text(type.rawValue).tag(type.rawValue)
                }
            }
            .pickerStyle(.segmented)

            if let trip = store.activeTrip {
                TravelCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Active: \(trip.title)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppTextSecondary"))
                        TravelProgressBar(progress: progress)
                        HStack {
                            Text("Completion")
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                            Spacer()
                            Text("\(store.packingProgressPercent(for: trip.id))%")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color("AppAccent"))
                        }
                    }
                }
            } else {
                Text("No active trip — add a destination on Home")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func categoryHeader(_ category: String, count: Int) -> some View {
        Button {
            viewModel.toggleCategory(category)
        } label: {
            TravelCard {
                HStack {
                    TravelIconBadge(systemImage: "folder.fill", size: 36, style: .accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("\(count) item(s)")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer()
                    Image(systemName: viewModel.expandedCategories.contains(category) ? "chevron.down" : "chevron.right")
                        .foregroundStyle(Color("AppAccent"))
                }
            }
        }
        .buttonStyle(.plain)
        .travelListRow()
    }

    @ViewBuilder
    private func taskRow(_ task: TravelTask) -> some View {
        TravelCard {
            TaskListCell(task: task, isPulsing: viewModel.pulsingTaskID == task.id)
        }
        .travelListRow()
        .swipeActions(edge: .leading) {
            Button {
                store.toggleTaskCompletion(id: task.id)
                if !task.isCompleted {
                    FeedbackManager.mediumAction()
                    viewModel.triggerTaskAnimation(id: task.id)
                } else {
                    FeedbackManager.lightTap()
                }
            } label: {
                Label(task.isCompleted ? "Undo" : "Done", systemImage: "checkmark")
            }
            .tint(Color("AppPrimary"))
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                FeedbackManager.lightTap()
                store.deleteTravelTask(id: task.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
