import Foundation

enum PhotoFileManager {
    static var vaultRootURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let root = appSupport.appendingPathComponent("PhotoVault", isDirectory: true)
        createIfNeeded(root)
        return root
    }

    static func directory(for folderId: UUID) -> URL {
        let dir = vaultRootURL.appendingPathComponent(folderId.uuidString, isDirectory: true)
        createIfNeeded(dir)
        return dir
    }

    @discardableResult
    static func saveImage(_ data: Data, folderId: UUID) -> String {
        let fileName = "\(UUID().uuidString).jpg"
        let url = directory(for: folderId).appendingPathComponent(fileName)
        try? data.write(to: url, options: .completeFileProtectionUnlessOpen)
        return fileName
    }

    static func loadImageData(folderId: UUID, fileName: String) -> Data? {
        let url = directory(for: folderId).appendingPathComponent(fileName)
        return try? Data(contentsOf: url)
    }

    static func deleteImage(folderId: UUID, fileName: String) {
        let url = directory(for: folderId).appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
    }

    static func deleteFolder(folderId: UUID) {
        try? FileManager.default.removeItem(at: directory(for: folderId))
    }

    private static func createIfNeeded(_ url: URL) {
        guard !FileManager.default.fileExists(atPath: url.path) else { return }
        try? FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true,
            attributes: [.protectionKey: FileProtectionType.completeUnlessOpen]
        )
    }
}
