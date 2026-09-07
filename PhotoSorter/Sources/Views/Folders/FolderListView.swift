import SwiftUI
import SwiftData

struct FolderListView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LocalFolder.createdAt, order: .reverse) private var folders: [LocalFolder]
    @State private var showNewFolder = false

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(folders) { folder in
                    NavigationLink {
                        FolderDetailView(folder: folder)
                    } label: {
                        FolderCell(folder: folder)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Delete Folder", role: .destructive) {
                            PhotoFileManager.deleteFolder(folder.id)
                            modelContext.delete(folder)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("My Folders")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showNewFolder = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
            }
        }
        .overlay {
            if folders.isEmpty {
                ContentUnavailableView("No folders yet", systemImage: "folder", description: Text("Tap + to create your first folder."))
            }
        }
        .sheet(isPresented: $showNewFolder) {
            NewFolderSheet { name in
                let folder = LocalFolder(name: name, ownerUserId: auth.currentUserId)
                modelContext.insert(folder)
            }
        }
    }
}

private struct FolderCell: View {
    let folder: LocalFolder

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "folder.fill")
                .font(.system(size: 44))
                .foregroundStyle(.tint)
            Text(folder.name)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
            Text("\(folder.photos.count) photo\(folder.photos.count == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}
