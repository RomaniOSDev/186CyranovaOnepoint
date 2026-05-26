import SwiftUI

struct TravelDocumentsView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var showAdd = false

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 12) {
                    if store.travelDocuments.isEmpty {
                        TravelCard {
                            TravelEmptyState(
                                icon: "doc.text.fill",
                                title: "No documents tracked",
                                message: "Add passport, visa, or insurance expiry dates to get reminders on Home.",
                                buttonTitle: "Add Document",
                                action: { showAdd = true }
                            )
                        }
                    } else {
                        ForEach(store.travelDocuments) { doc in
                            TravelCard(accent: doc.isExpiringSoon || doc.isExpired) {
                                DocumentListCell(document: doc)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    store.deleteDocument(id: doc.id)
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
        .navigationTitle("Travel Documents")
        .navigationBarTitleDisplayMode(.inline)
        .travelScreenStyle()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    FeedbackManager.lightTap()
                    dismiss()
                }
                .foregroundStyle(Color("AppTextSecondary"))
            }
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
        .sheet(isPresented: $showAdd) {
            DocumentFormView()
                .environmentObject(store)
        }
        .preferredColorScheme(.dark)
    }
}

struct DocumentFormView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var type: DocumentType = .passport
    @State private var expiryDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    TravelCard {
                        VStack(spacing: 16) {
                            Picker("Type", selection: $type) {
                                ForEach(DocumentType.allCases) { t in
                                    Text(t.rawValue).tag(t)
                                }
                            }
                            .pickerStyle(.segmented)
                            DatePicker("Expiry date", selection: $expiryDate, displayedComponents: .date)
                                .foregroundStyle(Color("AppTextPrimary"))
                            TextField("Notes", text: $notes)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("New Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { FeedbackManager.lightTap(); dismiss() }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let doc = TravelDocument(type: type, expiryDate: expiryDate, notes: notes)
                        store.addDocument(doc)
                        FeedbackManager.success()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
