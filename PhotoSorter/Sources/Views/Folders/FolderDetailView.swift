import SwiftUI
import SwiftData
import UIKit

struct FolderDetailView: View {
    @Bindable var folder: LocalFolder
    @Environment(\.modelContext) private var modelContext
    @State private var showPicker = false

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(folder.photos.sorted(by: { $0.createdAt > $1.createdAt })) { photo in
                    PhotoThumbnail(folderId: folder.id, photo: photo) {
                        delete(photo)
                    }
                }
            }
            .padding(8)
        }
        .navigationTitle(folder.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showPicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .overlay {
            if folder.photos.isEmpty {
                ContentUnavailableView("No photos yet", systemImage: "photo.on.rectangle", description: Text("Tap + to add photos from your library."))
            }
        }
        .sheet(isPresented: $showPicker) {
            PhotoPicker { dataItems in
                for data in dataItems {
                    let fileName = PhotoFileManager.saveImage(data, folderId: folder.id)
                    let photo = LocalPhoto(fileName: fileName, folder: folder)
                    modelContext.insert(photo)
                }
            }
        }
    }

    private func delete(_ photo: LocalPhoto) {
        PhotoFileManager.deleteImage(folderId: folder.id, fileName: photo.fileName)
        modelContext.delete(photo)
    }
}

private struct PhotoThumbnail: View {
    let folderId: UUID
    let photo: LocalPhoto
    var onDelete: () -> Void
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(.gray.opacity(0.2))
            }
        }
        .frame(height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contextMenu {
            Button("Delete", role: .destructive, action: onDelete)
        }
        .task {
            if let data = PhotoFileManager.loadImageData(folderId: folderId, fileName: photo.fileName) {
                image = UIImage(data: data)
            }
        }
    }
}
