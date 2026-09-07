import SwiftUI

struct NewFolderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    var onCreate: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Folder name", text: $name)
            }
            .navigationTitle("New Folder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onCreate(trimmed)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.height(180)])
    }
}
